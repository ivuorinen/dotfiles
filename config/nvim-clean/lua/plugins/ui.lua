return {
  -- Theme of choice, tokyonight
  -- https://github.com/folke/tokyonight.nvim
  {
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      vim.cmd.colorscheme 'tokyonight'
    end,
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
        vim.cmd 'colorscheme tokyonight-storm'
      end,
      set_light_mode = function()
        vim.api.nvim_set_option_value('background', 'light', {})
        vim.cmd 'colorscheme tokyonight-day'
      end,
    },
  },

  -- Remove all background colors to make nvim transparent
  -- https://github.com/xiyaowong/nvim-transparent
  { 'xiyaowong/nvim-transparent' },

  -- Twilight is a Lua plugin for Neovim 0.5 that dims inactive
  -- portions of the code you're editing using TreeSitter.
  -- https://github.com/folke/twilight.nvim
  {
    'folke/twilight.nvim',
    ft = 'markdown', -- Highlight markdown files
  },

  -- Seamless navigation between tmux panes and vim splits
  -- https://github.com/christoomey/vim-tmux-navigator
  {
    'christoomey/vim-tmux-navigator',
    lazy = false,
    enabled = true,
    cmd = {
      'TmuxNavigateLeft',
      'TmuxNavigateDown',
      'TmuxNavigateUp',
      'TmuxNavigateRight',
      'TmuxNavigatePrevious',
    },
    keys = {
      { '<c-h>', '<cmd><C-U>TmuxNavigateLeft<cr>' },
      { '<c-j>', '<cmd><C-U>TmuxNavigateDown<cr>' },
      { '<c-k>', '<cmd><C-U>TmuxNavigateUp<cr>' },
      { '<c-l>', '<cmd><C-U>TmuxNavigateRight<cr>' },
      { '<c-\\>', '<cmd><C-U>TmuxNavigatePrevious<cr>' },
    },
  },
  -- Cloak allows you to overlay *'s over defined patterns in defined files.
  -- https://github.com/laytan/cloak.nvim
  {
    'laytan/cloak.nvim',
    enabled = true,
    lazy = false,
    version = '*',
    config = function()
      require('cloak').setup {
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
      }
    end,
    keys = {
      { '<leader>tc', '<cmd>CloakToggle<cr>', desc = '[tc] Toggle Cloak' },
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
    lazy = false,
    enabled = true,
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
  {
    'LudoPinelli/comment-box.nvim',
    opts = {},
    init = function()
      local wk = require 'which-key'

      wk.add {
        { '<leader>cb', group = 'CommentBox' },
        { '<Leader>cbt', '<Cmd>CBccbox<CR>', desc = 'CommentBox: Box Title' },
        { '<Leader>cbd', '<Cmd>CBd<CR>', desc = 'Remove a box' },
        { '<Leader>cbl', '<Cmd>CBline<CR>', desc = 'CommentBox: Simple Line' },
        { '<Leader>cbm', '<Cmd>CBllbox14<CR>', desc = 'CommentBox: Marked' },
        { '<Leader>cbt', '<Cmd>CBllline<CR>', desc = 'CommentBox: Titled Line' },
      }
    end,
  },
  -- Automatically expand width of the current window.
  -- Maximizes and restore it. And all this with nice animations!
  -- https://github.com/anuvyklack/windows.nvim
  {
    'anuvyklack/windows.nvim',
    dependencies = {
      'anuvyklack/middleclass',
      'anuvyklack/animation.nvim',
    },
    config = function()
      vim.o.winwidth = 15
      vim.o.winminwidth = 10
      vim.o.equalalways = false
      require('windows').setup()
    end,
  },
}
