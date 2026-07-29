# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code)
when working with code in this repository.

## Repository Overview

Personal dotfiles repository for Ismo Vuorinen.
Uses **Dotbot** (not GNU Stow) to symlink configuration files into place.
The directory layout follows the XDG Base Directory Specification.

## Directory Layout and Linking

Installation: `./install` runs Dotbot with `install.conf.yaml`,
then applies `hosts/<hostname>/install.conf.yaml` if it exists.
Use `./install --links` to refresh symlinks only (skips shell provisioning steps).
Link steps live in `dotbot-links.yaml`; `install.conf.yaml` includes it and adds
the shell steps on top.

## Commands

Workflow commands (lint, format, test, shell/Lua tooling, pre-commit,
biome migration) are catalogued in `docs/commands.md`. Most are also
exposed via `dfm <subcommand>` and the `scripts` block in
`package.json` (run `dfm help` or `yarn run` to list).

## Commit Convention

Format and examples live in `.claude/rules/commit-format.md`.
Enforced at hook time by commitlint extending
`@ivuorinen/commitlint-config`.

## Architecture

### Shell Configuration Chain

Both `base/bashrc` and `base/zshrc` source `config/shared.sh`,
which loads:

- `config/lib.sh` — centralized logging + error/cleanup helpers
- `config/exports` — environment variables, XDG dirs, PATH
- `config/alias` — shell aliases

Zsh additionally uses **antidote** (in `tools/antidote/`) for plugin
management. All three shells (bash, zsh, fish) render their prompt
with **starship**.

### Centralized Logging (`config/lib.sh`)

`config/shared.sh` sources `config/lib.sh` first, so the helpers below
are available in every interactive shell and in every script that
sources `shared.sh` (including all `dfm-*` subcommands, which reach it
through `dfm_bootstrap`). Adapted from the dfm `common.sh` logging
functions and made portable across bash 3.2+, bash 5, and zsh (severities
map via a `case` statement, not a bash-only associative array).

**Load-time invariant:** because it lands in interactive shells,
`lib.sh` is side-effect-free on source — it only defines functions and
constants. It never runs `set -e`, installs traps, or calls `exit` at
the top level; scripts opt into those via `lib::strict` /
`lib::trap_cleanup`. Covered by `tests/lib.bats`.

### Theme Orchestrator (`config/theme/`)

Dark/light theming is owned by a stand-alone orchestrator. The details
live in `config/theme/CLAUDE.md`, which loads when you work in that
directory; `local/bin/theme-mode` is the public read API.

### msgr — Messaging Helper

`local/bin/msgr` provides colored output functions (`msgr msg`,
`msgr run`, `msgr yay`, `msgr err`, `msgr warn`). Sourced by `dfm`
and most scripts in `local/bin/`.

### dfm — Dotfiles Manager

`local/bin/dfm` is a git-style dispatcher: `dfm <section> <args>` execs
`dfm-<section>`. Architecture, the `dfm-lib` contract, and the command
list live in `local/bin/CLAUDE.md`, which loads when working there.

### mise — Unified Tool Manager

`config/mise/config.toml` pins the language runtimes and CLI tools.
Activated via `eval "$(mise activate bash)"` in `config/exports`.
Run `mise install` after adding new tools.

Python packages come from `config/mise/default-python-packages`, not pip
by hand — `python.default_packages_file` in the same config points at it.

### Host-specific Configs

Machine-specific overrides live in `hosts/<hostname>/`
with their own `base/`, `config/`, and `install.conf.yaml`.
These are layered on top of the global config during installation.

There is also a hostname-suffix dispatch inside `config/exports` for
shell-export overrides: any file at `~/.config/exports-<hostname>`
(or `-secret` variant) is sourced when the bash/zsh shell starts on
that machine. The canonical home for those files is
`hosts/<hostname>/config/exports-<hostname>`; the host overlay
symlinks them into `~/.config/` automatically.

## Code Style

- **Shell scripts**: shebang/shellcheck rules and shfmt settings are
  in `.claude/rules/shell-scripts.md`. shfmt config lives in
  `.editorconfig`.
- **Formatters**: stylua (Lua), Biome (JSON/JS/TS/Markdown), Prettier +
  yamllint (YAML). Their config files are authoritative; `.editorconfig`
  carries the per-filetype indent overrides.

## Gotchas

- **POSIX scripts** (validation rule in `.claude/rules/posix-scripts.md`,
  which holds the authoritative list): ten scripts are `sh`, not bash —
  eight `#!/bin/sh` under `local/bin/`, plus `local/bin/pushover` and
  `config/yabai/yabairc` on `#!/usr/bin/env sh`. Validate them with `sh -n`
  or `dash -n`, never `bash -n`.
- **Vendored files**: the six fzf files, `.claude/skills/graphify/`, and
  `local/bin/iterm2_shell_integration.zsh`.
  Edit policy: `.claude/rules/vendored-files.md`.
- **Fish config**: `config/fish/` has its own config chain
  (`config.fish`, `exports.fish`, `alias.fish`) plus 60+ functions.
- **gh CLI config**: `config/gh/hosts.yml` is managed by `gh` CLI
  and excluded from prettier (see `.prettierignore`).
- **Python**: Two scripts (`x-compare-versions.py`,
  `x-git-largest-files.py`) linted by Ruff (config in `pyproject.toml`).
- **Fish secrets**: `config/fish/secrets.d/*.fish` files are auto-sourced
  by `exports.fish`. Copy `github.fish.example` → `github.fish` for local
  secrets. Commit policy: `.claude/rules/secrets-files.md`.

## Claude Code Configuration

Hooks, skills and subagents live in `.claude/settings.json`,
`.claude/skills/` and `.claude/agents/`. Read those rather than a list
here — the list drifts, and the hook chain is the authority on what is
enforced.

- **Plugins** (required):
  - `context-mode`: Context window protection — must be
    installed for this repo. See routing rules below.
  - `context7`: Live documentation lookup

## context-mode

Mandatory MCP routing rules live in `.claude/rules/context-mode.md`.
That file is the single source of truth — do not duplicate its content
back into this file.

## graphify

This project has a knowledge graph at `graphify-out/` with god nodes,
community structure, and cross-file relationships. It is built by the
`graphify` skill (`.claude/skills/graphify/SKILL.md`) and holds a wiki
(`wiki/index.md`), a full report (`GRAPH_REPORT.md`), and the graph itself
(`graph.json`).

When to query it, which entry point to use, and when to rebuild it are
mandates — they live in `.claude/rules/graphify-first.md`. Do not duplicate
them back into this file.
