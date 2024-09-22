return {
  -- vscode-like pictograms for neovim lsp completion items
  -- https://github.com/onsails/lspkind-nvim
  { 'onsails/lspkind.nvim' },

  -- Rethinking Vim as a tool for writing
  -- https://github.com/preservim/vim-pencil
  { 'preservim/vim-pencil' },

  -- obsession.vim: continuously updated session files
  -- https://github.com/tpope/vim-obsession
  { 'tpope/vim-obsession' },

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

  -- LSP Configuration & Plugins
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
  },

  -- Meta type definitions for the Lua platform Luvit.
  -- https://github.com/Bilal2453/luvit-meta
  { 'Bilal2453/luvit-meta', lazy = true },

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
