return {
  -- Highly experimental plugin that completely replaces the UI
  -- for messages, cmdline and the popupmenu.
  -- https://github.com/folke/noice.nvim
  {
    'folke/noice.nvim',
    dependencies = {
      'MunifTanjim/nui.nvim',
      -- A fancy, configurable, notification manager for NeoVim
      -- https://github.com/rcarriga/nvim-notify
      {
        'rcarriga/nvim-notify',
        config = function()
          require('notify').setup {
            background_colour = '#000000',
            enabled = false,
          }
        end,
      },
    },
    setup = function()
      vim.g.noice_ignored_filetypes = { 'fugitiveblame', 'fugitive', 'gitcommit' }
      require('noice').setup {
        -- you can enable a preset for easier configuration
        presets = {
          bottom_search = true, -- use a classic bottom cmdline for search
          command_palette = true, -- position the cmdline and popupmenu together
          long_message_to_split = true, -- long messages will be sent to a split
          inc_rename = false, -- enables an input dialog for inc-rename.nvim
          lsp_doc_border = false, -- add a border to hover docs and signature help
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
              winhighlight = { Normal = 'Normal', FloatBorder = 'DiagnosticInfo' },
            },
          },
        },
        routes = {
          {
            filter = {
              event = 'msg_show',
              any = {
                { find = '%d+L, %d+B' },
                { find = '; after #%d+' },
                { find = '; before #%d+' },
                { find = '%d fewer lines' },
                { find = '%d more lines' },
              },
            },
            opts = { skip = true },
          },
        },
      }
    end,
  },
}
