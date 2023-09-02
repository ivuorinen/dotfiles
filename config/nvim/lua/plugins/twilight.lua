-- Twilight dims inactive portions of the
-- code you're editing using TreeSitter
-- https://github.com/folke/twilight.nvim
return {
  "folke/twilight.nvim",
  config = {
    dimming = {
      alpha = 0.5, -- amount of dimming
      inactive = false, -- when true, other windows will be fully dimmed (unless they contain the same buffer)
    },
    context = 3, -- amount of lines we will try to show around the current line
    treesitter = true, -- use treesitter when available for the filetype
    -- treesitter is used to automatically expand the visible text,
    -- but you can further control the types of nodes that should always be fully expanded
    expand = { -- for treesitter, we we always try to expand to the top-most ancestor with these types
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
