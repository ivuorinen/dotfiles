-- A pretty diagnostics, references, telescope results,
-- quickfix and location list to help you solve all the
-- trouble your code is causing.
-- https://github.com/folke/trouble.nvim
return {
  'folke/trouble.nvim',
  lazy = false,
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    auto_preview = true,
    auto_fold = true,
    auto_close = true,
    use_lsp_diagnostic_signs = true,
  },
}
