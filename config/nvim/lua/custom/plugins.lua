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
end

