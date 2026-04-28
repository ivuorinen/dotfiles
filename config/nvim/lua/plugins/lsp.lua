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
      -- Servers enabled in init.lua but absent from this list are expected
      -- to come from mise (or the system): `fish_lsp`, `taplo`. Keep this
      -- list in sync with `vim.lsp.enable {...}` in init.lua plus those
      -- mise/system exceptions.
      ensure_installed = {
        -- LSP servers (mason package names)
        'ansible-language-server',
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
        'goimports',
        'golangci-lint',
        'hadolint',
        'prettier',
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
