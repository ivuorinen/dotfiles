# Adversarial Review Findings — local/bin

Generated: 2026-04-16. Provable failures only. Each entry includes a trigger and minimal fix.

---

## CRITICAL

**BUG: eval injection via first argument**
File: `local/bin/x-foreach:15`
Category: Security
Severity: CRITICAL

The `listing` variable is passed directly to `eval`, allowing arbitrary shell command injection
through the first argument.

Trigger: `x-foreach 'ls -d */; id > /tmp/pwned' pwd`

Fix: Replace `for dir in $(eval "$listing")` — use direct command substitution without `eval`,
or pass the command as separate arguments and execute without `eval`.

---

## HIGH

**BUG: Uninitialized optional variables in curl call**
File: `local/bin/pushover:40-56`
Category: Error Handling
Severity: HIGH

Optional variables (`callback`, `timestamp`, `priority`, `retry`, `expire`, `title`, `sound`,
`url`, `url_title`) are used inside `__pushover_send_message()` but never initialized before the
`getopts` loop, so running without optional flags passes empty/unset values into curl.

Trigger: `pushover "hello"` with no optional flags

Fix: Initialize all optional variables to empty strings before the `getopts` loop.

---

**BUG: CURL availability not validated before first use**
File: `local/bin/pushover:39-57` (use) vs `:142` (check)
Category: Error Handling
Severity: HIGH

The script validates `CURL` at line 142 but `__pushover_send_message()` references `$CURL` at
line 40 onward. If `curl` is absent, the check is too late and the function runs with an empty
command.

Trigger: Remove `curl` from PATH, then call `pushover "test"`

Fix: Move the `CURL` validation to the top of the script, before any function definitions that
reference it.

---

**BUG: No directory existence check before tar**
File: `local/bin/x-backup-folder:79-82`
Category: Error Handling
Severity: HIGH

The script checks for an empty `$directory` argument but never verifies the path exists on disk.
`tar` will fail with a cryptic error and no cleanup occurs.

Trigger: `x-backup-folder /nonexistent/path`

Fix: Add `[ -d "$directory" ] || { msgr err "Directory does not exist: $directory"; exit 1; }`
before calling `backup_directory`.

---

**BUG: Theme file existence not checked before copy**
File: `local/bin/x-change-alacritty-theme:30-33`
Category: Error Handling
Severity: HIGH

The `cp -f` runs without confirming the source theme file exists. The script reports success even
when the copy silently fails.

Trigger: `x-change-alacritty-theme day` when `~/.config/alacritty/theme-day.toml` is absent

Fix: Add `[ -f "$theme_file" ] || { msgr err "Theme file not found: $theme_file"; return 1; }`
before the `cp` command.

---

**BUG: MySQL table names passed as a single quoted string**
File: `local/bin/x-backup-mysql-with-prefix:54-59`
Category: Logic
Severity: HIGH

The `mysqldump` call wraps the table list in a subshell with quotes, so all table names arrive as
one argument instead of separate arguments. `mysqldump` interprets the entire string as a single
table name and fails.

Trigger: `x-backup-mysql-with-prefix wp_ mydb wordpress` where multiple `wp_*` tables exist

Fix: Use unquoted expansion: `mysqldump "${database}" $(mysql_output)` so each table name is a
separate word.

---

**BUG: Premature script exit when no PHP is installed**
File: `local/bin/x-set-php-aliases:119`
Category: Error Handling
Severity: HIGH

With `set -euo pipefail` active, `brew list | grep '^php'` exits with code 1 when no PHP
formula is installed. `pipefail` propagates this non-zero exit and terminates the entire script
before any aliases are configured.

Trigger: Fresh system with no Homebrew PHP formula installed

Fix: `brew list | grep '^php' > "$BREW_LIST_CACHE" || true`

---

## MEDIUM

**BUG: Config file double-parsed with conflicting formats**
File: `local/bin/x-env-list:68-87` and `:132-136`
Category: Logic
Severity: MEDIUM

The grouping config is first parsed as YAML via `yq`, then parsed again as plain `key:value`
pairs. Any colon inside a YAML value is misread by the second parser, producing wrong group
assignments.

Trigger: Config at `$X_ENV_GROUPING` containing valid YAML with colons in values

Fix: Remove the second parsing block at lines 132–136; use only the `yq` path.

---

**BUG: Division by zero when quota value is zero**
File: `local/bin/x-quota-usage.php:59`
Category: Logic
Severity: MEDIUM

When `quota -w` returns a line with a quota field of `0`, the expression
`$result['used'] / $result['quota'] * 100` produces a PHP division-by-zero warning and yields
`INF` or `NAN`, which propagates into the output.

Trigger: System where `quota -w` returns a line with quota = `0`

Fix: Skip entries with zero quota: `if ((int)$result['quota'] <= 0) continue;`

---

**BUG: Empty stdin input returns exit 0 (silent pass)**
File: `local/bin/x-compare-versions.py:26-32`
Category: Logic
Severity: MEDIUM

When stdin is empty or contains fewer than 3 tokens, the comparisons list is empty and
`vercmp()` returns `True` without evaluating anything — callers receive a false success.

Trigger: `echo '' | x-compare-versions.py` → exits 0

Fix: Return `False` (or raise) when the token count is less than 3:
`if len(words) < 3: return False`
