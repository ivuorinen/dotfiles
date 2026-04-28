# Neovim Config Trim & Reorganization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Trim redundant plugins, migrate to native nvim 0.11 LSP config, deduplicate keymaps, and reorganize plugin files from 11 to 8.

**Architecture:** Remove 5 plugins (editorconfig.nvim, vim-go, shellcheck.nvim, nvim-lspconfig, mason-lspconfig.nvim). Replace nvim-lspconfig handler pattern with native `vim.lsp.config()` + `vim.lsp.enable()`. Consolidate 11 plugin files into 8 grouped by concern. Deduplicate LSP keymaps to rely on nvim 0.11 defaults.

**Tech Stack:** Neovim 0.11, Lua, lazy.nvim, mason.nvim, blink.cmp

---

### Task 1: Remove editorconfig.nvim from conform.lua

**Files:**
- Modify: `config/nvim/lua/plugins/conform.lua:72-76`

- [ ] **Step 1: Remove the editorconfig.nvim plugin spec**

Edit `config/nvim/lua/plugins/conform.lua` — remove lines 72-76:

```lua
-- REMOVE this entire block:
  {
    'gpanders/editorconfig.nvim',
    lazy = false,
  },
```

The file should end after the closing `}` of the conform.nvim spec (line 71). The final file should return only the conform.nvim spec (a single-element table).

- [ ] **Step 2: Verify nvim starts without errors**

Run: `nvim --headless -c 'qall' 2>&1`
Expected: No errors. `vim.g.editorconfig = true` in options.lua handles this natively.

- [ ] **Step 3: Commit**

```bash
git add config/nvim/lua/plugins/conform.lua
git commit -m "refactor(nvim): remove editorconfig.nvim, use nvim 0.11 built-in"
```

---

### Task 2: Rewrite lsp.lua — native vim.lsp.config + remove plugins

**Files:**
- Rewrite: `config/nvim/lua/plugins/lsp.lua`

- [ ] **Step 1: Write the new lsp.lua**

Replace the entire content of `config/nvim/lua/plugins/lsp.lua` with:

```lua
-- ╭─────────────────────────────────────────────────────────╮
-- │               LSP Setup and configuration               │
-- ╰─────────────────────────────────────────────────────────╯

require 'utils'

return {
  {
    'williamboman/mason.nvim',
    lazy = false,
    opts = {},
  },

  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'saghen/blink.cmp',
    },
    config = function()
      require('mason-tool-installer').setup {
        auto_install = true,
        auto_update = true,
        ensure_installed = {
          -- LSP servers
          'ansiblels',
          'ast-grep',
          'bash-language-server',
          'css-lsp',
          'dockerfile-language-server',
          'eslint-lsp',
          'gopls',
          'html-lsp',
          'intelephense',
          'json-lsp',
          'lua-language-server',
          'pyright',
          'tailwindcss-language-server',
          'terraform-ls',
          'typescript-language-server',
          'vim-language-server',
          'yaml-language-server',
          -- Tools
          'actionlint',
          'shfmt',
          'stylua',
          'shellcheck',
        },
      }

      -- ╭─────────────────────────────────────────────────────────╮
      -- │     Native LSP configuration (nvim 0.11+)              │
      -- │     Uses vim.lsp.config() + vim.lsp.enable()           │
      -- ╰─────────────────────────────────────────────────────────╯

      -- Set global capabilities from blink.cmp for all LSP servers
      vim.lsp.config('*', {
        capabilities = require('blink.cmp').get_lsp_capabilities(),
      })

      -- ── Per-server configuration ──────────────────────────────
      vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' },
        disable = { 'missing-fields' },
      },
      completion = { callSnippet = 'Replace' },
      workspace = { checkThirdParty = true },
      hint = {
        enable = true,
        arrayIndex = 'Auto',
        await = true,
        paramName = 'All',
        paramType = true,
        semicolon = 'SameLine',
        setType = false,
      },
    },
  },
  on_init = function(client)
    client.config.settings.Lua.workspace.library = {
      vim.env.VIMRUNTIME,
    }
    client.config.settings.Lua.runtime = { version = 'LuaJIT' }
    client:notify(
      'workspace/didChangeConfiguration',
      { settings = client.config.settings }
    )
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
    licenceKey = vim.env.INTELEPHENSE_LICENSE
      or GetIntelephenseLicense()
      or nil,
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

-- ── Enable all servers ────────────────────────────────────
vim.lsp.enable {
  'ansiblels',
  'ast_grep',
  'bashls',
  'cssls',
  'dockerls',
  'eslint',
  'gopls',
  'html',
  'intelephense',
  'jsonls',
  'lua_ls',
  'pyright',
  'tailwindcss',
  'terraformls',
  'ts_ls',
  'vimls',
  'yamlls',
}

-- ── Diagnostic Config ─────────────────────────────────────
vim.diagnostic.config {
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
  virtual_text = {
    source = 'if_many',
    spacing = 2,
    format = function(diagnostic)
      local diagnostic_message = {
        [vim.diagnostic.severity.ERROR] = diagnostic.message,
        [vim.diagnostic.severity.WARN] = diagnostic.message,
        [vim.diagnostic.severity.INFO] = diagnostic.message,
        [vim.diagnostic.severity.HINT] = diagnostic.message,
      }
      return diagnostic_message[diagnostic.severity]
    end,
  },
}

-- ── LSP Highlight (cursor word) ──────────────────────────
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-highlight', { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if
      client
      and client:supports_method(
        vim.lsp.protocol.Methods.textDocument_documentHighlight,
        event.buf
      )
    then
      local highlight_augroup =
        vim.api.nvim_create_augroup('lsp-highlight-refs', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup(
          'lsp-detach',
          { clear = true }
        ),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds {
            group = 'lsp-highlight-refs',
            buffer = event2.buf,
          }
        end,
      })
    end
  end,
})

    end, -- end mason-tool-installer config
  },

  {
    'zapling/mason-conform.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    opts = {},
  },

  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      enabled = true,
      debug = false,
      runtime = vim.env.VIMRUNTIME,
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  { 'j-hui/fidget.nvim', opts = {} },
}
```

