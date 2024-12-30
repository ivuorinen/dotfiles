return {
  {
    'rmagatti/auto-session',
    lazy = false,
    version = '*',
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      suppressed_dirs = {
        '/',
        '~/',
        '~/Downloads',
        '~/Library',
      },
      -- log_level = 'debug',
    },
  },

  {
    'nvim-lua/plenary.nvim',
    version = '*',
    lazy = false,
  },
}
