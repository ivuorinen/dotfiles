-- vim: ts=2 sts=2 sw=2 et

-- Install lazylazy
-- https://github.com/folke/lazy.nvim
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require 'options'
require 'keymaps'

require('lazy').setup {
  checker = {
    -- Automatically check for updates
    enabled = true,
  },
  spec = {
    -- Useful plugin to show you pending keybinds.
    -- https://github.com/folke/which-key.nvim
    {
      'folke/which-key.nvim',
      event = 'VimEnter', -- Sets the loading event to 'VimEnter'
      priority = 1001, -- Make sure to load this as soon as possible
      config = function() -- This is the function that runs, AFTER loading
        local wk = require 'which-key'
        wk.setup()

        wk.add {
          { '<leader>b', group = '[b] Buffer' },
          { '<leader>c', group = '[c] Code' },
          { '<leader>d', group = '[d] Document' },
          { '<leader>f', group = '[f] File' },
          { '<leader>g', group = '[g] Git' },
          { '<leader>l', group = '[l] LSP' },
          { '<leader>o', group = '[o] Open' },
          { '<leader>p', group = '[p] Project' },
          { '<leader>q', group = '[q] Quit' },
          { '<leader>s', group = '[s] Search' },
          { '<leader>t', group = '[t] Toggle' },
          { '<leader>w', group = '[w] Workspace' },
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

require 'config.misc'
