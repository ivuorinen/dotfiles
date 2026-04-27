# GitHub Copilot Cloud Agent Instructions

This is **ivuorinen's personal dotfiles repository**. It uses
[Dotbot](https://github.com/anishathalye/dotbot) (not GNU Stow) to symlink
configuration files into place, following the XDG Base Directory Specification.

---

## Directory Layout

| Source              | Symlink destination | Notes                                            |
|---------------------|---------------------|--------------------------------------------------|
| `base/*`            | `~/.*`              | Home-level dotfiles (`.` prefix added by Dotbot) |
| `config/*`          | `~/.config/`        | Application configurations                       |
| `local/bin/*`       | `~/.local/bin/`     | Helper scripts and utilities                     |
| `local/share/*`     | `~/.local/share/`   | Data files                                       |
| `local/man/**`      | `~/.local/man/`     | Manual pages                                     |
| `ssh/*`             | `~/.ssh/`           | SSH configuration (mode 0600)                    |
| `hosts/<hostname>/` | Layered overlay     | Machine-specific overrides                       |

Linking is driven by `install.conf.yaml` at the repo root (and an optional
`hosts/<hostname>/install.conf.yaml`). Dotbot plugins live in `tools/`.

---

## Essential Commands

```bash
# Install Node dependencies first (needed for linting/testing)
yarn install

# Lint everything
yarn lint              # biome + prettier + editorconfig-checker + markdownlint + md-table check
yarn lint:biome        # JS/TS/JSON/MD via Biome
yarn lint:ec           # EditorConfig checker
yarn lint:markdownlint # Markdown linting
yarn lint:md-table     # Markdown table formatting

# Auto-fix
yarn fix:biome         # Biome autofix
yarn fix:prettier      # Prettier autofix (YAML)
yarn fix:md-table      # Fix markdown tables

# Format
yarn format            # Biome format
yarn format:yaml       # Prettier for YAML

# Tests (Bats – Bash Automated Testing System)
yarn test              # Run all tests in tests/
./node_modules/.bin/bats tests/dfm.bats   # Run a single test file

# Shell linting (individual files)
shellcheck local/bin/<script>

# Lua formatting (neovim config)
stylua config/nvim/

# Pre-commit (all hooks at once)
pre-commit run --all-files
```

**Package manager: Yarn v4+** — do NOT use `npm install` or `npm run`.

> **MANDATORY: Run `yarn lint` before every commit. All lint issues must be
> fixed — no exceptions. A commit with lint errors is never acceptable.**

---

## Code Style Rules

| File type       | Formatter / Linter | Key settings                                                      |
|-----------------|--------------------|-------------------------------------------------------------------|
| Shell (bash/sh) | shfmt + shellcheck | 2-space, binary_next_line, switch_case_indent, function_next_line |
| Fish            | fish_indent        | 4-space indent, 120-char line limit                               |
| Lua             | stylua             | 90-char line limit (`stylua.toml`)                                |
| JSON / JS / TS  | Biome              | 90-char width (`biome.json`)                                      |
| Markdown        | Biome              | 120-char width override                                           |
| YAML            | Prettier           | Validated with yamllint (`.yamllint.yml`)                         |
| Python          | ruff               | Config in `pyproject.toml`                                        |

- **EditorConfig**: 2-space indent, UTF-8, LF line endings globally.
  `.editorconfig` has per-filetype overrides (4-space for PHP/fish, tabs for git config).
- **Shell scripts**: must include a shebang (`#!/usr/bin/env bash`) or
  `# shellcheck shell=bash`.
- **Commit messages**: Semantic Commits — `type(scope): summary`
  (e.g., `fix(tmux): correct prefix binding`). Enforced by commitlint.

### ShellCheck disabled rules (`.shellcheckrc`)

SC2039, SC2166, SC2154, SC1091, SC2174, SC2016 — these are intentionally
suppressed project-wide; do not add `# shellcheck disable` for them inline.

---

## Architecture

### Shell Configuration Chain

```text
base/bashrc ──┐
              ├──▶ config/shared.sh ──▶ config/exports  (env vars, XDG, PATH)
base/zshrc  ──┘                     └──▶ config/alias    (shell aliases)
```

Zsh additionally loads **antidote** (plugin manager, in `tools/antidote/`).
All three shells (bash, zsh, fish) render their prompt with **starship**;
the `~/.config/starship.toml` symlink is managed by the theme orchestrator
(`config/theme/handlers.d/starship`).

### Key Scripts

- **`local/bin/msgr`** — colored output helper (`msgr msg|run|yay|err|warn`).
  Sourced by `dfm` and most scripts in `local/bin/`.
- **`local/bin/dfm`** — the main dotfiles manager script. Key sub-commands:
  - `dfm install all` — install everything in tiered stages
  - `dfm brew install` / `dfm brew update` — Homebrew management
  - `dfm apt upkeep` — APT maintenance (Debian/Ubuntu)
  - `dfm dotfiles fmt` / `dfm dotfiles shfmt` — format configs/scripts
  - `dfm docs all` — regenerate documentation under `docs/`
  - `dfm scripts` — run scripts from `scripts/` (discovered via `@description` tags)
  - `dfm helpers <name>` — inspect aliases, colors, env, functions, path
  - `dfm check arch` / `dfm check host` — system info

### mise — Unified Tool Manager

`config/mise/config.toml` pins language runtimes (Node LTS, Python 3, Go, Rust)
and CLI tools (fd, ripgrep, eza, neovim, delta, shellcheck, shfmt, stylua, etc.).
Run `mise install` after adding new tools to the config.

### Git Submodules

External dependencies (Dotbot, dotbot-include, antidote, cheat cheatsheets)
are git submodules. All set to `ignore = dirty`. Updated automatically via
the `update-submodules.yml` GitHub Actions workflow.

### Host-specific Configs

Machine overrides live in `hosts/<hostname>/` (current hosts: `air`, `lakka`,
`s`, `tunkki`) with their own `base/`, `config/`, and `install.conf.yaml`.

---

## Files You Must NOT Modify

| File / Path                    | Reason                                       |
|--------------------------------|----------------------------------------------|
| `local/bin/fzf-tmux`           | Vendored from junegunn/fzf — read-only       |
| `yarn.lock` / `.yarn/`         | Managed by Yarn — do not hand-edit           |
| `tools/**` (submodule paths)   | Git submodules — changes belong upstream     |
| `config/fish/secrets.d/*.fish` | Real secrets — gitignored, never commit      |
| `config/gh/hosts.yml`          | Managed by `gh` CLI — excluded from Prettier |

---

## Important Gotchas

1. **POSIX scripts** — `x-ssh-audit`, `x-codeql`, `x-until-error`,
    `x-until-success`, `x-ssl-expiry-date` use `/bin/sh`. Validate with
    `sh -n`, not `bash -n`.
2. **Fish config chain** — `config/fish/config.fish` →
    `exports.fish` → `alias.fish`. The `exports.fish` auto-sources
    `secrets.d/*.fish`. Only `*.example` files and `README.md` in
    `secrets.d/` are tracked.
3. **Scripts in `scripts/`** are discovered by `dfm scripts` via a
    `@description` tag comment near the top of each file.
4. **Documentation** under `docs/` is generated — do not edit generated
    files manually; use `dfm docs all` to regenerate.
5. **`.github/copilot-instructions.md`** (this file) — do not delete or
    overwrite; update it incrementally when the repo changes significantly.

---

## Testing

Tests live in `tests/` and use [Bats](https://github.com/bats-core/bats-core).
Each script in `local/bin/` that has a `.bats` counterpart is fully covered.

```bash
yarn install          # install bats as a dev dependency
yarn test             # run all tests
./node_modules/.bin/bats tests/dfm.bats   # run a single file
```

---

## CI / GitHub Actions Workflows

| Workflow file               | Purpose                                        |
|-----------------------------|------------------------------------------------|
| `linters.yml`               | PR lint (Biome, EditorConfig, md-tables, etc.) |
| `update-submodules.yml`     | Scheduled submodule auto-update                |
| `new-release.yml`           | Semantic-release driven publishing             |
| `changelog.yml`             | Changelog generation                           |
| `pre-commit-autoupdate.yml` | Keep pre-commit hooks up to date               |
| `sync-labels.yml`           | Sync GitHub labels                             |
| `semantic-pr.yml`           | Enforce semantic PR titles                     |

---

## Common Workflows for an Agent

### Adding a new helper script to `local/bin/`

1. Create the script with a `#!/usr/bin/env bash` shebang.
2. Add a `@description <one-liner>` comment near the top.
3. Source `msgr` for output: `. "$DOTFILES/local/bin/msgr"`.
4. Add a corresponding `.md` and `.usage.kdl` sidecar (follow existing patterns).
5. Add a Bats test file in `tests/`.
6. Run `shellcheck local/bin/<script>` and `yarn lint`.

### Adding a new fish function to `config/fish/functions/`

1. Create `<name>.fish` following the existing patterns.
2. Validate: `fish -n config/fish/functions/<name>.fish` and
    `fish_indent --check config/fish/functions/<name>.fish`.

### Modifying Dotbot linking (`install.conf.yaml`)

Edit the file then validate the YAML with `yamllint install.conf.yaml`.
Dotbot config must remain valid YAML with the correct Dotbot schema.

### Adding a host-specific override

Add files under `hosts/<hostname>/` and update
`hosts/<hostname>/install.conf.yaml` using the same Dotbot schema.

### Formatting after edits

- Shell → `shfmt -i 2 -bn -ci -sr -fn -w <file>`
- Fish → `fish_indent -w <file>`
- Lua → `stylua <file>`
- JSON/JS/TS/MD → `yarn fix:biome`
- YAML → `yarn fix:prettier`

### Before every commit (mandatory, no exceptions)

```bash
yarn lint        # must pass with zero errors before any commit
```

If `yarn lint` reports errors, fix them and re-run until it is clean. Do not
commit with lint failures under any circumstances.
