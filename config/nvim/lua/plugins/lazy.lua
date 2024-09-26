return {
  -- A better annotation generator.
  -- Supports multiple languages and annotation conventions.
  -- https://github.com/danymat/neogen
  {
    'danymat/neogen',
    version = '*',
    opts = {
      enabled = true,
      snippet_engine = 'luasnip',
    },
  },

  -- The Refactoring library based off the Refactoring book by Martin Fowler
  -- https://github.com/ThePrimeagen/refactoring.nvim
  {
    'ThePrimeagen/refactoring.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('refactoring').setup()

      local r = require 'refactoring'

      vim.keymap.set('x', '<leader>re', function()
        r.refactor 'Extract Function'
      end)
      vim.keymap.set('x', '<leader>rf', function()
        r.refactor 'Extract Function To File'
      end)
      -- Extract function supports only visual mode
      vim.keymap.set('x', '<leader>rv', function()
        r.refactor 'Extract Variable'
      end)
      -- Extract variable supports only visual mode
      vim.keymap.set('n', '<leader>rI', function()
        r.refactor 'Inline Function'
      end)
      -- Inline func supports only normal
      vim.keymap.set({ 'n', 'x' }, '<leader>ri', function()
        r.refactor 'Inline Variable'
      end)
      -- Inline var supports both normal and visual mode

      vim.keymap.set('n', '<leader>rb', function()
        r.refactor 'Extract Block'
      end)
      vim.keymap.set('n', '<leader>rbf', function()
        r.refactor 'Extract Block To File'
      end)
      -- Extract block supports only normal mode
    end,
  },

  -- All the npm/yarn/pnpm commands I don't want to type
  -- https://github.com/vuki656/package-info.nvim
  {
    'vuki656/package-info.nvim',
    dependencies = { 'MunifTanjim/nui.nvim' },
  },

  -- Add/change/delete surrounding delimiter pairs with ease. Written with ❤️ in Lua.
  -- https://github.com/kylechui/nvim-surround
  {
    'kylechui/nvim-surround',
    version = '*', -- Use for stability; omit to use `main` branch for the latest features
    event = 'VeryLazy',
  },

  -- Highlight, list and search todo comments in your projects
  -- https://github.com/folke/todo-comments.nvim
  {
    'folke/todo-comments.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    opts = {},
  },

  -- Commenting
  -- https://github.com/numToStr/Comment.nvim
  {
    'numToStr/Comment.nvim', -- "gc" to comment visual regions/lines
    event = { 'BufRead', 'BufNewFile' },
    opts = {},
  },

  -- Detect tabstop and shiftwidth automatically
  -- https://github.com/tpope/vim-sleuth
  { 'tpope/vim-sleuth' },

  -- Vim plugin for automatic time tracking and metrics
  -- generated from your programming activity.
  -- https://github.com/wakatime/vim-wakatime
  { 'wakatime/vim-wakatime', lazy = false, enabled = true },
}
