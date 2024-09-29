-- Fancier statusline
-- https://github.com/nvim-lualine/lualine.nvim
return {
  'nvim-lualine/lualine.nvim',
  dependencies = {
    'kyazdani42/nvim-web-devicons',
    'folke/noice.nvim',
  },
  config = function()
    local function diff_source()
      local gitsigns = vim.b.gitsigns_status_dict
      if gitsigns then
        return {
          added = gitsigns.added,
          modified = gitsigns.changed,
          removed = gitsigns.removed,
        }
      end
    end

    require('lualine').setup {
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
        lualine_a = {
          'mode',
        },
        lualine_b = {
          { 'b:gitsigns_head', icon = '' },
          { 'diff', source = diff_source },
          'diagnostics',
        },
        lualine_c = {
          'buffers',
          -- 'filename',
        },
        lualine_x = {
          -- 'fileformat',
          'filetype',
        },
        lualine_y = {
          -- 'progress'
        },
        lualine_z = {
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
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {},
      },
    }
  end,
}
