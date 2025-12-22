return {
  {
    'ivuorinen/nvim-shellspec',
    ft = 'shellspec',
    config = function()
      require('shellspec').setup {
        auto_format = true,
        indent_size = 2,
        indent_comments = true,
      }
    end,
  },

  {
    'pablos123/shellcheck.nvim',
    config = function()
      require('shellcheck-nvim').setup {
        shellcheck_options = { '-x' },
      }
    end,
  },

  -- Go development plugin for Vim
  -- https://github.com/fatih/vim-go
  {
    'fatih/vim-go',
    config = function() end,
  },

  -- Clarify and beautify your comments using boxes and lines.
  -- https://github.com/LudoPinelli/comment-box.nvim
  {
    'LudoPinelli/comment-box.nvim',
    event = 'BufEnter',
    opts = {},
  },
}
