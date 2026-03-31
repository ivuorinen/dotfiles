return {
  -- Fuzzy Finder (files, lsp, etc)
  -- https://github.com/nvim-telescope/telescope.nvim
  {
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

      local tst = 'trouble.sources.telescope'
      local open_with_trouble = function(...) require(tst).open(...) end
      local add_to_trouble = function(...) require(tst).add(...) end

      t.setup {
        defaults = {
          vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            '--hidden',
            '--glob=!.git/',
            '--glob=!node_modules/',
            '--glob=!vendor/',
            '--glob=!.DS_Store',
          },
          preview = {
            filesize_limit = 0.1,
          },
          layout_strategy = 'horizontal',
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-j>'] = a.move_selection_next,
              ['<C-k>'] = a.move_selection_previous,
              ['<C-d>'] = a.move_selection_previous,
              ['<C-s>'] = a.cycle_previewers_next,
              ['<C-a>'] = a.cycle_previewers_prev,
              ['<C-t>'] = open_with_trouble,
              ['<C-q>'] = add_to_trouble,
            },
            n = {
              ['<C-t>'] = open_with_trouble,
              ['<C-q>'] = add_to_trouble,
            },
          },
        },
        pickers = {
          find_files = {
            find_command = {
              'fd',
              '--type',
              'f',
              '--hidden',
              '--strip-cwd-prefix',
              '--exclude',
              '.git',
              '--exclude',
              'node_modules',
              '--exclude',
              'vendor',
              '--exclude',
              '.DS_Store',
            },
          },
        },
        extensions = {
          lazy_plugins = {
            lazy_config = vim.fn.stdpath 'config' .. '/init.lua',
          },
        },
      }

      pcall(t.load_extension, 'lazy_plugins')
      pcall(t.load_extension, 'import')
      pcall(t.load_extension, 'noice')
    end,
  },

  -- A pretty diagnostics, references, telescope results,
  -- quickfix and location list to help you solve all the
  -- trouble your code is causing.
  -- https://github.com/folke/trouble.nvim
  {
    'folke/trouble.nvim',
    cmd = 'Trouble',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      auto_close = true,
      preview = { type = 'main', scratch = true },
      keys = {
        j = 'next',
        k = 'prev',
      },
      modes = {
        diagnostics = {
          auto_open = false,
        },
        test = {
          mode = 'diagnostics',
          preview = {
            type = 'split',
            relative = 'win',
            position = 'right',
            size = 0.25,
          },
        },
        cascade = {
          mode = 'diagnostics',
          filter = function(items)
            local severity = vim.diagnostic.severity.HINT
            for _, item in ipairs(items) do
              severity = math.min(severity, item.severity)
            end
            return vim.tbl_filter(
              function(item) return item.severity == severity end,
              items
            )
          end,
        },
      },
    },
  },
}
