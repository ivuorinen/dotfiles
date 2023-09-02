-- Telescope, a see-all-through file manager.
return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    { "nvim-lua/popup.nvim" },
    { "nvim-lua/plenary.nvim" },
    -- Fuzzy Finder Algorithm which requires local dependencies to be built.
    -- Only load if `make` is available. Make sure you have the system
    -- requirements installed.
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      -- NOTE: If you are having trouble with this installation,
      --       refer to the README for telescope-fzf-native for more instructions.
      build = "make",
      cond = function() return vim.fn.executable("make") == 1 end,
    },
    { "nvim-telescope/telescope-file-browser.nvim" },
  },
  config = function()
    local actions = require("telescope.actions")
    local sorters = require("telescope.sorters")
    local previewers = require("telescope.previewers")

    require("telescope").setup({
      defaults = {
        mappings = {
          i = {
            ["<ESC>"] = actions.close,
            ["<C-u>"] = false,
            ["<C-d>"] = false,
          },
        },
        vimgrep_arguments = {
          "rg",
          "-L",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
        },

        prompt_prefix = "   ",
        selection_caret = "  ",
        entry_prefix = "  ",
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
            results_width = 0.8,
          },
          vertical = {
            mirror = false,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        file_sorter = sorters.get_fuzzy_file,
        file_ignore_patterns = { "node_modules", "dotbot" },
        generic_sorter = sorters.get_generic_fuzzy_sorter,
        path_display = { "truncate" },
        winblend = 0,
        border = {},
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        color_devicons = true,
        use_less = true,
        set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
        file_previewer = previewers.vim_buffer_cat.new,
        grep_previewer = previewers.vim_buffer_vimgrep.new,
        qflist_previewer = previewers.vim_buffer_qflist.new,
        -- Developer configurations: Not meant for general override
        buffer_previewer_maker = previewers.buffer_previewer_maker,
      },
      pickers = {
        buffers = {
          mappings = {
            i = {
              ["<c-d>"] = actions.delete_buffer + actions.move_to_top,
            },
          },
        },
      },

      extensions_list = { "themes", "terms" },
    })

    pcall(require("telescope").load_extension, "fzf")
    pcall(require("telescope").load_extension, "file_browser")

    -- See `:help telescope.builtin`
    vim.keymap.set("n", "<leader>?", require("telescope.builtin").oldfiles, { desc = "[?] Find recently opened files" })
    vim.keymap.set("n", "<leader><space>", require("telescope.builtin").buffers, { desc = "[ ] Find existing buffers" })
    vim.keymap.set("n", "<leader>/", function()
      -- You can pass additional configuration to telescope to change theme, layout, etc.
      require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
        winblend = 10,
        previewer = false,
      }))
    end, { desc = "[/] Fuzzily search in current buffer" })

    vim.keymap.set(
      "n",
      "<leader>tg",
      require("telescope.builtin").git_files,
      { desc = "[T]elescope: Search [G]it files" }
    )
    vim.keymap.set("n", "<leader>tf", require("telescope.builtin").find_files, { desc = "[T]elescope: Search [F]iles" })
    vim.keymap.set("n", "<leader>th", require("telescope.builtin").help_tags, { desc = "[T]elescope: Search [H]elp" })
    vim.keymap.set(
      "n",
      "<leader>tw",
      require("telescope.builtin").grep_string,
      { desc = "[T]elescope: Search current [W]ord" }
    )
    vim.keymap.set(
      "n",
      "<leader>tr",
      require("telescope.builtin").live_grep,
      { desc = "[T]elescope: Search by G[r]ep" }
    )
    vim.keymap.set(
      "n",
      "<leader>td",
      require("telescope.builtin").diagnostics,
      { desc = "[T]elescope: Search [D]iagnostics" }
    )

    vim.keymap.set(
      "n",
      "<leader>tb",
      ":Telescope file_browser<CR>",
      { desc = "[T]elescope: File [B]rowser", noremap = true }
    )
  end,
}
