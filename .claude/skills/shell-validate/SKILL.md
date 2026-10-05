---
name: shell-validate
description: >-
  Validate shell scripts after editing.
  Apply when writing or modifying any shell script
  in local/bin/ or scripts/.
user-invocable: false
allowed-tools: Read, Grep, mcp__plugin_context-mode_context-mode__ctx_batch_execute
---

After editing any shell script in `local/bin/`, `scripts/`, or `config/`
(files with a `#!` shebang or `# shellcheck shell=` directive),
validate it. Run every command below through `ctx_batch_execute`
(`.claude/rules/bash-routing.md`); `Bash` denies them.

## 1. Determine the shell

- POSIX (`/bin/sh` or `#!/usr/bin/env sh` shebang, or a
  `# shellcheck shell=sh` directive) -> follow `.claude/rules/posix-scripts.md`
  for the validation method
- `/bin/bash` or `#!/usr/bin/env bash` shebang -> Bash, use `bash -n`
- `# shellcheck shell=bash` directive (no shebang) -> use `bash -n`
- No shebang and no directive -> default to `bash -n`

## 2. Syntax check

Run the syntax checker chosen in step 1:

```bash
bash -n <file>   # for bash scripts
```

If syntax check fails, fix the issue before proceeding.

## 3. ShellCheck

Run `shellcheck <file>`. The project `.shellcheckrc` already
disables SC2039, SC2166, SC2154, SC1091, SC2174, SC2016.
Only report and fix warnings that are NOT in that exclude list.

## Key files to never validate (not shell scripts)

- `*.md` files
- `*.bats` test files (Bats, not plain shell)
