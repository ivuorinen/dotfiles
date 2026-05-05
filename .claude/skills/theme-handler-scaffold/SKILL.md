---
name: theme-handler-scaffold
description: >-
  Scaffold a new theme handler in config/theme/handlers.d/<app>.
  Use when adding dark/light theme support for an app the
  orchestrator does not yet flip.
user-invocable: true
allowed-tools: Bash, Read, Write, Edit
---

Scaffolds a new entry in the theme orchestrator's handler chain. Per
`docs/audit/arch-profile.md` rules 1 and 2, each app gets:

- An executable handler at `config/theme/handlers.d/<app>` that
  receives `dark` or `light` as `$1` and applies the theme.
- One palette per variant under `config/theme/palettes.d/<app>.dark.<ext>`
  and `config/theme/palettes.d/<app>.light.<ext>` (extension matches
  the consuming format; omit when the format has no canonical
  extension).

## Inputs

- `<app>` — the app name (kebab-case, e.g. `alacritty`, `kitty`)
- `<ext>` — the palette file extension matching the app's config
  format (`toml`, `conf`, `yml`, etc.); omit for formats with no
  canonical extension (e.g. dircolors)

## Process

1. Reject if `config/theme/handlers.d/<app>` already exists.

2. Write the handler script with this template:

```bash
#!/usr/bin/env bash
# handlers.d/<app> — flip <app> to the requested theme variant.
set -uo pipefail

# shellcheck disable=SC1091
source "$(dirname -- "$0")/../_lib.sh"

mode="${1:-}"
[[ "$mode" = "dark" || "$mode" = "light" ]] || exit 2

src="${DOTFILES:-$HOME/.dotfiles}/config/theme/palettes.d/<app>.${mode}.<ext>"
[[ -r "$src" ]] || {
  echo "<app> handler: missing palette $src" >&2
  exit 1
}

# Apply theme: replace this with the app-specific flip command.
# Examples:
#   - cp "$src" "$XDG_CONFIG_HOME/<app>/active.<ext>"
#   - tmux source-file "$src"
#   - reload via app's IPC / signal

_atomic_write "$XDG_CONFIG_HOME/<app>/active.<ext>" "$(cat "$src")"
```

3. `chmod +x config/theme/handlers.d/<app>`.

4. Create stub palette files with a comment header:

```
# config/theme/palettes.d/<app>.dark.<ext>
# Catppuccin Mocha — fill in app-specific theme syntax here.
```

```
# config/theme/palettes.d/<app>.light.<ext>
# Catppuccin Latte — fill in app-specific theme syntax here.
```

5. Print:

    - Paths created
    - The reminder: "Update the handler body — the `_atomic_write`
      line is a placeholder. Most apps need their own reload
      command (e.g. `tmux source-file`, `kitty @ load-config`).
      The orchestrator forks every handler in parallel under a 5 s
      timeout; if your reload blocks, wrap it with `&` or
      short-circuit on failure."
    - Test command: `config/theme/apply dark` then
      `config/theme/apply light` to verify the handler fires.

## Conventions enforced

- Source `_lib.sh` for shared helpers (`_atomic_write`, etc.).
- Validate `$mode` is `dark` or `light`; exit 2 on garbage input.
- Read the palette file via `${DOTFILES:-$HOME/.dotfiles}` so the
  handler works regardless of how `apply` was invoked.
- Use `_atomic_write` for any destination file the user might
  re-read mid-flip (avoids partial-write corruption).
- Bash, not POSIX — handlers can use `[[`, arrays, etc.

## Verification

1. Run `config/theme/apply dark`; check the app reflects the dark
    palette.
2. Run `config/theme/apply light`; check the flip back works.
3. `bats tests/theme-handlers.bats` to confirm the orchestrator
    integration tests still pass.
4. Update the layout comments in any consumer files (e.g. tmux's
    theme-switch sourcing) to mention the new app.
