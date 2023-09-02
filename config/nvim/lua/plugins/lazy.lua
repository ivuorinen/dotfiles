return {
  -- Plenary is used by many other plugins
  { "nvim-lua/plenary.nvim", lazy = true },

  -- Icons on menu
  "onsails/lspkind-nvim",

  -- Restore folds and cursor position
  "senderle/restoreview",

  -- Create key bindings that stick. WhichKey is a lua plugin for Neovim that
  -- displays a popup with possible keybindings of the command you started typing.
  -- https://github.com/folke/which-key.nvim
  {
    "folke/which-key.nvim",
    enabled = true,
    lazy = false,
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      plugins = { spelling = true, marks = true, registers = true },
    },
  },

  -- Neovim plugin to improve the default vim.ui interfaces
  -- https://github.com/stevearc/dressing.nvim
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },

  -- The theme of choise, catppuccin
  ---- https://github.com/catppuccin/nvim
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 10000,
    enabled = true,
    lazy = false,
    config = function() vim.cmd.colorscheme("catppuccin") end,
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
          style = "catppuccin",
        },
        ts_rainbow = true,
        treesitter = true,
        lsp_trouble = true,
        which_key = true,
      },
    },
  },

  -- Notifications as a popup
  -- https://github.com/rcarriga/nvim-notify
  {
    "rcarriga/nvim-notify",
    keys = {
      {
        "<leader>un",
        function() require("notify").dismiss({ silent = true, pending = true }) end,
        desc = "Dismiss all Notifications",
      },
    },
    opts = {
      timeout = 3000,
      max_height = function() return math.floor(vim.o.lines * 0.75) end,
      max_width = function() return math.floor(vim.o.columns * 0.75) end,
    },
    init = function() vim.notify = require("notify") end,
  },

  {
    "dstein64/vim-startuptime",
    cmd = "StartupTime",
    config = function() vim.g.startuptime_tries = 10 end,
  },

  { "ThePrimeagen/harpoon" },

  -- A Neovim plugin hiding your colorcolumn when unneeded.
  -- https://github.com/m4xshen/smartcolumn.nvim
  {
    "m4xshen/smartcolumn.nvim",
    opts = {
      colorcolumn = { "80", "100", "120" },
      disabled_filetypes = { "help", "text", "markdown", "json", "lazy", "starter", "neo-tree" },
    },
  },

  -- Status information for LSP.
  "j-hui/fidget.nvim",

  -- Close buffer without messing up with the window.
  "famiu/bufdelete.nvim",

  -- Delete multiple vim buffers based on different conditions
  -- https://github.com/kazhala/close-buffers.nvim
  "kazhala/close-buffers.nvim",

  "nyoom-engineering/oxocarbon.nvim",

  -- JSONLS
  "b0o/schemastore.nvim",

  -- sleuth.vim: Heuristically set buffer options
  -- https://github.com/tpope/vim-sleuth
  "tpope/vim-sleuth",

  -- Neovim plugin for locking a buffer to a window
  -- https://github.com/stevearc/stickybuf.nvim
  { "stevearc/stickybuf.nvim",      opts = {} },

  -- Describe the regexp under the cursor
  -- https://github.com/bennypowers/nvim-regexplainer
  {
    "bennypowers/nvim-regexplainer",
    requires = {
      "nvim-treesitter/nvim-treesitter",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      -- automatically show the explainer when the cursor enters a regexp
      auto = true,
    },
  },

  -- Clarify and beautify your comments using boxes and lines.
  -- https://github.com/LudoPinelli/comment-box.nvim
  { "LudoPinelli/comment-box.nvim", opts = {} },

  {
    "codota/tabnine-nvim",
    name = "tabnine",
    build = vim.loop.os_uname().sysname == "Windows_NT" and "pwsh.exe -file .\\dl_binaries.ps1" or "./dl_binaries.sh",
    cmd = { "TabnineStatus", "TabnineDisable", "TabnineEnable", "TabnineToggle" },
    event = "User",
    opts = { accept_keymap = "<C-e>" },
  },

  -- Vim plugin for automatic time tracking and metrics generated from your programming activity.
  -- https://github.com/wakatime/vim-wakatime
  {
    "wakatime/vim-wakatime",
    lazy = false,
    enabled = true,
  },
}
