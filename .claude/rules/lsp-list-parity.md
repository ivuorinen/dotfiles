---
paths:
  - "config/nvim/init.lua"
  - "config/nvim/lsp/*.lua"
---

# LSP list parity

The `-- LSP` section of `init.lua` uses `mason-lspconfig` with
`automatic_enable = true`, which calls `vim.lsp.enable()` for every server mason
has installed. The explicit `vim.lsp.enable` block therefore contains **only** the
mise-managed exceptions — currently `fish_lsp` and `taplo`.

## Active server set

The active set of LSP servers is determined by two sources:
1. **`ensure_installed` in mason-tool-installer** — all mason-managed servers
    (using mason package names, e.g. `'bash-language-server'`).
2. **`vim.lsp.enable { 'fish_lsp', 'taplo' }`** — mise-managed servers only.

Do NOT add mason-managed servers to the bare `vim.lsp.enable` call. They are
auto-enabled by mason-lspconfig; adding them explicitly would double-enable them
(harmless but confusing).

## When adding a server

- If managed by mason: add it to `ensure_installed` (mason package name).
  mason-lspconfig will auto-enable it. Drop a `config/nvim/lsp/<name>.lua`
  only if the server needs custom `cmd`, `filetypes`, `root_markers`, or
  `settings`.
- If managed by mise: add the lspconfig server name to the bare
  `vim.lsp.enable { ... }` call in the `-- LSP` section of `init.lua`. Do NOT
  add it to `ensure_installed`.

## When removing a server

- If mason-managed: remove from `ensure_installed` and delete `lsp/<name>.lua`.
- If mise-managed: remove from `vim.lsp.enable` and delete `lsp/<name>.lua`.

## Verification

The only parity to check is that mise-managed exceptions are absent from
`ensure_installed` and present in `vim.lsp.enable`:

```bash
cd config/nvim && grep -E '"(fish_lsp|taplo)"' init.lua
# Expected: one match from vim.lsp.enable only, none from ensure_installed
```

The old diff-based check (ensure_installed vs vim.lsp.enable) no longer applies
and will produce false violations — do not run it.
