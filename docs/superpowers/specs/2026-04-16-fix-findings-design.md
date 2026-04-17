# Design: Fix Adversarial Review Findings

Date: 2026-04-16
Source: docs/findings-todo.md

## Scope

Fix 7 provable bugs found in `local/bin` scripts. Add Bats tests for each affected file.
Two findings are out of scope by decision: `x-foreach` (keep eval, comment only) and
`x-compare-versions.py` (empty-stdin-exits-0 treated as correct behavior).

## Execution Order

Serial, one file at a time: read → fix → write test.

### 1. x-foreach — comment only

**Finding:** eval injection via first argument (CRITICAL, accepted risk).
**Fix:** Add `# shellcheck disable=SC2294` and an intent comment on the eval line documenting
the owner-trust assumption.
**Test:** `tests/x-foreach.bats` — basic invocation that the command runs in matched dirs.

---

### 2. pushover — uninitialized vars + late CURL check (HIGH)

**Finding A:** 9 optional variables (`callback`, `timestamp`, `priority`, `retry`, `expire`,
`title`, `sound`, `url`, `url_title`) used in curl call without prior initialization.
**Fix A:** Initialize all 9 to `""` at the top of `__pushover_send_message()`, before the
`getopts` loop.

**Finding B:** `CURL` availability check at line 142 runs after the function that uses `$CURL`
is already defined and callable.
**Fix B:** Move the `command -v curl` assignment and guard to the top of the script, before any
function definitions.

**Test:** `tests/pushover.bats` — stubs curl via PATH; tests: (a) call with no optional flags
succeeds without crashing, (b) missing curl exits with non-zero before trying to send.

---

### 3. x-backup-folder — no directory existence check (HIGH)

**Finding:** `backup_directory` is called without verifying `$directory` exists on disk. `tar`
fails with a cryptic error.
**Fix:** Add `[ -d "$directory" ] || { msgr err "Directory does not exist: $directory"; exit 1; }`
before the `backup_directory` call.
**Test:** `tests/x-backup-folder.bats` — (a) nonexistent path exits 1 with message on stderr,
(b) existing directory produces a .tar.gz output file.

---

### 4. x-change-alacritty-theme — no source file check (HIGH)

**Finding:** `cp -f "$theme_file" ...` runs without confirming source exists. Reports success on
failure.
**Fix:** Add `[ -f "$theme_file" ] || { msgr err "Theme file not found: $theme_file"; return 1; }`
before the `cp`.
**Test:** `tests/x-change-alacritty-theme.bats` — (a) missing theme file exits 1, (b) valid theme
file copies to destination.

---

### 5. x-backup-mysql-with-prefix — table names as single string (HIGH)

**Finding:** `mysqldump "${database}" "$(mysql_output)"` quotes the subshell output, passing all
table names as one argument.
**Fix:** Remove the surrounding quotes: `mysqldump "${database}" $(mysql_output)`.
**Test:** `tests/x-backup-mysql-with-prefix.bats` — stubs `mysqldump` and `mysql` via PATH;
verifies the stub receives table names as separate arguments (check `$@` in stub).

---

### 6. x-set-php-aliases — pipefail exits on grep (HIGH)

**Finding:** `brew list | grep '^php'` exits 1 when no PHP formula is installed. With
`set -euo pipefail`, the script terminates before configuring any aliases.
**Fix:** Append `|| true` to the pipeline: `brew list | grep '^php' > "$BREW_LIST_CACHE" || true`.
**Test:** `tests/x-set-php-aliases.bats` — stubs `brew` to return no output; verifies script
exits 0 (does not crash on PHP-less system).

---

### 7. x-env-list — config file double-parsed (MEDIUM)

**Finding:** Grouping config is first parsed as YAML via `yq`, then parsed again as plain
`key:value` pairs at lines ~132–136. The second pass misreads YAML colons.
**Fix:** Remove the second key:value parsing block (the `for` loop that re-parses the config
after `yq` has already processed it).
**Test:** `tests/x-env-list.bats` — (a) runs without a grouping config file (no crash), (b) runs
with a valid YAML grouping config and produces grouped output.

---

### 8. x-quota-usage.php — division by zero (MEDIUM)

**Finding:** `$result['used'] / $result['quota'] * 100` triggers PHP warning and yields INF/NAN
when quota field is 0.
**Fix:** Add `if ((int)$result['quota'] <= 0) continue;` before the division.
**Test:** `tests/x-quota-usage.bats` — stubs `quota` binary via PATH to return a line with
quota=0; verifies script exits 0 and produces no PHP warnings in output.

---

## Test Conventions

- All tests in `tests/` as `.bats` files
- External dependencies (curl, mysqldump, mysql, brew, quota, alacritty) stubbed via
  `export PATH="$BATS_TEST_TMPDIR:$PATH"` with minimal fake binaries
- Each test file covers: happy path + the specific bug trigger addressed by the fix
- Run with: `./node_modules/.bin/bats tests/<file>.bats`

## Out of Scope

- `x-compare-versions.py`: empty-stdin-exits-0 is accepted behavior
- `x-foreach` functional behavior: eval kept, owner-trust documented
- No changes to linting config, no refactoring beyond the fixes listed
