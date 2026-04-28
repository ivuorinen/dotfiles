# Neovim Config Trim & Reorganization

## Context

The nvim config at `config/nvim/` has grown to ~33 plugins across 11 files.
Several plugins are redundant with nvim 0.11 built-ins, LSP keymaps are
duplicated in three places, and the file organization doesn't reflect
logical dependencies. This spec covers trimming, migrating to native
nvim 0.11 APIs, and reorganizing the plugin files.

## Changes

### 1. Remove redundant plugins

| Plugin                              | File        | Why                                                                                |
|-------------------------------------|-------------|------------------------------------------------------------------------------------|
| `gpanders/editorconfig.nvim`        | conform.lua | nvim 0.11 native (`vim.g.editorconfig = true` already set)                         |
| `fatih/vim-go`                      | code.lua    | gopls configured in lsp.lua with full hints; vim-go's fmt/imports already disabled |
| `pablos123/shellcheck.nvim`         | code.lua    | bashls integrates shellcheck diagnostics via LSP                                   |
| `neovim/nvim-lspconfig`             | lsp.lua     | Replaced by native `vim.lsp.config()` + `vim.lsp.enable()`                         |
| `williamboman/mason-lspconfig.nvim` | lsp.lua     | Handler pattern is nvim-lspconfig-specific; not needed with native API             |

### 2. Migrate to native LSP configuration (nvim 0.11)

Replace the nvim-lspconfig + mason-lspconfig handler pattern with:

```lua
-- Set global capabilities (blink.cmp)
vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
})

-- Per-server config
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      diagnostics = { globals = { 'vim' }, disable = { 'missing-fields' } },
      completion = { callSnippet = 'Replace' },
      workspace = { checkThirdParty = true },
      hint = { enable = true, paramName = 'All', paramType = true },
    },
  },
  on_init = function(client)
    client.config.settings.Lua.workspace.library = { vim.env.VIMRUNTIME }
    client.config.settings.Lua.runtime = { version = 'LuaJIT' }
    client:notify('workspace/didChangeConfiguration', { settings = client.config.settings })
  end,
})

vim.lsp.config('gopls', {
  settings = {
    gopls = {
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
})

vim.lsp.config('intelephense', {
  init_options = {
    licenceKey = vim.env.INTELEPHENSE_LICENSE or GetIntelephenseLicense() or nil,
  },
})

vim.lsp.config('yamlls', {
  settings = {
    yaml = {
      keyOrdering = false,
      schemaStore = { enable = true },
    },
  },
})

-- Enable all servers (empty-config ones don't need vim.lsp.config calls)
vim.lsp.enable({
  'ansiblels', 'ast_grep', 'bashls', 'cssls', 'dockerls', 'eslint',
  'gopls', 'html', 'intelephense', 'jsonls', 'lua_ls', 'pyright',
  'tailwindcss', 'terraformls', 'ts_ls', 'vimls', 'yamlls',
})
```

**Keep in lsp.lua:**
- `mason.nvim` — still installs LSP servers and tools
- `mason-tool-installer.nvim` — ensures tools are auto-installed
- `mason-conform.nvim` — bridges mason and conform
- `lazydev` — Lua LSP enhancements
- `fidget.nvim` — LSP progress indicator
- Diagnostic config (signs, virtual text, float borders)
- LSP highlight autocmds (CursorHold/CursorMoved)

**Remove from lsp.lua:**
- The entire `LspAttach` keymap callback (lines 26-140) — nvim 0.11 provides
  `grn` (rename), `gra` (code action), `grr` (references), `gri` (implementations)
  natively
- `nvim-lspconfig` and `mason-lspconfig` requires and setup

### 3. Deduplicate LSP keymaps

**Three sources currently:**
1. `lsp.lua` LspAttach: `<leader>grn`, `<leader>gra`, `<leader>grr`, etc.
2. `keymaps.lua`: `<leader>ca`, `<leader>cd`, `<leader>ci`, `<leader>cr`, etc.
3. nvim 0.11 defaults: `grn`, `gra`, `grr`, `gri` (no leader prefix)

**After cleanup:**
- nvim 0.11 defaults handle basic LSP operations (rename, code action, references, implementations)
- `keymaps.lua` `<leader>c*` mappings kept for telescope-powered variants:
  - **Remove** `<leader>ca` (code action — duplicates `gra`)
  - **Remove** `<leader>cr` (rename — duplicates `grn`)
  - **Keep** `<leader>cd` (telescope definitions), `<leader>ci` (telescope implementations),
    `<leader>cf` (format), `<leader>cp` (type defs), `<leader>cs` (doc symbols),
    `<leader>ct` (treesitter), `<leader>cws/cwd` (workspace symbols),
    `<leader>cci/cco` (incoming/outgoing calls)
- `lsp.lua` LspAttach keymap block is removed entirely

### 4. Config cleanups

**noice.lua (folke.lua):**
- Remove `['cmp.entry.get_documentation'] = true` — references nvim-cmp, not blink.cmp

