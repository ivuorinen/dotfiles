-- customize mason plugins
return { -- use mason-lspconfig to configure LSP installations
  {
    "williamboman/mason-lspconfig.nvim",
    -- overrides `require("mason-lspconfig").setup(...)`
    opts = {
      ensure_installed = {
        "ansiblels",
        "bashls",
        "clangd",
        "codeqlls",
        "cssls",
        "diagnosticls",
        "docker_compose_language_service",
        "dockerls",
        "emmet_ls",
        "eslint",
        "graphql",
        "html",
        "intelephense",
        "jsonls",
        "marksman",
        "psalm",
        "stylelint_lsp",
        "sqlls",
        "tailwindcss",
        "tsserver",
        "vuels",
        "yamlls",
      },
    },
  }, -- use mason-null-ls to configure Formatters/Linter installation for null-ls sources
  {
    "jay-babu/mason-null-ls.nvim",
    -- overrides `require("mason-null-ls").setup(...)`
    opts = {
      automatic_setup = true,
      automatic_installation = true,
    },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    -- overrides `require("mason-nvim-dap").setup(...)`
    opts = {
      automatic_installation = true,
      automatic_setup = true,
      ensure_installed = { "python", "php", "js", "bash" },
    },
  },
}
