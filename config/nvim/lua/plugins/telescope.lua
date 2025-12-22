return {
  -- Fuzzy Finder (files, lsp, etc)
  -- https://github.com/nvim-telescope/telescope.nvim
  'nvim-telescope/telescope.nvim',
  version = '*',
  lazy = true,
  cmd = 'Telescope',
  dependencies = {
    { 'nvim-lua/plenary.nvim' },

    -- A Telescope picker to quickly access configurations
    -- of plugins managed by lazy.nvim.
    -- https://github.com/polirritmico/telescope-lazy-plugins.nvim
    { 'polirritmico/telescope-lazy-plugins.nvim' },
  },
  config = function()
    local t = require 'telescope'
    local a = require 'telescope.actions'

    local open_with_trouble = require('trouble.sources.telescope').open
    local add_to_trouble = require('trouble.sources.telescope').add

    -- [[ Configure Telescope ]]
    -- See `:help telescope` and `:help telescope.setup()`
    t.setup {
      defaults = {
        preview = {
          filesize_limit = 0.1, -- MB
        },
        layout_strategy = 'horizontal',
        pickers = {
          mappings = {
            i = {
              ['<C-s>'] = a.cycle_previewers_next,
              ['<C-a>'] = a.cycle_previewers_prev,
            },
          },
        },
        mappings = {
          i = {
            ['<C-u>'] = false,
            ['<C-j>'] = a.move_selection_next,
            ['<C-k>'] = a.move_selection_previous,
            ['<C-d>'] = a.move_selection_previous,
            ['<C-t>'] = open_with_trouble,
            ['<C-q>'] = add_to_trouble,
          },
          n = {
            ['<C-t>'] = open_with_trouble,
            ['<C-q>'] = add_to_trouble,
          },
        },
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      extensions = {
        lazy_plugins = {
          -- Must be a valid path to the file containing the lazy spec and setup() call.
          lazy_config = vim.fn.stdpath 'config' .. '/init.lua',
        },
      },
    }

    -- Load extensions
    pcall(t.load_extension, 'lazy_plugins')
    pcall(t.load_extension, 'import')
  end,
}
