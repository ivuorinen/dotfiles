return {
  -- You can also add new plugins here as well:
  -- Add plugins, the lazy syntax
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    enabled = true,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha"
      })
    end,
  },
  "andweeb/presence.nvim",
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },
  {
    "wakatime/vim-wakatime",
    lazy = false,
    enabled = true,
  },
}
