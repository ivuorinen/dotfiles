---
description: "Search the whole repo for a name before deleting the thing it names."
---

# Deleting something means grepping for it first

Removing a subcommand, script, menu entry, or config key requires a
repo-wide search **before** the deletion, including `tests/` and generated
artifacts:

```bash
git grep -n '<name>'
```

The knowledge graph carries the suite: `scripts/graphify-tests.py` adds a
node per `tests/*.bats` file, a node per `@test` case, and a `tests` edge to
the code each file exercises. So

```bash
graphify explain '<script>.bats'     # which cases a test file holds
graphify path '<script>' '<script>.bats'
```

answers the test-to-code direction. Both commands print output, so run them
through `ctx_execute` (`.claude/rules/graphify-first.md`). Two limits keep
`git grep` the authority for deletions:

1. Edges come from path references and the `tests/<name>.bats` ↔
    `local/bin/<name>` convention. Five test files resolve to no node at all,
    and a test that reaches its target some other way has no edge.
2. The graph is a snapshot. Anything added since the last build is missing.

So query the graph to understand coverage, and still run `git grep -n '<name>'`
before deleting — it is the only check that sees uncommitted and
just-renamed code.

The same applies to generated files — completions, man pages, `local/md/`
and `docs/` are rebuilt by `scripts/install-completions.sh`, and a stale
reference there survives until that runs.
