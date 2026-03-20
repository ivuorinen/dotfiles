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
yarn lint:md-table     # Markdown table formatting check
yarn fix:md-table      # Auto-fix markdown tables

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

# Tooling maintenance
npx @biomejs/biome migrate --write  # Update biome schema version
```

## Pre-commit Hooks

Configured in `.pre-commit-config.yaml`: shellcheck, shfmt, biome,
yamllint, prettier, actionlint, stylua, fish_syntax/fish_indent, ruff.
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

### msgr — Messaging Helper

`local/bin/msgr` provides colored output functions (`msgr msg`,
`msgr run`, `msgr yay`, `msgr err`, `msgr warn`). Sourced by `dfm`
and most scripts in `local/bin/`.

### dfm — Dotfiles Manager

`local/bin/dfm` is the main management script. Key commands:
- `dfm install all` — install everything in tiered stages
- `dfm brew install` / `dfm brew update` — Homebrew management
- `dfm apt upkeep` — APT package maintenance (Debian/Ubuntu)
- `dfm dotfiles fmt` / `dfm dotfiles shfmt` — format configs/scripts
- `dfm helpers <name>` — inspect aliases, colors, env, functions, path
- `dfm docs all` — regenerate documentation under `docs/`
- `dfm check arch` / `dfm check host` — system info
- `dfm scripts` — run scripts from `scripts/` (discovered via `@description` tags)
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
  80-char width (Markdown uses 120-char override).
- **YAML**: Formatted with Prettier (`.prettierrc.json`),
  validated with yamllint (`.yamllint.yml`).

## ShellCheck Disabled Rules

Defined in `.shellcheckrc`:
SC2039 (POSIX `local`), SC2166 (`-o` in test),
SC2154 (unassigned variables), SC1091 (source following),
SC2174 (mkdir -p -m), SC2016 (single-quote expressions).

## Gotchas

- **POSIX scripts**: `x-ssh-audit`, `x-codeql`, `x-until-error`,
  `x-until-success`, `x-ssl-expiry-date` use `/bin/sh`.
  Validate with `sh -n`, not `bash -n`.
- **Vendor file**: `local/bin/fzf-tmux` is vendored from
  junegunn/fzf — do not modify.
- **Fish config**: `config/fish/` has its own config chain
  (`config.fish`, `exports.fish`, `alias.fish`) plus 60+ functions.
- **gh CLI config**: `config/gh/hosts.yml` is managed by `gh` CLI
  and excluded from prettier (see `.prettierignore`).
- **Python**: Two scripts (`x-compare-versions.py`,
  `x-git-largest-files.py`) linted by Ruff (config in `pyproject.toml`).
- **Fish secrets**: `config/fish/secrets.d/*.fish` files are auto-sourced
  by `exports.fish`. Copy `github.fish.example` → `github.fish` for local
  secrets. These files are gitignored; only `*.example` and `README.md`
  are tracked.

## Claude Code Configuration

- **Hooks** (`.claude/settings.json`):
  - *PreToolUse*: Blocks edits to `fzf-tmux`, `yarn.lock`,
    `.yarn/`, submodule paths, and real secrets.d files
  - *PostToolUse*: Auto-formats files by extension
    (shfmt, fish_indent, stylua, biome, prettier)
  - *PostToolUse*: Validates Dotbot `install.conf.yaml`
    after edits
  - *PostToolUse*: Warns on formatter/linter config changes
  - *Stop*: Runs `yarn lint` gate before finishing
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

## Package Manager

Yarn (v4+) is the package manager. Do not use npm.

# context-mode — MANDATORY routing rules

You have context-mode MCP tools available. These rules are NOT optional —
they protect your context window from flooding. A single unrouted command
can dump 56 KB into context and waste the entire session.

## BLOCKED commands — do NOT attempt these

### curl / wget — BLOCKED
Any Bash command containing `curl` or `wget` is intercepted and replaced with an error message. Do NOT retry.
Instead use:
- `ctx_fetch_and_index(url, source)` to fetch and index web pages
- `ctx_execute(language: "javascript", code: "const r = await fetch(...)")` to run HTTP calls in sandbox

### Inline HTTP — BLOCKED
Any Bash command containing `fetch('http`, `requests.get(`,
`requests.post(`, `http.get(`, or `http.request(` is intercepted
and replaced with an error message. Do NOT retry with Bash.
Instead use:
- `ctx_execute(language, code)` to run HTTP calls in sandbox — only stdout enters context

### WebFetch — BLOCKED
WebFetch calls are denied entirely. The URL is extracted and you are told to use `ctx_fetch_and_index` instead.
Instead use:
- `ctx_fetch_and_index(url, source)` then `ctx_search(queries)` to query the indexed content

## REDIRECTED tools — use sandbox equivalents

### Bash (>20 lines output)
Bash is ONLY for: `git`, `mkdir`, `rm`, `mv`, `cd`, `ls`, `npm install`, `pip install`, and other short-output commands.
For everything else, use:
- `ctx_batch_execute(commands, queries)` — run multiple commands + search in ONE call
- `ctx_execute(language: "shell", code: "...")` — run in sandbox, only stdout enters context

### Read (for analysis)
If you are reading a file to **Edit** it → Read is correct (Edit needs content in context).
If you are reading to **analyze, explore, or summarize** →
use `ctx_execute_file(path, language, code)` instead. Only your
printed summary enters context. The raw file stays in the sandbox.

### Grep (large results)
Grep results can flood context.
Use `ctx_execute(language: "shell", code: "grep ...")` to run
searches in sandbox. Only your printed summary enters context.

## Tool selection hierarchy

1. **GATHER**: `ctx_batch_execute(commands, queries)` — Primary
  tool. Runs all commands, auto-indexes output, returns search
  results. ONE call replaces 30+ individual calls.
2. **FOLLOW-UP**: `ctx_search(queries: ["q1", "q2", ...])` —
  Query indexed content. Pass ALL questions as array in ONE call.
3. **PROCESSING**: `ctx_execute(language, code)` |
  `ctx_execute_file(path, language, code)` — Sandbox execution.
  Only stdout enters context.
4. **WEB**: `ctx_fetch_and_index(url, source)` then
  `ctx_search(queries)` — Fetch, chunk, index, query.
  Raw HTML never enters context.
5. **INDEX**: `ctx_index(content, source)` — Store content in FTS5 knowledge base for later search.

## Subagent routing

When spawning subagents (Agent/Task tool), the routing block is
automatically injected into their prompt. Bash-type subagents are
upgraded to general-purpose so they have access to MCP tools.
You do NOT need to manually instruct subagents about context-mode.

## Output constraints

- Keep responses under 500 words.
- Write artifacts (code, configs, PRDs) to FILES — never return
  them as inline text. Return only: file path + 1-line description.
- When indexing content, use descriptive source labels so others can `ctx_search(source: "label")` later.

## ctx commands

| Command       | Action                                                                                |
|---------------|---------------------------------------------------------------------------------------|
| `ctx stats`   | Call the `ctx_stats` MCP tool and display the full output verbatim                    |
| `ctx doctor`  | Call the `ctx_doctor` MCP tool, run the returned shell command, display as checklist  |
| `ctx upgrade` | Call the `ctx_upgrade` MCP tool, run the returned shell command, display as checklist |