Key changes vs the old lsp.lua:
- Removed `neovim/nvim-lspconfig` — no longer a dependency
- Removed `williamboman/mason-lspconfig.nvim` — handler pattern gone
- Removed entire LspAttach keymap block (lines 26-82 of old file) — nvim 0.11 defaults handle `grn`, `gra`, `grr`, `gri`
- Removed `client_supports_method` compat shim — only targeting 0.11+
- Replaced `require('lspconfig')[server].setup()` with `vim.lsp.config()` + `vim.lsp.enable()`
- mason.nvim is now its own top-level spec (not nested under lspconfig)
- LSP config, diagnostics, and highlight autocmds live inside mason-tool-installer's `config` function (depends on blink.cmp for capabilities)
- lazydev no longer uses `lspconfig = true` integration (not relevant without lspconfig)

- [ ] **Step 2: Verify nvim starts and LSP attaches**

Run: `nvim --headless -c 'qall' 2>&1`
Expected: No errors on startup.

Then manually open a Lua file and check:
`:lua vim.print(vim.lsp.get_clients())`
Expected: lua_ls client present.

- [ ] **Step 3: Commit**

```bash
git add config/nvim/lua/plugins/lsp.lua
git commit -m "refactor(nvim): migrate to native vim.lsp.config, drop nvim-lspconfig"
```

---

### Task 3: Deduplicate keymaps in keymaps.lua

**Files:**
- Modify: `config/nvim/lua/keymaps.lua:56,63`

- [ ] **Step 1: Remove duplicate LSP keymaps**

In `config/nvim/lua/keymaps.lua`, remove these two lines:

```lua
-- REMOVE: duplicates nvim 0.11 default `gra` (code action)
K.ld('ca', 'n', ':lua vim.lsp.buf.code_action()<CR>', 'Code Action')
-- REMOVE: duplicates nvim 0.11 default `grn` (rename)
K.ld('cr', 'n', vim.lsp.buf.rename, 'Rename')
```

Keep all other `<leader>c*` mappings — they provide telescope-powered variants that go beyond the nvim 0.11 defaults.

- [ ] **Step 2: Verify keymaps still work**

Run: `nvim --headless -c 'qall' 2>&1`
Expected: No errors.

Manually verify: open a file, press `gra` — should trigger code action (nvim 0.11 default). Press `<leader>cd` — should open telescope definitions.

- [ ] **Step 3: Commit**

```bash
git add config/nvim/lua/keymaps.lua
git commit -m "refactor(nvim): remove duplicate LSP keymaps, rely on nvim 0.11 defaults"
```

---

### Task 4: Clean up catppuccin integrations in ui.lua

**Files:**
- Modify: `config/nvim/lua/plugins/ui.lua:67-78`

- [ ] **Step 1: Fix catppuccin integrations**

In `config/nvim/lua/plugins/ui.lua`, replace the integrations block:

```lua
-- OLD:
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          notify = false,
          mini = {
            enabled = true,
            indentscope_color = '',
          },
          -- More integrations:
          -- github.com/catppuccin/nvim#integrations
        },
```

With:

```lua
        integrations = {
          blink_cmp = true,
          mini = {
            enabled = true,
            indentscope_color = '',
          },
          neotree = true,
          noice = true,
          telescope = { enabled = true },
          treesitter = true,
          -- More integrations:
          -- github.com/catppuccin/nvim#integrations
        },
```

Changes:
- `cmp = true` → `blink_cmp = true` (matches actual completion plugin)
- Removed `gitsigns = true` (uses mini.git/mini.diff, not gitsigns)
- `nvimtree = true` → `neotree = true` (uses neo-tree, not nvim-tree)
- Removed `notify = false` (was false anyway)
- Added `noice`, `telescope`, `treesitter` integrations (actually used plugins)

- [ ] **Step 2: Verify theme loads correctly**

