return {
  -- Theme of choice, tokyonight
  -- https://github.com/folke/tokyonight.nvim
  {
    "folke/tokyonight.nvim",
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function() vim.cmd.colorscheme("tokyonight") end,
    opts = {
      transparent = true,
    },
  },

  -- Automatic dark mode
  -- https://github.com/f-person/auto-dark-mode.nvim
  {
    "f-person/auto-dark-mode.nvim",
    opts = {
      update_interval = 1000,
      set_dark_mode = function()
        vim.api.nvim_set_option_value("background", "dark", {})
        vim.cmd("colorscheme tokyonight-storm")
      end,
      set_light_mode = function()
        vim.api.nvim_set_option_value("background", "light", {})
        vim.cmd("colorscheme tokyonight-day")
      end,
    },
  },

  -- Remove all background colors to make nvim transparent
  -- https://github.com/xiyaowong/nvim-transparent
  { "xiyaowong/nvim-transparent" },

  -- Twilight is a Lua plugin for Neovim 0.5 that dims inactive
  -- portions of the code you're editing using TreeSitter.
  -- https://github.com/folke/twilight.nvim
  {
    "folke/twilight.nvim",
    ft = "markdown", -- Highlight markdown files
  },
}
