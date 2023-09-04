-- Twilight dims inactive portions of the
-- code you're editing using TreeSitter
-- https://github.com/folke/twilight.nvim
return {
  "folke/twilight.nvim",
  config = {
    dimming = {
      -- amount of dimming
      alpha = 0.2,
      -- when true, other windows will be fully dimmed (unless they contain the same buffer)
      inactive = false,
    },
    -- amount of lines we will try to show around the current line
    context = 3,
    -- use treesitter when available for the filetype
    -- treesitter is used to automatically expand the visible text,
    -- but you can further control the types of nodes that should always be fully expanded

    treesitter = true,

    -- for treesitter, we we always try to expand to the top-most ancestor with these types
    expand = {
      "function",
      "while_statement",
      "for_statement",
      "switch_statement",
      "method",
      "table",
      "if_statement",
    },
    exclude = {}, -- exclude these filetypes
  },
}