Run: `nvim --headless -c 'colorscheme catppuccin' -c 'qall' 2>&1`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add config/nvim/lua/plugins/ui.lua
git commit -m "fix(nvim): update catppuccin integrations to match actual plugins"
```

---

### Task 5: Clean up noice.nvim config in folke.lua

**Files:**
- Modify: `config/nvim/lua/plugins/folke.lua:24`

- [ ] **Step 1: Remove stale nvim-cmp reference**

In `config/nvim/lua/plugins/folke.lua`, remove line 24:

```lua
-- REMOVE this line:
          ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
```

This references `hrsh7th/nvim-cmp` which is not installed (blink.cmp is used instead).

- [ ] **Step 2: Verify noice loads**

Run: `nvim --headless -c 'qall' 2>&1`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add config/nvim/lua/plugins/folke.lua
git commit -m "fix(nvim): remove stale nvim-cmp reference from noice config"
```

---

### Task 6: Remove vim-go and shellcheck.nvim from code.lua

**Files:**
- Modify: `config/nvim/lua/plugins/code.lua`

- [ ] **Step 1: Remove vim-go and shellcheck.nvim specs**

In `config/nvim/lua/plugins/code.lua`, remove both plugin specs. The file should contain only:

```lua
return {
  {
    'ivuorinen/nvim-shellspec',
    ft = 'shellspec',
    config = function()
      require('shellspec').setup {
        auto_format = true,
        indent_size = 2,
        indent_comments = true,
      }
    end,
  },

  -- Detect tabstop and shiftwidth automatically
  -- https://github.com/tpope/vim-sleuth
  {
    'tpope/vim-sleuth',
  },

  -- Clarify and beautify your comments using boxes and lines.
  -- https://github.com/LudoPinelli/comment-box.nvim
  {
    'LudoPinelli/comment-box.nvim',
    event = 'BufEnter',
    opts = {},
  },
}
```

- [ ] **Step 2: Verify nvim starts**

Run: `nvim --headless -c 'qall' 2>&1`
Expected: No errors. gopls still works via native LSP config from Task 2.

- [ ] **Step 3: Commit**

```bash
git add config/nvim/lua/plugins/code.lua
git commit -m "refactor(nvim): remove vim-go and shellcheck.nvim, covered by LSP"
```

---

### Task 7: Reorganize plugin files (11 → 8)

This is the big file shuffle. All plugin specs are moved to their new homes. Since lazy.nvim auto-discovers `lua/plugins/*.lua`, renaming/moving is safe.

**Files:**
- Create: `config/nvim/lua/plugins/completion.lua`
- Create: `config/nvim/lua/plugins/editor.lua`
- Create: `config/nvim/lua/plugins/navigation.lua`
- Create: `config/nvim/lua/plugins/tools.lua`
- Delete: `config/nvim/lua/plugins/blink.lua`
- Delete: `config/nvim/lua/plugins/code.lua`
- Delete: `config/nvim/lua/plugins/folke.lua`
- Delete: `config/nvim/lua/plugins/mini.lua`
- Delete: `config/nvim/lua/plugins/neotree.lua`
- Delete: `config/nvim/lua/plugins/other.lua`
- Delete: `config/nvim/lua/plugins/telescope.lua`
- Modify: `config/nvim/lua/plugins/ui.lua`
- Keep unchanged: `config/nvim/lua/plugins/lsp.lua`, `config/nvim/lua/plugins/conform.lua`, `config/nvim/lua/plugins/treesitter.lua`

- [ ] **Step 1: Create completion.lua (rename from blink.lua)**

Create `config/nvim/lua/plugins/completion.lua` with the exact contents of the current `blink.lua` (unchanged):

```lua
return {
  -- Performant, batteries-included completion plugin for Neovim
  -- https://github.com/saghen/blink.cmp
  {
    'saghen/blink.cmp',
    version = '*',
    lazy = false, -- lazy loading handled internally
    dependencies = {
      -- Compatibility layer for using nvim-cmp sources on blink.cmp
      -- https://github.com/Saghen/blink.compat
      {
        'saghen/blink.compat',
        version = '*',
        -- lazy.nvim will automatically load the plugin when it's required by blink.cmp
        opts = {
          -- make sure to set opts so that lazy.nvim calls blink.compat's setup
          impersonate_nvim_cmp = true,
        },
      },

      -- Lua plugin to turn github copilot into a cmp source
      -- https://github.com/giuxtaposition/blink-cmp-copilot
      {
        'giuxtaposition/blink-cmp-copilot',
        dependencies = {
          -- Fully featured & enhanced replacement for copilot.vim complete
          -- with API for interacting with Github Copilot
          -- https://github.com/zbirenbaum/copilot.lua
          {
            'zbirenbaum/copilot.lua',
            cmd = 'Copilot',
            build = ':Copilot setup',
            event = { 'InsertEnter', 'LspAttach' },
            opts = {
              fix_pairs = true,
              suggestion = { enabled = false },
              panel = { enabled = false },
              filetypes = {
                markdown = true,
              },
            },
          },
        },
      },
    },
    ---@module 'blink.cmp'
    opts = {
      keymap = {
        preset = 'default',
        ['<C-x>'] = { 'show', 'show_documentation', 'hide_documentation' },
      },

      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = vim.g.nerd_font_variant or 'mono',
      },

      completion = {
        menu = {
          draw = {
            columns = {
              { 'label', 'label_description', gap = 1 },
              { 'kind_icon', 'kind', gap = 1 },
            },
          },
        },
        documentation = {
          auto_show = false,
          auto_show_delay_ms = 500,
        },
        ghost_text = {
          enabled = false,
        },
      },

      sources = {
        default = {
          'lsp',
          'copilot',
          'path',
          'snippets',
          'buffer',
          'lazydev',
        },
        providers = {
          copilot = {
            name = 'copilot',
            module = 'blink-cmp-copilot',
          },
          lazydev = {
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            score_offset = 100,
          },
        },
      },

      fuzzy = { implementation = 'lua' },

      signature = { enabled = true },
    },
    opts_extend = { 'sources.completion.enabled_providers' },
  },
}
```

