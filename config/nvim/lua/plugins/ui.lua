return {
  -- Theme of choice, tokyonight
  -- https://github.com/folke/tokyonight.nvim
  {
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      vim.cmd.colorscheme(vim.g.colors_theme)
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
        vim.cmd.colorscheme(vim.g.colors_variant_dark)
      end,
      set_light_mode = function()
        vim.api.nvim_set_option_value('background', 'light', {})
        vim.cmd.colorscheme(vim.g.colors_variant_light)
      end,
    },
  },

  -- Remove all background colors to make nvim transparent
  -- https://github.com/xiyaowong/nvim-transparent
  { 'xiyaowong/nvim-transparent', opts = {} },

  -- Twilight is a Lua plugin for Neovim 0.5 that dims inactive
  -- portions of the code you're editing using TreeSitter.
  -- https://github.com/folke/twilight.nvim
  { 'folke/twilight.nvim', opts = {} },

  -- Indent guides for Neovim
  -- https://github.com/lukas-reineke/indent-blankline.nvim
  { 'lukas-reineke/indent-blankline.nvim', main = 'ibl', opts = {} },

  -- Git integration for buffers
  -- https://github.com/lewis6991/gitsigns.nvim
  {
    'lewis6991/gitsigns.nvim',
    lazy = false,
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      current_line_blame = false,
      on_attach = function(bufnr)
        local gs = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', 'gn', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gs.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true })

        map('n', 'gp', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gs.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true })
      end,
    },
  },

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
    lazy = false,
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

  -- Automatically expand width of the current window.
  -- Maximizes and restore it. And all this with nice animations!
  -- https://github.com/anuvyklack/windows.nvim
  {
    'anuvyklack/windows.nvim',
    dependencies = {
      'anuvyklack/middleclass',
      'anuvyklack/animation.nvim',
    },
    opts = {},
  },

  -- Plugin to improve viewing Markdown files in Neovim
  -- https://github.com/MeanderingProgrammer/render-markdown.nvim
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    ft = 'markdown',
    opts = {},
  },
}
