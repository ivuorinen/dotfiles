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

Verification (run from the repo root):

```bash
cd config/nvim && diff \
  <(awk '/ensure_installed = \{/,/^[[:space:]]*\}/' lua/plugins/lsp.lua \
      | grep -oE '"[a-z_]+"' | sort -u) \
  <(awk '/vim\.lsp\.enable \{/,/^[[:space:]]*\}/' init.lua \
      | grep -oE '"[a-z_]+"' | sort -u)
```

The diff must contain only the mise-managed exceptions (currently
`fish_lsp` and `taplo`). The `awk` range scopes the grep to the
relevant table so settings keys, log levels, and unrelated string
literals do not appear as false drift.
