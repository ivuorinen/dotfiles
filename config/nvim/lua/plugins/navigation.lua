return {
  -- Fuzzy Finder (files, lsp, etc)
  -- https://github.com/nvim-telescope/telescope.nvim
  {
    'nvim-telescope/telescope.nvim',
    version = '*',
    lazy = true,
    cmd = 'Telescope',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },

      -- A Telescope picker to quickly access configurations
      -- of plugins managed by lazy.nvim.
      -- https://github.com/polirritmico/telescope-lazy-plugins.nvim
      { 'polirritmico/telescope-lazy-plugins.nvim' },
    },
    config = function()
      local t = require 'telescope'
      local a = require 'telescope.actions'

      local open_with_trouble = require('trouble.sources.telescope').open
      local add_to_trouble = require('trouble.sources.telescope').add

      t.setup {
        defaults = {
          vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--hidden',
            '--glob=!.git/',
          },
          preview = {
            filesize_limit = 0.1,
          },
          layout_strategy = 'horizontal',
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-j>'] = a.move_selection_next,
              ['<C-k>'] = a.move_selection_previous,
              ['<C-d>'] = a.move_selection_previous,
              ['<C-s>'] = a.cycle_previewers_next,
              ['<C-a>'] = a.cycle_previewers_prev,
              ['<C-t>'] = open_with_trouble,
              ['<C-q>'] = add_to_trouble,
            },
            n = {
              ['<C-t>'] = open_with_trouble,
              ['<C-q>'] = add_to_trouble,
            },
          },
        },
        pickers = {
          find_files = {
            find_command = {
              'fd',
              '--type',
              'f',
              '--hidden',
              '--strip-cwd-prefix',
              '--exclude',
              '.git',
              '--exclude',
              'node_modules',
              '--exclude',
              'vendor',
              '--exclude',
              '.DS_Store',
            },
          },
        },
        extensions = {
          lazy_plugins = {
            lazy_config = vim.fn.stdpath 'config' .. '/init.lua',
          },
        },
      }

      pcall(t.load_extension, 'lazy_plugins')
      pcall(t.load_extension, 'import')
      pcall(t.load_extension, 'noice')
    end,
  },

  -- Neo-tree is a Neovim plugin to browse the file system
  -- https://github.com/nvim-neo-tree/neo-tree.nvim
  {
    'nvim-neo-tree/neo-tree.nvim',
    version = '*',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
      {
        -- This plugins prompts the user to pick a window and returns
        -- the window id of the picked window
        -- https://github.com/s1n7ax/nvim-window-picker
        's1n7ax/nvim-window-picker',
        version = '3.*',
        opts = {
          filter_rules = {
            include_current_win = false,
            autoselect_one = true,
            bo = {
              filetype = { 'neo-tree', 'neo-tree-popup', 'notify' },
              buftype = { 'terminal', 'quickfix' },
            },
          },
        },
      },
    },
    cmd = 'Neotree',
    opts = {
      close_if_last_window = true,
      hide_root_node = true,
      popup_border_style = 'rounded',
      enable_git_status = true,
      enable_diagnostics = true,
      sources = {
        'filesystem',
        'buffers',
        'document_symbols',
      },
      source_selector = {
        winbar = false,
        statusline = false,
        separator = { left = '', right = '' },
        show_separator_on_edge = true,
        highlight_tab = 'SidebarTabInactive',
        highlight_tab_active = 'SidebarTabActive',
        highlight_background = 'StatusLine',
        highlight_separator = 'SidebarTabInactiveSeparator',
        highlight_separator_active = 'SidebarTabActiveSeparator',
      },
      event_handlers = {
        {
          event = 'file_opened',
          handler = function(_)
            local c = require 'neo-tree.command'
            c.execute { action = 'close' }
          end,
        },
      },
      default_component_configs = {
        indent = {
          padding = 0,
        },
        name = {
          use_git_status_colors = true,
          highlight_opened_files = true,
        },
      },
      git_status = {
        symbols = {
          added = '',
          modified = '',
          deleted = '✖',
          renamed = '󰁕',
          untracked = '',
          ignored = '',
          unstaged = '󰄱',
          staged = '',
          conflict = '',
        },
      },
      filesystem = {
        window = {
          mappings = {
            ['<Esc>'] = 'close_window',
            ['q'] = 'close_window',
            ['<cr>'] = 'open_with_window_picker',
          },
        },
        filtered_items = {
          hide_dotfiles = false,
          hide_hidden = true,
          never_show = {
            '.DS_Store',
          },
          hide_by_name = {
            'node_modules',
            '.git',
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
    ---@module 'trouble'
    'folke/trouble.nvim',
    cmd = 'Trouble',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    ---@type trouble.Config
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
          mode = 'diagnostics',
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

  -- Neovim plugin for locking a buffer to a window
  -- https://github.com/stevearc/stickybuf.nvim
  { 'stevearc/stickybuf.nvim', opts = {} },
}
