return {

  'ray-x/go.nvim',
  'ray-x/guihua.lua',

  {
    'rcarriga/nvim-dap-ui',
    dependencies = {
      'mfussenegger/nvim-dap',
      'nvim-neotest/nvim-nio',
      'theHamsta/nvim-dap-virtual-text',
      'leoluz/nvim-dap-go',
    },
    setup = function()
      require('dapui').setup()
      require('dap-go').setup()
      require('nvim-dap-virtual-text').setup()

      vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = 'DapBreakpoint', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })

      -- Debugger
      vim.api.nvim_set_keymap('n', '<leader>dt', ':DapUiToggle<CR>', { noremap = true })
      vim.api.nvim_set_keymap('n', '<leader>db', ':DapToggleBreakpoint<CR>', { noremap = true })
      vim.api.nvim_set_keymap('n', '<leader>dc', ':DapContinue<CR>', { noremap = true })
      vim.api.nvim_set_keymap('n', '<leader>dr', ":lua require('dapui').open({reset = true})<CR>", { noremap = true })
      vim.api.nvim_set_keymap('n', '<leader>ht', ":lua require('harpoon.ui').toggle_quick_menu()<CR>", { noremap = true })
    end,
  },
}
