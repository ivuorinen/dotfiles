# Fix Adversarial Review Findings — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix 7 provable bugs in local/bin scripts and add Bats tests for each, serial order.

**Architecture:** Each task is self-contained: write failing test → run to confirm failure → apply minimal fix → run to confirm pass → commit. No subagents. External dependencies (curl, mysql, mysqldump, brew, quota) are stubbed via PATH prepend.

**Tech Stack:** Bash, POSIX sh, PHP, Bats (test framework at `./node_modules/.bin/bats`)

---

## File Map

| Task | Fix file                               | Test file                                     |
|------|----------------------------------------|-----------------------------------------------|
| 1    | `local/bin/x-foreach` (comment only)   | `tests/x-foreach.bats` (new)                  |
| 2    | `local/bin/pushover`                   | `tests/pushover.bats` (new)                   |
| 3    | `local/bin/x-backup-folder`            | `tests/x-backup-folder.bats` (new)            |
| 4    | `local/bin/x-change-alacritty-theme`   | `tests/x-change-alacritty-theme.bats` (new)   |
| 5    | `local/bin/x-backup-mysql-with-prefix` | `tests/x-backup-mysql-with-prefix.bats` (new) |
| 6    | `local/bin/x-set-php-aliases`          | `tests/x-set-php-aliases.bats` (new)          |
| 7    | `local/bin/x-env-list`                 | `tests/x-env-list.bats` (new)                 |
| 8    | `local/bin/x-quota-usage.php`          | `tests/x-quota-usage.bats` (new)              |

---

## Task 1: x-foreach — document eval trust assumption

**Files:**
- Modify: `local/bin/x-foreach:20`
- Create: `tests/x-foreach.bats`

- [ ] **Step 1: Write the test**

```bash
cat > tests/x-foreach.bats << 'EOF'
#!/usr/bin/env bats

@test "x-foreach: exits 1 with usage when fewer than 2 args given" {
  run bash local/bin/x-foreach
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "x-foreach: runs command in each matched directory" {
  local tmpdir
  tmpdir=$(mktemp -d)
  mkdir -p "$tmpdir/alpha" "$tmpdir/beta"
  run bash local/bin/x-foreach "ls -d $tmpdir/*/" echo ok
  [ "$status" -eq 0 ]
  [[ "$output" == *"ok"* ]]
  rm -rf "$tmpdir"
}
EOF
```

- [ ] **Step 2: Run tests to verify they pass (no functional change needed)**

```
./node_modules/.bin/bats tests/x-foreach.bats
```

Expected: both tests PASS (the script already works; this is a baseline).

- [ ] **Step 3: Add intent comment to the eval line**

In `local/bin/x-foreach`, change line 20 from:

```bash
for dir in $(eval "$listing"); do
```

to:

```bash
# shellcheck disable=SC2294  # eval is intentional: listing is a trusted owner-supplied command string
for dir in $(eval "$listing"); do
```

- [ ] **Step 4: Re-run tests to confirm no regression**

```
./node_modules/.bin/bats tests/x-foreach.bats
```

Expected: both tests PASS.

- [ ] **Step 5: Commit**

```bash
git add local/bin/x-foreach tests/x-foreach.bats
git commit -m "test(x-foreach): add bats tests; document eval trust assumption"
```

---

## Task 2: pushover — initialize optional variables

**Files:**
- Modify: `local/bin/pushover` (before line 88, add 9 initializations)
- Create: `tests/pushover.bats`

**Context:** `callback`, `timestamp`, `priority`, `retry`, `expire`, `title`, `sound`, `url`,
`url_title` are used inside `__pushover_send_message()` (lines 49-57) but only assigned when
their getopts flags are passed. If sourced from a `set -u` shell without those flags, the script
crashes on undefined variable.

- [ ] **Step 1: Write the failing test**

