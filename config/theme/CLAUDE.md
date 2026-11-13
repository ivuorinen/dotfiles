# Theme orchestrator

Dark/light theming is owned by a stand-alone orchestrator:

- `config/theme/watcher` — self-locking daemon, spawned from shell init
  (skipped in SSH sessions). Subscribes to portal/gsettings on Linux,
  polls `defaults read` on macOS. If a Linux monitor stream ends it logs
  an ERROR and exits 1; the next interactive shell respawns it.
- Locks: the watcher's `daemon.pid` and apply's `apply.lock` are kernel
  flock(2) locks on fd 9 (`_acquire_lock`: flock(1), else macOS
  lockf(1)), so a killed holder never leaves one held. The pid inside is
  diagnostic only. Never unlink either file: a process that opened the
  old inode would lock it beside a new holder of the path.
- `config/theme/apply <mode>` — actor; atomic-writes
  `$XDG_STATE_HOME/dotfiles-theme/mode` (and its own record of the family,
  `applied-family`) and forks each `handlers.d/<name>` in parallel under a
  5s timeout. It skips only when both mode and family are unchanged (an
  unresolvable family is recorded as `-`, so it is unchanged too). A
  failed or timed-out handler is listed in `retry`; an unchanged apply
  re-runs only those handlers, at most once per 10 minutes (the file's
  mtime is the backoff clock). Every apply that writes `mode`,
  `applied-family` or `retry` holds `apply.lock` (`_acquire_lock`) and
  resolves the family and decides again under it, so concurrent shells
  start one retry per window, a flip waits for a running retry instead of
  racing it, and racing family switches settle on the last saved choice.
  A retry that finds the lock held exits 0; a flip that cannot get it
  within 10 s logs a WARN and exits 1 without applying. After every
  handler run it rewrites `generation`, a stamp a reader can compare to
  notice that a flip finished.
- The terminal owns the palette. An app that draws in the terminal's 16
  ANSI colours, with no ANSI colour as a fill under text, is recoloured by
  the terminal's scheme (one per family and mode) at draw time, running
  processes included, so it gets one static config and no handler: bat
  (`config/bat/config`), eza and ls (their built-in defaults), fzf
  (`FZF_DEFAULT_OPTS`), gitui (`config/gitui/theme.ron`), starship
  (`config/starship/starship.toml`) and fish (its built-in `default` theme,
  chosen in `config/fish/config.fish`). No ANSI colour reads as a fill in
  every family (the light schemes tune all 16 as text), so these configs
  drop the fills: no current-line background, reversed selections.
- `config/theme/handlers.d/<app>` — per-app flip executables, only for apps
  that cannot draw that way: tmux (status-bar surface shades), gh-dash and
  television (selection fills their configs cannot drop) and claude (the
  mode word). A failure must exit non-zero with a stderr line (apply logs
  it). A missing tool is a skip: stderr note, exit 0. Add new apps by
  dropping a file here (`theme-handler-scaffold` skill).
- The active theme family (`_theme_family` in `_lib.sh`):
  `DOTFILES_THEME_FAMILY` (test seam; an invalid value fails closed),
  else the per-machine saved choice in `$XDG_STATE_HOME/dotfiles-theme/choice`
  (skipped when missing, empty or invalid), else the tracked default
  `config/theme/family` (`oasis`). apply only reads the saved choice, and
  deletes the `family` file older applies kept their record in.
  `dfm theme family` lists the families and marks the active one, switches
  (`dfm theme family <name>`) and resets (`dfm theme reset`): it writes or
  removes the saved choice, then runs apply at the current mode.
  `dfm theme reapply [mode]` runs `apply --force`, which runs every handler
  even when nothing changed (after a palette edit), and `dfm theme status`
  shows the mode, the family and its source, the watcher and pending retries.
- `config/theme/palettes.d/<family>/<dark|light>/<app>[.<ext>]` — the
  assets of the apps that keep a handler, one tree per family
  (`catppuccin`, `kanagawa`, `oasis`, `warm-burnout`), plus each family's
  colour-role map in `palettes.d/<family>/ROLES.md`. A handler whose active
  family ships no file drops or rebuilds its artifact without it instead of
  keeping another family's palette.
- `config/theme/tmux-palette <mode>` — loads the catppuccin/tmux status
  engine with `config/tmux/catppuccin.conf` and the active family's
  `tmux.thm.conf` (a family without one keeps the flavour's upstream
  colours); called by `config/tmux/tmux.conf`'s bootstrap. On a flip,
  `handlers.d/tmux` re-sources the whole `tmux.conf` (so the bootstrap
  must never call that handler back — it would recurse).
- `local/bin/theme-mode` (and bash/fish functions) — public read API for
  the mode; `local/bin/dfm-theme` (`dfm theme`) — the user-facing commands.
  The engine stays here; dfm only calls it.
- Fallback: `config/theme/probe-osc11` — OSC 11 query for SSH and
  no-OS-source environments.

Open shells need nothing on a flip: the ANSI-drawn apps take their colours
from the terminal when they draw. nvim, vim and wezterm each resolve the
family themselves, in `_theme_family`'s order, and fall back to `oasis` when
nothing resolves. nvim and vim follow the OS appearance;
wezterm follows the mode file (on its reload watch list), falling back to
the OS appearance when there is none. After a family switch, running vim
and nvim sessions update within 3 s, and wezterm reloads when apply
rewrites the mode file on its watch list.

Claude Code follows the mode, not the family. `handlers.d/claude` sets
`theme` to `custom:dotfiles` once and, on each flip, rewrites
`${CLAUDE_CONFIG_DIR:-~/.claude}/themes/dotfiles.json` with `base` set to
the mode. Running sessions reload that file live. They do not re-apply
`theme` from `settings.json`, and `"auto"` misses flips. Its `*-ansi` bases
would follow the family, but paint diffs as ANSI fills.

Copilot CLI needs no handler: `config/copilot/settings.json` sets `theme`
to `default` ("Base-16 terminal colors"), which builds every colour from
the terminal's OSC 10/11/4 replies and falls back to ANSI names without
them. Keep it off `github`, the shipped default: it hard-codes `#ffffff` /
`#0D1117` and writes the terminal background itself.