**catppuccin (ui.lua):**
- Remove `cmp = true` — uses blink.cmp, not nvim-cmp
- Remove `gitsigns = true` — uses mini.git/mini.diff, not gitsigns
- Remove `nvimtree = true` — uses neo-tree, not nvim-tree
- Remove `notify = false` — already false/default

### 5. Reorganize plugin files

**Current (11 files):** blink.lua, code.lua, conform.lua, folke.lua, lsp.lua,
mini.lua, neotree.lua, other.lua, telescope.lua, treesitter.lua, ui.lua

**New (8 files):**

| File             | Plugins                                                                                                               | Rationale                                              |
|------------------|-----------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------|
| `lsp.lua`        | mason, mason-tool-installer, mason-conform, lazydev, fidget, native vim.lsp.config                                    | LSP server management                                  |
| `completion.lua` | blink.cmp, blink.compat, blink-cmp-copilot, copilot.lua                                                               | Completion engine (renamed from blink.lua for clarity) |
| `editor.lua`     | mini.nvim (17 modules), vim-sleuth, hardtime.nvim                                                                     | Editing behavior and text manipulation                 |
| `ui.lua`         | catppuccin, auto-dark-mode, nvim-colorizer, virt-column, noice, nvim-notify, nui, transparent.nvim                    | Visual appearance and UI chrome                        |
| `navigation.lua` | telescope, telescope-lazy-plugins, neo-tree, nvim-window-picker, fff.nvim, stickybuf, trouble.nvim, nvim-web-devicons | Finding, browsing, and navigating                      |
| `treesitter.lua` | nvim-treesitter                                                                                                       | Syntax (unchanged)                                     |
| `conform.lua`    | conform.nvim                                                                                                          | Formatting (unchanged, editorconfig.nvim removed)      |
| `tools.lua`      | vim-wakatime, nvim-shellspec, comment-box.nvim, plenary.nvim                                                          | Misc tools and utilities                               |

**Migration approach:** Create new files, move plugin specs, delete old files.
All in one commit to keep git history clean.

## Files to modify

| File                         | Action                                                                                     |
|------------------------------|--------------------------------------------------------------------------------------------|
| `lua/plugins/lsp.lua`        | Rewrite: native vim.lsp.config, remove lspconfig/mason-lspconfig, remove LspAttach keymaps |
| `lua/plugins/blink.lua`      | Rename to `lua/plugins/completion.lua`                                                     |
| `lua/plugins/code.lua`       | Delete (contents split to editor.lua and tools.lua)                                        |
| `lua/plugins/folke.lua`      | Delete (contents moved to ui.lua and navigation.lua)                                       |
| `lua/plugins/mini.lua`       | Delete (contents moved to editor.lua)                                                      |
| `lua/plugins/neotree.lua`    | Delete (contents moved to navigation.lua)                                                  |
| `lua/plugins/other.lua`      | Delete (contents moved to tools.lua)                                                       |
| `lua/plugins/telescope.lua`  | Delete (contents moved to navigation.lua)                                                  |
| `lua/plugins/ui.lua`         | Rewrite: merge visual plugins, fix catppuccin integrations                                 |
| `lua/plugins/conform.lua`    | Edit: remove editorconfig.nvim entry                                                       |
| `lua/plugins/treesitter.lua` | Unchanged                                                                                  |
| `lua/plugins/editor.lua`     | New: mini.nvim + vim-sleuth + hardtime                                                     |
| `lua/plugins/navigation.lua` | New: telescope + neo-tree + fff + stickybuf + trouble                                      |
| `lua/plugins/tools.lua`      | New: wakatime + shellspec + comment-box + plenary                                          |
| `lua/keymaps.lua`            | Edit: remove telescope-powered LSP maps that duplicate nvim 0.11 defaults                  |
| `lua/autogroups.lua`         | Unchanged                                                                                  |
| `lua/options.lua`            | Unchanged                                                                                  |
| `lua/utils.lua`              | Unchanged                                                                                  |
| `init.lua`                   | Unchanged (lazy auto-discovers lua/plugins/)                                               |

## Verification

1. Open nvim — no errors on startup (`nvim --startuptime /tmp/nvim-startup.log`)
2. `:checkhealth` — verify LSP servers attach correctly
3. `:LspInfo` or `:lua vim.print(vim.lsp.get_clients())` — confirm servers start
4. Test LSP keymaps: `grn` (rename), `gra` (code action), `grr` (references)
5. Test `<leader>c*` keymaps still work via telescope
6. `:Lazy` — verify all plugins load without errors
7. Open a Go file — confirm gopls attaches with hints
8. Open a Lua file — confirm lua_ls attaches, lazydev works
9. Open a shell script — confirm bashls attaches with shellcheck diagnostics
10. Test format-on-save (`:w` in a Lua file should trigger stylua)
11. `:Telescope` — verify telescope + extensions still work
12. `:Neotree toggle` — verify file explorer works
