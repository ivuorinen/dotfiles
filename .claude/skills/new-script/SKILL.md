---
name: new-script
description: >-
  Scaffold a new helper script in local/bin/ with proper
  boilerplate, msgr sourcing when it prints messages, and
  documentation tag.
user-invocable: true
allowed-tools: Bash, Read, Write, Edit
---

When creating a new script in `local/bin/`, follow this template:

## 1. Script file

Create `local/bin/<name>` with:

```bash
#!/usr/bin/env bash
#USAGE about "<one-line description>"

set -euo pipefail

# Only when the script prints messages (see below). msgr reads unset
# variables, so it is sourced with nounset off.
set +u
# shellcheck source=msgr
. "$(dirname "\$0")/msgr"
set -u

# Script logic here
```

- The `#USAGE about` directive is required — `install-completions.sh`
  discovers scripts by `grep -q '#USAGE\|//USAGE'`; scripts without it
  get no completions, markdown docs, or manpages
- Add `#USAGE flag`, `#USAGE arg`, `#USAGE cmd` lines as needed
  (see <https://usage.jdx.dev/cli/scripts>)
- Use `msgr` functions for messages: `msgr msg`, `msgr run`,
  `msgr yay`, `msgr err`, `msgr warn`. A script that never prints a
  message — one whose output is data, like `is-sudoer` or
  `git-ls-existing` — leaves out the msgr block
- Escape every dollar-digit in this file with a backslash (`\$0`,
  `\$1`): Claude Code otherwise replaces them with the skill's
  arguments, which mangled this template once
- POSIX scripts (`/bin/sh`) must never source msgr (it is bash; sourcing it breaks a POSIX script)

## 2. Make executable

```bash
chmod +x local/bin/<name>
```

## 3. Generate docs

Run `scripts/install-completions.sh` to regenerate completions,
markdown docs, and manpages for all inline-annotated scripts in
`local/bin/` and `scripts/`.

## 4. Validate

Run the shell-validate skill checks (syntax + shellcheck).

## Naming conventions

- `x-` prefix for standalone utilities (e.g., `x-ssl-expiry-date`)
- Short names for frequently used commands (e.g., `a`, `ad`, `ae`)
- `git-` prefix for git subcommands (e.g., `git-dirty`)
