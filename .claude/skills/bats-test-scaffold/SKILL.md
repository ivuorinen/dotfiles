---
name: bats-test-scaffold
description: >-
  Scaffold a bats test file in tests/<script>.bats matching a script
  in local/bin/<script>. Use when adding tests for an existing
  script that lacks coverage.
user-invocable: true
allowed-tools: Bash, Read, Write, Edit
---

Scaffolds `tests/<script>.bats` for a script under `local/bin/<script>`.
The convention in this repo (per `docs/audit/arch-profile.md` rule 6
and `docs/audit/arch-findings.md`) is one bats file per script,
named after the script.

## Inputs

- `<script>` — basename of the file under `local/bin/` (no extension
  if the script has none; include extension if it does, e.g.
  `x-compare-versions.py`)

## Process

1. Verify the script exists at `local/bin/<script>`. Read its first
    30 lines to extract:
    - shebang (`/usr/bin/env bash` vs `/bin/sh` vs `python3` etc.)
    - `# @description` tag if present (`dfm scripts` uses it)
    - first `usage()` / `--help` block, to seed `@test` cases

2. Reject if `tests/<script>.bats` already exists. Suggest editing
    the existing file instead.

3. Write the new file with this template (bash example — adapt
    the `bash …` line for python/sh as needed):

```bash
#!/usr/bin/env bats
# Tests for local/bin/<script>.

setup()
{
  export DOTFILES="$PWD"
  TMPDIR_TEST=$(mktemp -d)
  export TMPDIR_TEST
}

teardown()
{
  rm -rf "$TMPDIR_TEST"
}

@test "<script>: prints usage on --help" {
  run bash local/bin/<script> --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage"* || "$output" == *"usage"* ]]
}

@test "<script>: exits non-zero on missing required argument" {
  run bash local/bin/<script>
  [ "$status" -ne 0 ]
}
```

For `/bin/sh` POSIX scripts, replace `bash local/bin/...` with
`sh local/bin/...`. For Python scripts, use `python3 local/bin/...`.

4. Print the path of the new file and run `bats tests/<script>.bats`
    once to confirm the scaffold runs cleanly (the placeholder
    assertions may fail — that's fine, they prompt the user to
    adapt).

## Conventions enforced

- Use bare `bats` from PATH (mise) — never `./node_modules/.bin/bats`.
  This matches the repo's standard test invocation.
- `setup()`/`teardown()` always present, with `TMPDIR_TEST` named
  to avoid clobbering the standard `TMPDIR` env var (per the fix
  in finding N-029).
- At minimum: one `--help` test and one missing-arg test. Real
  behaviour assertions go in subsequent `@test` blocks added by
  the user.

## Verification

After scaffolding, the user should:

1. Replace the placeholder `@test` blocks with real behaviour
    assertions.
2. Run `yarn test` to confirm the new file is discovered and runs.
3. Commit the scaffold + behaviour tests together.
