# Theme orchestrator

Dark/light theming is owned by a stand-alone orchestrator:

- `config/theme/watcher` — self-locking daemon, spawned from shell init
  (skipped in SSH sessions). Subscribes to portal/gsettings on Linux,
  polls `defaults read` on macOS. If a Linux monitor stream ends it logs
  an ERROR and exits 1; the next interactive shell respawns it.
- `config/theme/apply <mode>` — actor; atomic-writes
  `$XDG_STATE_HOME/dotfiles-theme/mode` (and `family`) and forks each
  `handlers.d/<name>` in parallel under a 5s timeout. It skips only when
  both mode and family are unchanged (an unresolvable family is recorded
  as `-`, so it is unchanged too). A failed or timed-out handler is
  listed in `retry`; an unchanged apply re-runs only those handlers, at
  most once per 10 minutes (the file's mtime is the backoff clock).
  Every apply that writes `mode`, `family` or `retry` holds
  `apply.lock` (`_acquire_lock`) and decides under it, so concurrent
  shells start one retry per window and a flip waits for a running
  retry instead of racing it. A retry that finds the lock held exits 0;
  a flip that cannot get it within 10 s logs a WARN and exits 1 without
  applying.
- `config/theme/handlers.d/<app>` — per-app flip executables; a failure
  must exit non-zero with a stderr line (apply logs it). A missing tool
  is a skip: stderr note, exit 0. Add new apps by dropping a file here
  (`theme-handler-scaffold` skill).
- `config/theme/family` — the active theme family, one word
  (`oasis`). Switch with an edit plus `config/theme/apply
  "$(theme-mode)"`. `DOTFILES_THEME_FAMILY` overrides it (test seam).
- `config/theme/palettes.d/<family>/<dark|light>/<app>[.<ext>]` — theme
  assets, one tree per family (`catppuccin`, `kanagawa`, `oasis`). A handler
  whose active family ships no file removes its stale link instead of
  keeping another family's palette.
- `config/theme/tmux-palette <mode>` — sources the active family's tmux
  palette; called by `config/tmux/tmux.conf`'s bootstrap. On a flip,
  `handlers.d/tmux` re-sources the whole `tmux.conf` (so the bootstrap
  must never call that handler back — it would recurse).
- `local/bin/theme-mode` (and bash/fish functions) — public read API.
- Fallback: `config/theme/probe-osc11` — OSC 11 query for SSH and
  no-OS-source environments.

Fish reacts to flips via `config/fish/conf.d/theme-switch.fish`,
which watches the mode state file. nvim, vim and wezterm read
`config/theme/family` directly. nvim and vim follow the OS appearance;
wezterm follows the mode file (on its reload watch list), falling back to
the OS appearance when there is none. After a family switch, running vim
sessions update within 3 s and wezterm on its next config reload; nvim
reads the family only at startup and needs a restart.

Claude Code follows the mode, not the family. `handlers.d/claude` sets
`theme` to `custom:dotfiles` once and, on each flip, rewrites
`${CLAUDE_CONFIG_DIR:-~/.claude}/themes/dotfiles.json` with `base` set to
the mode. Running sessions reload that file live. They do not re-apply
`theme` from `settings.json`, and `"auto"` misses flips.
