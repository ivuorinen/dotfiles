return {

  -- A better annotation generator.
  -- Supports multiple languages and annotation conventions.
  -- https://github.com/danymat/neogen
  { 'danymat/neogen', version = '*', opts = { enabled = true, snippet_engine = 'luasnip' } },

  -- The Refactoring library based off the Refactoring book by Martin Fowler
  -- https://github.com/ThePrimeagen/refactoring.nvim
  { 'ThePrimeagen/refactoring.nvim', dependencies = { 'nvim-lua/plenary.nvim', 'nvim-treesitter/nvim-treesitter' }, opts = {} },

  -- All the npm/yarn/pnpm commands I don't want to type
  -- https://github.com/vuki656/package-info.nvim
  { 'vuki656/package-info.nvim', dependencies = { 'MunifTanjim/nui.nvim' } },

  -- Add/change/delete surrounding delimiter pairs with ease. Written with ❤️ in Lua.
  -- https://github.com/kylechui/nvim-surround
  { 'kylechui/nvim-surround', version = '*', event = 'VeryLazy' },

  -- Highlight, list and search todo comments in your projects
  -- https://github.com/folke/todo-comments.nvim
  { 'folke/todo-comments.nvim', dependencies = { 'nvim-lua/plenary.nvim' }, opts = {} },

  -- Commenting
  -- "gc" to comment visual regions/lines
  -- https://github.com/numToStr/Comment.nvim
  { 'numToStr/Comment.nvim', event = { 'BufRead', 'BufNewFile' }, opts = {} },

  -- Detect tabstop and shiftwidth automatically
  -- https://github.com/tpope/vim-sleuth
  { 'tpope/vim-sleuth' },

  -- Vim plugin for automatic time tracking and metrics
  -- generated from your programming activity.
  -- https://github.com/wakatime/vim-wakatime
  { 'wakatime/vim-wakatime', lazy = false, enabled = true },
}
