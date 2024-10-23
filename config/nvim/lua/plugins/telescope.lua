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

    -- A Telescope picker to quickly access configurations
    -- of plugins managed by lazy.nvim.
    -- https://github.com/polirritmico/telescope-lazy-plugins.nvim
    { 'polirritmico/telescope-lazy-plugins.nvim' },

    -- Neovim plugin. Telescope.nvim extension that adds LuaSnip integration.
    -- https://github.com/benfowler/telescope-luasnip.nvim
    { 'benfowler/telescope-luasnip.nvim' },

    -- Fuzzy Finder Algorithm which requires local dependencies to be built.
    -- Only load if `make` is available
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = vim.fn.executable 'make' == 1,
    },

    -- Import modules with ease
    -- https://github.com/piersolenski/telescope-import.nvim
    { 'piersolenski/telescope-import.nvim' },
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
      extensions = {
        lazy_plugins = {
          -- Must be a valid path to the file containing the lazy spec and setup() call.
          lazy_config = vim.fn.stdpath 'config' .. '/init.lua',
        },
        import = {
          -- Imports can be added at a specified line whilst keeping the cursor in place
          insert_at_top = true,
          -- Optionally support additional languages or modify existing languages...
          custom_languages = {
            {
              -- The filetypes that ripgrep supports (find these via `rg --type-list`)
              extensions = { 'js', 'ts' },
              -- The Vim filetypes
              filetypes = { 'vue' },
              -- Optionally set a line other than 1
              insert_at_line = 2, ---@type function|number
              -- The regex pattern for the import statement
              regex = [[^(?:import(?:[\"'\s]*([\w*{}\n, ]+)from\s*)?[\"'\s](.*?)[\"'\s].*)]],
            },
          },
        },
      },
    }

    -- Load extensions
    pcall(t.load_extension, 'harpoon')
    pcall(t.load_extension, 'git_worktree')
    pcall(t.load_extension, 'lazy_plugins')
    pcall(t.load_extension, 'luasnip')
    pcall(t.load_extension, 'import')

    -- Enable telescope fzf native, if installed
    pcall(t.load_extension, 'fzf')

    -- [[ Telescope Keymaps ]]
    -- See `:help telescope.builtin`
    -- See `:help telescope.keymap`
    vim.keymap.set('n', '<leader>/', function()
      -- You can pass additional configuration to telescope to change theme, layout, etc.
      require('telescope.builtin').current_buffer_fuzzy_find(
        themes.get_dropdown {
          winblend = 20,
          previewer = true,
        }
      )
    end, { desc = '[/] Fuzzily search in current buffer]' })
  end,
}
