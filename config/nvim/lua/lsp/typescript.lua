require("lspconfig").tsserver.setup({
  capabilities = CAPABILITIES,
  on_attach = function(client, bufnr)
    if client.server_capabilities.documentSymbolProvider then require("nvim-navic").attach(client, bufnr) end
  end,
})
