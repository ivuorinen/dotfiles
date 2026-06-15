-- ╭─────────────────────────────────────────────────────────╮
-- │              neovim configuration options               │
-- ╰─────────────────────────────────────────────────────────╯
-- See `:help vim.opt`
--     `:help vim.g`
-- For more options, you can see `:help option-list`

local g = vim.g
local o = vim.opt

-- vim.g
g.mapleader = ' ' -- Space as the leader key
g.maplocalleader = ' ' -- Space as the local leader key

-- Nerd Font is installed (Brewfile / fonts) — used by mini.icons
-- and the diagnostic-sign branch in lua/autogroups.lua. Set explicitly so
-- the nil-fallback paths don't silently disable nerd-font glyphs.
g.have_nerd_font = true

g.loaded_perl_provider = 0 -- Disable perl provider
g.loaded_ruby_provider = 0 -- Disable ruby provider
g.loaded_node_provider = 0 -- Disable node provider

-- vim.options
o.confirm = true -- Confirm before closing unsaved buffers
o.laststatus = 3 -- Global statusline (one bar; 0=hidden, 2=per-window, 3=global)
o.dictionary = '/usr/share/dict/words' -- enables <C-x><C-k> word completion
o.ignorecase = true -- Ignore case in search patterns
o.inccommand = 'split' -- Preview substitutions live, as you type!
o.list = true -- Show invisible characters
o.listchars = { tab = '» ', trail = '·', nbsp = '␣' } -- glyphs: tab, trailing ws, nbsp
-- eob=' ' hides ~ past EOF; fold glyphs rendered by the custom statuscolumn
o.fillchars = { eob = ' ', foldopen = '▾', foldclose = '▸', foldsep = ' ' }
o.number = true -- Show line numbers
o.numberwidth = 3 -- ≤99 lines; numberwidth-adjust autocmd expands for larger files
o.relativenumber = true -- Show relative line numbers
o.scrolloff = 8 -- Show context around cursor
o.sidescrolloff = 8 -- Show context around cursor
o.signcolumn = 'yes' -- Keep signcolumn on by default
-- statuscolumn: signs | line number (abs on cursor, rel elsewhere) | fold
-- stylua: ignore
local fc = '%{foldlevel(v:lnum) > 0'
  .. ' ? (foldlevel(v:lnum) > foldlevel(v:lnum - 1)'
  .. ' ? (foldclosed(v:lnum) == -1 ? "▾" : "▸")'
  .. ' : " ") : " "} '
-- stylua: ignore
local ln = '%{v:relnum == 0 ? v:lnum : v:relnum}'
o.statuscolumn = '%s' .. ln .. ' ' .. fc
o.spell = true -- Enable spell checking
o.spelllang = 'en_gb,en_us' -- Set the spell checking language
o.splitbelow = true -- split to the bottom
o.splitright = true -- vsplit to the right
o.termguicolors = true -- Enable GUI colors
o.timeoutlen = 250 -- key sequence wait in ms (default 1000); affects clue popup speed
o.updatetime = 250 -- faster CursorHold: LSP highlights, gitsigns (default 4000)
o.undofile = true -- Persistent undo across sessions
o.cursorline = true -- Highlight current line
o.linebreak = true -- Break lines at word boundaries
o.breakindent = true -- Indent wrapped lines
o.smartcase = true -- Smart case for search (with ignorecase)
o.infercase = true -- Smart case for completion
o.smartindent = true -- Auto indentation
o.virtualedit = 'block' -- Virtual editing in visual block mode
o.completeopt = { 'menuone', 'noselect', 'popup' } -- no auto-select; popup docs
o.formatoptions = 'qjl1' -- q=gq on comments; j=strip leader on join; l,1=no insert-break
o.mouse = 'a' -- Enable mouse support
o.writebackup = false -- Don't backup on write
o.pumblend = 10 -- Transparent popup menu (0 = opaque)
o.pumheight = 10 -- Popup menu max height (0 = unlimited)
o.winblend = 10 -- Transparent floating windows (0 = opaque)
o.ruler = false -- position shown in mini.statusline; ruler in cmdline is redundant

-- Folding via treesitter (native; no plugin required)
o.foldmethod = 'expr'
o.foldexpr = 'v:lua.vim.treesitter.foldexpr()' -- Neovim 0.10+ native treesitter API
o.foldtext = '' -- '' = Neovim 0.10+ native display: first line + syntax highlight
o.foldlevel = 99 -- keep all folds open during editing
o.foldlevelstart = 99 -- open all folds when a file is first opened

-- Compared to default (blank,buffers,curdir,folds,help,tabpages,winsize,terminal):
-- dropped 'blank' (empty windows) and 'help'; added 'winpos' and 'localoptions'
o.sessionoptions = 'buffers,curdir,folds,tabpages,winsize,winpos,terminal,localoptions'

o.wildmode = 'longest:full,full' -- Command-line completion mode

-- Sync clipboard with OS (unnamedplus). Deferred via vim.schedule to avoid
-- startup overhead. Disabled in SSH sessions: SSH_TTY is set but clipboard
-- tools (pbcopy/xclip) are unavailable over the tunnel. See :help 'clipboard'
vim.schedule(function()
  local c = vim.env.SSH_TTY and '' or 'unnamedplus'
  o.clipboard = c
end)
