# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code)
when working with code in this repository.

## Repository Overview

Personal dotfiles repository for Ismo Vuorinen.
Uses **Dotbot** (not GNU Stow) to symlink configuration files into place.
The directory layout follows the XDG Base Directory Specification.

## Directory Layout and Linking

| Source              | Destination       | Notes                                     |
|---------------------|-------------------|-------------------------------------------|
| `base/*`            | `~/.*`            | Home-level dotfiles (`.` added by Dotbot) |
| `config/*`          | `~/.config/`      | Application configurations                |
| `local/bin/*`       | `~/.local/bin/`   | Helper scripts and utilities              |
| `local/share/*`     | `~/.local/share/` | Data files                                |
| `local/man/**`      | `~/.local/man/`   | Manual pages                              |
| `ssh/*`             | `~/.ssh/`         | SSH configuration (mode 0600)             |
| `hosts/<hostname>/` | Overlays          | Host-specific overrides                   |

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

## Pre-commit Hooks

Configured in `.pre-commit-config.yaml`: shellcheck, shfmt, biome,
yamllint, prettier, actionlint, stylua, fish_syntax/fish_indent, ruff.
Run `pre-commit run --all-files` to check everything.

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

- `logger::log <LEVEL> <msg>` and the `logger::{debug,info,warn,error}`
  wrappers — level-filtered, timestamped output to stderr, gated by
  `$LOG_LEVEL` (DEBUG < INFO < WARN < ERROR; default `INFO`). The level
  tag is colorized when stderr is a TTY.
- `lib::log` / `lib::error` — unconditional timestamped lines.
- `LIB_E_*` — named exit codes (`LIB_E_INVALID_ARGUMENT`,
  `LIB_E_COMMAND_NOT_FOUND`, …) for `exit`/`return`.
- `lib::strict` — opt-in `set -euo pipefail` + ERR trap via
  `lib::error::handle`. `lib::register_cleanup <path>` +
  `lib::trap_cleanup` — opt-in EXIT cleanup of temp paths.

**Load-time invariant:** because it lands in interactive shells,
`lib.sh` is side-effect-free on source — it only defines functions and
constants. It never runs `set -e`, installs traps, or calls `exit` at
the top level; scripts opt into those via `lib::strict` /
`lib::trap_cleanup`. Covered by `tests/lib.bats`.

### Theme Orchestrator (`config/theme/`)

Dark/light theming is owned by a stand-alone orchestrator:

- `config/theme/watcher` — self-locking daemon, spawned from shell init
  (skipped in SSH sessions). Subscribes to portal/gsettings on Linux,
  polls `defaults read` on macOS.
- `config/theme/apply <mode>` — actor; atomic-writes
  `$XDG_STATE_HOME/dotfiles-theme/mode` and forks each
  `handlers.d/<name>` in parallel under a 5s timeout.
- `config/theme/handlers.d/{tmux,starship,fish,dircolors}` — per-app
  flip executables. Add new apps by dropping a file here.
- `config/theme/palettes.d/[app].[variant].[ext]` — theme assets,
  consolidated in one place.
- `local/bin/theme-mode` (and bash/fish functions) — public read API.
- Fallback: `config/theme/probe-osc11` — OSC 11 query for SSH and
  no-OS-source environments.

Fish reacts to flips via `config/fish/conf.d/theme-switch.fish`,
which watches the mode state file.

### msgr — Messaging Helper

`local/bin/msgr` provides colored output functions (`msgr msg`,
`msgr run`, `msgr yay`, `msgr err`, `msgr warn`). Sourced by `dfm`
and most scripts in `local/bin/`.

### dfm — Dotfiles Manager

`local/bin/dfm` is a thin **git-style dispatcher**: `dfm <section>
<args>` resolves and execs `dfm-<section>` (sibling of the dispatcher
first, then `$PATH`), mirroring how git finds `git-<command>`. The
dispatcher resolves `$0` through any symlinks first, so "the folder it
is in" is the script's real location (the repo's `local/bin`) even when
invoked via a `~/.local/bin/dfm` symlink — dropping a new `dfm-<sub>`
into `local/bin/` works immediately, before `./install` links it. Each
section lives in its own executable:

- `local/bin/dfm-{install,brew,apt,check,dotfiles,helpers,docs,scripts,tests,secrets,cleanup}`
  — one file per section, each carrying its own `#USAGE` subtree.
- `local/bin/dfm-lib` — sourced (non-executable) shared library:
  the bootstrap family, `menu_builder`, `get_script_description`, and the
  `secrets_*` family. The missing exec bit keeps `dfm lib` from matching
  it and signals "source, don't run". Subcommands re-dispatch across
  sections via the `$DFM` variable it exports; same-section fan-out uses
  local function calls.
  - Bootstrap is split for speed: `dfm_bootstrap_min` (env + msgr only)
    serves menu/help paths, while `dfm_bootstrap` adds the bash-4 guard
    and sources `config/shared.sh` (which pulls in `config/exports` —
    `mise activate`, `brew shellenv`, etc.). Each subcommand calls
    `dfm_bootstrap_for "$@"`, which picks the cheap path for no-arg/help
    invocations and the full path for real actions. This keeps `dfm` and
    `dfm <section>` listings fast (no environment sourcing per section).
  - Tool-gated sections (`dfm-apt`, `dfm-brew`) are omitted from the `dfm`
    listing entirely on systems lacking the tool: `dfm_section_requires`
    maps the section to its command and `usage()` skips it when
    `command -v` finds nothing (no bootstrap needed). A direct
    `dfm apt`/`dfm brew` on such a system prints only a "not available on
    this system" notice — the check sits first in the section function and
    gates the menu too. `command -v` (not `x-have`) is used so the gate
    works under the cheap menu-path bootstrap.

