return {
  --
  -- Menu
  --
  -- Icons on menu
  "onsails/lspkind-nvim",

  -- Restore folds and cursor position
  "senderle/restoreview",

  --
  -- Appearance
  --

  -- The theme of choise, catppuccin
  ---- https://github.com/catppuccin/nvim
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 10000,
    enabled = true,
    lazy = false,
    config = function()
  vim.cmd.colorscheme("catppuccin")
    end,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      dim_inactive = {
        enabled = true,
        shade = "dark",
        percentage = 0.15,
      },
      integrations = {
        aerial = true,
        barbecue = {
          dim_dirname = true, -- directory name is dimmed by default
          bold_basename = true,
          dim_context = false,
          alt_background = false,
        },
        cmp = true,
        dap = { enabled = true, enable_ui = true },
        gitsigns = true,
        harpoon = true,
        indent_blankline = {
          enabled = true,
          colored_indent_levels = false,
        },
        mason = true,
        neotree = true,
        notify = true,
        nvimtree = false,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
          },
          inlay_hints = {
            background = true,
          },
        },
        semantic_tokens = true,
        symbols_outline = true,
        telescope = {
          enabled = true,
          style = "catppuccin"
        },
        ts_rainbow = true,
        treesitter = true,
        lsp_trouble = true,
        which_key = true,
      },
    },
  },
  -- Status information for LSP.
  "j-hui/fidget.nvim",

  -- Close buffer without messing up with the window.
  "famiu/bufdelete.nvim",

  "nyoom-engineering/oxocarbon.nvim",

  -- JSONLS
  "b0o/schemastore.nvim",
}