- [ ] **Step 2: Create editor.lua (mini.nvim + vim-sleuth + hardtime)**

Create `config/nvim/lua/plugins/editor.lua`:

```lua
return {
  -- Library of 40+ independent Lua modules improving overall Neovim
  -- (version 0.8 and higher) experience with minimal effort
  --
  -- https://github.com/nvim-mini/mini.nvim
  -- https://github.com/nvim-mini/mini.nvim?tab=readme-ov-file#modules
  --
  -- YouTube: Text editing with 'mini.nvim' - Neovimconf 2024 - Evgeni Chasnovski
  -- https://www.youtube.com/watch?v=cNK5kYJ7mrs
  {
    'nvim-mini/mini.nvim',
    version = false,
    priority = 1001,
    config = function()
      -- ╭─────────────────────────────────────────────────────────╮
      -- │                      Text editing                       │
      -- ╰─────────────────────────────────────────────────────────╯

      -- Better Around/Inside textobjects
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 750 }

      -- Comment lines
      require('mini.comment').setup()

      -- Text edit operators
      -- g= - Evaluate text and replace with output
      -- gx - Exchange text regions
      -- gm - Multiply (duplicate) text
      -- gr - Replace text with register
      -- gs - Sort text
      require('mini.operators').setup()

      -- Split and join arguments, lists, and other sequences
      require('mini.splitjoin').setup()

      -- Fast and feature-rich surround actions
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      -- - sff   - find right (`sf`) part of surrounding function call (`f`)
      require('mini.surround').setup()

      -- ╭─────────────────────────────────────────────────────────╮
      -- │                    General workflow                     │
      -- ╰─────────────────────────────────────────────────────────╯

      -- Presets for common options and mappings
      -- h: MiniBasics.config
      require('mini.basics').setup {
        options = {
          basics = true,
          extra_ui = true,
        },
        mappings = {
          basic = true,
          option_toggle_prefix = [[<leader>tm]],
        },
      }

      -- Buffer removing (unshow, delete, wipeout), which saves window layout
      require('mini.bufremove').setup()

      -- Show next key clues
      local miniclue = require 'mini.clue'
      ---@modules mini.clue
      miniclue.setup {
        window = {
          config = {
            width = 'auto',
          },
        },
        triggers = {
          -- Leader triggers
          { mode = 'n', keys = '<Leader>' },
          { mode = 'x', keys = '<Leader>' },

          -- Built-in completion
          { mode = 'i', keys = '<C-x>' },

          -- `g` key
          { mode = 'n', keys = 'g' },
          { mode = 'x', keys = 'g' },

          -- Marks
          { mode = 'n', keys = "'" },
          { mode = 'n', keys = '`' },
          { mode = 'x', keys = "'" },
          { mode = 'x', keys = '`' },

          -- Registers
          { mode = 'n', keys = '"' },
          { mode = 'x', keys = '"' },
          { mode = 'i', keys = '<C-r>' },
          { mode = 'c', keys = '<C-r>' },

          -- Window commands
          { mode = 'n', keys = '<C-w>' },

          -- `z` key
          { mode = 'n', keys = 'z' },
          { mode = 'x', keys = 'z' },
        },

        -- These mark the sections in the popup
        clues = {
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          miniclue.gen_clues.z(),
          { mode = 'n', keys = '<Leader>a', desc = '+Automation' },
          { mode = 'n', keys = '<Leader>b', desc = '+Buffers' },
          { mode = 'n', keys = '<Leader>c', desc = '+Code' },
          { mode = 'n', keys = '<Leader>cb', desc = '+CommentBox' },
          { mode = 'n', keys = '<Leader>cc', desc = '+Calls' },
          { mode = 'n', keys = '<Leader>q', desc = '+Quit' },
          { mode = 'n', keys = '<Leader>s', desc = '+Telescope' },
          { mode = 'n', keys = '<Leader>t', desc = '+Toggle' },
          { mode = 'n', keys = '<Leader>tm', desc = '+Mini' },
          { mode = 'n', keys = '<Leader>x', desc = '+Trouble' },
          { mode = 'n', keys = '<leader>z', desc = '+TreeSitter' },
          { mode = 'n', keys = '<leader>zg', desc = '+Goto' },
          { mode = 'n', keys = '<Leader>?', desc = '+Help' },
          { mode = 'n', keys = 'd', desc = '+Diagnostics' },
          { mode = 'n', keys = 'y', desc = '+Yank' },
        },
      }

      -- Work with diff hunks
      require('mini.diff').setup()

      -- Git integration
      require('mini.git').setup()

      -- Session management (read, write, delete)
      require('mini.sessions').setup {
        autowrite = true,
        directory = vim.g.sessions_dir or vim.fn.stdpath 'data' .. '/sessions',
        file = '',
      }

      -- ╭─────────────────────────────────────────────────────────╮
      -- │                       Appearance                        │
      -- ╰─────────────────────────────────────────────────────────╯

      -- Animate common Neovim actions
      require('mini.animate').setup()

      -- Highlight cursor word and its matches
      require('mini.cursorword').setup()

      -- Highlight patterns in text
      local hp = require 'mini.hipatterns'
      hp.setup {
        highlighters = {
          fixme = {
            pattern = '%f[%w]()FIXME:?%s*()%f[%W]',
            group = 'MiniHipatternsFixme',
          },
          hack = {
            pattern = '%f[%w]()HACK:?%s*()%f[%W]',
            group = 'MiniHipatternsHack',
          },
          todo = {
            pattern = '%f[%w]()TODO:?%s*()%f[%W]',
            group = 'MiniHipatternsNote',
          },
          note = {
            pattern = '%f[%w]()NOTE()%f[%W]',
            group = 'MiniHipatternsNote',
          },
          bug = {
            pattern = '%f[%w]()BUG:?%s*()%f[%W]',
            group = 'MiniHipatternsHack',
          },
          perf = {
            pattern = '%f[%w]()PERF:?%s*()%f[%W]',
            group = 'MiniHipatternsNote',
          },
        },

        -- Highlight hex color strings (`#rrggbb`) using that color
        hex_color = hp.gen_highlighter.hex_color(),
      }

      -- Icons
      require('mini.icons').setup {
        file = {
          ['.keep'] = { glyph = '󰊢', hl = 'MiniIconsGrey' },
          ['devcontainer.json'] = { glyph = '', hl = 'MiniIconsAzure' },
        },
        filetype = {
          dotenv = { glyph = '', hl = 'MiniIconsYellow' },
        },
      }

      -- Visualize and work with indent scope
      require('mini.indentscope').setup()

      -- Fast and flexible start screen
      local starter = require 'mini.starter'
      ---@modules mini.starter
      starter.setup {
        items = {
          starter.sections.telescope(),
          starter.sections.builtin_actions(),
          starter.sections.recent_files(5),
        },
        content_hooks = {
          starter.gen_hook.adding_bullet(),
          starter.gen_hook.indexing('all', { 'Builtin actions' }),
          starter.gen_hook.aligning('center', 'center'),
        },
      }

      -- Minimal and fast statusline module with opinionated default look
      local sl = require 'mini.statusline'
      ---@modules mini.statusline
      sl.setup {
        use_icons = true,
        set_vim_settings = true,
        content = {
          active = function()
            local mode, mode_hl = sl.section_mode { trunc_width = 100 }
            local git = sl.section_git { trunc_width = 40 }
            local diagnostics = sl.section_diagnostics {
              trunc_width = 75,
              signs = {
                ERROR = 'E ',
                WARN = 'W ',
                INFO = 'I ',
                HINT = 'H ',
              },
            }
            local lsp = MiniStatusline.section_lsp { trunc_width = 75 }
            local filename = sl.section_filename { trunc_width = 140 }
            local fileinfo = sl.section_fileinfo { trunc_width = 9999 }
            local location = sl.section_location { trunc_width = 9999 }
            return sl.combine_groups {
              { hl = mode_hl, strings = { mode } },
              {
                hl = 'MiniStatuslineDevinfo',
                strings = { git, lsp },
              },
              '%<', -- Mark general truncate point
              { hl = 'statuslineFilename', strings = { filename } },
              '%=', -- End left alignment
              { hl = 'statuslineFileinfo', strings = { diagnostics } },
              { hl = 'statuslineFileinfo', strings = { fileinfo } },
              { hl = mode_hl, strings = { location } },
            }
          end,
        },
      }

      -- Work with trailing whitespace
      require('mini.trailspace').setup()
    end,
  },

  -- Detect tabstop and shiftwidth automatically
  -- https://github.com/tpope/vim-sleuth
  { 'tpope/vim-sleuth' },

  -- Break bad habits, master Vim motions
  -- https://github.com/m4xshen/hardtime.nvim
  {
    'm4xshen/hardtime.nvim',
    lazy = false,
    dependencies = { 'MunifTanjim/nui.nvim' },
    opts = {
      restriction_mode = 'hint',
      disabled_keys = {
        ['<Up>'] = { '', 'n' },
        ['<Down>'] = { '', 'n' },
        ['<Left>'] = { '', 'n' },
        ['<Right>'] = { '', 'n' },
        ['<C-Up>'] = { '', 'n' },
        ['<C-Down>'] = { '', 'n' },
        ['<C-Left>'] = { '', 'n' },
        ['<C-Right>'] = { '', 'n' },
      },
      disabled_filetypes = {
        'TelescopePrompt',
        'Trouble',
        'lazy',
        'mason',
        'help',
        'notify',
        'dashboard',
        'alpha',
      },
      hints = {
        ['[dcyvV][ia][%(%)]'] = {
          message = function(keys)
            return 'Use ' .. keys:sub(1, 2) .. 'b instead of ' .. keys
          end,
          length = 3,
        },
        ['[dcyvV][ia][%{%}]'] = {
          message = function(keys)
            return 'Use ' .. keys:sub(1, 2) .. 'B instead of ' .. keys
          end,
          length = 3,
        },
      },
    },
  },
}
```

- [ ] **Step 3: Create navigation.lua (telescope + neo-tree + trouble + fff + stickybuf)**

Create `config/nvim/lua/plugins/navigation.lua`:

```lua
return {
  -- Fuzzy Finder (files, lsp, etc)
  -- https://github.com/nvim-telescope/telescope.nvim
  {
    'nvim-telescope/telescope.nvim',
    version = '*',
    lazy = true,
    cmd = 'Telescope',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },

      -- A Telescope picker to quickly access configurations
      -- of plugins managed by lazy.nvim.
      -- https://github.com/polirritmico/telescope-lazy-plugins.nvim
      { 'polirritmico/telescope-lazy-plugins.nvim' },
    },
    config = function()
      local t = require 'telescope'
      local a = require 'telescope.actions'

      local open_with_trouble = require('trouble.sources.telescope').open
      local add_to_trouble = require('trouble.sources.telescope').add

      t.setup {
        defaults = {
          preview = {
            filesize_limit = 0.1,
          },
          layout_strategy = 'horizontal',
          pickers = {
            mappings = {
              i = {
                ['<C-s>'] = a.cycle_previewers_next,
                ['<C-a>'] = a.cycle_previewers_prev,
              },
            },
          },
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-j>'] = a.move_selection_next,
              ['<C-k>'] = a.move_selection_previous,
              ['<C-d>'] = a.move_selection_previous,
              ['<C-t>'] = open_with_trouble,
              ['<C-q>'] = add_to_trouble,
            },
            n = {
              ['<C-t>'] = open_with_trouble,
              ['<C-q>'] = add_to_trouble,
            },
          },
        },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        extensions = {
          lazy_plugins = {
            lazy_config = vim.fn.stdpath 'config' .. '/init.lua',
          },
        },
      }

      pcall(t.load_extension, 'lazy_plugins')
      pcall(t.load_extension, 'import')
    end,
  },

  -- Neo-tree is a Neovim plugin to browse the file system
  -- https://github.com/nvim-neo-tree/neo-tree.nvim
  {
    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
      {
        -- This plugins prompts the user to pick a window and returns
        -- the window id of the picked window
        -- https://github.com/s1n7ax/nvim-window-picker
        's1n7ax/nvim-window-picker',
        version = '3.*',
        opts = {
          filter_rules = {
            include_current_win = false,
            autoselect_one = true,
            bo = {
              filetype = { 'neo-tree', 'neo-tree-popup', 'notify' },
              buftype = { 'terminal', 'quickfix' },
            },
          },
        },
      },
    },
    cmd = 'Neotree',
    opts = {
      close_if_last_window = true,
      hide_root_node = true,
      popup_border_style = 'rounded',
      enable_git_status = true,
      enable_diagnostics = true,
      sources = {
        'filesystem',
        'buffers',
        'document_symbols',
      },
      source_selector = {
        winbar = false,
        statusline = false,
        separator = { left = '', right = '' },
        show_separator_on_edge = true,
        highlight_tab = 'SidebarTabInactive',
        highlight_tab_active = 'SidebarTabActive',
        highlight_background = 'StatusLine',
        highlight_separator = 'SidebarTabInactiveSeparator',
        highlight_separator_active = 'SidebarTabActiveSeparator',
      },
      event_handlers = {
        {
          event = 'file_opened',
          handler = function(_)
            local c = require 'neo-tree.command'
            c.execute { action = 'close' }
          end,
        },
      },
      default_component_configs = {
        indent = {
          padding = 0,
        },
        name = {
          use_git_status_colors = true,
          highlight_opened_files = true,
        },
      },
      git_status = {
        symbols = {
          added = '',
          modified = '',
          deleted = '✖',
          renamed = '󰁕',
          untracked = '',
          ignored = '',
          unstaged = '󰄱',
          staged = '',
          conflict = '',
        },
      },
      filesystem = {
        window = {
          mappings = {
            ['<Esc>'] = 'close_window',
            ['q'] = 'close_window',
            ['<cr>'] = 'open_with_window_picker',
          },
        },
        filtered_items = {
          hide_dotfiles = false,
          hide_hidden = true,
          never_show = {
            '.DS_Store',
          },
          hide_by_name = {
            'node_modules',
            '.git',
          },
        },
      },
    },
  },

  -- A pretty diagnostics, references, telescope results,
  -- quickfix and location list to help you solve all the
  -- trouble your code is causing.
  -- https://github.com/folke/trouble.nvim
  {
    ---@module 'trouble'
    'folke/trouble.nvim',
    lazy = false,
    cmd = 'Trouble',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    ---@type trouble.Config
    opts = {
      auto_preview = true,
      auto_fold = true,
      auto_close = true,
      use_lsp_diagnostic_signs = true,
      keys = {
        j = 'next',
        k = 'prev',
      },
      modes = {
        diagnostics = {
          auto_open = false,
        },
        test = {
          mode = 'diagnostics',
          preview = {
            type = 'split',
            relative = 'win',
            position = 'right',
            size = 0.25,
          },
        },
        cascade = {
          mode = 'diagnostics',
          filter = function(items)
            local severity = vim.diagnostic.severity.HINT
            for _, item in ipairs(items) do
              severity = math.min(severity, item.severity)
            end
            return vim.tbl_filter(
              function(item) return item.severity == severity end,
              items
            )
          end,
        },
      },
    },
  },

  -- Neovim plugin for locking a buffer to a window
  -- https://github.com/stevearc/stickybuf.nvim
  { 'stevearc/stickybuf.nvim', opts = {} },
}
```

- [ ] **Step 4: Create tools.lua (wakatime + shellspec + comment-box + plenary)**

Create `config/nvim/lua/plugins/tools.lua`:

```lua
return {
  {
    'nvim-lua/plenary.nvim',
    version = '*',
    lazy = false,
  },

  -- Vim plugin for automatic time tracking and metrics
  -- generated from your programming activity.
  -- https://github.com/wakatime/vim-wakatime
  { 'wakatime/vim-wakatime', lazy = false, enabled = true },

  {
    'ivuorinen/nvim-shellspec',
    ft = 'shellspec',
    config = function()
      require('shellspec').setup {
        auto_format = true,
        indent_size = 2,
        indent_comments = true,
      }
    end,
  },

  -- Clarify and beautify your comments using boxes and lines.
  -- https://github.com/LudoPinelli/comment-box.nvim
  {
    'LudoPinelli/comment-box.nvim',
    event = 'BufEnter',
    opts = {},
  },
}
```

- [ ] **Step 5: Update ui.lua — merge visual plugins from current ui.lua + noice from folke.lua**

Replace the entire content of `config/nvim/lua/plugins/ui.lua` with:

```lua
return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      require('catppuccin').setup {
        flavour = 'auto',
        background = {
          light = 'latte',
          dark = 'mocha',
        },
        transparent_background = false,
        float = {
          transparent = true,
          solid = false,
        },
        show_end_of_buffer = false,
        term_colors = false,
        dim_inactive = {
          enabled = true,
          shade = 'dark',
          percentage = 0.15,
        },
        no_italic = false,
        no_bold = false,
        no_underline = false,
        styles = {
          comments = { 'italic' },
          conditionals = { 'italic' },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        lsp_styles = {
          virtual_text = {
            errors = { 'italic' },
            hints = { 'italic' },
            warnings = { 'italic' },
            information = { 'italic' },
            ok = { 'italic' },
          },
          underlines = {
            errors = { 'underline' },
            hints = { 'underline' },
            warnings = { 'underline' },
            information = { 'underline' },
            ok = { 'underline' },
          },
          inlay_hints = {
            background = true,
          },
        },
        color_overrides = {},
        custom_highlights = {},
        default_integrations = true,
        auto_integrations = false,
        integrations = {
          blink_cmp = true,
          mini = {
            enabled = true,
            indentscope_color = '',
          },
          neotree = true,
          noice = true,
          telescope = { enabled = true },
          treesitter = true,
          -- More integrations:
          -- github.com/catppuccin/nvim#integrations
        },
      }

      vim.cmd.colorscheme 'catppuccin'
    end,
  },

  -- Automatic dark mode
  -- https://github.com/f-person/auto-dark-mode.nvim
  {
    'f-person/auto-dark-mode.nvim',
    opts = {
      update_interval = 1000,
      -- stylua: ignore
      set_dark_mode = function()
        vim.api.nvim_set_option_value('background', 'dark', {})
      end,
      set_light_mode = function()
        vim.api.nvim_set_option_value('background', 'light', {})
      end,
    },
  },

  -- The fastest Neovim colorizer
  -- https://github.com/catgoose/nvim-colorizer.lua
  {
    'catgoose/nvim-colorizer.lua',
    event = 'BufReadPre',
    opts = {
      user_default_options = {
        names = false,
      },
    },
  },

  {
    'dmtrKovalenko/fff.nvim',
    build = function()
      require('fff.download').download_or_build_binary()
    end,
    opts = {
      debug = {
        enabled = true,
        show_scores = true,
      },
    },
    lazy = false,
    keys = {
      {
        'ff',
        function() require('fff').find_files() end,
        desc = 'FFFind files',
      },
    },
  },

  -- Display a character as the colorcolumn
  -- https://github.com/lukas-reineke/virt-column.nvim
  { 'lukas-reineke/virt-column.nvim', opts = {} },

  -- Highly experimental plugin that completely
  -- replaces the UI for messages, cmdline and the popupmenu.
  -- https://github.com/folke/noice.nvim
  {
    ---@module 'noice'
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {
      'MunifTanjim/nui.nvim',
      {
        'rcarriga/nvim-notify',
        opts = { background_colour = '#000000' },
      },
    },
    opts = {
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = false,
      },
      routes = {
        {
          view = 'notify',
          filter = { event = 'msg_showmode' },
        },
        {
          filter = {
            event = 'msg_show',
            kind = '',
            any = {
              { find = 'written' },
              { find = '%d of %d --%d%--' },
            },
          },
          opts = { skip = true },
        },
        {
          filter = {
            event = 'msg_show',
            any = {
              { find = '%d+L, %d+B' },
              { find = '; after #%d+' },
              { find = '; before #%d+' },
              { find = "' added to" },
            },
          },
          view = 'mini',
        },
        {
          filter = {
            event = 'lsp',
            kind = 'progress',
            cond = function(message)
              local client = vim.tbl_get(message.opts, 'progress', 'client')
              return client == 'lua_ls'
            end,
          },
          opts = { skip = true },
        },
      },
      views = {
        cmdline_popup = {
          position = {
            row = 5,
            col = '50%',
          },
          size = {
            width = 60,
            height = 'auto',
          },
        },
        popupmenu = {
          relative = 'editor',
          position = {
            row = 8,
            col = '50%',
          },
          size = {
            width = 60,
            height = 10,
          },
          border = {
            style = 'rounded',
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = {
              Normal = 'Normal',
              FloatBorder = 'DiagnosticInfo',
            },
          },
        },
      },
    },
  },

  -- xiyaowong/transparent.nvim
  { 'xiyaowong/transparent.nvim' },
}
```

- [ ] **Step 6: Delete old files**

```bash
rm config/nvim/lua/plugins/blink.lua
rm config/nvim/lua/plugins/code.lua
rm config/nvim/lua/plugins/folke.lua
rm config/nvim/lua/plugins/mini.lua
rm config/nvim/lua/plugins/neotree.lua
rm config/nvim/lua/plugins/other.lua
rm config/nvim/lua/plugins/telescope.lua
```

- [ ] **Step 7: Verify final plugin file list**

```bash
ls config/nvim/lua/plugins/
```

Expected files (8):
```
completion.lua
conform.lua
editor.lua
lsp.lua
navigation.lua
tools.lua
treesitter.lua
ui.lua
```

- [ ] **Step 8: Verify nvim starts without errors**

Run: `nvim --headless -c 'qall' 2>&1`
Expected: No errors.

Run: `nvim --headless -c 'Lazy check' -c 'qall' 2>&1`
Expected: Lazy loads all plugins successfully.

- [ ] **Step 9: Commit**

```bash
git add config/nvim/lua/plugins/
git commit -m "refactor(nvim): reorganize plugin files from 11 to 8 by concern"
```

---

### Task 8: Update CLAUDE.md for nvim config

**Files:**
- Modify: `config/nvim/CLAUDE.md`

- [ ] **Step 1: Update CLAUDE.md to reflect new file structure**

Update the plugin files table in `config/nvim/CLAUDE.md` to reflect the new 8-file organization:

```markdown
## Plugin Files (one per concern)

