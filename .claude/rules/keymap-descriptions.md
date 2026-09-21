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

## Enforcement

The `keymap-desc` pre-commit hook runs `scripts/check-keymap-desc.py` on
every staged `config/nvim/**/*.lua` file. It parses each `K.*` call —
quotes, comments and inline `function … end` bodies included — and fails
when the opts argument is neither a string literal nor a table holding
`desc`. Run it by hand with `python3 scripts/check-keymap-desc.py`; exit 0
means every call is labelled.
