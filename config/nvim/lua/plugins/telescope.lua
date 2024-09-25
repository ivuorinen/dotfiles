return {
  -- Fuzzy Finder (files, lsp, etc)
  -- https://github.com/nvim-telescope/telescope.nvim
  'nvim-telescope/telescope.nvim',
  version = '*',
  lazy = false,
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-telescope/telescope-symbols.nvim' },
    { 'folke/which-key.nvim' },
    { 'ThePrimeagen/harpoon' },

    -- Fuzzy Finder Algorithm which requires local dependencies to be built.
    -- Only load if `make` is available
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = vim.fn.executable 'make' == 1,
    },
  },
  config = function()
    local t = require 'telescope'
    local a = require 'telescope.actions'
    local themes = require 'telescope.themes'

    -- [[ Configure Telescope ]]
    -- See `:help telescope` and `:help telescope.setup()`
    t.setup {
      defaults = {
        layout_strategy = 'horizontal',
        layout_config = {
          preview_width = 0.65,
          horizontal = {
            size = {
              width = '95%',
              height = '95%',
            },
          },
        },
        pickers = {
          find_files = {
            theme = 'dropdown',
          },
        },
        mappings = {
          i = {
            ['<C-u>'] = false,
            ['<C-j>'] = a.move_selection_next,
            ['<C-k>'] = a.move_selection_previous,
            ['<C-d>'] = a.move_selection_previous,
          },
        },
      },
    }

    -- Load extensions
    pcall(t.load_extension, 'harpoon')
    pcall(t.load_extension, 'git_worktree')
    -- Enable telescope fzf native, if installed
    pcall(t.load_extension, 'fzf')

    -- [[ Telescope Keymaps ]]
    -- See `:help telescope.builtin`
    -- See `:help telescope.keymap`
    local b = require 'telescope.builtin'

    local wk = require 'which-key'
    wk.add {
      { '<leader><space>', b.buffers, desc = '[ ] Find existing buffers' },
      { '<leader><tab>', "<Cmd>lua require('telescope.builtin').commands()<CR>", desc = 'Telescope: Commands' },
      { '<leader>sS', b.git_status, desc = 'Git Status' },
      { '<leader>sd', b.diagnostics, desc = 'Search Diagnostics' },
      { '<leader>sf', b.find_files, desc = 'Search Files' },
      { '<leader>sg', b.live_grep, desc = 'Search by Grep' },
      { '<leader>sm', ':Telescope harpoon marks<CR>', desc = 'Harpoon Marks' },
      { '<leader>sn', "<cmd>lua require('telescope').extensions.notify.notify()<CR>", desc = 'Notify' },
      { '<leader>so', b.oldfiles, desc = 'Find recently Opened files' },
      { '<leader>st', ':TodoTelescope<CR>', desc = 'Telescope: Todo' },
      { '<leader>sw', b.grep_string, desc = 'Search current Word' },
    }

    vim.keymap.set('n', '<leader>/', function()
      -- You can pass additional configuration to telescope to change theme, layout, etc.
      b.current_buffer_fuzzy_find(themes.get_dropdown {
        winblend = 10,
        previewer = true,
      })
    end, { desc = '[/] Fuzzily search in current buffer]' })
  end,
}
