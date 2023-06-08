return {
  -- Add the community repository of plugin specifications
  "AstroNvim/astrocommunity",
  -- example of imporing a plugin, comment out to use it or add your own.
  -- available plugins can be found at
  -- https://github.com/AstroNvim/astrocommunity
  {
    import = "astrocommunity.colorscheme.catppuccin",
    opts = {
      flavour = "mocha",
      transparent_background = true,
      dim_inactive = {
        enabled = true,
        shade = "dark",
        percentage = 0.15,
      },
    }
  },
  -- { import = "astrocommunity.completion.copilot-lua-cmp" },
  { import = "astrocommunity.bars-and-lines.smartcolumn-nvim" },
  {
    "m4xshen/smartcolumn.nvim",
    opts = {
      colorcolumn = { "80", "100", "120" },
      disabled_filetypes = { "help", "text", "markdown", "json" },
    },
  },
  { import = "astrocommunity.diagnostics.trouble-nvim" },
  {
    "folke/trouble.nvim",
    opts = {
      auto_open = true,
      position = "right"
    }
  },
  { import = "astrocommunity.editing-support.refactoring-nvim" },
  { import = "astrocommunity.editing-support.neogen" },
  { import = "astrocommunity.editing-support.nvim-regexplainer" },
  { import = "astrocommunity.editing-support.todo-comments-nvim" },
  { import = "astrocommunity.indent.mini-indentscope" },
  { import = "astrocommunity.markdown-and-latex.glow-nvim" },
  { import = "astrocommunity.motion.harpoon" },
  { import = "astrocommunity.pack.php" },
  { import = "astrocommunity.project.neoconf-nvim" },
  { import = "astrocommunity.project.nvim-spectre" },
  { import = "astrocommunity.project.project-nvim" },
  { import = "astrocommunity.test.neotest" },
  { import = "astrocommunity.utility.neodim" },
  { import = "astrocommunity.utility.transparent-nvim" },
}

