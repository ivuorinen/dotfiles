local util = require("lspconfig.util")
-- local config = require 'lspconfig.configs'

-- This duplicate exec is just a workaruond, if don't execute at first,
-- the nvim will stuck when you first init rome socket
-- local rome_cmd = { 'rome', 'lsp-proxy' }

-- local merged_table = vim.tbl_extend("keep", {
--   textDocument = {
--     formatting = {
--       dynamicRegistration = true
--     }
--   }
-- }, capabilities);
--
require("lspconfig").rome.setup({
  -- cmd = rome_cmd,
  -- filetypes = {
  --   'javascript',
  --   'javascriptreact',
  --   'typescript',
  --   'typescriptreact',
  --   'json'
  -- },
  root_dir = util.root_pattern("rome.json"),
  single_file_support = true,
  on_attach = function(client, bufnr)
    if client.server_capabilities.documentSymbolProvider then require("nvim-navic").attach(client, bufnr) end
  end,
  capabilities = CAPABILITIES,
})
