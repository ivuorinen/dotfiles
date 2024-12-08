-- ╭─────────────────────────────────────────────────────────╮
-- │              neovim configuration options               │
-- ╰─────────────────────────────────────────────────────────╯
-- See `:help vim.opt`
--     `:help vim.g`
-- For more options, you can see `:help option-list`

local g = vim.g     -- A table to store global variables
local o = vim.opt   -- A table to store global options

vim.loader.enable() -- Enable the plugin loader

-- vim.global
g.mapleader = ' '                          -- Space as the leader key
g.maplocalleader = ' '                     -- Space as the local leader key
g.colors_theme = 'tokyonight'              -- Set the colorscheme
g.colors_variant_light = 'tokyonight-day'  -- Set the light variant
g.colors_variant_dark = 'tokyonight-storm' -- Set the dark variant
g.editorconfig = true                      -- Make sure editorconfig support is enabled
g.loaded_perl_provider = 0                 -- Disable perl provider
g.loaded_ruby_provider = 0                 -- Disable ruby provider

-- vim.options
o.breakindent = true               -- Enable break indent
o.completeopt = 'menuone,noselect' -- Popup menu when typing
o.cursorline = true                -- Show which line your cursor is on
o.inccommand = 'split'             -- Preview substitutions live, as you type!
o.mouse = 'a'                      -- Enable mouse support
o.number = true                    -- Show line numbers
o.relativenumber = true            -- Show relative line numbers
o.scrolloff = 15                   -- Show context around cursor
o.showmode = false                 -- Don't show mode
o.signcolumn = 'yes:2'             -- Keep signcolumn on by default
o.smartindent = true               -- Insert indents automatically
o.spell = true                     -- Enable spell checking
o.spelllang = 'en_us'              -- Set the spell checking language
o.splitbelow = true                -- split to the bottom
o.splitright = true                -- vsplit to the right
o.termguicolors = true             -- Fixes Notify opacity issues
o.timeoutlen = 250                 -- Decrease mapped sequence wait time
o.undofile = true                  -- Save undo history
o.updatetime = 250                 -- 250 ms = 2,5 seconds
o.ignorecase = true                -- Ignore case in search patterns
o.smartcase = true                 -- Override 'ignorecase' if pattern contains upper case chars


o.list = true -- Show some invisible characters
o.listchars = { tab = '» ', trail = '·', nbsp = '␣' } -- Which invisible chars to show

-- Enable the colorcolumn
vim.api.nvim_set_option_value('colorcolumn', '+1', { scope = 'global' })

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  See `:help 'clipboard'`
vim.schedule(function()
  local c = vim.env.SSH_TTY and '' or 'unnamedplus'
  vim.opt.clipboard = c
end)

-- vim: ts=2 sts=2 sw=2 et
