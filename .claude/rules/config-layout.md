---
description: "App configuration lives in config/<app>/; top-level config/ files are shell entry points only."
paths:
  - "config/*"
---

# config/ layout

Put an app's configuration in `config/<app>/`, one directory per app.
Never add a new top-level file to `config/` unless it is a cross-cutting
shell entry point on the level of `shared.sh`, `lib.sh`, `exports`, or
`alias`.
