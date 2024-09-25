return {
  -- A better annotation generator.
  -- Supports multiple languages and annotation conventions.
  -- https://github.com/danymat/neogen
  {
    'danymat/neogen',
    version = '*',
    keys = {
      {
        '<leader>cg',
        '<cmd>lua require("neogen").generate()<CR>',
        desc = 'Generate annotations',
      },
    },
    config = function()
      require('neogen').setup {
        enabled = true,
        snippet_engine = 'luasnip',
      }
    end,
  },

  -- Rethinking Vim as a tool for writing
  -- https://github.com/preservim/vim-pencil
  { 'preservim/vim-pencil' },

  -- surround.vim: Delete/change/add parentheses/quotes/XML-tags/much more with ease
  -- https://github.com/tpope/vim-surround
  { 'tpope/vim-surround' },

  -- Highlight, list and search todo comments in your projects
  -- https://github.com/folke/todo-comments.nvim
  {
    'folke/todo-comments.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    config = function()
      require('todo-comments').setup {}
    end,
  },

  -- Indent guides for Neovim
  -- https://github.com/lukas-reineke/indent-blankline.nvim
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
  },

  -- Commenting
  -- https://github.com/numToStr/Comment.nvim
  {
    'numToStr/Comment.nvim', -- "gc" to comment visual regions/lines
    event = { 'BufRead', 'BufNewFile' },
    config = function()
      require('Comment').setup()
    end,
  },

  -- Detect tabstop and shiftwidth automatically
  -- https://github.com/tpope/vim-sleuth
  { 'tpope/vim-sleuth' },

  -- Vim plugin for automatic time tracking and metrics
  -- generated from your programming activity.
  -- https://github.com/wakatime/vim-wakatime
  { 'wakatime/vim-wakatime', lazy = false, enabled = true },
}
