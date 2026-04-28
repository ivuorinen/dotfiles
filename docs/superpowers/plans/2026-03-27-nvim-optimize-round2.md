# Neovim Config Optimization Round 2 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove mini.basics (move settings to options.lua), clean up dead references, and improve plugin lazy-loading.

**Architecture:** Expand options.lua with 16 settings from mini.basics, add 10 toggle keymaps to keymaps.lua, remove dead references to uninstalled plugins, and improve lazy-loading for 3 plugins.

**Tech Stack:** Neovim 0.11, Lua, lazy.nvim, mini.nvim

---

### Task 1: Expand options.lua with mini.basics settings

**Files:**
- Modify: `config/nvim/lua/options.lua`

- [ ] **Step 1: Replace stale comment and add new settings**

In `config/nvim/lua/options.lua`, replace lines 21-23:

```lua
-- vim.options
-- Most of the good defaults are provided by `mini.basics`
-- See: lua/plugins/mini.lua
```

With:

```lua
-- vim.options
```

Then after line 42 (`o.updatetime = 250`), add these new settings:

```lua
o.undofile = true -- Persistent undo across sessions
o.cursorline = true -- Highlight current line
o.linebreak = true -- Break lines at word boundaries
o.breakindent = true -- Indent wrapped lines
o.smartcase = true -- Smart case for search (with ignorecase)
o.infercase = true -- Smart case for completion
o.smartindent = true -- Auto indentation
o.virtualedit = 'block' -- Virtual editing in visual block mode
o.completeopt = 'menuone,noselect' -- Completion menu behavior
o.formatoptions = 'qjl1' -- Comment formatting
o.mouse = 'a' -- Enable mouse support
o.backup = false -- Don't create backup files
o.writebackup = false -- Don't backup on write
o.pumblend = 10 -- Transparent popup menu
o.pumheight = 10 -- Popup menu max height
o.winblend = 10 -- Transparent floating windows
```

- [ ] **Step 2: Verify**

Run: `nvim --headless -c 'qall' 2>&1`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add config/nvim/lua/options.lua
git commit -m "refactor(nvim): expand options.lua with mini.basics settings"
```

---

### Task 2: Add toggle keymaps to keymaps.lua

**Files:**
- Modify: `config/nvim/lua/keymaps.lua`

- [ ] **Step 1: Remove CloakToggle and add toggle mappings**

In `config/nvim/lua/keymaps.lua`, replace lines 106-111:

```lua
-- ── Toggle settings ─────────────────────────────────────────
-- Convention is 't' followed by the operation
K.nl('tc', ':CloakToggle<cr>', 'Cloak: Toggle')
K.nl('te', ':Neotree toggle<cr>', 'Toggle Neotree')
K.nl('tl', ToggleBackground, 'Toggle Light/Dark Mode')
K.nl('tn', ':Noice dismiss<cr>', 'Noice: Dismiss Notification')
```

With:

```lua
-- ── Toggle settings ─────────────────────────────────────────
-- Convention is 't' followed by the operation
K.nl('te', ':Neotree toggle<cr>', 'Toggle Neotree')
K.nl('tl', ToggleBackground, 'Toggle Light/Dark Mode')
K.nl('tn', ':Noice dismiss<cr>', 'Noice: Dismiss Notification')

-- ── Option toggles ──────────────────────────────────────────
-- Convention is 'tm' followed by the option letter
K.nl('tmb', ToggleBackground, 'Toggle background')
K.nl('tmc', function() vim.o.cursorline = not vim.o.cursorline end, 'Toggle cursorline')
K.nl('tmC', function() vim.o.cursorcolumn = not vim.o.cursorcolumn end, 'Toggle cursorcolumn')
K.nl('tmd', function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, 'Toggle diagnostics')
K.nl('tmh', function() vim.o.hlsearch = not vim.o.hlsearch end, 'Toggle hlsearch')
K.nl('tml', function() vim.o.list = not vim.o.list end, 'Toggle list')
K.nl('tmn', function() vim.o.number = not vim.o.number end, 'Toggle number')
K.nl('tmr', function() vim.o.relativenumber = not vim.o.relativenumber end, 'Toggle relativenumber')
K.nl('tms', function() vim.o.spell = not vim.o.spell end, 'Toggle spell')
K.nl('tmw', function() vim.o.wrap = not vim.o.wrap end, 'Toggle wrap')
```

- [ ] **Step 2: Verify**

Run: `nvim --headless -c 'qall' 2>&1`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add config/nvim/lua/keymaps.lua
git commit -m "refactor(nvim): add option toggle keymaps, remove orphaned CloakToggle"
```

