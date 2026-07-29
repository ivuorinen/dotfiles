# Theme orchestrator

Dark/light theming is owned by a stand-alone orchestrator:

- `config/theme/watcher` — self-locking daemon, spawned from shell init
  (skipped in SSH sessions). Subscribes to portal/gsettings on Linux,
  polls `defaults read` on macOS.
- `config/theme/apply <mode>` — actor; atomic-writes
  `$XDG_STATE_HOME/dotfiles-theme/mode` and forks each
  `handlers.d/<name>` in parallel under a 5s timeout.
- `config/theme/handlers.d/{tmux,starship,fish,dircolors}` — per-app
  flip executables. Add new apps by dropping a file here.
- `config/theme/palettes.d/[app].[variant].[ext]` — theme assets,
  consolidated in one place.
- `local/bin/theme-mode` (and bash/fish functions) — public read API.
- Fallback: `config/theme/probe-osc11` — OSC 11 query for SSH and
  no-OS-source environments.

Fish reacts to flips via `config/fish/conf.d/theme-switch.fish`,
which watches the mode state file.
