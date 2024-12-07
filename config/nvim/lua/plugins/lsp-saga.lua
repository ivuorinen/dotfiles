-- improve neovim lsp experience
-- https://github.com/nvimdev/lspsaga.nvim
-- https://nvimdev.github.io/lspsaga/
return {
  'nvimdev/lspsaga.nvim',
  event = 'LspAttach',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'nvim-tree/nvim-web-devicons',
  },
  keys = {
    {
      '<leader>ca',
      '<cmd>Lspsaga code_action<cr>',
      desc = 'LSPSaga: Code Actions',
    },
    {
      '<leader>cci',
      '<cmd>Lspsaga incoming_calls<cr>',
      desc = 'LSPSaga: Incoming Calls',
    },
    {
      '<leader>cco',
      '<cmd>Lspsaga outgoing_calls<cr>',
      desc = 'LSPSaga: Outgoing Calls',
    },
    {
      '<leader>cd',
      '<cmd>Lspsaga show_line_diagnostics<cr>',
      desc = 'LSPSaga: Show Line Diagnostics',
    },
    {
      '<leader>ci',
      '<cmd>Lspsaga implement<cr>',
      desc = 'LSPSaga: Implementations',
    },
    {
      '<leader>cl',
      '<cmd>Lspsaga show_cursor_diagnostics<cr>',
      desc = 'LSPSaga: Show Cursor Diagnostics',
    },
    {
      '<leader>cp',
      '<cmd>Lspsaga peek_definition<cr>',
      desc = 'LSPSaga: Peek Definition',
    },
    { '<leader>cr', '<cmd>Lspsaga rename<cr>', desc = 'LSPSaga: Rename' },
    {
      '<leader>cR',
      '<cmd>Lspsaga rename ++project<cr>',
      desc = 'LSPSaga: Rename Project wide',
    },
    {
      '<leader>cs',
      '<cmd>Lspsaga signature_help<cr>',
      desc = 'LSPSaga: Signature Documentation',
    },
    {
      '<leader>ct',
      '<cmd>Lspsaga peek_type_definition<cr>',
      desc = 'LSPSaga: Peek Type Definition',
    },
    {
      '<leader>cu',
      '<cmd>Lspsaga preview_definition<cr>',
      desc = 'LSPSaga: Preview Definition',
    },
    {
      '<leader>cv',
      '<cmd>Lspsaga diagnostic_jump_prev<cr>',
      desc = 'LSPSaga: Diagnostic Jump Prev',
    },
    {
      '<leader>cw',
      '<cmd>Lspsaga diagnostic_jump_next<cr>',
      desc = 'LSPSaga: Diagnostic Jump Next',
    },
  },
  opts = {
    code_action = {
      show_server_name = true,
    },
    diagnostic = {
      keys = {
        quit = { 'q', '<ESC>' },
      },
    },
  },
}
