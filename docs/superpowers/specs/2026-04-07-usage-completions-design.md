# Usage KDL Specs, Shell Completions, Docs & Manpages

## Goal

Add `usage` CLI spec files (`.usage.kdl`) for all owned scripts, then
generate shell completions (fish, bash, zsh), markdown documentation,
and manpages. All generated artifacts are committed to the repo and
regenerated via a script.

## Scope

### Scripts receiving KDL specs

**local/bin/** — all scripts except:

- `fzf-tmux` (vendored from junegunn/fzf)
- `iterm2_shell_integration.zsh` (not ours)
- `README.md`, `raycast/`, `*.md` docs

This includes bash scripts, python (`.py`), perl (`.pl`), and php
(`.php`) scripts.

**scripts/*.sh** — all 17 scripts.

### File locations

| Artifact            | Path                                    | Destination                          |
|---------------------|-----------------------------------------|--------------------------------------|
| KDL specs (bin)     | `local/bin/<name>.usage.kdl`            | `~/.local/bin/` (existing glob link) |
| KDL specs (scripts) | `scripts/<name>.usage.kdl`              | Not linked (build-time only)         |
| Fish completions    | `config/fish/completions/<name>.fish`   | `~/.config/fish/completions/`        |
| Bash completions    | `config/bash/completions.d/<name>.bash` | `~/.config/bash/completions.d/`      |
| Zsh completions     | `config/zsh/completions.d/_<name>`      | `~/.config/zsh/completions.d/`       |
| Markdown docs       | `local/md/<name>.md`                    | Not linked (reference docs)          |
| Manpages            | `local/man/man1/<name>.1`               | `~/.local/man/man1/` (existing link) |
| Generator script    | `scripts/install-completions.sh`        | Not linked                           |

### Dotbot changes (install.conf.yaml)

- Add `~/.config/bash/completions.d` to `create:` block
- Add `~/.config/zsh/completions.d` to `create:` block
- Directories are already covered by the `config/*` glob link

### Shell integration

- **Fish**: Already works — auto-loads from `~/.config/fish/completions/`
- **Bash**: Add sourcing loop in `config/shared.sh` or `base/bashrc`:
  `for f in ~/.config/bash/completions.d/*.bash; do source "$f"; done`
- **Zsh**: Add `~/.config/zsh/completions.d` to `fpath` in zshrc
  before `compinit`

### scripts/install-completions.sh

- Has `@description` tag for `dfm scripts` discovery
- Requires `usage` CLI (installed via mise)
- Globs `local/bin/*.usage.kdl` and `scripts/*.usage.kdl`
- For each spec, extracts bin name from the KDL `bin` field
- Generates for each spec:
  - `usage generate completion {fish,bash,zsh} <bin> -f <spec>`
  - `usage generate markdown -f <spec> --out-file local/md/<bin>.md`
  - `usage generate manpage -f <spec> --out-file local/man/man1/<bin>.1`
- Reports summary of generated artifacts

### dfm integration

`dfm install all` calls `install-completions.sh` after the mise
installation step, so `usage` CLI is available.

## KDL spec approach

- **dfm**: Full subcommand tree — install (all, apt-packages,
  cheat-databases, composer, dnf-packages, fonts, gh, git-crypt,
  imagick, macos, mise, mise-cleanup, ntfy, python-libs, shellspec,
  xcode-cli-tools, z), apt (upkeep, install, update, upgrade,
  autoremove, clean), brew (install, update, updatebundle, autoupdate,
  leaves, clean, untracked), check (arch, host), dotfiles (fmt,
  yamlfmt, shfmt, reset_all, reset_nvim), helpers (aliases, colors,
  env, functions, nvim, path, tmux, wezterm), docs (all, tmux, nvim,
  wezterm), scripts (dynamic), tests (msgr, params)
- **Complex scripts** (a, git-attributes, git-update-dirs,
  x-gh-get-latest-version, x-sonarcloud, x-codeql, php-switcher,
  x-localip, x-thumbgen, etc.): Detailed flags, args, env vars
- **Simple scripts** (x-hr, x-ip, x-term-colors, x-welcome-banner):
  Minimal specs — just `bin` and `about`
- **msgr**: Subcommands for msg, run, yay, err, warn
- **scripts/*.sh**: Most take no args (install scripts), some have
  flags discovered during implementation

### Manpage & markdown notes

- `local/man/man1/` already exists with vendored pages (`fzf.1`,
  `fzf-tmux.1`) — Dotbot already links `local/man/**` to `~/.local/man/`
- `local/md/` is a new directory for generated markdown docs
- Manpages use section 1 (user commands) by default

## Not in scope

- Removing existing hand-written completions in `config/zsh/completion/`
  or `config/fish/completions/` — those are for external tools
