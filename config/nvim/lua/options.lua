-- ╭─────────────────────────────────────────────────────────╮
-- │              neovim configuration options               │
-- ╰─────────────────────────────────────────────────────────╯
-- See `:help vim.opt`
--     `:help vim.g`
-- For more options, you can see `:help option-list`

local g = vim.g -- A table to store global variables
local o = vim.opt -- A table to store global options
local a = vim.api -- A table to store API functions

-- vim.global
g.mapleader = ' ' -- Space as the leader key
g.maplocalleader = ' ' -- Space as the local leader key

g.colors_theme = 'pencil' -- Set the colorscheme
-- g.colors_variant_light = 'tokyonight-day' -- Set the light variant
-- g.colors_variant_dark = 'tokyonight-storm' -- Set the dark variant

g.editorconfig = true -- Make sure editorconfig support is enabled
g.loaded_perl_provider = 0 -- Disable perl provider
g.loaded_ruby_provider = 0 -- Disable ruby provider
g.loaded_java_provider = 0 -- Disable java provider

-- vim.options
-- Most of the good defaults are provided by `mini.basics`
-- See: lua/plugins/mini.lua
o.confirm = true -- Confirm before closing unsaved buffers
o.dictionary = '/usr/share/dict/words' -- Add system dictionary
o.ignorecase = true -- Ignore case in search patterns
o.inccommand = 'split' -- Preview substitutions live, as you type!
o.list = true -- Show invisible characters
o.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
o.number = true -- Show line numbers
o.numberwidth = 3 -- Set the width of the number column
o.relativenumber = true -- Show relative line numbers
o.scrolloff = 8 -- Show context around cursor
o.sidescrolloff = 8 -- Show context around cursor
o.signcolumn = 'yes' -- Keep signcolumn on by default
o.spell = true -- Enable spell checking
o.spelllang = 'fi,en_us' -- Set the spell checking language
o.splitbelow = true -- split to the bottom
o.splitright = true -- vsplit to the right
o.termguicolors = true -- Enable GUI colors
o.timeoutlen = 250 -- Decrease mapped sequence wait time
o.updatetime = 250 -- 250 ms = 2,5 seconds

-- Session options
-- This is a comma separated list of options that will be
-- saved when a session ends.
local so = 'buffers,curdir,folds,tabpages,winsize,winpos,terminal,localoptions'
o.sessionoptions = so

o.wildmode = 'longest:full,full' -- Command-line completion mode

-- Enable the colorcolumn
a.nvim_set_option_value('colorcolumn', '+1', { scope = 'global' })

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  See `:help 'clipboard'`
vim.schedule(function()
  local c = vim.env.SSH_TTY and '' or 'unnamedplus'
  o.clipboard = c
end)

-- vim: ts=2 sts=2 sw=2 et
