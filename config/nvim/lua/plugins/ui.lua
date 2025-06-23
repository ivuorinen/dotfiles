return {
  {
    'rmehri01/onenord.nvim',
    opts = {},
  },
  -- Automatic dark mode
  -- https://github.com/f-person/auto-dark-mode.nvim
  {
    'f-person/auto-dark-mode.nvim',
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        vim.api.nvim_set_option_value('background', 'dark', {})
        -- vim.cmd.colorscheme(vim.g.colors_variant_dark)
      end,
      set_light_mode = function()
        vim.api.nvim_set_option_value('background', 'light', {})
        -- vim.cmd.colorscheme(vim.g.colors_variant_light)
      end,
    },
  },

  -- The fastest Neovim colorizer
  -- https://github.com/catgoose/nvim-colorizer.lua
  {
    'catgoose/nvim-colorizer.lua',
    event = 'BufReadPre',
    opts = {
      user_default_options = {
        names = false,
      },
    },
  },

  -- Remove all background colors to make nvim transparent
  -- https://github.com/xiyaowong/nvim-transparent
  {
    'xiyaowong/nvim-transparent',
    lazy = false,
    config = function()
      local t = require 'transparent'
      t.setup {
        extra_groups = {
          'NormalNC',
          'NormalFloat',
          'FloatBorder',
          'TelescopeBorder',
          'TelescopePromptBorder',
          'TelescopeResultsBorder',
          'TelescopePreviewBorder',
        },
      }
      t.clear_prefix 'NeoTree'
    end,
  },

  -- Display a character as the colorcolumn
  -- https://github.com/lukas-reineke/virt-column.nvim
  { 'lukas-reineke/virt-column.nvim', opts = {} },

  -- Neovim plugin for locking a buffer to a window
  -- https://github.com/stevearc/stickybuf.nvim
  { 'stevearc/stickybuf.nvim', opts = {} },

  -- Break bad habits, master Vim motions
  -- https://github.com/m4xshen/hardtime.nvim
  {
    'm4xshen/hardtime.nvim',
    lazy = false,
    dependencies = { 'MunifTanjim/nui.nvim' },
    opts = {},
  },
}
