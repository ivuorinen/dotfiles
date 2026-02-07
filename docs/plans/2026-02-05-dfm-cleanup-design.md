# dfm Cleanup Design

## Summary

Clean up `local/bin/dfm` to fix bugs, remove dead code, improve
cross-platform portability, and make error handling consistent.

## Changes

### 1. Bash Version Bootstrap

Add a check at the top of the script (after variable declarations)
that requires bash 4.0+. On macOS, if bash is too old, install
Homebrew (if missing) and bash, then print instructions and exit.
The check itself uses only bash 3.2-compatible syntax.

### 2. Remove Fish Dead Code

Remove `CURRENT_SHELL` detection, `source_file()` function, and all
fish branches. Replace `source_file` calls with direct `source`.
The script has a bash shebang — fish handling was unreachable.

### 3. Bug Fixes

- Remove `ntfy` from install menu (no install script exists)
- Fix `msg)` → `msgr)` case label in `section_tests`
- Guard all `shift` calls against empty argument lists
- Quote `$width` in `menu_builder` seq calls
- Fix `$"..."` locale string → `"..."` in `usage()`
- Fix `exit 0` on apt.txt error → `return 1`

### 4. Replace `declare -A` in `section_scripts`

Replace associative array with indexed `"name:desc"` array,
matching the pattern used everywhere else in the script.
Move `get_script_description()` to top-level (out of the function).

### 5. Early-Return Guards & exit → return

- `section_brew()`: Early return with `msgr warn` if brew unavailable.
  Remove duplicate `! x-have brew` check.
- `section_apt()`: Same pattern for apt.
- `section_check()`: Replace `exit` with `return`.
- `section_apt() install`: Replace `exit` with `return`.
- `section_brew() untracked`: Replace `exit` with `return`.

## Files Changed

- `local/bin/dfm` (all changes)

## Verification

- `yarn test` (existing bats test)
- `shellcheck local/bin/dfm`
- `bash -n local/bin/dfm` (syntax check)
