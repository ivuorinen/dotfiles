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
  ---@type TSConfig
  opts = {
    auto_install = true, -- Auto install the parser generators
    sync_install = false, -- Sync install the parser generators, install async

    -- Add languages to be installed here that you want installed for treesitter
    ensure_installed = {
      'bash',
      'json',
      'jsonc',
      'lua',
      'luadoc',
      'markdown',
      'markdown_inline',
      'query',
      'regex',
      'vim',
      'vimdoc',
      'yaml',
    },

    highlight = { enable = true },
    indent = { enable = true },
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
      },
    },
  },
  config = function(_, opts)
    require('nvim-treesitter.configs').setup(opts)

    vim.api.nvim_create_autocmd({ 'FileType' }, {
      callback = function()
        -- Set foldmethod to treesitter if available
        if require('nvim-treesitter.parsers').has_parser() then
          vim.opt.foldmethod = 'expr'
          vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
        else
          -- Otherwise, set foldmethod to syntax
          vim.opt.foldmethod = 'syntax'
        end

        vim.opt.foldlevel = 9 -- Open all folds by default
        vim.opt.foldnestmax = 99 -- Maximum fold nesting
      end,
    })
  end,
}
