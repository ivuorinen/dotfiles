#!/usr/bin/env python3
"""Add the bats test suite to the graphify knowledge graph.

graphify does not know what a .bats file is. Registering the extension against
its bash extractor does not help either: tree-sitter-bash sees no `@test`
blocks (they are not bash syntax) and cannot resolve the thing under test,
because a bats file names it inside a string --
`"$BATS_TEST_DIRNAME/../local/bin/msgr"`. A whole 17-test file yields three
nodes that way, none of them an edge to the code it covers.

So the test suite was invisible to the graph, which
`.claude/rules/run-tests-before-commit.md` documented as a carve-out: "the
knowledge graph contains no nodes from tests/, so a graphify query returns
nothing for a test-to-code dependency."

This closes that gap with a deterministic extractor -- no LLM, no parser --
emitting one node per test file, one per `@test` case, and an edge from each
file to the code it exercises. It patches graphify-out/graph.json in place and
is idempotent: a re-run replaces the previous test subgraph rather than
duplicating it.

Usage:
    scripts/graphify-tests.py            # patch graph.json, then: graphify export html
    scripts/graphify-tests.py --check    # report what would change, write nothing
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
GRAPH = REPO / "graphify-out" / "graph.json"
TESTS = REPO / "tests"

# Nodes this script owns. Tagged so a re-run can drop the previous subgraph
# without touching anything the real extractors produced.
ORIGIN = "bats-tests"

# Paths a test file may reference. Anchored to the trees this repo actually
# tests, so a stray word in a comment cannot masquerade as a target.
TARGET_RE = re.compile(r"(?:\.\./)?((?:local/bin|scripts|config|\.claude/hooks)/[A-Za-z0-9._/-]+)")
TEST_RE = re.compile(r'^\s*@test\s+([\'"])(.+?)\1\s*\{', re.MULTILINE)


def node_id(rel_path: str) -> str:
    """Mirror graphify's AST id convention: full relative path, extension dropped.

    local/bin/msgr -> local_bin_msgr ; .claude/hooks/x.sh -> claude_hooks_x
    Diverging from this silently orphans every edge, so it is the one rule here
    that must not drift.
    """
    stem = re.sub(r"\.(sh|bash|bats|py|fish|lua|zsh)$", "", rel_path)
    return re.sub(r"[^a-z0-9]+", "_", stem.lower()).strip("_")


def slug(text: str, limit: int = 48) -> str:
    return re.sub(r"[^a-z0-9]+", "_", text.lower()).strip("_")[:limit]


def collect(existing_ids: set[str]) -> tuple[list[dict], list[dict], list[str]]:
    """Build the test subgraph, emitting edges only to nodes that already exist."""
    nodes: list[dict] = []
    edges: list[dict] = []
    unresolved: list[str] = []

    for path in sorted(TESTS.glob("*.bats")):
        rel = f"tests/{path.name}"
        text = path.read_text(encoding="utf-8")
        file_id = node_id(rel)

        nodes.append(
            {
                "id": file_id,
                "label": path.name,
                "file_type": "code",
                "source_file": rel,
                "source_location": "L1",
                "metadata": {},
                "_origin": ORIGIN,
                "norm_label": path.stem.lower(),
            }
        )

        # One node per @test case: the case names are the suite's real
        # documentation ("msgr ok: prints the message with the success marker")
        # and are what a human actually searches for.
        for match in TEST_RE.finditer(text):
            name = match.group(2)
            line = text[: match.start()].count("\n") + 1
            case_id = f"{file_id}_{slug(name)}"
            nodes.append(
                {
                    "id": case_id,
                    "label": name,
                    "file_type": "code",
                    "source_file": rel,
                    "source_location": f"L{line}",
                    "metadata": {},
                    "_origin": ORIGIN,
                    "norm_label": name.lower(),
                }
            )
            edges.append(_edge(file_id, case_id, "contains", rel, f"L{line}"))

        # Targets referenced by path inside the file, plus the
        # tests/<name>.bats <-> local/bin/<name> naming convention that the
        # bats-test-scaffold skill establishes.
        targets = {node_id(m.group(1)) for m in TARGET_RE.finditer(text)}
        targets.add(node_id(f"local/bin/{path.stem}"))

        matched = False
        for target in sorted(targets):
            if target == file_id:
                continue
            if target in existing_ids:
                edges.append(_edge(file_id, target, "tests", rel, "L1"))
                matched = True
        if not matched:
            unresolved.append(rel)

    return nodes, edges, unresolved


def _edge(source: str, target: str, relation: str, source_file: str, loc: str) -> dict:
    return {
        "source": source,
        "target": target,
        "relation": relation,
        "confidence": "EXTRACTED",
        "confidence_score": 1.0,
        "source_file": source_file,
        "source_location": loc,
        "weight": 1.0,
        "_origin": ORIGIN,
    }


def prune_dangling(graph: dict) -> int:
    """Drop links whose endpoints do not exist.

    The full build left 93 of these: semantic subagents invented ids that never
    matched what the AST produced. They are invisible in the HTML view but
    inflate the edge count and make the health diagnostic report corruption.
    """
    ids = {n["id"] for n in graph["nodes"]}
    before = len(graph["links"])
    graph["links"] = [e for e in graph["links"] if e["source"] in ids and e["target"] in ids]
    return before - len(graph["links"])


def main() -> int:
    parser = argparse.ArgumentParser(description="Add the bats test suite to the graphify graph.")
    parser.add_argument("--check", action="store_true", help="report changes without writing")
    args = parser.parse_args()

    if not GRAPH.exists():
        print(f"no graph at {GRAPH.relative_to(REPO)} -- build it with /graphify first", file=sys.stderr)
        return 1

    graph = json.loads(GRAPH.read_text(encoding="utf-8"))

    # Idempotence: drop whatever a previous run of this script added.
    graph["nodes"] = [n for n in graph["nodes"] if n.get("_origin") != ORIGIN]
    graph["links"] = [e for e in graph["links"] if e.get("_origin") != ORIGIN]

    existing = {n["id"] for n in graph["nodes"]}
    nodes, edges, unresolved = collect(existing)

    # A test belongs with the code it covers, so inherit that community rather
    # than re-clustering 1482 nodes to rediscover the same grouping.
    community_of = {n["id"]: n.get("community") for n in graph["nodes"]}
    for node in nodes:
        covered = [e["target"] for e in edges if e["source"] == node["id"] and e["relation"] == "tests"]
        parent = next((community_of[t] for t in covered if community_of.get(t) is not None), None)
        node["community"] = parent

    # Test cases inherit their file's community.
    by_id = {n["id"]: n for n in nodes}
    for edge in edges:
        if edge["relation"] == "contains":
            by_id[edge["target"]]["community"] = by_id[edge["source"]].get("community")

    pruned = prune_dangling(graph)
    cases = sum(1 for n in nodes if "_" in n["id"] and n["label"] != Path(n["source_file"]).name)
    files = len(nodes) - cases
    test_edges = sum(1 for e in edges if e["relation"] == "tests")

    print(f"test files:    {files}")
    print(f"test cases:    {cases}")
    print(f"tests edges:   {test_edges}")
    print(f"pruned links:  {pruned} (dangling endpoints)")
    if unresolved:
        print(f"unresolved:    {len(unresolved)} test file(s) matched no node in the graph")
        for rel in unresolved[:10]:
            print(f"                 {rel}")

    if args.check:
        print("\n--check: nothing written")
        return 0

    graph["nodes"].extend(nodes)
    graph["links"].extend(edges)
    GRAPH.write_text(json.dumps(graph, ensure_ascii=False), encoding="utf-8")
    print(f"\ngraph.json updated: {len(graph['nodes'])} nodes, {len(graph['links'])} links")
    print("regenerate the viewer with: graphify export html")
    return 0


if __name__ == "__main__":
    sys.exit(main())
