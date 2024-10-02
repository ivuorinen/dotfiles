-- improve neovim lsp experience
-- https://github.com/nvimdev/lspsaga.nvim
-- https://nvimdev.github.io/lspsaga/
return {
  'nvimdev/lspsaga.nvim',
  event = 'LspAttach',
  dependencies = {
    'nvim-treesitter/nvim-treesitter', -- optional
    'nvim-tree/nvim-web-devicons', -- optional
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
