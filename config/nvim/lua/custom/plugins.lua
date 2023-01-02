return function(use)

    -- 💥 Create key bindings that stick.
    -- WhichKey is a lua plugin that displays a popup with 
    -- possible keybindings of the command you started typing.
    use({ "folke/which-key.nvim", config = function() require("which-key").setup({}) end })

    -- 🍨 Soothing pastel theme for (Neo)vim
    -- https://github.com/catppuccin/nvim
    -- use { "catppuccin/nvim", as = "catppuccin" }
    -- vim.cmd.colorscheme('catppuccin-latte')

    -- markdown preview plugin for (neo)vim
    -- https://github.com/iamcco/markdown-preview.nvim
    use({ "iamcco/markdown-preview.nvim",
        run = function() vim.fn["mkdp#util#install"]() end,
    })

    -- The neovim tabline plugin.
    -- https://github.com/romgrk/barbar.nvim
    use 'nvim-tree/nvim-web-devicons'
    use { 'romgrk/barbar.nvim', wants = 'nvim-web-devicons' }

    -- Pretty UI
    use 'stevearc/dressing.nvim' -- Neovim plugin to improve the default vim.ui interfaces
    use 'rcarriga/nvim-notify' -- A fancy, configurable, notification manager for NeoVim
    use 'vigoux/notifier.nvim' -- Non-intrusive notification system for neovim
    use { 'folke/todo-comments.nvim', -- ✅ Highlight, list and search todo comments in your projects
        requires = 'nvim-lua/plenary.nvim',
        config = function() require('todo-comments').setup {} end,
    }

    -- The Refactoring library based off the Refactoring book by Martin Fowler
    -- https://github.com/ThePrimeagen/refactoring.nvim
    use {
        "ThePrimeagen/refactoring.nvim",
        requires = {
            {"nvim-lua/plenary.nvim"},
            {"nvim-treesitter/nvim-treesitter"}
        }
    }

    -- An asynchronous linter plugin for Neovim complementary to the built-in Language Server Protocol support.
    -- https://github.com/mfussenegger/nvim-lint
    use 'mfussenegger/nvim-lint'
    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function() require("lint").try_lint() end,
    })

    -- nvim orgmode, to get me use nvim even more.
    use ({ "nvim-orgmode/orgmode",
        config = function() require("orgmode").setup({}) end,
    })

    -- Remaps for the refactoring operations currently offered by the plugin
    local map = vim.api.nvim_set_keymap
    local refactoring_opts = { noremap = true, silent = true, expr = false }
    map("v", "<leader>re", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>]], refactoring_opts)
    map("v", "<leader>rf", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function To File')<CR>]], refactoring_opts)
    map("v", "<leader>rv", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Variable')<CR>]], refactoring_opts)
    map("v", "<leader>ri", [[ <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]], refactoring_opts)

    -- Extract block doesn't need visual mode
    map("n", "<leader>rb", [[ <Cmd>lua require('refactoring').refactor('Extract Block')<CR>]], refactoring_opts)
    map("n", "<leader>rbf", [[ <Cmd>lua require('refactoring').refactor('Extract Block To File')<CR>]], refactoring_opts)

    -- Inline variable can also pick up the identifier currently under the cursor without visual mode
    map("n", "<leader>ri", [[ <Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]],refactoring_opts)

    -- prompt for a refactor to apply when the remap is triggered
    map("v", "<leader>rr", ":lua require('refactoring').select_refactor()<CR>", refactoring_opts)

end

