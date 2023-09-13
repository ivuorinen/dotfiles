-- Completion for snippets.
-- luacheck: globals vim CAPABILITIES
local vim = vim
CAPABILITIES = vim.lsp.protocol.make_client_capabilities()
CAPABILITIES.textDocument.completion.completionItem.snippetSupport = true

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(client, bufnr)
  local nmap = function(keys, func, desc)
    if desc then desc = "LSP: " .. desc end

    vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
  end

  if client.server_capabilities.documentSymbolProvider then require("nvim-navic").attach(client, bufnr) end

  local wk = require("which-key")

  wk.register({
    l = {
      name = "+lsp",
      n = { vim.lsp.buf.rename, "Rename" },
      c = { vim.lsp.buf.code_action, "Code Action" },
      f = { "<cmd>Format", "Format current buffer with LSP" },
      D = { vim.lsp.buf.declaration, "[G]oto [D]eclaration" },
      w = {
        name = "[w]orkspace",
        a = { vim.lsp.buf.add_workspace_folder, "[w]orkspace: [a]dd folder" },
        r = { vim.lsp.buf.remove_workspace_folder, "[w]orkspace: [r]emove folder" },
        l = {
          function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
          "[w]orkspace [l]ist folders",
        },
      },
    },
    g = {
      name = "+goto",
      d = { vim.lsp.buf.definition, "[G]oto [D]efinition" },
      r = { require("telescope.builtin").lsp_references, "[G]oto [R]eferences" },
      I = { vim.lsp.buf.implementation, "[G]oto [I]mplementation" },
      D = { vim.lsp.buf.type_definition, "Type [D]efinition" },
      s = { require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols" },
      w = { require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols" },
    },
  }, { prefix = "<leader>" })

  -- See `:help K` for why this keymap
  nmap("K", vim.lsp.buf.hover, "Hover Documentation")
  nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

  -- Create a command `:Format` local to the LSP buffer
  -- vim.api.nvim_buf_create_user_command(
  --  bufnr,
  --  "Format",
  --  function(_) vim.lsp.buf.format() end,
  --  { desc = "Format current buffer with LSP" }
  -- )
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here.
--  They will automatically be installed.
--
--  Add any additional override configuration in the following
--  tables. They will be passed to the `settings` field of the
--  server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your
--  language server will attach to you can define the property
--  'filetypes' to the map in question.
local servers = {
  ansiblels = {},
  bashls = {},
  clangd = {},
  cssls = {
    cmd = { "vscode-css-language-server", "--stdio" },
    filetypes = { "css", "scss", "less" },
    -- root_dir  = root_pattern("package.json", ".git") or bufdir,
    settings = {
      css = {
        validate = true,
      },
      less = {
        validate = true,
      },
      scss = {
        validate = true,
      },
    },
    single_file_support = true,
    capabilities = CAPABILITIES,
  },
  diagnosticls = {},
  docker_compose_language_service = {},
  dockerls = {},
  eslint = {}, -- JS
  gopls = {},  -- Go
  graphql = {},
  html = { filetypes = { "html", "twig", "hbs" } },
  intelephense = {}, -- PHP
  jsonls = {
    json = {
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
    },
  },
  lua_ls = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
  marksman = {},      -- Markdown
  psalm = {},         -- PHP
  pylsp = {},         -- Python
  pyright = {},       -- Python
  rust_analyzer = {}, -- Rust
  terraformls = {},   -- Terraform
  tsserver = {},      -- TypeScript
  vuels = {},         -- Vue
  yamlls = {          -- YAML
    yaml = {
      schemaStore = {
        -- You must disable built-in schemaStore support if you want to use
        -- this plugin and its advanced options like `ignore`.
        enable = false,
        -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
        url = "",
      },
      schemas = require("schemastore").yaml.schemas(),
    },
  },
}

-- Setup neovim lua configuration
require("neodev").setup()

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = vim.tbl_keys(servers),
  automatic_installtion = true,
})
