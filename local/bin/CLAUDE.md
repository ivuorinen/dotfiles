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
into `local/bin/` works immediately, before `./install` links it. No
argument or `help`/`-h`/`--help` prints a menu with status 0; an unknown
section or subcommand prints an error and the menu on stderr and exits 2
(`dfm_fallback` in each section, the same check in the dispatcher), so a
renamed command in a script or install config fails loudly. Each section
lives in its own executable:

- `local/bin/dfm-{install,brew,apt,check,dotfiles,helpers,docs,scripts,tests,secrets,ssh,cleanup,theme}`
  — one file per section, each carrying its own `#USAGE` subtree.
- `local/bin/dfm-lib` — sourced (non-executable) shared library: the
  bootstrap family and the menu helpers (`menu_builder`, `dfm_menu`,
  `dfm_fallback`). Helpers one section uses live in that section
  (`secrets_*` in `dfm-secrets`). The missing exec bit keeps `dfm lib` from
  matching it and signals "source, don't run". Subcommands re-dispatch
  across sections via the `$DFM` variable it exports; same-section fan-out
  uses local function calls. Sections print through the external `msgr`
  command; dfm-lib does not source msgr.
  - Bootstrap is split for speed: `dfm_bootstrap_min` (variables only)
    serves menu/help paths and the commands that need no shell environment,
    while `dfm_bootstrap` also sources `config/shared.sh` (which pulls in
    `config/exports` — `mise activate`, `brew shellenv`, etc., ~200 ms).
    Most subcommands call `dfm_bootstrap_for "$@"`, which picks the cheap
    path for no-arg/help invocations and the full path for real actions;
    `dfm-docs`, `dfm-ssh`, `dfm-secrets` and `dfm-tests` always take the
    cheap path, and `dfm-check`/`dfm-theme` pick per command. There is no
    bash version guard: dfm runs on stock macOS bash 3.2, and
    `tests/dfm-lib.bats` rejects bash-4-only syntax in the dfm files.
  - Menus come from each section's `#USAGE` block (`dfm_menu`), the same
    spec the completions are generated from; the `dfm` listing renders
    every section in-process. `dfm-docs` and `dfm-scripts` build their
    menus from `docs/*.md` and `scripts/install-*.sh` instead.
  - Packages are one section, `dfm-packages`: `mise bootstrap packages`
    apply/status/upgrade for every manager the host has (apt, dnf, and
    Homebrew formulae and casks on macOS through mise, without the brew
    CLI). mise skips managers the host lacks, so no section is tool-gated.
    `prune` is deliberately absent: it would uninstall phpenv's PHP.

Completions/docs/manpages: `scripts/install-completions.sh` stitches the
per-section `#USAGE` fragments into one `dfm` spec (skipping `dfm`/`dfm-*`
in its per-file loop), so the single `dfm` completion tree still covers
every section. Key commands:

- `dfm install all` — Xcode CLI tools (macOS), then `mise bootstrap` (the
  declared packages, macOS defaults, the login shell; packages skipped
  without sudo), the mise tools, fonts (Linux), cheat databases, gh
  extensions and completions; exits 1 naming any failed step
- `dfm packages apply` / `status` / `upgrade` — the packages mise declares
  (`config/mise/conf.d/`); apply and upgrade skip without sudo rights
- `dfm dotfiles fmt` / `dfm dotfiles shfmt` — run `mise run fix` and then
  the prek `shfmt` hook, or the hook alone (the commit gate's own formatter
  and flags, not a second copy)
- `dfm dotfiles reset-nvim` — delete nvim's XDG data, state, cache and
  config, relink the config, reinstall the mise tools
- `dfm cleanup old-vms [--dry-run]` and the other cleanup steps fail when a
  tool fails, so `dfm cleanup all` reports it
- `dfm helpers <name>` — inspect aliases, colors, env, functions, path;
  `dfm helpers docs-*` (docs-aliases/nvim/tmux/wezterm/all) regenerate docs
- `dfm docs [name]` — list/show `docs/*.md` (glow → bat → cat; never
  scans `docs/audit/`)
- `dfm check arch` / `dfm check os` / `dfm check host` — the CPU
  (`uname -m`), the OS kernel name (`uname -s`) and the hostname
  (`uname -n`); with an argument, exit 0 on a match and 1 otherwise
- `dfm check perms [--fix]` — verify (or repair) the declared directory
  modes from `dotbot-links.yaml` plus a table of security-critical paths
  dotbot cannot express: the two `secrets.d` trees, `config/gh`,
  `config/git`, gnupg/aws/kube, and the secret files themselves at `0600`.
  `--fix` exists because dotbot's `create:` applies a mode only when it
  creates the path — it can establish a mode, never restore one. `./install`
  runs the `--fix` form last.
- `dfm scripts` — run `install-*.sh` scripts from `scripts/` (menu labels from `@description`)
- `dfm tests` — test visualization helpers
- `dfm theme family [name]` / `reset` / `mode` / `reapply [mode]` /
  `status` — list and switch families, print the mode, re-run every handler
  (`config/theme/apply --force`), and show the orchestrator's state. The
  engine stays in `config/theme/`; `theme-mode` stays the read API.
