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
- One palette per mode, per theme family, under
  `config/theme/palettes.d/<family>/dark/<app>.<ext>` and
  `config/theme/palettes.d/<family>/light/<app>.<ext>` (extension
  matches the consuming format; omit when the format has no canonical
  extension). Every family under `palettes.d/` needs both, or
  `tests/theme-palettes.bats` fails.

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
_theme_family > /dev/null || exit 1

# Empty when the active family ships no palette for this app/mode.
src="$(_palette "$mode" <app>.<ext>)" || src=""
dst="$HOME/.config/<app>/theme.<ext>"

# Apply theme: replace this with the app-specific flip. The default
# links the palette, or removes a stale link from another family when
# the active one ships none. For a composed or state-dir artifact,
# rebuild it without the palette (or delete it) in the empty-src case.
mkdir -p -- "$(dirname -- "$dst")"
_link_palette "$src" "$dst"
```

3. `chmod +x config/theme/handlers.d/<app>`.

4. Create a stub palette for every family and mode, e.g.:

```
# config/theme/palettes.d/<family>/dark/<app>.<ext>
# <Family> dark variant — fill in app-specific theme syntax here.
```

```
# config/theme/palettes.d/<family>/light/<app>.<ext>
# <Family> light variant — fill in app-specific theme syntax here.
```

Add `<app>.<ext>` to `REQUIRED` in `tests/theme-palettes.bats`.

5. Print:

    - Paths created
    - The reminder: "Update the handler body — the `_link_palette`
      line is a placeholder. Most apps need their own reload
      command (e.g. `tmux source-file`, `kitty @ load-config`).
      The orchestrator forks every handler in parallel under a 5 s
      timeout; if your reload blocks, wrap it with `&` or
      short-circuit on failure."
    - Test command: `config/theme/apply dark` then
      `config/theme/apply light` to verify the handler fires.

## Conventions enforced

- Source `_lib.sh` for shared helpers (`_palette`, `_link_palette`,
  `_atomic_write`, etc.).
- Validate `$mode` is `dark` or `light`; exit 2 on garbage input.
- Exit 1 without touching anything when `_theme_family` fails.
- Resolve the palette with `_palette`, never a hand-built path, and
  handle the "family ships none" case so palettes never mix.
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
