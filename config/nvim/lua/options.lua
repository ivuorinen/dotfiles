-- ╭─────────────────────────────────────────────────────────╮
-- │              neovim configuration options               │
-- ╰─────────────────────────────────────────────────────────╯
-- See `:help vim.opt`
--     `:help vim.g`
-- For more options, you can see `:help option-list`

local g = vim.g -- A table to store global variables
local o = vim.opt -- A table to store global options

-- vim.global
g.mapleader = ' ' -- Space as the leader key
g.maplocalleader = ' ' -- Space as the local leader key

g.editorconfig = true -- Make sure editorconfig support is enabled
g.loaded_perl_provider = 0 -- Disable perl provider
g.loaded_ruby_provider = 0 -- Disable ruby provider
g.loaded_java_provider = 0 -- Disable java provider

-- vim.options
o.confirm = true -- Confirm before closing unsaved buffers
o.dictionary = '/usr/share/dict/words' -- Add system dictionary
o.ignorecase = true -- Ignore case in search patterns
o.inccommand = 'split' -- Preview substitutions live, as you type!
o.list = true -- Show invisible characters
o.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
o.fillchars = { eob = ' ', foldopen = '▾', foldclose = '▸', foldsep = ' ' }
o.number = true -- Show line numbers
o.numberwidth = 3 -- Set the width of the number column
o.relativenumber = true -- Show relative line numbers
o.scrolloff = 8 -- Show context around cursor
o.sidescrolloff = 8 -- Show context around cursor
o.signcolumn = 'yes' -- Keep signcolumn on by default
-- stylua: ignore
local fc = '%{foldlevel(v:lnum) > 0'
  .. ' ? (foldlevel(v:lnum) > foldlevel(v:lnum - 1)'
  .. ' ? (foldclosed(v:lnum) == -1 ? "▾" : "▸")'
  .. ' : " ") : " "} '
o.statuscolumn = '%s%l ' .. fc
o.spell = true -- Enable spell checking
o.spelllang = 'en_gb,en_us' -- Set the spell checking language
o.splitbelow = true -- split to the bottom
o.splitright = true -- vsplit to the right
o.termguicolors = true -- Enable GUI colors
o.timeoutlen = 250 -- Decrease mapped sequence wait time
o.updatetime = 250 -- 250 ms = 0.25 seconds
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

-- Folding via treesitter
o.foldmethod = 'expr'
o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
o.foldtext = ''
o.foldcolumn = '0'
o.foldlevel = 99
o.foldlevelstart = 99

-- Session options
-- This is a comma separated list of options that will be
-- saved when a session ends.
local so = 'buffers,curdir,folds,tabpages,winsize,winpos,terminal,localoptions'
o.sessionoptions = so

o.wildmode = 'longest:full,full' -- Command-line completion mode

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  See `:help 'clipboard'`
vim.schedule(function()
  local c = vim.env.SSH_TTY and '' or 'unnamedplus'
  o.clipboard = c
end)

-- vim: ts=2 sts=2 sw=2 et
