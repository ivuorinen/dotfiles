-- ╭─────────────────────────────────────────────────────────╮
-- │              neovim configuration options               │
-- ╰─────────────────────────────────────────────────────────╯
-- See `:help vim.opt`
-- For more options, you can see `:help option-list`

vim.loader.enable()

-- Map leader and local leader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set the colorscheme and variants
vim.g.colors_theme = 'tokyonight'
vim.g.colors_variant_light = 'tokyonight-day'
vim.g.colors_variant_dark = 'tokyonight-storm'

-- Make sure editorconfig support is enabled
vim.g.editorconfig = true

-- Enable the colorcolumn
vim.api.nvim_set_option_value('colorcolumn', '+1', { scope = 'global' })

-- Enable line numbers and relative line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  See `:help 'clipboard'`
vim.schedule(function()
  local c = vim.env.SSH_TTY and '' or 'unnamedplus'
  vim.opt.clipboard = c
end)

vim.opt.breakindent = true -- Enable break indent
vim.opt.smartindent = true -- Insert indents automatically

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or
-- more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250
vim.wo.signcolumn = 'yes'

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 250

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 15

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- Fixes Notify opacity issues
vim.o.termguicolors = true

-- Set spell checking
vim.o.spell = true
vim.o.spelllang = 'en_us'

-- Tree-sitter settings
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- kevinhwang91/nvim-ufo settings
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
vim.o.foldcolumn = '1' -- '0' is not bad
-- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- folke/noice.nvim settings
vim.g.noice_ignored_filetypes = {
  'fugitiveblame',
  'fugitive',
  'gitcommit',
  'noice',
}

-- vim: ts=2 sts=2 sw=2 et
