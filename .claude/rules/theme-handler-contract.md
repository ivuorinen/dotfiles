---
description: "Theme apps register through handlers.d; palettes follow palettes.d/<family>/<mode>/<app>[.<ext>]."
paths:
  - "config/theme/**"
---

# Theme handler contract

- Never special-case an app in `config/theme/apply` or
  `config/theme/watcher`. Add an executable
  `config/theme/handlers.d/<app>` instead (the
  `theme-handler-scaffold` skill writes one).
- Name palette files
  `config/theme/palettes.d/<family>/<dark|light>/<app>[.<ext>]`. The
  active family is the one word in `config/theme/family`
  (`DOTFILES_THEME_FAMILY` overrides it in tests).
- Resolve palettes with `_palette <mode> <file>` from `_lib.sh`, never
  by building the path by hand. When the active family ships no file,
  the handler must leave nothing from another family in place:
  `_link_palette "" <dst>` removes a stale symlink (never a regular
  file), and state/composed handlers drop or rebuild their artifact
  without the palette. Palettes never mix across families.
  `tests/theme-handlers.bats` fails on any `palettes.d` literal in a code
  line of a handler or `tmux-palette`.
- A new family must ship the same file set as the others, in both
  modes; `tests/theme-palettes.bats` enforces it.
