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
  opts = {
    auto_install = true,  -- Auto install the parser generators
    ignore_install = {},  -- List of parsers to ignore installing
    sync_install = false, -- Sync install the parser generators, install async
    -- modules = {},         -- Load only specific modules

    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = {
      'bash',
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
          goto_definition = '<leader>zgd',
          list_definitions = '<leader>zgl',
          list_definitions_toc = '<leader>zg0',
          goto_next_usage = '<a-n>',
          goto_previous_usage = '<a-p>',
        },
      },
      smart_rename = {
        enable = true,
        -- Assign keymaps to false to disable them, e.g. `smart_rename = false`.
        keymaps = {
          smart_rename = '<leader>zr',
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
    -- incremental_selection = {
    --   enable = true,
    --   keymaps = {
    --     init_selection = '<leader>zs',
    --     node_decremental = '<leader>zsd',
    --     node_incremental = '<leader>zsi',
    --     scope_decremental = '<leader>zsD',
    --     scope_incremental = '<leader>zsI',
    --   },
    -- },
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
      },
    },
  },
  config = function(_, opts)
    require('nvim-treesitter.configs').setup(opts)

    vim.api.nvim_create_autocmd({ "FileType" }, {
      callback = function()
        -- Set foldmethod to treesitter if available
        if require("nvim-treesitter.parsers").has_parser() then
          vim.opt.foldmethod = "expr"
          vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
        else
          -- Otherwise, set foldmethod to syntax
          vim.opt.foldmethod = "syntax"
        end

        vim.opt.foldlevel = 9    -- Open all folds by default
        vim.opt.foldnestmax = 99 -- Maximum fold nesting
      end,
    })
  end,
}
