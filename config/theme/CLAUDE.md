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
  handler run it rewrites `generation`, the stamp open shells compare at
  each prompt before reloading the colour caches.
- `config/theme/handlers.d/<app>` — per-app flip executables; a failure
  must exit non-zero with a stderr line (apply logs it). A missing tool
  is a skip: stderr note, exit 0. Add new apps by dropping a file here
  (`theme-handler-scaffold` skill).
- The active theme family (`_theme_family` in `_lib.sh`):
  `DOTFILES_THEME_FAMILY` (test seam; an invalid value fails closed),
  else the per-machine saved choice in `$XDG_STATE_HOME/dotfiles-theme/choice`
  (skipped when missing, empty or invalid), else the tracked default
  `config/theme/family` (`oasis`). apply only reads the saved choice, and
  deletes the `family` file older applies kept their record in.
  `local/bin/theme` lists the families and marks the active one, switches
  (`theme <family>`) and resets (`theme --reset`): it writes or removes the
  saved choice, then runs apply at the current mode.
- `config/theme/palettes.d/<family>/<dark|light>/<app>[.<ext>]` — theme
  assets, one tree per family (`catppuccin`, `kanagawa`, `oasis`,
  `warm-burnout`). A handler
  whose active family ships no file removes its stale link instead of
  keeping another family's palette.
- `config/theme/tmux-palette <mode>` — sources the active family's tmux
  palette; called by `config/tmux/tmux.conf`'s bootstrap. On a flip,
  `handlers.d/tmux` re-sources the whole `tmux.conf` (so the bootstrap
  must never call that handler back — it would recurse).
- `local/bin/theme-mode` (and bash/fish functions) — public read API for
  the mode; `local/bin/theme` — the public family switcher.
- Fallback: `config/theme/probe-osc11` — OSC 11 query for SSH and
  no-OS-source environments.

Open shells react to flips at their next prompt: bash and zsh through the
hook in `config/theme/shell-env.sh`, fish through
`config/fish/conf.d/theme-switch.fish` (which also re-saves its theme).
Both watch the `generation` stamp and reload LS_COLORS, BAT_THEME and the
fzf palette. fish (`__dotfiles_theme_name`), nvim,
vim and wezterm each resolve the family themselves, in `_theme_family`'s
order, and fall back to `oasis` (fish to no theme change) when nothing
resolves. nvim and vim follow the OS appearance;
wezterm follows the mode file (on its reload watch list), falling back to
the OS appearance when there is none. After a family switch, running vim
and nvim sessions update within 3 s, and wezterm reloads when apply
rewrites the mode file on its watch list.

Claude Code follows the mode, not the family. `handlers.d/claude` sets
`theme` to `custom:dotfiles` once and, on each flip, rewrites
`${CLAUDE_CONFIG_DIR:-~/.claude}/themes/dotfiles.json` with `base` set to
the mode. Running sessions reload that file live. They do not re-apply
`theme` from `settings.json`, and `"auto"` misses flips.
