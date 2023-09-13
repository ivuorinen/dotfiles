-- luacheck: globals vim
local vim = vim

-- Use the new FileType system of Neovim.
-- let g:do_filetype_lua = 1
vim.g.do_filetype_lua = 1

vim.wo.linebreak = true      -- Fix moving through lines 'gk' and 'gj'
vim.o.breakindent = true     -- Enable break indent
vim.o.undofile = true        -- Save undo history
vim.wo.number = true         -- Show lines number (hybrid)
vim.wo.relativenumber = true -- Show lines number (hybrid)
vim.wo.signcolumn = "yes"    -- Keep signcolumn on by default
vim.o.laststatus = 3         -- Global statusline.
vim.o.cmdheight = 0          -- To have a extra line :)
vim.wo.wrap = true           -- Set wrap for words
vim.o.showtabline = 2        -- Always show tabs
vim.o.list = true            -- Show xtra spaces
vim.o.wildmenu = true        -- Set wildmenu for later use
vim.o.hlsearch = true        -- Highlighting search
vim.o.ruler = true           -- Set ruler for better look
vim.o.hidden = true          -- No nice message
vim.o.showcmd = true         -- Partial commands only in the screen
vim.o.showmatch = true       -- Match braces when inserting new ones
vim.opt.backup = false       -- No backups because some plugins freak out
vim.opt.writebackup = false  -- No backups because some plugins freak out
vim.o.scrolloff = 40         -- Off scroll when moving through the buffer
vim.go.termguicolors = true  -- For terminal RGB colours
vim.go.t_Co = "256"          -- Colours, I believe
vim.go.t_ut = ""             -- Colours, I believe
vim.o.laststatus = 3         -- Space for tabs
vim.o.softtabstop = 2        -- Space for tabs
vim.o.expandtab = true       -- Expand tab to use spaces instead
vim.o.tabstop = 2            -- Space for tabs
vim.bo.shiftwidth = 2        -- Space for tabs
vim.o.shiftwidth = 2         -- Space for tabs
vim.o.formatoptions = "tqj"  -- Format options to not create new lines with comments
vim.o.mouse = "a"            -- Mouse working with neovim

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Cursor line
vim.o.cursorline = true
vim.wo.cursorline = true
vim.o.cursorcolumn = true
vim.wo.cursorcolumn = true

-- Spell language to English (UK)
vim.o.spelllang = "en_gb"
vim.bo.spelllang = "en_gb"

-- When "on" the commands listed below move the cursor to the first non-blank
--  of the line.  When off the cursor is kept in the same column (if possible).
-- https://neovim.io/doc/user/options.html#'startofline'
vim.o.startofline = true

-- Complete options
vim.o.completeopt = "menuone,longest,noselect"
vim.o.shortmess = vim.o.shortmess .. "c"

--  ╭──────────────────────────────────────────────────────────╮
--  │ Variables                                                │
--  ╰──────────────────────────────────────────────────────────╯

vim.api.nvim_set_var("one_allow_itali:set cursorlinec:set cursorlines", 1)
vim.api.nvim_set_var("do_filetype_lua", 1)
vim.api.nvim_set_var("MRU_File", "~/.cache/vim_mru_files")

--  ╭──────────────────────────────────────────────────────────╮
--  │ API                                                      │
--  ╰──────────────────────────────────────────────────────────╯

-- Change title accordingly.
vim.api.nvim_set_option("title", true)

-- Set clipboard to be global across the system
vim.api.nvim_set_option("clipboard", "unnamedplus")

-- Set dictionary to language spell
vim.api.nvim_set_option("dictionary", "/usr/share/dict/words")

-- Wildignore for when opening files :0
vim.api.nvim_set_option(
  "wildignore",
  "*/tmp*/,*/node_modules/*,_site,*/__pycache__/,*/venv/*,*/target/*,*/.vim$,~$,*/.log"
)

-- Folding
vim.api.nvim_set_option("foldmethod", "syntax")
vim.api.nvim_set_option("foldenable", false)
vim.api.nvim_set_option("foldminlines", 5)
vim.api.nvim_set_option("foldcolumn", "1")
