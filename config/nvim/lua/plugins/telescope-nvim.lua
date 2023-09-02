-- Telescope, a see-all-through file manager.
-- vim: ts=2 sw=2 si et
-- luacheck: globals vim
return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    { "nvim-lua/popup.nvim" },
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
    pcall(require("telescope").load_extension, "harpoon")

    -- See `:help telescope.builtin`
    local tbi = require("telescope.builtin")
    local wk = require("which-key")
    wk.register({
      ["?"] = {
        function() tbi.oldfiles() end,
        "[?] Find recently opened files",
      },
      ["<space>"] = {
        function() tbi.buffers() end,
        "[ ] Find existing buffers",
      },
      ["/"] = {
        function()
          -- You can pass additional configuration to telescope to change theme, layout, etc.
          tbi.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
            winblend = 10,
            previewer = false,
          }))
        end,
        "[/] Fuzzily search in current buffer",
      },

      t = {
        b = {
          "<cmd>Telescope file_browser<CR>",
          "[T]elescope: File [B]rowser",
        },
        d = {
          function() tbi.diagnostics() end,
          "[T]elescope: Search [D]iagnostics",
        },

        f = {
          function() tbi.find_files() end,
          "[T]elescope: Search [F]iles",
        },
        g = {
          function() tbi.git_files() end,
          "[T]elescope: Search [G]it files",
        },
        h = {
          function() tbi.help_tags() end,
          "[T]elescope: Search [H]elp",
        },
        r = {
          function() tbi.live_grep() end,
          "[T]elescope: Search by G[r]ep",
        },
        w = {
          function() tbi.grep_string() end,
          "[T]elescope: Search current [W]ord",
        },
      },
    }, { prefix = "<leader>" })
  end,
}
