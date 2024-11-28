return {
  -- Theme of choice, tokyonight
  -- https://github.com/folke/tokyonight.nvim
  {
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function() vim.cmd.colorscheme(vim.g.colors_theme) end,
    opts = {
      transparent = true,
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

  -- Neovim plugin to animate the cursor with a smear effect in all terminals
  -- https://github.com/sphamba/smear-cursor.nvim
  { 'sphamba/smear-cursor.nvim', opts = {} },

  -- A neovim plugin that shows colorcolumn dynamically
  -- https://github.com/Bekaboo/deadcolumn.nvim
  { 'Bekaboo/deadcolumn.nvim' },

  -- vim dashboard
  -- https://github.com/nvimdev/dashboard-nvim
  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    config = function()
      require('dashboard').setup {
        theme = 'doom',
        config = {
          disable_move = true,
          week_header = {
            enable = true,
          },
          shortcut = {},
          center = {
            {
              icon = ' ',
              icon_hl = '@variable',
              desc = 'Files',
              group = 'Label',
              action = 'Telescope find_files',
              key = 'f',
            },
            {
              icon = ' ',
              desc = 'Marks',
              group = 'DiagnosticHint',
              action = 'Telescope harpoon marks',
              key = 'a',
            },
            {
              icon = '⚑ ',
              desc = 'TODO',
              group = 'DiagnosticOptions',
              action = 'TodoTelescope',
              key = 't',
            },
            {
              icon = ' ',
              desc = 'Search',
              group = 'Number',
              action = 'Telescope live_grep',
              key = 's',
            },
            {
              icon = '󰊳 ',
              desc = 'Lazy Update',
              group = '@property',
              action = 'Lazy update',
              key = 'u',
            },
            {
              icon = '☉ ',
              desc = 'Quit',
              group = 'DiagnosticError',
              action = 'q',
              key = 'q',
            },
          },
        },
      }
    end,
    dependencies = { { 'nvim-tree/nvim-web-devicons' } },
  },

  -- Remove all background colors to make nvim transparent
  -- https://github.com/xiyaowong/nvim-transparent
  { 'xiyaowong/nvim-transparent', opts = {} },

  -- Display a character as the colorcolumn
  -- https://github.com/lukas-reineke/virt-column.nvim
  { 'lukas-reineke/virt-column.nvim', opts = {} },

  -- ui components
  { 'MunifTanjim/nui.nvim', lazy = true },

  -- Seamless navigation between tmux panes and vim splits
  -- https://github.com/christoomey/vim-tmux-navigator
  {
    'christoomey/vim-tmux-navigator',
    cmd = {
      'TmuxNavigateLeft',
      'TmuxNavigateDown',
      'TmuxNavigateUp',
      'TmuxNavigateRight',
      'TmuxNavigatePrevious',
    },
    opts = {},
  },

  -- Cloak allows you to overlay *'s over defined patterns in defined files.
  -- https://github.com/laytan/cloak.nvim
  {
    'laytan/cloak.nvim',
    version = '*',
    opts = {
      enabled = true,
      cloak_character = '*',
      -- The applied highlight group (colors) on the cloaking, see `:h highlight`.
      highlight_group = 'Comment',
      patterns = {
        {
          -- Match any file starting with ".env".
          -- This can be a table to match multiple file patterns.
          file_pattern = {
            '.env*',
            'wrangler.toml',
            '.dev.vars',
          },
          -- Match an equals sign and any character after it.
          -- This can also be a table of patterns to cloak,
          -- example: cloak_pattern = { ":.+", "-.+" } for yaml files.
          cloak_pattern = '=.+',
        },
      },
    },
  },
  -- Close buffer without messing up with the window.
  -- https://github.com/famiu/bufdelete.nvim
  { 'famiu/bufdelete.nvim' },

  -- Neovim plugin for locking a buffer to a window
  -- https://github.com/stevearc/stickybuf.nvim
  { 'stevearc/stickybuf.nvim', opts = {} },

  -- Describe the regexp under the cursor
  -- https://github.com/bennypowers/nvim-regexplainer
  {
    'bennypowers/nvim-regexplainer',
    event = 'BufEnter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'MunifTanjim/nui.nvim',
    },
    opts = {
      -- automatically show the explainer when the cursor enters a regexp
      auto = true,
    },
  },

  -- Clarify and beautify your comments using boxes and lines.
  -- https://github.com/LudoPinelli/comment-box.nvim
  { 'LudoPinelli/comment-box.nvim', opts = {} },

  -- Plugin to improve viewing Markdown files in Neovim
  -- https://github.com/MeanderingProgrammer/render-markdown.nvim
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    ft = 'markdown',
    opts = {},
  },
}