```bash
cat > tests/pushover.bats << 'EOF'
#!/usr/bin/env bats

setup() {
  STUB_DIR="$(mktemp -d)"
  # curl stub: returns Pushover success JSON
  cat > "$STUB_DIR/curl" << 'STUB'
#!/usr/bin/env sh
echo '{"status":1,"request":"stub-id"}'
STUB
  chmod +x "$STUB_DIR/curl"
  export PATH="$STUB_DIR:$PATH"
  export PUSHOVER_TOKEN="fake-token"
  export PUSHOVER_USER="fake-user"
  export STUB_DIR
}

teardown() {
  rm -rf "$STUB_DIR"
}

@test "pushover: exits 1 when curl is not available" {
  local no_curl
  no_curl="$(mktemp -d)"
  # Do NOT copy curl stub into no_curl — it stays empty
  run env PATH="$no_curl" sh local/bin/pushover "test message"
  [ "$status" -eq 1 ]
  [[ "$output" == *"curl"* ]] || [[ "$stderr" == *"curl"* ]]
  rm -rf "$no_curl"
}

@test "pushover: exits 0 with message only and no optional flags" {
  run sh local/bin/pushover "hello world"
  [ "$status" -eq 0 ]
}

@test "pushover: exits 0 with title flag" {
  run sh local/bin/pushover -t "My Title" "hello"
  [ "$status" -eq 0 ]
}
EOF
```

- [ ] **Step 2: Run tests to see current state**

```
./node_modules/.bin/bats tests/pushover.bats
```

