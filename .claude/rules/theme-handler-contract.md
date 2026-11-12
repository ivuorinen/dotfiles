---
description: "Theme apps register through handlers.d; palettes follow palettes.d/<family>/<mode>/<app>[.<ext>]."
paths:
  - "config/theme/**"
---

# Theme handler contract

- Never add a handler for an app that can draw in the terminal's 16 ANSI
  colours with no ANSI colour as a fill under text: give it one static
  config instead, and the terminal's scheme recolours it
  (`config/theme/CLAUDE.md`).
- Never special-case an app in `config/theme/apply` or
  `config/theme/watcher`. Add an executable
  `config/theme/handlers.d/<app>` instead (the
  `theme-handler-scaffold` skill writes one).
- Name palette files
  `config/theme/palettes.d/<family>/<dark|light>/<app>[.<ext>]`. The
  active family comes from `_theme_family`: the saved choice in
  `$XDG_STATE_HOME/dotfiles-theme/choice`, else the one word in
  `config/theme/family` (`DOTFILES_THEME_FAMILY` overrides both in tests).
- Resolve palettes with `_palette <mode> <file>` from `_lib.sh`, never
  by building the path by hand. When the active family ships no file,
  the handler must leave nothing from another family in place: a link
  handler removes its stale symlink (never a regular file), and
  state/composed handlers drop or rebuild their artifact without the
  palette. Palettes never mix across families.
  `tests/theme-handlers.bats` fails on any `palettes.d` literal in a code
  line of a handler or `tmux-palette`.
- A new family must ship the same file set as the others, in both
  modes; `tests/theme-palettes.bats` enforces it.
