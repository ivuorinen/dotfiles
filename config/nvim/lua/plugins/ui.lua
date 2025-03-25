return {
  -- https://github.com/preservim/vim-colors-pencil
  {
    'preservim/vim-colors-pencil',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      vim.cmd 'colorscheme pencil'
      vim.api.nvim_set_option_value('pencil_terminal_italics', 1, {})
    end,
  },

  -- Automatic dark mode
  -- https://github.com/f-person/auto-dark-mode.nvim
  {
    'f-person/auto-dark-mode.nvim',
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        vim.api.nvim_set_option_value('background', 'dark', {})
        -- vim.cmd.colorscheme(vim.g.colors_variant_dark)
      end,
      set_light_mode = function()
        vim.api.nvim_set_option_value('background', 'light', {})
        -- vim.cmd.colorscheme(vim.g.colors_variant_light)
      end,
    },
  },

  -- The fastest Neovim colorizer
  -- https://github.com/catgoose/nvim-colorizer.lua
  {
    'catgoose/nvim-colorizer.lua',
    opts = {
      user_default_options = {
        names = false,
      },
    },
  },

  -- A neovim plugin that shows colorcolumn dynamically
  -- https://github.com/Bekaboo/deadcolumn.nvim
  { 'Bekaboo/deadcolumn.nvim' },

  -- Remove all background colors to make nvim transparent
  -- https://github.com/xiyaowong/nvim-transparent
  { 'xiyaowong/nvim-transparent', opts = {} },

  -- Display a character as the colorcolumn
  -- https://github.com/lukas-reineke/virt-column.nvim
  { 'lukas-reineke/virt-column.nvim', opts = {} },

  -- Neovim plugin for locking a buffer to a window
  -- https://github.com/stevearc/stickybuf.nvim
  { 'stevearc/stickybuf.nvim', opts = {} },
}
