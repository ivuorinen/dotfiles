---
description: "The bats suite must be run and must pass before any commit that touches covered code."
---

# Run the tests before committing

Run `bats tests/` and get a passing result before committing any change
under `tests/`, `local/bin/`, `scripts/`, `base/`, or the shell entry points
in `config/` (`theme/`, `shared.sh`, `lib.sh`, `exports`, `alias`). A red
suite blocks the commit. Fix the code or fix the test — never commit with a
failure outstanding.

## Read the result correctly

Never judge the suite from truncated output. `bats tests/ | tail -2` prints
the last two tests and hides every failure above them, which is how a
`not ok` reached `main` in commit 28b5336.

Use one of these instead:

```bash
bats tests/; echo "exit=$?"          # 0 means green
bats tests/ 2>&1 | grep '^not ok'    # empty means green
```

The exit code is the authority. `ok 222 ...` as the final line proves
nothing about tests 1 through 221.

## Deleting something means grepping for it first

Removing a subcommand, script, menu entry, or config key requires a
repo-wide search **before** the deletion, including `tests/` and generated
artifacts:

```bash
git grep -n '<name>'
```

`.claude/skills/graphify` does not cover this: the knowledge graph contains
no nodes from `tests/`, so a graphify query returns nothing for a
test-to-code dependency. Use `git grep`.

The same applies to generated files — completions, man pages, `local/md/`
and `docs/` are rebuilt by `scripts/install-completions.sh`, and a stale
reference there survives until that runs.

## Enforcement

`.pre-commit-config.yaml` runs the suite on every commit that stages a file
under the covered paths. A docs-only commit skips it, because nothing the
suite asserts can change. Bypassing that hook is forbidden — see
`.claude/rules/no-hook-bypass.md`.

The suite takes about 30 seconds. That is the price of the gate, and it is
paid on commit rather than in CI.
