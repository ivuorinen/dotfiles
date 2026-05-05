---
paths:
  - "config/nvim/lua/plugins/lsp.lua"
  - "config/nvim/init.lua"
  - "config/nvim/lsp/*.lua"
---

# LSP list parity

The `ensure_installed` list in `config/nvim/lua/plugins/lsp.lua`
(mason-tool-installer) and the `vim.lsp.enable {...}` list in
`config/nvim/init.lua` must stay in sync, modulo the mise-installed
servers — currently `fish_lsp` and `taplo`, which are present in the
`vim.lsp.enable` list but not in `ensure_installed` because mise
manages their binaries.

When adding a server: add it to `vim.lsp.enable {...}` AND to
`ensure_installed` (unless it comes from mise). Drop a matching
`config/nvim/lsp/<name>.lua` if the server needs custom `cmd`,
`filetypes`, `root_markers`, or `settings`.

When removing a server: drop it from BOTH lists and delete the
matching `lsp/<name>.lua`.

Verification: `diff <(grep -oE '\"[a-z_]+\"' lua/plugins/lsp.lua)
<(grep -oE '\"[a-z_]+\"' init.lua)` should differ only by the
mise-managed exceptions.
