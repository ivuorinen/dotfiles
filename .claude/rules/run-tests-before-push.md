---
description: "The bats suite must pass before pushing any commit that touches covered code."
paths:
  - "tests/**"
  - "local/bin/**"
  - "scripts/**"
  - "base/**"
  - "config/theme/**"
  - "config/shared.sh"
  - "config/lib.sh"
  - "config/exports"
  - "config/alias"
  - ".claude/hooks/**"
  - ".claude/rules/vendored-files.md"
---

# Run the tests before pushing

The full suite must pass before a push that carries a change under `tests/`,
`local/bin/`, `scripts/`, `base/`, or the shell entry points in `config/`
(`theme/`, `shared.sh`, `lib.sh`, `exports`, `alias`). A red suite blocks the
push. Fix the code or fix the test — never push with a failure outstanding.

While working, run the test files for what you changed
(`bats tests/<name>.bats`) before each commit. They take seconds. The full
suite catches pairings no file name shows, such as `local/bin/dfm-install`
breaking `tests/dfm.bats`.

## Read the result correctly

Never judge the suite from truncated output. `bats tests/ | tail -2` prints
the last two tests and hides every failure above them, which is how a
`not ok` reached `main` in commit 28b5336.

Use one of these instead:

```bash
scripts/bats-run.sh; echo "exit=$?"  # 0 means green; ends with a failure list
bats tests/; echo "exit=$?"          # 0 means green
bats tests/ 2>&1 | grep '^not ok'    # empty means green
```

The exit code is the authority. `ok 222 ...` as the final line proves
nothing about tests 1 through 221. `scripts/bats-run.sh` (what the hook
and CI run) closes with a block naming every failing test as `file:line`
with its failed assertion; its absence on a non-zero exit means bats
aborted before running tests.

## Loading

This rule is path-scoped to the same paths the bats hook covers, so it loads
when you touch code the suite guards rather than in every session. The hook
below is the mechanical gate: if the rule never loads, a push touching those
paths still runs the suite and still fails on red.

## Enforcement

`.pre-commit-config.yaml` runs the suite at the `pre-push` stage when the
pushed commits change a file under the covered paths. A docs-only push skips
it, because nothing the suite asserts can change. CI
(`.github/workflows/tests.yml`) runs it again on every PR to `main`.
Bypassing the hook is forbidden — see `.claude/rules/no-hook-bypass.md`.

The suite takes about five minutes (1280 tests). It runs per push rather than
per commit so that splitting work into small commits stays cheap. The
pre-push hook exists only after `prek install` has run in the clone.