Expected: `exits 0 with message only` and `exits 0 with title flag` may already pass (sh
doesn't error on unset vars by default). This establishes the baseline. If they pass, they
still serve as regression tests for the fix.

- [ ] **Step 3: Add variable initializations to pushover**

In `local/bin/pushover`, add these 9 lines immediately before `OPTIND=1` (currently line 88):

```sh
callback=""
timestamp=""
priority=""
retry=""
expire=""
title=""
sound=""
url=""
url_title=""
```

The section around line 84 should look like this after the edit:

```sh
CURL_OPTS=""
devices=""
optstring="c:d:D:e:p:r:t:T:s:u:U:a:h"

callback=""
timestamp=""
priority=""
retry=""
expire=""
title=""
sound=""
url=""
url_title=""

OPTIND=1
while getopts ${optstring} c; do
```

- [ ] **Step 4: Run tests to confirm they pass**

```
./node_modules/.bin/bats tests/pushover.bats
```

Expected: all 3 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add local/bin/pushover tests/pushover.bats
git commit -m "fix(pushover): initialize optional vars before getopts; add bats tests"
```

---

## Task 3: x-backup-folder — guard against nonexistent directory

**Files:**
- Modify: `local/bin/x-backup-folder:79-83`
- Create: `tests/x-backup-folder.bats`

**Context:** `main()` checks for empty `$directory` but never checks whether the path exists.
`tar` then fails with a cryptic error. Fix: add `[ -d "$directory" ]` check before calling
`backup_directory`.

- [ ] **Step 1: Write the failing test**

```bash
cat > tests/x-backup-folder.bats << 'EOF'
#!/usr/bin/env bats

setup() {
  WORK_DIR="$(mktemp -d)"
  SCRIPT="$(pwd)/local/bin/x-backup-folder"
  cd "$WORK_DIR"
}

teardown() {
  cd - > /dev/null
  rm -rf "$WORK_DIR"
}

@test "x-backup-folder: exits 1 with clear message for nonexistent directory" {
  run bash "$SCRIPT" "/tmp/does-not-exist-$$"
  [ "$status" -eq 1 ]
  [[ "$output" == *"does not exist"* ]]
}

@test "x-backup-folder: creates tar.gz for existing directory" {
  mkdir -p "$WORK_DIR/src"
  echo "hello" > "$WORK_DIR/src/file.txt"
  run bash "$SCRIPT" "$WORK_DIR/src"
  [ "$status" -eq 0 ]
  ls ./*.tar.gz 2>/dev/null | grep -q '.'
}

@test "x-backup-folder: exits 1 when no arguments given" {
  run bash "$SCRIPT"
  [ "$status" -eq 1 ]
}
EOF
```

- [ ] **Step 2: Run tests to confirm first test currently fails (tar error, not our message)**

```
./node_modules/.bin/bats tests/x-backup-folder.bats
```

Expected: `exits 1 with clear message` FAILS (tar error, not "does not exist"). Other tests
may PASS or FAIL depending on environment.

- [ ] **Step 3: Add directory existence guard to x-backup-folder**

In `local/bin/x-backup-folder`, in the `main()` function, add between the empty-check block
and the `backup_directory` call. The section (currently lines 79-83) should become:

```bash
  if [ -z "$directory" ]; then
    msg_err "DIRECTORY (first argument) is missing"
  fi

  if [ ! -d "$directory" ]; then
    msg_err "Directory does not exist: $directory"
  fi

  backup_directory "$directory" "$filename"
```

- [ ] **Step 4: Run tests to confirm all pass**

```
./node_modules/.bin/bats tests/x-backup-folder.bats
```

Expected: all 3 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add local/bin/x-backup-folder tests/x-backup-folder.bats
git commit -m "fix(x-backup-folder): guard against nonexistent directory; add bats tests"
```

---

## Task 4: x-change-alacritty-theme — guard against missing theme file

**Files:**
- Modify: `local/bin/x-change-alacritty-theme:34-36` (inside `set_alacritty_theme`)
- Create: `tests/x-change-alacritty-theme.bats`

**Context:** `cp -f "$theme_file" "$A_DIR/theme-active.toml"` runs without checking the source
exists. `A_DIR` is derived from `${XDG_CONFIG_HOME:-$HOME/.config}/alacritty`, so tests can
control it via `XDG_CONFIG_HOME`.

- [ ] **Step 1: Write the failing test**

```bash
cat > tests/x-change-alacritty-theme.bats << 'EOF'
#!/usr/bin/env bats

setup() {
  THEME_DIR="$(mktemp -d)/alacritty"
  mkdir -p "$THEME_DIR"
  touch "$THEME_DIR/alacritty.toml"
  export XDG_CONFIG_HOME="$(dirname "$THEME_DIR")"
}

teardown() {
  rm -rf "$(dirname "$THEME_DIR")"
}

@test "x-change-alacritty-theme: exits non-zero when theme file is missing" {
  # No theme-day.toml exists in THEME_DIR
  run bash local/bin/x-change-alacritty-theme day
  [ "$status" -ne 0 ]
  [[ "$output" == *"not found"* ]] || [[ "$output" == *"No such file"* ]]
}

@test "x-change-alacritty-theme: exits 0 and copies theme when file exists" {
  echo "theme = night" > "$THEME_DIR/theme-night.toml"
  run bash local/bin/x-change-alacritty-theme night
  [ "$status" -eq 0 ]
  [ -f "$THEME_DIR/theme-active.toml" ]
}

@test "x-change-alacritty-theme: exits 1 when no argument given" {
  run bash local/bin/x-change-alacritty-theme
  [ "$status" -eq 1 ]
}
EOF
```

- [ ] **Step 2: Run tests to confirm first test currently fails wrong**

```
./node_modules/.bin/bats tests/x-change-alacritty-theme.bats
```

Expected: first test FAILS (cp error message doesn't match "not found"). Second and third may
vary.

- [ ] **Step 3: Add theme file existence guard**

In `local/bin/x-change-alacritty-theme`, replace the body of `set_alacritty_theme()`:

```bash
set_alacritty_theme()
{
  local theme=$1
  local theme_file="$A_DIR/theme-$theme.toml"
  msg "Setting alacritty theme to $theme ($theme_file)"
  if [ ! -f "$theme_file" ]; then
    echo "ERROR: Theme file not found: $theme_file" >&2
    return 1
  fi
  cp -f "$theme_file" "$A_DIR/theme-active.toml"
  return 0
}
```

- [ ] **Step 4: Run tests to confirm all pass**

```
./node_modules/.bin/bats tests/x-change-alacritty-theme.bats
```

Expected: all 3 tests PASS.

- [ ] **Step 5: Commit**

```bash
git add local/bin/x-change-alacritty-theme tests/x-change-alacritty-theme.bats
git commit -m "fix(x-change-alacritty-theme): guard missing theme file; add bats tests"
```

---

## Task 5: x-backup-mysql-with-prefix — unquote table name expansion

**Files:**
- Modify: `local/bin/x-backup-mysql-with-prefix:55-61`
- Create: `tests/x-backup-mysql-with-prefix.bats`

**Context:** The `mysqldump` call quotes `"$(mysql_output)"`, passing all table names as a single
argument. Removing the quotes lets word-splitting deliver each name as a separate argument.

- [ ] **Step 1: Write the failing test**

```bash
cat > tests/x-backup-mysql-with-prefix.bats << 'EOF'
#!/usr/bin/env bats

setup() {
  STUB_DIR="$(mktemp -d)"

  # mysql stub: echoes two table names after stripping the header line
  cat > "$STUB_DIR/mysql" << 'STUB'
#!/usr/bin/env sh
printf "Tables_in_db (wp_)\n"
printf "wp_options\n"
printf "wp_posts\n"
STUB
  chmod +x "$STUB_DIR/mysql"

  # mysqldump stub: records argument count and args to files
  # argc.txt = number of args; args.txt = one arg per line
  cat > "$STUB_DIR/mysqldump" << STUB
#!/usr/bin/env sh
echo "\$#" > "$STUB_DIR/argc.txt"
printf "%s\n" "\$@" > "$STUB_DIR/args.txt"
STUB
  chmod +x "$STUB_DIR/mysqldump"

  export PATH="$STUB_DIR:$PATH"
  export STUB_DIR
}

teardown() {
  rm -rf "$STUB_DIR"
}

@test "x-backup-mysql-with-prefix: passes each table as a separate argument" {
  run bash local/bin/x-backup-mysql-with-prefix wp_ mysite wordpress
  [ "$status" -eq 0 ]
  # Before fix: mysqldump gets 2 args (database + 1 quoted multi-line string)
  # After fix:  mysqldump gets 3 args (database + wp_options + wp_posts)
  local argc
  argc=$(cat "$STUB_DIR/argc.txt")
  [ "$argc" -eq 3 ]
}

@test "x-backup-mysql-with-prefix: exits 1 without required arguments" {
  run bash local/bin/x-backup-mysql-with-prefix
  [ "$status" -eq 1 ]
}
EOF
```

- [ ] **Step 2: Run test to confirm first test currently fails**

```
./node_modules/.bin/bats tests/x-backup-mysql-with-prefix.bats
```

Expected: `passes each table as a separate argument` FAILS — the args file contains a single
entry with embedded newlines (`wp_options\nwp_posts`), not two separate lines.

- [ ] **Step 3: Remove quotes around the subshell in mysqldump call**

In `local/bin/x-backup-mysql-with-prefix`, replace lines 55-61:

```bash
  mysqldump \
    "${database}" \
    "$(
      echo "show tables like '${prefix}%';" \
        | mysql "${database}" \
        | sed '/Tables_in/d'
    )" > "${filename_timestamp}"
```

with:

```bash
  mysqldump \
    "${database}" \
    $(
      echo "show tables like '${prefix}%';" \
        | mysql "${database}" \
        | sed '/Tables_in/d'
    ) > "${filename_timestamp}"
```

- [ ] **Step 4: Run tests to confirm all pass**

```
./node_modules/.bin/bats tests/x-backup-mysql-with-prefix.bats
```

Expected: both tests PASS.

- [ ] **Step 5: Commit**

```bash
git add local/bin/x-backup-mysql-with-prefix tests/x-backup-mysql-with-prefix.bats
git commit -m "fix(x-backup-mysql-with-prefix): unquote table expansion; add bats tests"
```

---

## Task 6: x-set-php-aliases — survive missing PHP installation

**Files:**
- Modify: `local/bin/x-set-php-aliases:119`
- Create: `tests/x-set-php-aliases.bats`

**Context:** `brew list | grep '^php' > "$BREW_LIST_CACHE"` — with `set -euo pipefail`, grep
exiting 1 (no PHP formulas) terminates the script before aliases are configured.
Fix: append `|| true`.

- [ ] **Step 1: Write the failing test**

```bash
cat > tests/x-set-php-aliases.bats << 'EOF'
#!/usr/bin/env bats

setup() {
  STUB_DIR="$(mktemp -d)"
  CACHE_HOME="$(mktemp -d)"

  # brew stub: `brew list` returns nothing; `brew --prefix` returns /usr/local
  cat > "$STUB_DIR/brew" << 'STUB'
#!/usr/bin/env sh
case "$1" in
  list)     exit 0 ;;
  --prefix) echo "/usr/local" ;;
esac
STUB
  chmod +x "$STUB_DIR/brew"

  export PATH="$STUB_DIR:$PATH"
  export XDG_CACHE_HOME="$CACHE_HOME"
  export STUB_DIR CACHE_HOME
}

teardown() {
  rm -rf "$STUB_DIR" "$CACHE_HOME"
}

@test "x-set-php-aliases: exits 0 when no PHP formula is installed" {
  run bash local/bin/x-set-php-aliases
  [ "$status" -eq 0 ]
}

@test "x-set-php-aliases: creates cache file even when no PHP found" {
  run bash local/bin/x-set-php-aliases
  [ "$status" -eq 0 ]
  [ -f "$CACHE_HOME/x-set-php-aliases/brew_list.cache" ]
}
EOF
```

- [ ] **Step 2: Run tests to confirm first test currently fails**

```
./node_modules/.bin/bats tests/x-set-php-aliases.bats
```

Expected: `exits 0 when no PHP formula is installed` FAILS — script exits 1 because grep finds
no matches.

- [ ] **Step 3: Add `|| true` to the grep pipeline**

In `local/bin/x-set-php-aliases`, change line 119 from:

```bash
  brew list | grep '^php' > "$BREW_LIST_CACHE"
```

to:

```bash
  brew list | grep '^php' > "$BREW_LIST_CACHE" || true
```

- [ ] **Step 4: Run tests to confirm all pass**

```
./node_modules/.bin/bats tests/x-set-php-aliases.bats
```

Expected: both tests PASS.

- [ ] **Step 5: Commit**

```bash
git add local/bin/x-set-php-aliases tests/x-set-php-aliases.bats
git commit -m "fix(x-set-php-aliases): tolerate no-PHP system via pipefail guard; add bats tests"
```

---

## Task 7: x-env-list — remove double-parse block

**Files:**
- Modify: `local/bin/x-env-list:146-150`
- Create: `tests/x-env-list.bats`

**Context:** Lines 146-150 re-read `$X_ENV_GROUPING` as colon-separated `key:group` pairs. This
runs after the `yq`-based YAML parse (lines 99-144) and misreads YAML colons, adding bogus
entries to `DEFINED_GROUPS`. Remove the block entirely.

```bash
# REMOVE this block (lines 146-150):
if [[ -f "$X_ENV_GROUPING" ]]; then
  while IFS=':' read -r key group; do
    DEFINED_GROUPS+=("$key=$group")
  done < "$X_ENV_GROUPING"
fi
```

- [ ] **Step 1: Write the test**

```bash
cat > tests/x-env-list.bats << 'EOF'
#!/usr/bin/env bats

@test "x-env-list: exits 0 and prints group headers without config file" {
  run bash local/bin/x-env-list
  [ "$status" -eq 0 ]
  [[ "$output" == *"# "* ]]
}

@test "x-env-list: does not add bogus groups from YAML colon parsing" {
  local cfg
  cfg="$(mktemp --suffix=.yaml)"
  cat > "$cfg" << 'YAML'
custom_grouping: []
protected_keys: []
skipped_keys: []
YAML
  run env X_ENV_GROUPING="$cfg" bash local/bin/x-env-list
  rm -f "$cfg"
  # "custom_grouping" should NOT appear as a group header
  [[ "$output" != *"# custom_grouping"* ]]
}
EOF
```

- [ ] **Step 2: Run tests to see current state**

```
./node_modules/.bin/bats tests/x-env-list.bats
```

Expected: second test FAILS if `yq` is installed (bogus group `# custom_grouping` appears in
output). First test should PASS.

Note: if `yq` is not installed the second test skips the double-parse path; both tests PASS.
The fix is still correct either way.

- [ ] **Step 3: Remove the double-parse block**

In `local/bin/x-env-list`, delete lines 146-150:

```bash
if [[ -f "$X_ENV_GROUPING" ]]; then
  while IFS=':' read -r key group; do
    DEFINED_GROUPS+=("$key=$group")
  done < "$X_ENV_GROUPING"
fi
```

The blank line between the `yq` block and `is_protected()` can remain.

- [ ] **Step 4: Run tests to confirm all pass**

```
./node_modules/.bin/bats tests/x-env-list.bats
```

Expected: both tests PASS.

- [ ] **Step 5: Commit**

```bash
git add local/bin/x-env-list tests/x-env-list.bats
git commit -m "fix(x-env-list): remove double-parse block that misread YAML as key:group; add bats tests"
```

---

## Task 8: x-quota-usage.php — guard against zero quota

**Files:**
- Modify: `local/bin/x-quota-usage.php:59` (add guard before the division)
- Create: `tests/x-quota-usage.bats`

**Context:** Line 59 divides `$result['used']` by `$result['quota']`. When quota is 0, PHP
emits a division-by-zero warning and produces `INF`. Guard with a `continue` before line 59.

- [ ] **Step 1: Write the failing test**

```bash
cat > tests/x-quota-usage.bats << 'EOF'
#!/usr/bin/env bats

setup() {
  STUB_DIR="$(mktemp -d)"

  # quota stub: returns a line with quota field = 0
  cat > "$STUB_DIR/quota" << 'STUB'
#!/usr/bin/env sh
printf "Filesystem  kbytes  quota  limit\n"
printf "---\n"
printf "/dev/disk1  1000    0      0\n"
STUB
  chmod +x "$STUB_DIR/quota"

  export PATH="$STUB_DIR:$PATH"
  export STUB_DIR
}

teardown() {
  rm -rf "$STUB_DIR"
}

@test "x-quota-usage: exits 0 with no PHP warnings when quota is zero" {
  run php local/bin/x-quota-usage.php
  [ "$status" -eq 0 ]
  [[ "$output" != *"Division by zero"* ]]
  [[ "$output" != *"Warning"* ]]
}

@test "x-quota-usage: exits 1 when quota binary is missing" {
  local no_quota
  no_quota="$(mktemp -d)"
  run env PATH="$no_quota" php local/bin/x-quota-usage.php
  [ "$status" -ne 0 ]
  rm -rf "$no_quota"
}
EOF
```

- [ ] **Step 2: Run tests to confirm first test currently fails**

```
./node_modules/.bin/bats tests/x-quota-usage.bats
```

Expected: first test FAILS — output contains `Warning: Division by zero`.

Note: second test may behave differently depending on PHP version / error reporting.

- [ ] **Step 3: Add zero-quota guard to x-quota-usage.php**

In `local/bin/x-quota-usage.php`, add a guard immediately before line 59. The block starting
at line 57 should become:

```php
    $result = array_combine(['fs', 'used', 'quota', 'limit'], $values);

    if ((int)$result['quota'] <= 0) {
        continue;
    }

    $result['used_percentage'] = round($result['used'] / $result['quota'] * 100, 3);
```

- [ ] **Step 4: Run tests to confirm all pass**

```
./node_modules/.bin/bats tests/x-quota-usage.bats
```

Expected: first test PASS (no division by zero). Second test behavior depends on environment
but should be non-zero exit when quota binary is absent.

- [ ] **Step 5: Commit**

```bash
git add local/bin/x-quota-usage.php tests/x-quota-usage.bats
git commit -m "fix(x-quota-usage): skip entries with zero quota to prevent division by zero; add bats tests"
```

---

## Final Verification

- [ ] **Run the full test suite**

```
yarn test
```

Expected: all existing tests pass, all 8 new test files pass.

- [ ] **Run the lint gate**

```
yarn lint
```

Expected: no errors.
