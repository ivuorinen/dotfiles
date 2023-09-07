-- Git integration for buffers
-- https://github.com/lewis6991/gitsigns.nvim
-- luacheck: globals vim
return {
  "lewis6991/gitsigns.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = {
    signs = {
      add = { hl = "GitSignsAdd", text = "┃", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
      change = { hl = "GitSignsChange", text = "┃", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
      delete = { hl = "GitSignsDelete", text = "_", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
      topdelete = { hl = "GitSignsDelete", text = "‾", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
      changedelete = { hl = "GitSignsChange", text = "~", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
    },
    signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
    numhl = false,     -- Toggle with `:Gitsigns toggle_numhl`
    linehl = false,    -- Toggle with `:Gitsigns toggle_linehl`
    word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Navigation
      map("n", "]c", function()
        if vim.wo.diff then return "]c" end
        vim.schedule(function() gs.next_hunk() end)
        return "<Ignore>"
      end, { expr = true })

      map("n", "[c", function()
        if vim.wo.diff then return "[c" end
        vim.schedule(function() gs.prev_hunk() end)
        return "<Ignore>"
      end, { expr = true })

      -- Actions
      map("n", "<leader>oghs", gs.stage_hunk, { desc = "Stage Hunk" })
      map("n", "<leader>oghr", gs.reset_hunk, { desc = "Reset Hunk" })
      map("v", "<leader>oghs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end)
      map("v", "<leader>oghr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end)
      map("n", "<leader>oghS", gs.stage_buffer, { desc = "Stage Buffer" })
      map("n", "<leader>oghu", gs.undo_stage_hunk, { desc = "Undo Stage Hunk" })
      map("n", "<leader>oghR", gs.reset_buffer, { desc = "Reset Buffer" })
      map("n", "<leader>oghp", gs.preview_hunk, { desc = "Preview Hunk" })
      map("n", "<leader>ogbl", function() gs.blame_line({ full = true }) end, { desc = "Blame Line" })
      map("n", "<leader>ogbt", gs.toggle_current_line_blame, { desc = "Toggle Current Line Blame" })
      map("n", "<leader>oghd", gs.diffthis, { desc = "Diff This" })
      map("n", "<leader>oghD", function() gs.diffthis("~") end)
      map("n", "<leader>ogtd", gs.toggle_deleted, { desc = "Toggle Deleted" })

      -- Text object
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
    end,
    watch_gitdir = {
      interval = 1000,
      follow_files = true,
    },
    attach_to_untracked = true,
    current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
      delay = 1000,
    },
    current_line_blame_formatter_opts = {
      relative_time = false,
    },
    sign_priority = 6,
    update_debounce = 100,
    status_formatter = nil, -- Use default
    max_file_length = 40000,
    preview_config = {
      -- Options passed to nvim_open_win
      border = "single",
      style = "minimal",
      relative = "cursor",
      row = 0,
      col = 1,
    },
    yadm = {
      enable = false,
    },
  },
}
