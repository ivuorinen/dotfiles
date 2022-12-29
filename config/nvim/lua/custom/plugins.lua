return function(use)
    use({
        "folke/which-key.nvim",
        config = function()
            require("which-key").setup({})
        end
    })

    -- catppuccin theme
    use { "catppuccin/nvim", as = "catppuccin" }
    vim.cmd.colorscheme('catppuccin-latte')

    -- https://github.com/iamcco/markdown-preview.nvim
    use({
        "iamcco/markdown-preview.nvim",
        run = function() vim.fn["mkdp#util#install"]() end,
    })

    -- https://github.com/romgrk/barbar.nvim
    use 'nvim-tree/nvim-web-devicons'
    use {'romgrk/barbar.nvim', wants = 'nvim-web-devicons'}

    -- https://github.com/ThePrimeagen/refactoring.nvim
    use {
        "ThePrimeagen/refactoring.nvim",
        requires = {
            {"nvim-lua/plenary.nvim"},
            {"nvim-treesitter/nvim-treesitter"}
        }
    }
    -- Remaps for the refactoring operations currently offered by the plugin
    vim.api.nvim_set_keymap("v", "<leader>re", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>]], {noremap = true, silent = true, expr = false})
    vim.api.nvim_set_keymap("v", "<leader>rf", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function To File')<CR>]], {noremap = true, silent = true, expr = false})
    vim.api.nvim_set_keymap("v", "<leader>rv", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Variable')<CR>]], {noremap = true, silent = true, expr = false})
    vim.api.nvim_set_keymap("v", "<leader>ri", [[ <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]], {noremap = true, silent = true, expr = false})

    -- Extract block doesn't need visual mode
    vim.api.nvim_set_keymap("n", "<leader>rb", [[ <Cmd>lua require('refactoring').refactor('Extract Block')<CR>]], {noremap = true, silent = true, expr = false})
    vim.api.nvim_set_keymap("n", "<leader>rbf", [[ <Cmd>lua require('refactoring').refactor('Extract Block To File')<CR>]], {noremap = true, silent = true, expr = false})

    -- Inline variable can also pick up the identifier currently under the cursor without visual mode
    vim.api.nvim_set_keymap("n", "<leader>ri", [[ <Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]], {noremap = true, silent = true, expr = false})
end

