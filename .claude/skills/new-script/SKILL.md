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

set -euo pipefail

# shellcheck source=msgr
. "$(dirname "$0")/msgr"

# Script logic here
```

- Use `msgr` functions for output: `msgr msg`, `msgr run`,
  `msgr yay`, `msgr err`, `msgr warn`
- The `@description` tag is required — `dfm scripts` discovers
  scripts by it
- POSIX scripts (`/bin/sh`) should NOT source msgr

## 2. Make executable

```bash
chmod +x local/bin/<name>
```

## 3. Generate docs

Run `dfm docs script <name>` or manually create `local/bin/<name>.md`
with a usage summary.

## 4. Validate

Run the shell-validate skill checks (syntax + shellcheck).

## Naming conventions

- `x-` prefix for standalone utilities (e.g., `x-ssl-expiry-date`)
- Short names for frequently used commands (e.g., `a`, `ad`, `ae`)
- `git-` prefix for git subcommands (e.g., `git-dirty`)
