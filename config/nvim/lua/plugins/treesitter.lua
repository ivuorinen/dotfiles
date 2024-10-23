-- Highlight, edit, and navigate code
-- https://github.com/nvim-treesitter/nvim-treesitter
return {
  'nvim-treesitter/nvim-treesitter',
  version = false, -- last release is way too old and doesn't work on Windows
  build = function()
    pcall(require('nvim-treesitter.install').update { with_sync = true })
  end,
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
    'nvim-treesitter/nvim-treesitter-refactor',
    'nvim-treesitter/nvim-treesitter-context',
    'JoosepAlviste/nvim-ts-context-commentstring',
  },
  config = function()
    require('nvim-treesitter.configs').setup {
      auto_install = true,
      ignore_install = {},
      sync_install = true,
      modules = {},

      -- Add languages to be installed here that you want installed for treesitter
      ensure_installed = {
        'bash',
        'c',
        'css',
        'diff',
        'go',
        'html',
        'javascript',
        'jsdoc',
        'json',
        'jsonc',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'python',
        'query',
        'regex',
        'rust',
        'sql',
        'terraform',
        'toml',
        'tsx',
        'typescript',
        'vim',
        'vimdoc',
        'xml',
        'yaml',
      },

      refactor = {
        navigation = {
          enable = true,
          -- Assign keymaps to false to disable them, e.g. `goto_definition = false`.
          keymaps = {
            goto_definition = '<leader>gnd',
            list_definitions = '<leader>gnD',
            list_definitions_toc = '<leader>gO',
            goto_next_usage = '<a-*>',
            goto_previous_usage = '<a-#>',
          },
        },
        smart_rename = {
          enable = true,
          -- Assign keymaps to false to disable them, e.g. `smart_rename = false`.
          keymaps = {
            smart_rename = 'grr',
          },
        },
        highlight_definitions = {
          enable = true,
          -- Set to false if you have an `updatetime` of ~100.
          clear_on_cursor_move = true,
        },
        highlight_current_scope = { enable = false },
      },
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<a-space>',
          node_incremental = '<a-space>',
          scope_incremental = '<c-s>',
          node_decremental = '<c-backspace>',
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ['aa'] = '@parameter.outer',
            ['ia'] = '@parameter.inner',
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
            ['ii'] = '@conditional.inner',
            ['ai'] = '@conditional.outer',
            ['il'] = '@loop.inner',
            ['al'] = '@loop.outer',
            ['at'] = '@comment.outer',
          },
        },
        move = {
          enable = true,
          set_jumps = true, -- whether to set jumps in the jumplist
          goto_next_start = {
            [']f'] = '@function.outer',
            [']]'] = '@class.outer',
          },
          goto_next_end = {
            [']F'] = '@function.outer',
            [']['] = '@class.outer',
          },
          goto_previous_start = {
            ['[f'] = '@function.outer',
            ['[['] = '@class.outer',
          },
          goto_previous_end = {
            ['[F'] = '@function.outer',
            ['[]'] = '@class.outer',
          },
        },
        swap = {
          enable = true,
          swap_next = {
            ['<leader>cn'] = '@parameter.inner',
          },
          swap_previous = {
            ['<leader>cP'] = '@parameter.inner',
          },
        },
      },
    }
  end,
}
