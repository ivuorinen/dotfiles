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

Follow the shfmt settings in `.editorconfig`; they are enumerated in
`.claude/rules/editorconfig.md`. The `shell-validate` skill runs both
shellcheck and shfmt after each Edit/Write.

POSIX (`/bin/sh`) scripts have their own validation rule — read
`.claude/rules/posix-scripts.md` before checking one, and use the method it
names.
