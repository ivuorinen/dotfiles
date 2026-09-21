---
description: "Theme apps register through handlers.d; palettes follow palettes.d/<app>.<variant>[.<ext>]."
paths:
  - "config/theme/**"
---

# Theme handler contract

- Never special-case an app in `config/theme/apply` or
  `config/theme/watcher`. Add an executable
  `config/theme/handlers.d/<app>` instead (the
  `theme-handler-scaffold` skill writes one).
- Name palette files `config/theme/palettes.d/<app>.<dark|light>[.<ext>]`.