Completions/docs/manpages: `scripts/install-completions.sh` stitches the
per-section `#USAGE` fragments into one `dfm` spec (skipping `dfm`/`dfm-*`
in its per-file loop), so the single `dfm` completion tree still covers
every section. Key commands:

- `dfm install all` — install everything in tiered stages
- `dfm brew install` / `dfm brew update` — Homebrew management
- `dfm apt upkeep` — APT package maintenance (Debian/Ubuntu)
- `dfm dotfiles fmt` / `dfm dotfiles shfmt` — format configs/scripts
- `dfm helpers <name>` — inspect aliases, colors, env, functions, path;
  `dfm helpers docs-*` (docs-aliases/nvim/tmux/wezterm/all) regenerate docs
- `dfm docs <name>` — show generated documentation under `docs/`
- `dfm check arch` / `dfm check host` — system info
- `dfm scripts` — run `install-*.sh` scripts from `scripts/` (menu labels from `@description`)
- `dfm tests` — test visualization helpers

### mise — Unified Tool Manager

`config/mise/config.toml` manages language runtimes (Node LTS, Python 3,
Go latest, Rust stable) and CLI tools (fd, ripgrep, eza, neovim, delta,
zoxide, etc.). Activated via `eval "$(mise activate bash)"` in
`config/exports`. Run `mise install` after adding new tools.

### Submodules

External dependencies are git submodules (Dotbot, plugins,
tmux plugins, cheatsheets, antidote).
Managed by `add-submodules.sh`. All set to `ignore = dirty`.
Updated automatically via GitHub Actions on a schedule.

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

- **EditorConfig**: 2-space indent, UTF-8, LF line endings.
  See `.editorconfig` for per-filetype overrides
  (4-space for PHP/fish, tabs for git config).
- **Shell scripts**: shebang/shellcheck rules and shfmt settings are
  in `.claude/rules/shell-scripts.md`. shfmt config lives in
  `.editorconfig`.
- **Lua** (neovim config): Formatted with stylua (`stylua.toml`),
  90-char line length.
- **JSON/JS/TS/Markdown**: Formatted with Biome (`biome.json`),
  90-char width (Markdown uses 120-char override).
- **YAML**: Formatted with Prettier (`.prettierrc.json`),
  validated with yamllint (`.yamllint.yml`).

## ShellCheck Disabled Rules

Defined in `.shellcheckrc`:
SC2039 (POSIX `local`), SC2166 (`-o` in test),
SC2154 (unassigned variables), SC1091 (source following),
SC2174 (mkdir -p -m), SC2016 (single-quote expressions).

## Gotchas

- **POSIX scripts** (validation rule in `.claude/rules/posix-scripts.md`):
  `x-ssh-audit`, `x-codeql`, `x-until-error`, `x-until-success`, and
  `x-ssl-expiry-date` use `/bin/sh`.
- **Vendor file**: `local/bin/fzf-tmux` is vendored from junegunn/fzf.
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

- **Hooks** (`.claude/settings.json`):
  - _PreToolUse_: Blocks edits to `fzf-tmux`, `yarn.lock`,
    `.yarn/`, submodule paths, and real secrets.d files
  - _PostToolUse_: Auto-formats files by extension
    (shfmt, fish_indent, stylua, biome, prettier)
  - _PostToolUse_: Validates Dotbot `install.conf.yaml`
    after edits
  - _PostToolUse_: Warns on formatter/linter config changes
  - _Stop_: Runs `yarn lint` gate before finishing
- **Skills** (`.claude/skills/`):
  - `shell-validate`: Auto-validates shell scripts
    (syntax + shellcheck)
  - `fish-validate`: Auto-validates fish scripts
    (syntax + fish_indent)
  - `lua-format`: Auto-formats Lua files with stylua
  - `yaml-validate`: Auto-validates YAML files
    (yamllint + actionlint)
  - `dotbot-validate`: Validates Dotbot install.conf.yaml
  - `new-script`: Scaffolds helper scripts in local/bin/
  - `new-fish-function`: Scaffolds fish functions
  - `host-override`: Creates host-specific config overlays
- **Subagents** (`.claude/agents/`):
  - `code-reviewer`: Reviews shell/fish/lua changes
- **Plugins** (required):
  - `context-mode`: Context window protection — must be
    installed for this repo. See routing rules below.
  - `context7`: Live documentation lookup

## context-mode

Mandatory MCP routing rules live in `.claude/rules/context-mode.md`.
That file is the single source of truth — do not duplicate its content
back into this file.
