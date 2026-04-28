# Neovim Config Optimization Round 2

## Context

After the initial trim (11→8 plugin files, removed 5 redundant plugins,
native LSP migration), a second pass found: mini.basics duplicating
options.lua, orphaned keymaps/autogroups referencing removed plugins,
and plugins loaded eagerly that could be lazy.

## Changes

### 1. Remove mini.basics, expand options.lua

Remove `require('mini.basics').setup(...)` from `editor.lua`.

Add these settings to `options.lua` (provided by mini.basics but not
currently in options.lua):

| Setting         | Value                | Why                                     |
|-----------------|----------------------|-----------------------------------------|
| `undofile`      | `true`               | Persistent undo across sessions         |
| `cursorline`    | `true`               | Highlight current line                  |
| `linebreak`     | `true`               | Break lines at word boundaries          |
| `breakindent`   | `true`               | Indent wrapped lines                    |
| `smartcase`     | `true`               | Smart case for search (with ignorecase) |
| `infercase`     | `true`               | Smart case for completion               |
| `smartindent`   | `true`               | Auto indentation                        |
| `virtualedit`   | `'block'`            | Virtual editing in visual block mode    |
| `completeopt`   | `'menuone,noselect'` | Completion menu behavior                |
| `formatoptions` | `'qjl1'`             | Comment formatting                      |
| `mouse`         | `'a'`                | Enable mouse support                    |
| `backup`        | `false`              | Don't create backup files               |
| `writebackup`   | `false`              | Don't backup on write                   |
| `pumblend`      | `10`                 | Transparent popup menu                  |
| `pumheight`     | `10`                 | Popup menu max height                   |
| `winblend`      | `10`                 | Transparent floating windows            |

Remove stale comment "Most of the good defaults are provided by
`mini.basics`" from options.lua.

### 2. Preserve `<leader>tm` toggle mappings

Add toggle keymaps to `keymaps.lua` to replace mini.basics toggles:

| Keymap        | Action                         |
|---------------|--------------------------------|
| `<leader>tmb` | Toggle background (light/dark) |
| `<leader>tmc` | Toggle cursorline              |
| `<leader>tmC` | Toggle cursorcolumn            |
| `<leader>tmd` | Toggle diagnostics             |
| `<leader>tmh` | Toggle hlsearch                |
| `<leader>tml` | Toggle list (invisible chars)  |
| `<leader>tmn` | Toggle number                  |
| `<leader>tmr` | Toggle relativenumber          |
| `<leader>tms` | Toggle spell                   |
| `<leader>tmw` | Toggle wrap                    |

### 3. Dead references cleanup

**keymaps.lua:**
- Remove `K.nl('tc', ':CloakToggle<cr>', ...)` — cloak.nvim not installed

**autogroups.lua:**
- Remove from close-with-q pattern list: `gitsigns.blame`, `grug-far`,
  `neotest-output`, `neotest-output-panel`, `neotest-summary`,
  `spectre_panel`, `tsplayground`

**editor.lua (mini.clue):**
- Remove `{ mode = 'n', keys = '<Leader>tm', desc = '+Mini' }` clue
  → rename to `'+Toggle Options'` since toggles now live in keymaps.lua

### 4. Lazy-loading improvements

| Plugin          | Current                            | Change                                   |
|-----------------|------------------------------------|------------------------------------------|
| `trouble.nvim`  | `lazy = false` + `cmd = 'Trouble'` | Remove `lazy = false` (cmd handles lazy) |
| `hardtime.nvim` | `lazy = false`                     | Change to `event = 'VeryLazy'`           |
| `vim-sleuth`    | No lazy config                     | Add `event = 'BufReadPre'`               |

## Files to modify

| File                         | Action                                                            |
|------------------------------|-------------------------------------------------------------------|
| `lua/options.lua`            | Add 16 settings, remove stale comment                             |
| `lua/keymaps.lua`            | Add 10 toggle keymaps, remove CloakToggle                         |
| `lua/autogroups.lua`         | Remove 7 dead filetype patterns                                   |
| `lua/plugins/editor.lua`     | Remove mini.basics setup, update mini.clue desc, fix lazy-loading |
| `lua/plugins/navigation.lua` | Remove `lazy = false` from trouble.nvim                           |

## Verification

1. `nvim --headless -c 'qall'` — no errors
2. `stylua --check config/nvim/` — formatting passes
3. Open nvim, verify: cursorline visible, undo persists after restart
4. `<leader>tms` toggles spell, `<leader>tmw` toggles wrap
5. `:Trouble diagnostics` still works (lazy-loaded via cmd)
6. hardtime hints still appear when using arrow keys
