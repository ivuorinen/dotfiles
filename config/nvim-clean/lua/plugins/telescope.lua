return {
  -- Fuzzy Finder (files, lsp, etc)
  -- https://github.com/nvim-telescope/telescope.nvim
  {
    'nvim-telescope/telescope.nvim',
    version = '*',
    dependencies = {
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-telescope/telescope-symbols.nvim' },

      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = vim.fn.executable 'make' == 1,
      },
    },
    setup = function()
      local t = require 'telescope'
      local a = require 'telescope.actions'
      local b = require 'telescope.builtin'
      local themes = require 'telescope.themes'
      require('telescope').load_extension 'harpoon'
      t.load_extension 'git_worktree'

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

      -- Enable telescope fzf native, if installed
      pcall(t.load_extension, 'fzf')

      -- See `:help telescope.builtin`
      vim.keymap.set('n', '<leader>so', b.oldfiles, { desc = '[?] Find recently opened files' })
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        b.current_buffer_fuzzy_find(themes.get_dropdown {
          winblend = 10,
          previewer = true,
        })
      end, { desc = '[/] Fuzzily search in current buffer]' })

      vim.keymap.set('n', '<leader>sf', b.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>sw', b.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', b.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', b.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sb', b.buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<leader>sS', b.git_status, { desc = '' })
      vim.keymap.set('n', '<leader>sm', ':Telescope harpoon marks<CR>', { desc = 'Harpoon [M]arks' })
      vim.keymap.set('n', '<Leader>sr', "<CMD>lua require('telescope').extensions.git_worktree.git_worktrees()<CR>")
      vim.keymap.set('n', '<Leader>sR', "<CMD>lua require('telescope').extensions.git_worktree.create_git_worktree()<CR>")
      vim.keymap.set('n', '<Leader>sn', "<CMD>lua require('telescope').extensions.notify.notify()<CR>")

      vim.api.nvim_set_keymap('n', 'st', ':TodoTelescope<CR>', { noremap = true })
      vim.api.nvim_set_keymap('n', '<Leader><tab>', "<Cmd>lua require('telescope.builtin').commands()<CR>", { noremap = false })
    end,
  },
}
