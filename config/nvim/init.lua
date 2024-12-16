-- ╭─────────────────────────────────────────────────────────╮
-- │            ivuorinen's Neovim configuration             │
-- ╰─────────────────────────────────────────────────────────╯

-- ── Install lazylazy ────────────────────────────────────────────────
-- https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
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

-- ── Add ~/.local/bin to the PATH ────────────────────────────────────
vim.fn.setenv(
  'PATH',
  vim.fn.expand '$HOME/.local/bin' .. ':' .. vim.fn.expand '$PATH'
)

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
    install = {
      colorscheme = { vim.g.colors_theme },
    },
  }
)

require('nvm-default').setup()

require 'keymaps'

-- vim: ts=2 sts=2 sw=2 et
