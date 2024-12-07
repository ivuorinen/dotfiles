-- Useful plugin to show you pending keybinds.
-- https://github.com/folke/which-key.nvim
return {
  'folke/which-key.nvim',
  lazy = false,
  version = '*',
  priority = 1001, -- Make sure to load this as soon as possible
  dependencies = {
    'nvim-lua/plenary.nvim',
    'echasnovski/mini.icons',
  },
  config = function()
    local wk = require 'which-key'
    wk.setup()

    wk.add {
      -- ── LSP ─────────────────────────────────────────────────────────────
      {
        'dn',
        '<cmd>lua vim.diagnostic.goto_next()<CR>',
        desc = 'Diagnostic: Goto Next',
      },
      {
        'dp',
        '<cmd>lua vim.diagnostic.goto_prev()<CR>',
        desc = 'Diagnostic: Goto Prev',
      },
      {
        'gD',
        '<cmd>lua vim.lsp.buf.declaration()<CR>',
        desc = 'LSP: Goto Declaration',
      },
      {
        'gI',
        '<cmd>lua vim.lsp.buf.implementation()<CR>',
        desc = 'LSP: Goto Implementation',
      },
      {
        'gR',
        '<cmd>Trouble lsp_references<cr>',
        desc = 'Toggle LSP References',
      },
      {
        'gd',
        '<cmd>lua vim.lsp.buf.definition()<CR>',
        desc = 'LSP: Goto Definition',
      },
      {
        'gr',
        '<cmd>lua require("telescope.builtin").lsp_references()<CR>',
        desc = 'LSP: Goto References',
      },
    }
  end,
}
