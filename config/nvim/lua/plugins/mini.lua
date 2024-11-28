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

  -- Move lines and blocks of text
  { 'echasnovski/mini.move', version = '*', opts = {} },

  -- Jump to next/previous single character
  {
    'echasnovski/mini.jump',
    version = '*',
    opts = {
      mappings = {
        forward = 'f',
        backward = 'F',
        forward_till = 't',
        backward_till = 'T',
        repeat_jump = ';',
      },
    },
  },

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

  -- Highlight cursor word and its matches
  { 'echasnovski/mini.cursorword', version = '*' },

  -- Split and join arguments, lists, and other sequences
  -- Replaced Wansmer/treesj
  { 'echasnovski/mini.splitjoin', version = '*', opts = {} },

  -- Work with diff hunks
  -- Replaced lewis6991/gitsigns.nvim
  { 'echasnovski/mini.diff', version = '*', opts = {} },
}
