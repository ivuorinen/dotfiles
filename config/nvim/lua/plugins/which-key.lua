-- Useful plugin to show you pending keybinds.
-- https://github.com/folke/which-key.nvim
return {
  'folke/which-key.nvim',
  lazy = false,
  version = '*',
  priority = 1001, -- Make sure to load this as soon as possible
  dependencies = {
    'nvim-lua/plenary.nvim',
    'echasnovski/mini.icons',
  },
  config = function()
    local wk = require 'which-key'
    wk.setup()

    wk.add {
      -- Groups
      {
        '<leader>b',
        group = '[b] Buffer',
        expand = function()
          return require('which-key.extras').expand.buf()
        end,
      },
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
      { '<leader>z', group = '[x] FZF & Harpoon' },
      { '<leader>?', group = '[?] Help' },
      {
        '<leader>?w',
        function()
          wk.show { global = false }
        end,
        desc = 'Buffer Local Keymaps (which-key)',
      },
      -- Misc keybinds
      { 'QQ', ':q!<CR>', desc = 'Quit without saving' },
    }
  end,
}