| File             | Purpose                                             |
|------------------|-----------------------------------------------------|
| `lsp.lua`        | mason + native vim.lsp.config + 17 language servers |
| `completion.lua` | Completion engine (blink.cmp + copilot source)      |
| `editor.lua`     | mini.nvim modules + vim-sleuth + hardtime           |
| `ui.lua`         | catppuccin, noice, auto-dark-mode, colorizer, fff   |
| `navigation.lua` | telescope, neo-tree, trouble, stickybuf             |
| `treesitter.lua` | Syntax highlighting with auto_install               |
| `conform.lua`    | Format-on-save (shfmt, stylua, golangci-lint, etc)  |
| `tools.lua`      | wakatime, shellspec, comment-box, plenary           |
```

Also update the LSP Architecture section to mention `vim.lsp.config()` + `vim.lsp.enable()` instead of nvim-lspconfig.

- [ ] **Step 2: Commit**

```bash
git add config/nvim/CLAUDE.md
git commit -m "docs(nvim): update CLAUDE.md for new plugin structure"
```

---

### Task 9: Final verification

- [ ] **Step 1: Full startup test**

Run: `nvim --startuptime /tmp/nvim-startup.log --headless -c 'qall'`
Check: `tail -1 /tmp/nvim-startup.log` — should show total startup time.

- [ ] **Step 2: Run stylua check**

Run: `cd /Users/ivuorinen/.dotfiles && stylua --check config/nvim/`
Expected: No formatting issues.

- [ ] **Step 3: Manual verification checklist**

Open nvim and verify:
1. `:Lazy` — all plugins load without errors
2. Open a Lua file — `lua_ls` attaches (`:lua vim.print(vim.lsp.get_clients())`)
3. Press `grn` — rename works (nvim 0.11 default)
4. Press `gra` — code action works (nvim 0.11 default)
5. Press `<leader>cd` — telescope definitions works
6. `:Telescope keymaps` — works
7. `:Neotree toggle` — file explorer works
8. `:w` in a Lua file — stylua format-on-save works
9. Completion popup appears when typing
10. `:Noice` — noice UI is active
