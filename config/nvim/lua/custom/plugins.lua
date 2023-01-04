return function(use)

    -- 💥 Create key bindings that stick.
    -- WhichKey is a lua plugin that displays a popup with
    -- possible keybindings of the command you started typing.
    use({ "folke/which-key.nvim",
        config = function() require("which-key").setup({}) end
    })

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
            { "nvim-lua/plenary.nvim" },
            { "nvim-treesitter/nvim-treesitter" }
        }
    }

    -- An asynchronous linter plugin for Neovim complementary to the built-in Language Server Protocol support.
    -- https://github.com/mfussenegger/nvim-lint
    use 'mfussenegger/nvim-lint'
    vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function() require("lint").try_lint() end,
    })

    -- nvim orgmode, to get me use nvim even more.
    use({ "nvim-orgmode/orgmode",
        config = function() require("orgmode").setup({}) end,
    })

    -- Markdown support
    use 'preservim/vim-markdown'
    use 'godlygeek/tabular'

    -- obsidian plugin for nvim
    -- https://github.com/epwalsh/obsidian.nvim
    use({ "epwalsh/obsidian.nvim",
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
    use { "zbirenbaum/neodim",
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
    use ({ "jose-elias-alvarez/null-ls.nvim",
        requires = { "nvim-lua/plenary.nvim" },
        config = function ()
            local null_ls = require("null-ls")

            null_ls.setup({
                sources = {
                    null_ls.builtins.formatting.blade_formatter,
                    null_ls.builtins.formatting.eslint,
                    null_ls.builtins.formatting.fixjson,
                    null_ls.builtins.formatting.lua_format,
                    null_ls.builtins.formatting.markdownlint,
                    null_ls.builtins.formatting.prettier,
                    null_ls.builtins.formatting.shfmt,
                    null_ls.builtins.formatting.stylelint,
                    -- null_ls.builtins.formatting.stylua,
                    null_ls.builtins.formatting.terraform_fmt,
                    null_ls.builtins.formatting.trim_whitespace,
                    null_ls.builtins.formatting.yamlfmt,
                    null_ls.builtins.diagnostics.alex,
                    null_ls.builtins.diagnostics.ansiblelint,
                    null_ls.builtins.diagnostics.actionlint,
                    null_ls.builtins.diagnostics.codespell,
                    null_ls.builtins.diagnostics.dotenv_linter,
                    null_ls.builtins.diagnostics.editorconfig_checker,
                    null_ls.builtins.diagnostics.eslint,
                    null_ls.builtins.diagnostics.hadolint,
                    null_ls.builtins.diagnostics.jsonlint,
                    null_ls.builtins.diagnostics.luacheck,
                    null_ls.builtins.diagnostics.markdownlint,
                    null_ls.builtins.diagnostics.php,
                    null_ls.builtins.diagnostics.phpcs,
                    null_ls.builtins.diagnostics.phpstan,
                    null_ls.builtins.diagnostics.psalm,
                    null_ls.builtins.diagnostics.shellcheck,
                    null_ls.builtins.diagnostics.spectral,
                    null_ls.builtins.diagnostics.stylelint,
                    null_ls.builtins.diagnostics.todo_comments,
                    null_ls.builtins.diagnostics.trail_space,
                    null_ls.builtins.diagnostics.xo,
                    null_ls.builtins.diagnostics.yamllint,
                    null_ls.builtins.completion.spell,
                    null_ls.builtins.completion.luasnip,
                    null_ls.builtins.code_actions.eslint,
                    null_ls.builtins.code_actions.shellcheck,
                    null_ls.builtins.code_actions.xo,
                }
            })
        end
    })


    local map = vim.api.nvim_set_keymap

    map("n", "<leader>ff", ":Format", { noremap = true, silent = true })

    -- Remaps for the refactoring operations currently offered by the plugin
    local refact_opts = { noremap = true, silent = true, expr = false }
    map("v", "<leader>re", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>]], refact_opts)
    map("v", "<leader>rf", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Function To File')<CR>]],
        refact_opts)
    map("v", "<leader>rv", [[ <Esc><Cmd>lua require('refactoring').refactor('Extract Variable')<CR>]], refact_opts)
    map("v", "<leader>ri", [[ <Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]], refact_opts)

    -- Extract block doesn't need visual mode
    map("n", "<leader>rb", [[ <Cmd>lua require('refactoring').refactor('Extract Block')<CR>]], refact_opts)
    map("n", "<leader>rbf", [[ <Cmd>lua require('refactoring').refactor('Extract Block To File')<CR>]], refact_opts)

    -- Inline variable can also pick up the identifier currently under the cursor without visual mode
    map("n", "<leader>ri", [[ <Cmd>lua require('refactoring').refactor('Inline Variable')<CR>]], refact_opts)

    -- prompt for a refactor to apply when the remap is triggered
    map("v", "<leader>rr", ":lua require('refactoring').select_refactor()<CR>", refact_opts)

end

