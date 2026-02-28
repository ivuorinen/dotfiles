---
name: shell-validate
description: >-
  Validate shell scripts after editing.
  Apply when writing or modifying any shell script
  in local/bin/ or scripts/.
user-invocable: false
allowed-tools: Bash, Read, Grep
---

After editing any shell script in `local/bin/`, `scripts/`, or `config/`
(files with a `#!` shebang or `# shellcheck shell=` directive),
validate it:

## 1. Determine the shell

- `/bin/sh` or `#!/usr/bin/env sh` shebang -> POSIX, use `sh -n`
- `/bin/bash` or `#!/usr/bin/env bash` shebang -> Bash, use `bash -n`
- `# shellcheck shell=bash` directive (no shebang) -> use `bash -n`
- `# shellcheck shell=sh` directive (no shebang) -> use `sh -n`
- No shebang and no directive -> default to `bash -n`

## 2. Syntax check

Run the appropriate syntax checker:

```bash
bash -n <file>   # for bash scripts
sh -n <file>     # for POSIX sh scripts
```

If syntax check fails, fix the issue before proceeding.

## 3. ShellCheck

Run `shellcheck <file>`. The project `.shellcheckrc` already
disables SC2039, SC2166, SC2154, SC1091, SC2174, SC2016.
Only report and fix warnings that are NOT in that exclude list.

## Key files to never validate (not shell scripts)

- `local/bin/fzf-tmux` (vendor file)
- `*.md` files
- `*.bats` test files (Bats, not plain shell)