---

### Task 3: Clean up autogroups.lua dead patterns

**Files:**
- Modify: `config/nvim/lua/autogroups.lua`

- [ ] **Step 1: Remove dead filetype patterns from close-with-q**

In `config/nvim/lua/autogroups.lua`, replace the close-with-q pattern list (lines 31-47):

```lua
  pattern = {
    'PlenaryTestPopup',
    'checkhealth',
    'dbout',
    'gitsigns.blame',
    'grug-far',
    'help',
    'lspinfo',
    'man',
    'neotest-output',
    'neotest-output-panel',
    'neotest-summary',
    'notify',
    'qf',
    'spectre_panel',
    'startuptime',
    'tsplayground',
  },
```

With:

```lua
  pattern = {
    'PlenaryTestPopup',
    'checkhealth',
    'dbout',
    'help',
    'lspinfo',
    'man',
    'notify',
    'qf',
    'startuptime',
  },
```

Removed: `gitsigns.blame`, `grug-far`, `neotest-output`, `neotest-output-panel`, `neotest-summary`, `spectre_panel`, `tsplayground` — these plugins are not installed.

- [ ] **Step 2: Verify**

Run: `nvim --headless -c 'qall' 2>&1`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add config/nvim/lua/autogroups.lua
git commit -m "refactor(nvim): remove dead filetype patterns from autogroups"
```

---

### Task 4: Remove mini.basics from editor.lua and update mini.clue

**Files:**
- Modify: `config/nvim/lua/plugins/editor.lua`

- [ ] **Step 1: Remove mini.basics setup block**

In `config/nvim/lua/plugins/editor.lua`, remove lines 48-62:

```lua
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
```

Replace with:

```lua
      -- ╭─────────────────────────────────────────────────────────╮
      -- │                    General workflow                     │
      -- ╰─────────────────────────────────────────────────────────╯
```

- [ ] **Step 2: Update mini.clue descriptor**

In the same file, replace line 124:

```lua
          { mode = 'n', keys = '<Leader>tm', desc = '+Mini' },
```

With:

```lua
          { mode = 'n', keys = '<Leader>tm', desc = '+Toggle Options' },
```

- [ ] **Step 3: Fix lazy-loading for hardtime and vim-sleuth**

In the same file, replace:

```lua
  { 'tpope/vim-sleuth' },
```

With:

```lua
  { 'tpope/vim-sleuth', event = 'BufReadPre' },
```

And replace:

```lua
    'm4xshen/hardtime.nvim',
    lazy = false,
```

With:

```lua
    'm4xshen/hardtime.nvim',
    event = 'VeryLazy',
```

- [ ] **Step 4: Verify**

Run: `nvim --headless -c 'qall' 2>&1`
Expected: No errors.

- [ ] **Step 5: Commit**

```bash
git add config/nvim/lua/plugins/editor.lua
git commit -m "refactor(nvim): remove mini.basics, improve lazy-loading"
```

---

### Task 5: Fix trouble.nvim lazy-loading in navigation.lua

**Files:**
- Modify: `config/nvim/lua/plugins/navigation.lua:180`

- [ ] **Step 1: Remove redundant lazy = false**

In `config/nvim/lua/plugins/navigation.lua`, replace:

```lua
    'folke/trouble.nvim',
    lazy = false,
    cmd = 'Trouble',
```

With:

```lua
    'folke/trouble.nvim',
    cmd = 'Trouble',
```

The `cmd = 'Trouble'` already tells lazy.nvim to load the plugin when the `:Trouble` command is used.

- [ ] **Step 2: Verify**

Run: `nvim --headless -c 'qall' 2>&1`
Expected: No errors.

- [ ] **Step 3: Commit**

```bash
git add config/nvim/lua/plugins/navigation.lua
git commit -m "refactor(nvim): fix trouble.nvim lazy-loading"
```

---

### Task 6: Final verification

- [ ] **Step 1: Run stylua check**

Run: `cd /Users/ivuorinen/.dotfiles && stylua --check config/nvim/`
Expected: No formatting issues.

- [ ] **Step 2: Run headless startup**

Run: `nvim --headless -c 'qall' 2>&1`
Expected: No errors.

- [ ] **Step 3: Manual verification checklist**

Open nvim and verify:
1. Cursorline is visible (from new option)
2. `<leader>tms` toggles spell on/off
3. `<leader>tmw` toggles wrap on/off
4. `:Trouble diagnostics` works (lazy-loaded)
5. Arrow keys still show hardtime hints (lazy-loaded via VeryLazy)
6. `:Lazy` shows all plugins load without errors
