---
paths:
  - "config/nvim/**/*.lua"
---

# Neovim keymap descriptions

Always pass a description when registering keymaps via the global
`K` table (`K.n`, `K.nl`, `K.d`, `K.ld` defined in
`config/nvim/lua/utils.lua`).

`opts` may be a string (converted to `{ desc = str }`) or a table.
Either form is acceptable, but the description must be present:
mini.clue surfaces it in the popup, and an omitted description leaves
the binding unlabelled in `<leader>?`.
