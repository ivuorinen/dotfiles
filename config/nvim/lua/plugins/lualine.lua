-- Fancier statusline
-- https://github.com/nvim-lualine/lualine.nvim
return {
  'nvim-lualine/lualine.nvim',
  dependencies = {
    'kyazdani42/nvim-web-devicons',
    'folke/noice.nvim',
  },
  opts = {
    options = {
      icons_enabled = true,
      component_separators = '|',
      section_separators = '',
    },
    -- Sections
    -- +-------------------------------------------------+
    -- | A | B | C                             X | Y | Z |
    -- +-------------------------------------------------+
    sections = {
      lualine_b = {
        {
          'buffers',
        },
      },

      lualine_x = {
        {
          require('noice').api.statusline.mode.get,
          cond = require('noice').api.statusline.mode.has,
        },
        {
          require('noice').api.status.command.get,
          cond = require('noice').api.status.command.has,
        },
      },
    },
  },
}
