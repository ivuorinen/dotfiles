# theme-mode

Print the theme orchestrator's current dark/light state.

## Usage

```bash
theme-mode          # prints "dark" or "light" to stdout
```

Takes no arguments and always exits 0, so callers can inline the
result in conditionals or command substitutions:

```bash
[ "$(theme-mode)" = "light" ] && echo "wear sunglasses"
apply "$(theme-mode)"
```

## Resolution order

1. `$XDG_STATE_HOME/dotfiles-theme/mode` — canonical state file
    written by `config/theme/apply` (and refreshed by the watcher).
2. `config/theme/probe-osc11` against `/dev/tty` — only when stdin
    is a TTY (skips cron, CI, and piped scripts to avoid blocking).
3. Literal `dark` — fail-safe default when the state file is
    missing/invalid and no terminal is available to probe.

## Related

- `config/theme/apply <mode>` — write the state and fire handlers.
- `config/theme/watcher` — daemon that calls `apply` on OS changes.
- `theme_mode` shell function in `config/exports` — non-forking
  bash/zsh twin used by hot prompt paths.

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
