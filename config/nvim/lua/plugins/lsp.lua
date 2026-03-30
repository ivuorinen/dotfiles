-- ╭─────────────────────────────────────────────────────────╮
-- │               LSP Setup and configuration               │
-- ╰─────────────────────────────────────────────────────────╯
-- Server definitions live in lsp/*.lua files.
-- vim.lsp.config + vim.lsp.enable are called from init.lua.

return {
  {
    'williamboman/mason.nvim',
    lazy = false,
    opts = {},
  },

  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    opts = {
      auto_install = true,
      auto_update = true,
      ensure_installed = {
        -- LSP servers (mason package names)
        'ansible-language-server',
        'ast-grep',
        'bash-language-server',
        'css-lsp',
        'dockerfile-language-server',
        'eslint-lsp',
        'gopls',
        'html-lsp',
        'intelephense',
        'json-lsp',
        'lua-language-server',
        'pyright',
        'tailwindcss-language-server',
        'terraform-ls',
        'typescript-language-server',
        'vim-language-server',
        'yaml-language-server',
        -- Tools
        'actionlint',
        'ansible-lint',
        'golangci-lint',
        'hadolint',
        'shfmt',
        'stylua',
        'shellcheck',
      },
    },
  },

  {
    'zapling/mason-conform.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    opts = {},
  },
}
