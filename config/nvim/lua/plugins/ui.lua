return {
  -- Theme of choice, tokyonight
  -- https://github.com/folke/tokyonight.nvim
  {
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function() vim.cmd.colorscheme(vim.g.colors_theme) end,
    opts = {
      transparent = true,
      on_colors = function(colors)
        colors.gitSigns = {
          add = colors.teal,
          change = colors.purple,
          delete = colors.red,
        }
      end,
      on_highlights = function(hl, c)
        local util = require 'tokyonight.util'
        local prompt = '#2d3149'

        hl.NeoTreeFileNameOpened = {
          fg = c.orange,
        }

        hl.GitSignsCurrentLineBlame = {
          fg = c.fg_gutter,
        }

        hl.StatusLine = {
          bg = util.darken(c.bg_dark, 0.98, '#000000'),
          fg = c.fg_dark,
        }
        hl.StatusLineComment = {
          bg = util.darken(c.bg_dark, 0.85, '#000000'),
          fg = c.comment,
        }

        hl.LineNrAbove = {
          fg = c.fg_gutter,
        }
        hl.LineNr = {
          fg = util.lighten(c.fg_gutter, 0.7),
        }
        hl.LineNrBelow = {
          fg = c.fg_gutter,
        }

        hl.MsgArea = {
          bg = util.darken(c.bg_dark, 0.85, '#000000'),
        }

        -- Spelling
        hl.SpellBad = {
          undercurl = true,
          sp = '#7F3A43',
        }

        -- Telescope
        hl.TelescopeNormal = {
          bg = c.bg_dark,
          fg = c.fg_dark,
        }
        hl.TelescopeBorder = {
          bg = c.bg_dark,
          fg = c.bg_dark,
        }
        hl.TelescopePromptNormal = {
          bg = prompt,
        }
        hl.TelescopePromptBorder = {
          bg = prompt,
          fg = prompt,
        }
        hl.TelescopePromptTitle = {
          bg = c.bg,
          fg = c.fg_dark,
        }
        hl.TelescopePreviewTitle = {
          bg = c.bg_dark,
          fg = c.bg_dark,
        }
        hl.TelescopeResultsTitle = {
          bg = c.bg_dark,
          fg = c.bg_dark,
        }

        -- Indent
        hl.MiniIndentscopeSymbol = {
          fg = util.darken(c.bg_highlight, 0.30),
        }
        hl.IblScope = {
          fg = util.darken(c.bg_highlight, 0.80),
        }

        -- Floaterm
        hl.Floaterm = {
          bg = prompt,
        }
        hl.FloatermBorder = {
          bg = prompt,
          fg = prompt,
        }

        -- Copilot
        hl.CopilotSuggestion = {
          fg = c.comment,
        }

        -- NeoTree
        hl.NeoTreeFileNameOpened = {
          fg = c.fg,
          bold = true,
        }
        hl.NvimTreeNormal = {
          bg = util.darken(c.bg_dark, 0.85, '#000000'),
        }
        hl.NvimTreeNormalNC = {
          bg = util.darken(c.bg_dark, 0.85, '#000000'),
        }
        hl.NvimTreeWinSeparator = {
          fg = util.darken(c.bg_dark, 0.85, '#000000'),
          bg = util.darken(c.bg_dark, 0.85, '#000000'),
        }
      end,
    },
  },

  -- Automatic dark mode
  -- https://github.com/f-person/auto-dark-mode.nvim
  {
    'f-person/auto-dark-mode.nvim',
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        vim.api.nvim_set_option_value('background', 'dark', {})
        vim.cmd.colorscheme(vim.g.colors_variant_dark)
      end,
      set_light_mode = function()
        vim.api.nvim_set_option_value('background', 'light', {})
        vim.cmd.colorscheme(vim.g.colors_variant_light)
      end,
    },
  },

  -- The fastest Neovim colorizer
  -- https://github.com/catgoose/nvim-colorizer.lua
  {
    'catgoose/nvim-colorizer.lua',
    opts = {
      user_default_options = {
        names = false,
      },
    },
  },

  -- A neovim plugin that shows colorcolumn dynamically
  -- https://github.com/Bekaboo/deadcolumn.nvim
  { 'Bekaboo/deadcolumn.nvim' },

  -- Remove all background colors to make nvim transparent
  -- https://github.com/xiyaowong/nvim-transparent
  { 'xiyaowong/nvim-transparent', opts = {} },

  -- Display a character as the colorcolumn
  -- https://github.com/lukas-reineke/virt-column.nvim
  { 'lukas-reineke/virt-column.nvim', opts = {} },

  -- Neovim plugin for locking a buffer to a window
  -- https://github.com/stevearc/stickybuf.nvim
  { 'stevearc/stickybuf.nvim', opts = {} },
}
