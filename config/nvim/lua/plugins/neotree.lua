-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim
return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
    {
      -- This plugins prompts the user to pick a window and returns
      -- the window id of the picked window
      -- https://github.com/s1n7ax/nvim-window-picker
      's1n7ax/nvim-window-picker',
      version = '2.*',
      opts = {
        filter_rules = {
          include_current_win = false,
          autoselect_one = true,
          -- filter using buffer options
          bo = {
            -- if the file type is one of following, the window will be ignored
            filetype = { 'neo-tree', 'neo-tree-popup', 'notify' },
            -- if the buffer type is one of following, the window will be ignored
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
      winbar = true,
      statusline = false,
      separator = { left = '', right = '' },
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
          require('neo-tree.command').execute { action = 'close' }
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
        -- Change type
        added = '',
        modified = '',
        deleted = '✖',
        renamed = '󰁕',
        -- Status type
        untracked = '',
        ignored = '',
        unstaged = '󰄱',
        staged = '',
        conflict = '',
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
        hide_hidden = true, -- only works on Windows for hidden files/directories
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
}
