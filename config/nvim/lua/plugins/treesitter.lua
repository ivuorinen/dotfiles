-- Highlight, edit, and navigate code
-- https://github.com/nvim-treesitter/nvim-treesitter
return {
  'nvim-treesitter/nvim-treesitter',
  version = false, -- last release is way too old and doesn't work on Windows
  lazy = false,
  build = ':TSUpdate',
  opts = {
    auto_install = true, -- Auto install the parser generators
    sync_install = false, -- Sync install the parser generators, install async

    install_dir = vim.fn.stdpath 'data' .. '/site',

    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = {
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'regex',
      'yaml',
    },

    highlight = { enable = true },
    indent = { enable = true },
  },
  config = function(_, opts) require('nvim-treesitter').setup(opts) end,
}
