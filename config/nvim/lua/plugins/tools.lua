return {
  {
    'nvim-lua/plenary.nvim',
    version = '*',
    lazy = false,
  },

  -- Vim plugin for automatic time tracking and metrics
  -- generated from your programming activity.
  -- https://github.com/wakatime/vim-wakatime
  { 'wakatime/vim-wakatime', lazy = false, enabled = true },

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

  -- Clarify and beautify your comments using boxes and lines.
  -- https://github.com/LudoPinelli/comment-box.nvim
  {
    'LudoPinelli/comment-box.nvim',
    event = 'BufEnter',
    opts = {},
  },
}
