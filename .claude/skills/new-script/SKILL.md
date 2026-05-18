---
name: new-script
description: >-
  Scaffold a new helper script in local/bin/ with proper
  boilerplate, msgr sourcing, and documentation tag.
user-invocable: true
allowed-tools: Bash, Read, Write, Edit
---

When creating a new script in `local/bin/`, follow this template:

## 1. Script file

Create `local/bin/<name>` with:

```bash
#!/usr/bin/env bash
# @description <one-line description>
#USAGE about "<one-line description>"

set -euo pipefail

# shellcheck source=msgr
. "$(dirname "$0")/msgr"

# Script logic here
```

- The `@description` tag is required — `dfm scripts` discovers
  scripts by it
- The `#USAGE about` directive is required — `install-completions.sh`
  discovers scripts by `grep -q '#USAGE\|//USAGE'`; scripts without it
  get no completions, markdown docs, or manpages
- Add `#USAGE flag`, `#USAGE arg`, `#USAGE cmd` lines as needed
  (see https://usage.jdx.dev/cli/scripts)
- Use `msgr` functions for output: `msgr msg`, `msgr run`,
  `msgr yay`, `msgr err`, `msgr warn`
- POSIX scripts (`/bin/sh`) should NOT source msgr

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
