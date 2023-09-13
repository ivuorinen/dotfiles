-- A VS Code like winbar for Neovim
-- https://github.com/utilyre/barbecue.nvim
return {
  "utilyre/barbecue.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
    "SmiteshP/nvim-navic",
    "nvim-tree/nvim-web-devicons",
  },
  version = "*",
  opts = {
    theme = "catppuccin",

    -- If you set this to false, floating windows will look weird
    exclude_float = true,

    -- Instead of excluding countless number of filetypes, barbecue tries to only show on some buftypes
    -- "": file buffer
    -- "nofile": e.g. nvim-tree and nvim-dap-ui
    -- "prompt": e.g. telescope.nvim and nvim-fzf
    -- "terminal": e.g. fterm.nvim and toggleterm.nvim
    -- ...
    include_buftypes = { "" },

    ---Filetypes not to enable winbar in.
    ---
    ---@type string[]
    exclude_filetypes = {
      "",
      "txt",
      "markdown",
    },

    -- :help events
    -- :help [event] (like :help BufWinEnter)
    update_events = {
      "BufWinEnter",
      "BufWritePost",
      "CursorMoved",
      "CursorMovedI",
      "TextChanged",
      "TextChangedI",
    },

    -- Show `~  ...` instead of `/  home  user  ...`
    tilde_home = true,

    -- Your winbar will have a little padding from the edge
    prefix = "  ",

    -- The sign between each entry
    separator = "  ",

    -- Show if lsp context is available but there is nothing to show
    no_info_indicator = "…",

    -- Symbol to show if file has been modified (not saved). It's usually `[+]` in vim
    -- `nil` to disable
    modified_indicator = nil,

    -- Icons passed to nvim-navic
    icons = {
      File = " ",
      Module = " ",
      Namespace = " ",
      Package = " ",
      Class = " ",
      Method = " ",
      Property = " ",
      Field = " ",
      Constructor = " ",
      Enum = "練",
      Interface = "練",
      Function = " ",
      Variable = " ",
      Constant = " ",
      String = " ",
      Number = " ",
      Boolean = "◩ ",
      Array = " ",
      Object = " ",
      Key = " ",
      Null = "ﳠ ",
      EnumMember = " ",
      Struct = " ",
      Event = " ",
      Operator = " ",
      TypeParameter = " ",
      Define = " ",
    },
  },
}
