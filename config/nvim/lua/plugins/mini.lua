-- https://github.com/echasnovski/mini.nvim
-- https://github.com/echasnovski/mini.nvim/tree/main?tab=readme-ov-file#modules
return {
  -- Presets for common options and mappings
  { 'echasnovski/mini.basics', version = '*' },

  -- Visualize and work with indent scope
  -- Replaced lukas-reineke/indent-blankline.nvim
  { 'echasnovski/mini.indentscope', version = '*', opts = {} },

  -- Animate common Neovim actions
  -- Replaced anuvyklack/windows.nvim
  { 'echasnovski/mini.animate', version = '*', opts = {} },

  -- Fast and feature-rich surround actions
  -- Replaced kylechui/nvim-surround
  { 'echasnovski/mini.surround', version = '*', opts = {} },

  -- Icons
  {
    'echasnovski/mini.icons',
    opts = {
      file = {
        ['.keep'] = { glyph = '󰊢', hl = 'MiniIconsGrey' },
        ['devcontainer.json'] = { glyph = '', hl = 'MiniIconsAzure' },
      },
      filetype = {
        dotenv = { glyph = '', hl = 'MiniIconsYellow' },
      },
    },
  },

  -- Split and join arguments, lists, and other sequences
  -- Replaced Wansmer/treesj
  { 'echasnovski/mini.splitjoin', version = '*', opts = {} },

  -- Work with diff hunks
  -- Replaced lewis6991/gitsigns.nvim
  { 'echasnovski/mini.diff', version = '*', opts = {} },
}
