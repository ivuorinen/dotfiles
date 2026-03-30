-- ╭─────────────────────────────────────────────────────────╮
-- │            ivuorinen's Neovim configuration             │
-- ╰─────────────────────────────────────────────────────────╯

-- ── Install lazy ────────────────────────────────────────────────────
-- https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
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
vim.env.PATH = vim.env.HOME
  .. '/.local/share/mise/shims:'
  .. vim.env.HOME
  .. '/.local/bin:'
  .. vim.env.PATH

require 'options'
require 'autogroups'

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
  'gopls',
  'html',
  'intelephense',
  'jsonls',
  'lua_ls',
  'pyright',
  'tailwindcss',
  'terraformls',
  'ts_ls',
  'vimls',
  'yamlls',
}

require 'keymaps'

-- vim: set ts=2 sts=2 sw=2 wrap et :
