-- vim: ts=2 sts=2 sw=2 et

-- Install lazylazy
-- https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
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

require 'options'
require 'keymaps'

require('lazy').setup {
  checker = {
    -- Automatically check for updates
    enabled = true,
    nofity = false,
  },
  spec = {
    -- Useful plugin to show you pending keybinds.
    -- https://github.com/folke/which-key.nvim
    {
      'folke/which-key.nvim',
      lazy = false, -- Load this plugin lazily
      version = '*',
      priority = 1001, -- Make sure to load this as soon as possible
      dependencies = {
        'nvim-lua/plenary.nvim',
        'echasnovski/mini.icons',
      },
      config = function() -- This is the function that runs, AFTER loading
        local wk = require 'which-key'
        wk.setup()

        wk.add {
          { '<leader>b', group = '[b] Buffer' },
          { '<leader>c', group = '[c] Code' },
          { '<leader>d', group = '[d] Document' },
          { '<leader>g', group = '[g] Git' },
          { '<leader>l', group = '[l] LSP' },
          { '<leader>p', group = '[p] Project' },
          { '<leader>q', group = '[q] Quit' },
          { '<leader>s', group = '[s] Search' },
          { '<leader>t', group = '[t] Toggle' },
          { '<leader>w', group = '[w] Workspace' },
          { '<leader>x', group = '[z] Trouble' },
          { '<leader>z', group = '[x] FZF' },
          { '<leader>?', group = '[?] Help' },
          {
            '<leader>?w',
            function()
              wk.show { global = false }
            end,
            desc = 'Buffer Local Keymaps (which-key)',
          },
        }
      end,
    },
    -- Import plugins from `lua/plugins` directory
    { import = 'plugins' },
  },
}
