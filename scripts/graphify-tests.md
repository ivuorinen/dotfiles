# graphify-tests

Adds the bats suite to the graphify knowledge graph.

## Why not just teach graphify about .bats

Three attempts, all worse:

1. **Add `.bats` to `CODE_EXTENSIONS`.** Files are classified as code, but no
    extractor is registered for them, so they contribute **0 nodes**.

2. **Also map `.bats` to `extract_bash` in `_DISPATCH`.** Works on a single
    file. The suite has 87, which crosses `_PARALLEL_THRESHOLD = 20`; graphify
    then forks a process pool, and macOS `spawn` workers re-import graphify
    clean, losing the patch. Back to **0 nodes**, silently.

3. **Force it sequential.** Now it runs, and yields 3 nodes for a 17-test
    file — the file, an `_entry`, and `setup()` — with no edge to the code
    under test.

Even when the bash parser runs, it is the wrong tool: `@test "name" { }` is not
bash syntax so the cases are invisible, and a bats file names its target inside
a string — `"$BATS_TEST_DIRNAME/../local/bin/msgr"` — which no bash grammar
resolves into an edge.

A deterministic extractor is both less code and strictly better data.

## What it emits

- one node per `tests/*.bats` file
- one node per `@test` case, labelled with the case name and anchored to its line
- a `tests` edge from each file to the code it exercises
- a `contains` edge from each file to its cases

Targets resolve from path references inside the file
(`local/bin/…`, `scripts/…`, `config/…`, `.claude/hooks/…`) plus the
`tests/<name>.bats` ↔ `local/bin/<name>` convention that the
`bats-test-scaffold` skill establishes.

**Edges are only emitted to nodes that already exist in the graph.** A test
whose target cannot be resolved is reported, not linked — inventing the edge
would recreate the dangling-endpoint problem this script also cleans up.

Test nodes inherit the community of the code they cover, so `tests/msgr.bats`
lands in the `msgr` community rather than a synthetic "tests" island.

## Usage

```bash
scripts/graphify-tests.py --check   # report, write nothing
scripts/graphify-tests.py           # patch graphify-out/graph.json
graphify export html                # regenerate the viewer
```

Idempotent: nodes and links it owns are tagged `_origin: bats-tests`, and a
re-run drops the previous subgraph before adding the current one.

## Run it after every graph rebuild

`/graphify` and `graphify update .` both rewrite `graph.json` from their own
extractors and know nothing about this script, so the test subgraph is lost on
every rebuild. The full sequence is:

```bash
graphify update .            # or /graphify for a full rebuild
scripts/graphify-tests.py
graphify export html
```

## Known gaps

Five test files resolve to no node: they exercise things the graph names
differently (shell aliases, hook bundles) or that postdate the last build. They
are listed on every run rather than silently dropped.

## Tests

`tests/graphify-tests.bats`.
