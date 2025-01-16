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
      bypass_save_filetypes = {
        'PlenaryTestPopup',
        'alpha',
        'checkhealth',
        'dashboard',
        'dbout',
        'gitsigns.blame',
        'grug-far',
        'help',
        'lspinfo',
        'man',
        'neo-tree',
        'neotest-output',
        'neotest-output-panel',
        'neotest-summary',
        'notify',
        'qf',
        'spectre_panel',
        'startuptime',
        'trouble',
        'tsplayground',
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
