return {
  {
    'neanias/everforest-nvim',
    version = false,
    lazy = false,
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require('everforest').setup {
        background = 'soft', -- hard, medium, soft
        transparent_background_level = 0, -- 0, 1, 2
        sign_column_background = 'none', -- none, dimmed, normal
        disable_italic_comments = false,
        diagnostic_virtual_text = 'coloured', -- coloured, gray, underline, none
        diagnostic_line_highlight = true,
        diagnostic_line_highlight_background = 'dimmed', -- dimmed, normal
        diagnostic_text_highlight = true,
        ui_contrast = 'low', -- high, low
        italics = true,
        spell_foreground = true,
        show_eob = true,
        colours_override = function() end,
        float_style = 'dim',
        on_highlights = function(_, _) end,
        dim_inactive_windows = true,
        inlay_hints_background = 'dimmed',
      }
    end,
  },

  -- {
  --   'rose-pine/neovim',
  --   name = 'rose-pine',
  --   opts = {
  --     dim_inactive_windows = false,
  --     extend_background_behind_borders = true,
  --     styles = {
  --       bold = true,
  --       italic = true,
  --       transparency = true,
  --     },
  --     enable = {
  --       terminal = true,
  --       legacy_highlights = true, -- Improve compatibility for previous versions of Neovim
  --       migrations = true, -- Handle deprecated options automatically
  --     },
  --   },
  --   config = function() vim.cmd 'colorscheme rose-pine' end,
  -- },

  -- Automatic dark mode
  -- https://github.com/f-person/auto-dark-mode.nvim
  {
    'f-person/auto-dark-mode.nvim',
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        vim.api.nvim_set_option_value('background', 'dark', {})
        -- vim.cmd.colorscheme(vim.g.colors_variant_dark)
        -- vim.cmd 'colorscheme rose-pine'
      end,
      set_light_mode = function()
        vim.api.nvim_set_option_value('background', 'light', {})
        -- vim.cmd.colorscheme(vim.g.colors_variant_light)
        -- vim.cmd 'colorscheme rose-pine-dawn'
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
  -- {
  --   'xiyaowong/nvim-transparent',
  --   lazy = false,
  --   enabled = false,
  --   config = function()
  --     local t = require 'transparent'
  --     t.setup {
  --       extra_groups = {
  --         'NormalNC',
  --         'NormalFloat',
  --         'FloatTitle',
  --         'FloatBorder',
  --         'NotifyDEBUGBorder',
  --         'NotifyERRORBorder',
  --         'NotifyINFOBorder',
  --         'NotifyINFOBorder73',
  --         'NotifyINFOBorder75',
  --         'NotifyINFOBorder101',
  --         'NotifyTRACEBorder',
  --         'NotifyWARNBorder',
  --         'TelescopeBorder',
  --         'TelescopePromptBorder',
  --         'TelescopeResultsBorder',
  --         'TelescopePreviewBorder',
  --       },
  --     }
  --     t.clear_prefix 'NeoTree'
  --   end,
  -- },

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
    opts = {
      restriction_mode = 'hint',
      disabled_keys = {
        ['<Up>'] = { '', 'n' },
        ['<Down>'] = { '', 'n' },
        ['<Left>'] = { '', 'n' },
        ['<Right>'] = { '', 'n' },
        ['<C-Up>'] = { '', 'n' },
        ['<C-Down>'] = { '', 'n' },
        ['<C-Left>'] = { '', 'n' },
        ['<C-Right>'] = { '', 'n' },
      },
      disabled_filetypes = {
        'TelescopePrompt',
        'Trouble',
        'lazy',
        'mason',
        'help',
        'notify',
        'dashboard',
        'alpha',
      },
      hints = {
        ['[dcyvV][ia][%(%)]'] = {
          message = function(keys)
            return 'Use ' .. keys:sub(1, 2) .. 'b instead of ' .. keys
          end,
          length = 3,
        },
        ['[dcyvV][ia][%{%}]'] = {
          message = function(keys)
            return 'Use ' .. keys:sub(1, 2) .. 'B instead of ' .. keys
          end,
          length = 3,
        },
      },
    },
  },
}
