-- luacheck: globals vim
return {
  -- The theme of choise, catppuccin
  -- https://github.com/catppuccin/nvim
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    enabled = true,
    config = function()
      vim.cmd.colorscheme("catppuccin")
    end,
    opts = {
      flavour = "mocha",
    },
  },
  -- Remove all background colors to make nvim transparent
  -- https://github.com/xiyaowong/transparent.nvim
  {
    "xiyaowong/transparent.nvim",
    lazy = false,
    enabled = true,
    config = function()
      vim.g.transparent_groups = vim.list_extend(
        vim.g.transparent_groups or {},
        vim.tbl_map(function(v)
          return v.hl_group
        end, vim.tbl_values(require("bufferline.config").highlights))
      )
    end,
  },
  -- A fancy, configurable, notification manager for NeoVim
  -- https://github.com/rcarriga/nvim-notify
  {
    "rcarriga/nvim-notify",
    opts = {
      -- Set background color to black so transparent doesn't mess stuff up
      background_colour = "#000000",
    },
  },
  -- Getting you where you want with the fewest keystrokes.
  -- https://github.com/ThePrimeagen/harpoon
  { "ThePrimeagen/harpoon" },
  -- Close buffer without messing up with the window.
  -- https://github.com/famiu/bufdelete.nvim
  { "famiu/bufdelete.nvim" },
  -- Neovim plugin for locking a buffer to a window
  -- https://github.com/stevearc/stickybuf.nvim
  { "stevearc/stickybuf.nvim", opts = {} },
  -- Automatically expand width of the current window.
  -- Maximizes and restore it. And all this with nice animations!
  -- https://github.com/anuvyklack/windows.nvim
  {
    "anuvyklack/windows.nvim",
    dependencies = {
      "anuvyklack/middleclass",
      "anuvyklack/animation.nvim",
    },
    config = function()
      vim.o.winwidth = 10
      vim.o.winminwidth = 10
      vim.o.equalalways = false
      require("windows").setup()
    end,
  },
}
