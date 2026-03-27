return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      require('catppuccin').setup {
        flavour = 'auto',
        background = {
          light = 'latte',
          dark = 'mocha',
        },
        transparent_background = false,
        show_end_of_buffer = false,
        term_colors = true,
        dim_inactive = {
          enabled = true,
          shade = 'dark',
          percentage = 0.15,
        },
        styles = {
          comments = { 'italic' },
          conditionals = { 'italic' },
        },
        default_integrations = true,
        auto_integrations = true,
        integrations = {
          mini = {
            enabled = true,
            indentscope_color = '',
          },
        },
      }

      vim.cmd.colorscheme 'catppuccin'
    end,
  },

  -- Automatic dark mode
  -- https://github.com/f-person/auto-dark-mode.nvim
  {
    'f-person/auto-dark-mode.nvim',
    opts = {
      update_interval = 1000,
      -- stylua: ignore
      set_dark_mode = function()
        vim.api.nvim_set_option_value('background', 'dark', {})
      end,
      set_light_mode = function()
        vim.api.nvim_set_option_value('background', 'light', {})
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

  -- Highly experimental plugin that completely
  -- replaces the UI for messages, cmdline and the popupmenu.
  -- https://github.com/folke/noice.nvim
  {
    ---@module 'noice'
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {
      'MunifTanjim/nui.nvim',
      {
        'rcarriga/nvim-notify',
        opts = { background_colour = '#1e1e2e' },
      },
    },
    opts = {
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
      routes = {
        {
          filter = { event = 'msg_showmode' },
          opts = { skip = true },
        },
        {
          filter = {
            event = 'msg_show',
            kind = '',
            any = {
              { find = 'written' },
              { find = '%d of %d --%d%--' },
            },
          },
          opts = { skip = true },
        },
        {
          filter = {
            event = 'msg_show',
            any = {
              { find = '%d+L, %d+B' },
              { find = '; after #%d+' },
              { find = '; before #%d+' },
              { find = "' added to" },
            },
          },
          view = 'mini',
        },
        {
          filter = {
            event = 'lsp',
            kind = 'progress',
            cond = function(message)
              local client = vim.tbl_get(message.opts, 'progress', 'client')
              return client == 'lua_ls'
            end,
          },
          opts = { skip = true },
        },
      },
      views = {
        cmdline_popup = {
          position = {
            row = 5,
            col = '50%',
          },
          size = {
            width = 60,
            height = 'auto',
          },
        },
        popupmenu = {
          relative = 'editor',
          position = {
            row = 8,
            col = '50%',
          },
          size = {
            width = 60,
            height = 10,
          },
          border = {
            style = 'rounded',
            padding = { 0, 1 },
          },
          win_options = {
            winhighlight = {
              Normal = 'Normal',
              FloatBorder = 'DiagnosticInfo',
            },
          },
        },
      },
    },
  },

  -- xiyaowong/transparent.nvim
  {
    'xiyaowong/transparent.nvim',
    init = function() vim.g.transparent_enabled = true end,
  },
}
