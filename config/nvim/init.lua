-- ╭─────────────────────────────────────────────────────────╮
-- │            ivuorinen's Neovim configuration             │
-- ╰─────────────────────────────────────────────────────────╯

-- ── Install lazy ────────────────────────────────────────────────────
-- https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
---@diagnostic disable-next-line: undefined-field
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    lazyrepo,
    lazypath,
  }
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- ── Add mise shims and ~/.local/bin to the PATH ───────────────────────
-- Guarded so `:source $MYVIMRC` doesn't duplicate entries each time.
local function _path_prepend(p)
  if vim.env.PATH:find(p, 1, true) == nil then vim.env.PATH = p .. ':' .. vim.env.PATH end
end
_path_prepend(vim.env.HOME .. '/.local/bin')
_path_prepend(vim.env.HOME .. '/.local/share/mise/shims')

-- nvim 0.12+ niceness
require('vim._core.ui2').enable {}

require 'options'
require 'autogroups'
require 'utils' -- registers K + HasConfig/Gated/TOOL_CONFIGS globals

-- ── Load plugins ────────────────────────────────────────────────────
require('lazy').setup(
  -- Automatically load plugins from lua/plugins
  'plugins',
  -- Lazy Configuration
  {
    checker = {
      -- Automatically check for updates
      enabled = true,
      -- We don't want to be notified about updates
      notify = false,
    },
    change_detection = {
      -- No need to notify about changes
      notify = false,
    },
    dev = {
      path = '~/Code/nvim', -- Load wip plugins from this path
    },
    install = {
      colorscheme = { 'catppuccin' },
    },
    profiling = {
      loader = true,
    },
  }
)

-- ── Native LSP setup (after lazy so blink.cmp is available) ─────────
vim.lsp.config('*', {
  capabilities = require('blink.cmp').get_lsp_capabilities(),
})
vim.lsp.enable {
  'ansiblels',
  'bashls',
  'cssls',
  'dockerls',
  'eslint',
  'fish_lsp',
  'gopls',
  'html',
  'intelephense',
  'jsonls',
  'lua_ls',
  'pyright',
  'tailwindcss',
  'taplo',
  'terraformls',
  'ts_ls',
  'vimls',
  'yamlls',
}

require 'keymaps'

-- vim: set ts=2 sts=2 sw=2 wrap et :
