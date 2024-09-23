return {
  'folke/trouble.nvim',
  lazy = false,
  dependencies = 'nvim-tree/nvim-web-devicons',
  keys = {
    { '<leader>xx', '<cmd>TroubleToggle<cr>', desc = 'Toggle Trouble' },
    { '<leader>xw', '<cmd>TroubleToggle workspace_diagnostics<cr>', desc = 'Toggle Workspace Diagnostics' },
    { '<leader>xd', '<cmd>TroubleToggle document_diagnostics<cr>', desc = 'Toggle Document Diagnostics' },
    { '<leader>xl', '<cmd>TroubleToggle loclist<cr>', desc = 'Toggle Loclist' },
    { '<leader>xq', '<cmd>TroubleToggle quickfix<cr>', desc = 'Toggle Quickfix' },
    { 'gR', '<cmd>TroubleToggle lsp_references<cr>', desc = 'Toggle LSP References' },
  },
  config = function()
    require('trouble').setup {
      auto_preview = false,
      auto_fold = true,
      auto_close = true,
      use_lsp_diagnostic_signs = true,
    }

    -- Diagnostic signs
    -- https://github.com/folke/trouble.nvim/issues/52
    local signs = {
      Error = ' ',
      Warning = ' ',
      Hint = ' ',
      Information = ' ',
    }
    for type, icon in pairs(signs) do
      local hl = 'DiagnosticSign' .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
    end
  end,
}
