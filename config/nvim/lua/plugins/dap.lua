return {
  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',
      'theHamsta/nvim-dap-virtual-text',
      'ray-x/go.nvim',
      'ray-x/guihua.lua',
      'leoluz/nvim-dap-go',
    },
    keys = {
      { '<leader>dt', '<cmd>DapUiToggle', desc = 'DAP: Toggle UI' },
      { '<leader>db', '<cmd>DapToggleBreakpoint', desc = 'DAP: Toggle Breakpoint' },
      { '<leader>dc', '<cmd>DapContinue', desc = 'DAP: Continue' },
      { '<leader>dr', ":lua require('dapui').open({reset = true})<CR>", desc = 'DAP: Reset' },
      { '<leader>ht', ":lua require('harpoon.ui').toggle_quick_menu()<CR>", desc = 'DAP: Harpoon UI' },
    },
    setup = function()
      require('dapui').setup()
      require('dap-go').setup()
      require('nvim-dap-virtual-text').setup()

      vim.fn.sign_define(
        'DapBreakpoint',
        { text = '🔴', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' }
      )
    end,
  },
}
