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

## Commands

```bash
# Install dependencies (required before lint/test)
yarn install

# Linting
yarn lint              # Run biome + prettier + editorconfig-checker
yarn lint:biome        # Biome only
yarn lint:ec           # EditorConfig checker only

# Formatting
yarn fix:biome         # Autofix with biome (JS/TS/JSON/MD)
yarn fix:prettier      # Autofix with prettier (YAML)
yarn format            # Format with biome
yarn format:yaml       # Format YAML files with prettier

# Testing (Bats - Bash Automated Testing System)
yarn test              # Run all tests in tests/
# Run a single test file:
./node_modules/.bin/bats tests/dfm.bats

# Shell linting
shellcheck <script>    # Lint shell scripts
```

## Pre-commit Hooks

Configured in `.pre-commit-config.yaml`: shellcheck, shfmt, biome,
yamllint, prettier, actionlint, stylua, fish_syntax/fish_indent.
Run `pre-commit run --all-files` to check everything.

## Commit Convention

Semantic Commit messages: `type(scope): summary`
(e.g., `fix(tmux): correct prefix binding`).
Enforced by commitlint extending `@ivuorinen/commitlint-config`.

## Architecture

### Shell Configuration Chain

Both `base/bashrc` and `base/zshrc` source `config/shared.sh`,
which loads:
- `config/exports` — environment variables, XDG dirs, PATH
- `config/alias` — shell aliases

Zsh additionally uses **antidote** (in `tools/antidote/`)
for plugin management and **oh-my-posh** for the prompt.

### dfm — Dotfiles Manager

`local/bin/dfm` is the main management script. Key commands:
- `dfm install all` — install everything (called during `./install`)
- `dfm brew install` / `dfm brew update` — Homebrew management
- `dfm docs all` — regenerate documentation under `docs/`

### Submodules

External dependencies are git submodules (Dotbot, plugins,
tmux plugins, cheatsheets, antidote).
Managed by `add-submodules.sh`. All set to `ignore = dirty`.
Updated automatically via GitHub Actions on a schedule.

### Host-specific Configs

Machine-specific overrides live in `hosts/<hostname>/`
with their own `base/`, `config/`, and `install.conf.yaml`.
These are layered on top of the global config during installation.

## Code Style

- **EditorConfig**: 2-space indent, UTF-8, LF line endings.
  See `.editorconfig` for per-filetype overrides
  (4-space for PHP/fish, tabs for git config).
- **Shell scripts**: Must have a shebang or
  `# shellcheck shell=bash` directive.
  Follow shfmt settings in `.editorconfig`
  (2-space indent, `binary_next_line`,
  `switch_case_indent`, `space_redirects`, `function_next_line`).
- **Lua** (neovim config): Formatted with stylua (`stylua.toml`),
  90-char line length.
- **JSON/JS/TS/Markdown**: Formatted with Biome (`biome.json`),
  80-char width.
- **YAML**: Formatted with Prettier (`.prettierrc.json`),
  validated with yamllint (`.yamllint.yml`).

## ShellCheck Disabled Rules

Defined in `.shellcheckrc`:
SC2039 (POSIX `local`), SC2166 (`-o` in test),
SC2154 (unassigned variables), SC1091 (source following),
SC2174 (mkdir -p -m), SC2016 (single-quote expressions).

## Package Manager

Yarn (v4.12.0) is the package manager. Do not use npm.
