return function(use)

  -- 💥 Create key bindings that stick.
  -- WhichKey is a lua plugin that displays a popup with
  -- possible keybindings of the command you started typing.
  -- https://github.com/folke/which-key.nvim
  use({
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup({})
    end
  })

  -- 🍨 Soothing pastel theme for (Neo)vim
  -- https://github.com/catppuccin/nvim
  -- use { "catppuccin/nvim", as = "catppuccin" }
  -- vim.cmd.colorscheme('catppuccin-latte')

  -- markdown preview plugin for (neo)vim
  -- https://github.com/iamcco/markdown-preview.nvim
  use({
    "iamcco/markdown-preview.nvim",
    run = function()
      vim.fn["mkdp#util#install"]()
    end,
  })

  -- The neovim tabline plugin.
  -- https://github.com/romgrk/barbar.nvim
  use 'nvim-tree/nvim-web-devicons'
  use { 'romgrk/barbar.nvim', wants = 'nvim-web-devicons' }

  --
  -- Pretty UI
  --

  -- Neovim plugin to improve the default vim.ui interfaces
  use 'stevearc/dressing.nvim'
  -- A fancy, configurable, notification manager for NeoVim
  use 'rcarriga/nvim-notify'
  -- Non-intrusive notification system for neovim
  use 'vigoux/notifier.nvim'
  -- ✅ Highlight, list and search todo comments in your projects
  use {
    'folke/todo-comments.nvim',
    requires = 'nvim-lua/plenary.nvim',
    config = function()
      require('todo-comments').setup {}
    end,
  }

  -- The Refactoring library based off the Refactoring book by Martin Fowler
  -- https://github.com/ThePrimeagen/refactoring.nvim
  use {
    "ThePrimeagen/refactoring.nvim",
    requires = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-treesitter/nvim-treesitter" }
    }
  }

  -- An asynchronous linter plugin for Neovim complementary to
  -- the built-in Language Server Protocol support.
  -- https://github.com/mfussenegger/nvim-lint
  use 'mfussenegger/nvim-lint'
  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    callback = function()
      require("lint").try_lint()
    end,
  })

  -- nvim orgmode, to get me use nvim even more.
  use({
    "nvim-orgmode/orgmode",
    config = function()
      require('orgmode').setup_ts_grammar()
    end,
  })

  -- Markdown support
  use 'preservim/vim-markdown'
  use 'godlygeek/tabular'

  -- obsidian plugin for nvim
  -- https://github.com/epwalsh/obsidian.nvim
  use({
    "epwalsh/obsidian.nvim",
    config = function()
      require("obsidian").setup({
        dir = '~/.local/share/_nvalt',
        notes_subdir = "notes",
        daily_notes = {
          folder = "_daily"
        },
        completion = {
          nvim_cmp = true, -- if using nvim-cmp, otherwise set to false
        }
      })
    end
  })

  -- Creates missing folders on save
  -- https://github.com/jghauser/mkdir.nvim
  use { 'jghauser/mkdir.nvim' }

  -- Neovim plugin for dimming the highlights of unused
  -- functions, variables, parameters, and more
  -- https://github.com/zbirenbaum/neodim
  use {
    "zbirenbaum/neodim",
    event = "LspAttach",
    config = function()
      require("neodim").setup({
        alpha = 0.75,
        blend_color = "#000000",
        update_in_insert = {
          enable = true,
          delay = 100,
        },
        hide = {
          virtual_text = true,
          signs = true,
          underline = true,
        }
      })
    end
  }

  -- EditorConfig plugin for Neovim
  -- https://github.com/gpanders/editorconfig.nvim
  use { 'gpanders/editorconfig.nvim' }

  -- Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua.
  -- https://github.com/jose-elias-alvarez/null-ls.nvim
  use { "jose-elias-alvarez/null-ls.nvim" }

  -- mason-null-ls bridges mason.nvim with the null-ls plugin
  -- - making it easier to use both plugins together.
  -- https://github.com/jay-babu/mason-null-ls.nvim
  use {
    "jayp0521/mason-null-ls.nvim",
    requires = { "jose-elias-alvarez/null-ls.nvim" }
  }

end

