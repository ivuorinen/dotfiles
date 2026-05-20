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

## Manual verification

No automated hook enforces this rule. Run the following grep before
opening a PR that touches `config/nvim/`:

```bash
# Two-argument K.* calls (missing the opts/desc argument) are bugs.
grep -nrE '\bK\.(n|nl|d|ld)\(\s*"[^"]*"\s*,\s*[^,)]+\)\s*$' config/nvim/ \
  | grep -v utils.lua
```

A non-empty result is a regression. The `utils.lua` exclusion covers
the K-table definition itself.
