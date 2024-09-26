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
    setup = function()
      require('dapui').setup()
      require('dap-go').setup()
      require('nvim-dap-virtual-text').setup {}

      vim.fn.sign_define('DapBreakpoint', {
        text = '🔴',
        texthl = 'DapBreakpoint',
        linehl = 'DapBreakpoint',
        numhl = 'DapBreakpoint',
      })
    end,
  },
}
