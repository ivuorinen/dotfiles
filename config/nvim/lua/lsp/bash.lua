require("lspconfig").bashls.setup({
  cmd = {
    "bash-language-server",
    "start",
  },
  filetypes = { "sh", "zsh" },
  capabilities = CAPABILITIES,
})
