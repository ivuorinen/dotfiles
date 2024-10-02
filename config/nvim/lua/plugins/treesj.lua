-- Neovim plugin for splitting/joining blocks of code
-- https://github.com/Wansmer/treesj
return {
  'Wansmer/treesj',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  opts = {
    use_default_keymaps = false,
  },
}
