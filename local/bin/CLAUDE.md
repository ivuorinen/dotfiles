# CLAUDE.md — `local/bin/`

Helper scripts and the `dfm` dotfiles manager. Loaded when working
with files under `local/bin/`.

## dfm — Dotfiles Manager

`local/bin/dfm` is a thin **git-style dispatcher**: `dfm <section>
<args>` resolves and execs `dfm-<section>` (sibling of the dispatcher
first, then `$PATH`), mirroring how git finds `git-<command>`. The
dispatcher resolves `$0` through any symlinks first, so "the folder it
is in" is the script's real location (the repo's `local/bin`) even when
invoked via a `~/.local/bin/dfm` symlink — dropping a new `dfm-<sub>`
into `local/bin/` works immediately, before `./install` links it. Each
section lives in its own executable:

- `local/bin/dfm-{install,brew,apt,check,dotfiles,helpers,docs,scripts,tests,secrets,ssh,cleanup}`
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
- `dfm docs [name]` — list/show `docs/*.md` (glow → bat → cat; never
  scans `docs/audit/`)
- `dfm check arch` / `dfm check host` — system info
- `dfm scripts` — run `install-*.sh` scripts from `scripts/` (menu labels from `@description`)
- `dfm tests` — test visualization helpers
