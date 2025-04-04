return {
  -- A collection of small QoL plugins for Neovim
  -- https://github.com/folke/snacks.nvim
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      input = { enabled = true },
      notifier = {
        enabled = true,
        timeout = 3000,
      },
      gitbrowse = { enabled = true },
      quickfile = { enabled = true },
      statuscolumn = {
        enabled = true,
        left = { 'mark', 'sign' }, -- priority of signs on the left (high to low)
        right = { 'fold', 'git' }, -- priority of signs on the right (high to low)
        folds = {
          open = true, -- show open fold icons
          git_hl = false, -- use Git Signs hl for fold icons
        },
        git = {
          -- patterns to match Git signs
          patterns = { 'GitSign', 'MiniDiffSign' },
        },
        refresh = 50, -- refresh at most every 50ms
      },
      words = { enabled = true },
      styles = {
        notification = {
          wo = { wrap = true }, -- Wrap notifications
        },
      },
    },
  },

  -- Highly experimental plugin that completely
  -- replaces the UI for messages, cmdline and the popupmenu.
  -- https://github.com/folke/noice.nvim
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    },
    opts = {
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
        },
      },
      -- you can enable a preset for easier configuration
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false, -- add a border to hover docs and signature help
      },
      routes = {
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
          border = {
            style = 'none',
            padding = { 1, 2 },
          },
          filter_options = {},
          win_options = {
            winhighlight = 'NormalFloat:NormalFloat,FloatBorder:FloatBorder',
          },
        },
      },
    },
  },

  -- A pretty diagnostics, references, telescope results,
  -- quickfix and location list to help you solve all the
  -- trouble your code is causing.
  -- https://github.com/folke/trouble.nvim
  {
    'folke/trouble.nvim',
    lazy = false,
    cmd = 'Trouble',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      auto_preview = true,
      auto_fold = true,
      auto_close = true,
      use_lsp_diagnostic_signs = true,
      keys = {
        j = 'next',
        k = 'prev',
      },
      modes = {
        diagnostics = {
          auto_open = false,
        },
        test = {
          mode = 'diagnostics',
          preview = {
            type = 'split',
            relative = 'win',
            position = 'right',
            size = 0.25,
          },
        },
        cascade = {
          mode = 'diagnostics', -- inherit from diagnostics mode
          filter = function(items)
            local severity = vim.diagnostic.severity.HINT
            for _, item in ipairs(items) do
              severity = math.min(severity, item.severity)
            end
            return vim.tbl_filter(
              function(item) return item.severity == severity end,
              items
            )
          end,
        },
      },
    },
  },
}
