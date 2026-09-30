# Theme orchestrator

Dark/light theming is owned by a stand-alone orchestrator:

- `config/theme/watcher` — self-locking daemon, spawned from shell init
  (skipped in SSH sessions). Subscribes to portal/gsettings on Linux,
  polls `defaults read` on macOS.
- `config/theme/apply <mode>` — actor; atomic-writes
  `$XDG_STATE_HOME/dotfiles-theme/mode` (and `family`) and forks each
  `handlers.d/<name>` in parallel under a 5s timeout. It skips only when
  both mode and family are unchanged.
- `config/theme/handlers.d/<app>` — per-app flip executables. Add new
  apps by dropping a file here (`theme-handler-scaffold` skill).
- `config/theme/family` — the active theme family, one word
  (`kanagawa`). Switch with an edit plus `config/theme/apply
  "$(theme-mode)"`. `DOTFILES_THEME_FAMILY` overrides it (test seam).
- `config/theme/palettes.d/<family>/<dark|light>/<app>[.<ext>]` — theme
  assets, one tree per family (`catppuccin`, `kanagawa`). A handler
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
`config/theme/family` directly and follow the OS appearance. After a
family switch, running vim sessions update within 3 s and wezterm on its
next config reload; nvim reads the family only at startup and needs a
restart.
