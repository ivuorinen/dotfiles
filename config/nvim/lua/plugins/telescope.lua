return {
  -- Fuzzy Finder (files, lsp, etc)
  -- https://github.com/nvim-telescope/telescope.nvim
  'nvim-telescope/telescope.nvim',
  version = '*',
  lazy = true,
  cmd = 'Telescope',
  dependencies = {
    { 'nvim-lua/plenary.nvim' },
    { 'nvim-telescope/telescope-symbols.nvim' },

    -- Telescope plugin for file browsing
    { 'nvim-telescope/telescope-file-browser.nvim' },

    -- A Telescope picker to quickly access configurations
    -- of plugins managed by lazy.nvim.
    -- https://github.com/polirritmico/telescope-lazy-plugins.nvim
    { 'polirritmico/telescope-lazy-plugins.nvim' },

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
    local c = require 'telescope.config'

    local open_with_trouble = require('trouble.sources.telescope').open
    local add_to_trouble = require('trouble.sources.telescope').add

    -- Clone the default Telescope configuration
    local vimgrep_arguments = { unpack(c.values.vimgrep_arguments) }

    -- I want to search in hidden/dot files.
    table.insert(vimgrep_arguments, '--hidden=true')
    table.insert(vimgrep_arguments, '--glob')
    -- I don't want to search in the `.git` directory.
    table.insert(vimgrep_arguments, '!**/.git/*')

    -- [[ Configure Telescope ]]
    -- See `:help telescope` and `:help telescope.setup()`
    t.setup {
      defaults = {
        preview = {
          filesize_limit = 0.1, -- MB
        },
        -- `hidden = true` is not supported in text grep commands.
        vimgrep_arguments = vimgrep_arguments,

        layout_strategy = 'horizontal',
        pickers = {
          find_files = {
            -- `hidden = true` will still show the inside of `.git/` as
            -- it's not `.gitignore`d.
            find_command = { 'rg', '--files', '--hidden', '--glob', '!**/.git/*' },
            theme = 'dropdown',
          },
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
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<CR>',
          node_incremental = '<CR>',
          scope_incremental = '<TAB>',
          node_decremental = '<S-TAB>',
        },
      },
      context_commentstring = {
        enable = true,
        enable_autocmd = false,
      },
      extensions = {
        lazy_plugins = {
          -- Must be a valid path to the file containing the lazy spec and setup() call.
          lazy_config = vim.fn.stdpath 'config' .. '/init.lua',
        },
      },
    }

    -- Load extensions
    pcall(t.load_extension, 'git_worktree')
    pcall(t.load_extension, 'lazy_plugins')
    pcall(t.load_extension, 'luasnip')
    pcall(t.load_extension, 'import')

    -- Enable telescope fzf native, if installed
    pcall(t.load_extension, 'fzf')

    -- [[ Telescope Keymaps ]]
    -- See `:help telescope.builtin`
    -- See `:help telescope.keymap`
  end,
}
