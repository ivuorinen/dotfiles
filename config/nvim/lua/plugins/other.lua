return {
  {
    'rmagatti/auto-session',
    lazy = false,
    version = '*',
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
