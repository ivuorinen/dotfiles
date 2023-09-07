-- luacheck: globals vim
local key = vim.api.nvim_set_keymap
local remap = { noremap = true, silent = true }

-- Set with normal Vim opts, 'Space' as mapleader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set 'Space' as <NOP> key to leadermap key
key("n", "<Space>", "<NOP>", remap)

-- Global, windows options of neovim:
require("options")

-- Filetype specialties.
require("filetype")

-- To adminstrate packages:
require("plugin-manager")

-- LSP for editing.
require("lsp")

-- Autocmd commands from Vimscript
require("autocmd")

-- Personal Keymaps of neovim:
require("keymappings")

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
