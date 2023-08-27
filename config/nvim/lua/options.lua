local option = vim.api.nvim_set_option
local set = vim.api.nvim_set_var

-- Fix moving through lines 'gk' and 'gj'
vim.wo.linebreak = true

-- Enable break indent
vim.o.breakindent = true

-- Use the new FileType system of Neovim.
-- let g:do_filetype_lua = 1

-- Save undo history
vim.o.undofile = true

-- Show lines number (hybrid)
vim.wo.number = true
vim.wo.relativenumber = true

-- Keep signcolumn on by default
vim.wo.signcolumn = "yes"

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- To have a extra line :)
vim.o.cmdheight = 0

-- Set wrap for words
vim.wo.wrap = true

-- Always show tabs
vim.o.showtabline = 2

-- Show xtra spaces
vim.opt.list = true

-- Set wildmenu for later use
vim.o.wildmenu = true

-- Highlighting search
vim.o.hlsearch = true

-- Set ruler for better look
vim.o.ruler = true

-- No nice message
vim.o.hidden = true

-- Partial commands only in the screen
vim.o.showcmd = true

-- Match braces when inserting new ones :)
vim.o.showmatch = true

-- Cursor line
---- Cursor column
vim.o.cursorline = true
vim.wo.cursorline = true
vim.o.cursorcolumn = true
vim.wo.cursorcolumn = true

-- Off scroll when moving through the buffer
vim.o.scrolloff = 40

-- For terminal RGB colours
vim.go.termguicolors = true

-- Colours, I believe
vim.go.t_Co = "256"
vim.go.t_ut = ""

-- Space for tabs
vim.o.laststatus = 3

-- Space for tabs
vim.o.softtabstop = 2

-- Expand tab to use spaces instead
vim.o.expandtab = true

--  Space for tabs
vim.o.tabstop = 2

-- Space for tabs
vim.bo.shiftwidth = 2

-- Space for tabs
vim.o.shiftwidth = 2

-- Format options to not create new lines with comments
vim.o.formatoptions = "tqj"

-- Mouse working with neovim
vim.o.mouse = "a"

-- viminfo file
-- vim.o.viminfo = vim.o.viminfo .. '~/.config/nvim/viminfo'

-- Spell language to English (UK)
vim.o.spelllang = "en_gb"
vim.bo.spelllang = "en_gb"

-- Global statusline.
vim.opt.laststatus = 3

-- When "on" the commands listed below move the cursor to the first non-blank
--  of the line.  When off the cursor is kept in the same column (if possible).
-- https://neovim.io/doc/user/options.html#'startofline'
vim.opt.startofline = true

-- Columns line "limit"
-- vim.o.cc = '85'

-- Set path for better searching across the system
-- vim.o.path = vim.o.path .. '**'

-- Complete options
vim.o.completeopt = "menuone,longest,noselect"
vim.o.shortmess = vim.o.shortmess .. "c"

-- Menu Transparency.
vim.go.pumblend = 10

--------------------Variables-----------------

set("one_allow_itali:set cursorlinec:set cursorlines", 1)
set("do_filetype_lua", 1)
set("MRU_File", "~/.cache/vim_mru_files")

--------------------API------------------------

-- Change title accordingly.
-- option('title', true)

-- Set clipboard to be global across the system
option("clipboard", "unnamedplus")

-- Basic fold column
option("foldcolumn", "1")

-- Set dictionary to language spell
option("dictionary", "/usr/share/dict/words")

-- Wildignore for when opening files :0
option("wildignore", "*/tmp*/,*/node_modules/*,_site,*/__pycache__/,*/venv/*,*/target/*,*/.vim$,~$,*/.log")

-- Folding
option("foldmethod", "syntax")

-- File format for neovim reading
option("fileformat", "unix")
