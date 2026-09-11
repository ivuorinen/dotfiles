#!/usr/bin/env python3
"""Detect drift between the repo's third-party exclusion lists.

Five gates each carry their own copy of "which trees are third-party and must
not be analysed". `.codacy.yml` states the requirement in prose -- "Keep the
four in step when one moves" -- but nothing enforced it, so a tree added to one
gate could silently stay missing from the rest.

The gates do not have identical scope: ruff and bandit only ever see Python,
grype only scans dependency manifests, so demanding that every gate list every
tree would report dozens of differences that are all correct. Instead this
checks the *coverage matrix* -- which gates cover which tree -- against a
reviewed baseline, and fails when that matrix changes. Adding a tree to one
gate and not the others changes the matrix, which is exactly the drift the
prose asks for. A deliberate change is recorded with --update.

Usage:
    scripts/check-exclusion-drift.py            # check, exit 1 on drift
    scripts/check-exclusion-drift.py --update   # re-baseline after a reviewed change

Wired into `yarn lint` as `lint:exclusions`.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import tomllib
from pathlib import Path

# EXCLUSION_CHECK_ROOT lets tests point the checker at a fixture repo. Without
# it a gate that can never be made to fail is untestable, and an exclusion
# check that cannot fail is worse than none -- it reports green forever.
REPO = Path(os.environ.get("EXCLUSION_CHECK_ROOT") or Path(__file__).resolve().parent.parent)
BASELINE = REPO / ".exclusion-baseline.json"


def normalise(raw: str) -> str:
    """Reduce one exclusion entry to a bare repo-relative tree path.

    The gates spell the same tree five ways -- "./tools/**", "tools",
    "./tools", "tools/" -- so they are only comparable once the leading "./"
    and any trailing glob are stripped.
    """
    entry = raw.strip().strip("\"'")
    entry = re.sub(r"^\./", "", entry)
    entry = re.sub(r"/\*{1,2}$", "", entry)
    return entry.rstrip("/")


def _yaml_list(path: Path, key: str) -> set[str]:
    """Collect `- item` entries under a top-level YAML key.

    Deliberately regex-based rather than PyYAML: these two files are flat lists
    of strings, and a stdlib-only checker is one less thing to install in CI.
    """
    if not path.exists():
        return set()
    out: set[str] = set()
    in_block = False
    for line in path.read_text(encoding="utf-8").splitlines():
        if re.match(rf"^{re.escape(key)}\s*:", line):
            in_block = True
            continue
        if in_block:
            item = re.match(r"^\s*-\s*(.+?)\s*$", line)
            if item:
                out.add(normalise(item.group(1)))
                continue
            # A non-comment, non-blank line that is not a list item ends the block.
            if line.strip() and not line.lstrip().startswith("#"):
                break
    return out


def from_grype() -> set[str]:
    return _yaml_list(REPO / ".grype.yaml", "exclude")


def from_codacy() -> set[str]:
    return _yaml_list(REPO / ".codacy.yml", "exclude_paths")


def _pyproject() -> dict:
    path = REPO / "pyproject.toml"
    if not path.exists():
        return {}
    with path.open("rb") as fh:
        return tomllib.load(fh)


def from_ruff() -> set[str]:
    tool = _pyproject().get("tool", {}).get("ruff", {})
    return {normalise(e) for e in tool.get("extend-exclude", [])}


def from_bandit() -> set[str]:
    tool = _pyproject().get("tool", {}).get("bandit", {})
    return {normalise(e) for e in tool.get("exclude_dirs", [])}


def from_megalinter() -> set[str]:
    """Pull the alternation out of FILTER_REGEX_EXCLUDE.

    The value is a regex, not a list: `(node_modules|tools|config/fzf)`. Only
    the alternation branches are exclusion entries.
    """
    path = REPO / ".mega-linter.yml"
    if not path.exists():
        return set()
    text = path.read_text(encoding="utf-8")
    block = re.search(r"^FILTER_REGEX_EXCLUDE\s*:\s*>?\s*\n((?:\s+.*\n)+)", text, re.MULTILINE)
    if not block:
        return set()
    joined = " ".join(block.group(1).split())
    inner = re.search(r"\(([^)]*)\)", joined)
    if not inner:
        return set()
    return {normalise(part) for part in inner.group(1).split("|") if part.strip()}


GATES = {
    "grype": from_grype,
    "codacy": from_codacy,
    "ruff": from_ruff,
    "bandit": from_bandit,
    "megalinter": from_megalinter,
}


def coverage() -> dict[str, list[str]]:
    """Build {tree: [gates that exclude it]} across every gate."""
    per_gate = {name: fn() for name, fn in GATES.items()}
    matrix: dict[str, list[str]] = {}
    for tree in sorted({t for trees in per_gate.values() for t in trees}):
        matrix[tree] = sorted(name for name, trees in per_gate.items() if tree in trees)
    return matrix


def report_drift(current: dict[str, list[str]], baseline: dict[str, list[str]]) -> int:
    added = sorted(set(current) - set(baseline))
    removed = sorted(set(baseline) - set(current))
    changed = sorted(t for t in set(current) & set(baseline) if current[t] != baseline[t])

    if not (added or removed or changed):
        print(f"exclusion drift: OK ({len(current)} trees across {len(GATES)} gates)")
        return 0

    print("exclusion drift detected -- the gates no longer agree with the reviewed baseline.\n")
    for tree in added:
        print(f"  NEW      {tree}")
        print(f"           covered by: {', '.join(current[tree])}")
        missing = sorted(set(GATES) - set(current[tree]))
        if missing:
            print(f"           absent from: {', '.join(missing)}")
    for tree in removed:
        print(f"  DROPPED  {tree}  (was covered by: {', '.join(baseline[tree])})")
    for tree in changed:
        gained = sorted(set(current[tree]) - set(baseline[tree]))
        lost = sorted(set(baseline[tree]) - set(current[tree]))
        print(f"  CHANGED  {tree}")
        if gained:
            print(f"           now also in: {', '.join(gained)}")
        if lost:
            print(f"           no longer in: {', '.join(lost)}")

    print(
        "\nAdd the tree to the other gates (.grype.yaml, .codacy.yml, pyproject.toml "
        "[tool.ruff]/[tool.bandit], .mega-linter.yml) and to .claude/rules/vendored-files.md,\n"
        "or record the difference as intentional with:  scripts/check-exclusion-drift.py --update"
    )
    return 1


def main() -> int:
    parser = argparse.ArgumentParser(description="Detect drift between the repo's third-party exclusion lists.")
    parser.add_argument("--update", action="store_true", help="rewrite the baseline from the current files")
    args = parser.parse_args()

    current = coverage()

    if args.update:
        BASELINE.write_text(json.dumps(current, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
        print(f"baseline written: {BASELINE.relative_to(REPO)} ({len(current)} trees)")
        return 0

    if not BASELINE.exists():
        print(f"no baseline at {BASELINE.relative_to(REPO)} -- create one with --update", file=sys.stderr)
        return 1

    baseline = json.loads(BASELINE.read_text(encoding="utf-8"))
    return report_drift(current, baseline)


if __name__ == "__main__":
    sys.exit(main())
