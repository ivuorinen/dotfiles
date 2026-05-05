---
paths:
  - "local/bin/**"
  - "scripts/**"
  - "config/theme/handlers.d/**"
  - "config/theme/apply"
  - "config/theme/watcher"
  - "config/theme/probe-osc11"
---

# Shell scripts — bash style

Every shell script in this repo must start with one of:

- `#!/usr/bin/env bash` — for bash-flavoured scripts (default)
- `#!/bin/sh` plus a `# shellcheck shell=sh` directive on line 2
- A `# shellcheck shell=bash` directive on line 1 when the file is
  sourced (no shebang)

The shellcheck directive lets `shellcheck` lint sourced libraries
that have no shebang. Without it the linter falls back to `sh` mode
and flags valid bash constructs.

Follow the shfmt settings in `.editorconfig`:
2-space indent, `binary_next_line`, `switch_case_indent`,
`space_redirects`, `function_next_line`. The `shell-validate` skill
runs both shellcheck and shfmt after each Edit/Write.

POSIX (`/bin/sh`) scripts are listed in
`.claude/rules/posix-scripts.md`. Validate those with `sh -n`,
not `bash -n`.
