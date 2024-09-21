return {

  { "tpope/vim-fugitive" },

  -- Git integration for buffers
  -- https://github.com/lewis6991/gitsigns.nvim
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
        current_line_blame = false,
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
          map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>")
          map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>")
          map("n", "<leader>hS", gs.stage_buffer)
          map("n", "<leader>ha", gs.stage_hunk)
          map("n", "<leader>hu", gs.undo_stage_hunk)
          map("n", "<leader>hR", gs.reset_buffer)
          map("n", "<leader>hp", gs.preview_hunk)
          map("n", "<leader>hb", function() gs.blame_line({ full = true }) end)
          map("n", "<leader>tB", gs.toggle_current_line_blame)
          map("n", "<leader>hd", gs.diffthis)
          map("n", "<leader>hD", function() gs.diffthis("~") end)

          -- Text object
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>")
        end,
      })
    end,
  },

  -- git-worktree.nvim: Manage git worktrees
  -- https://github.com/ThePrimeagen/git-worktree.nvim
  {
    "ThePrimeagen/git-worktree.nvim",
    config = function() require("git-worktree").setup() end,
  },

  -- An interactive and powerful Git interface for Neovim, inspired by Magit
  -- https://github.com/NeogitOrg/neogit
  {
    "NeogitOrg/neogit",
    config = function()
      -- This contains mainly Neogit but also a bunch of Git settings
      -- like fetching branches with telescope or blaming with fugitive
      local neogit = require("neogit")

      vim.keymap.set("n", "<leader>gs", neogit.open, { silent = true, noremap = true })
      vim.keymap.set("n", "<leader>gc", ":Neogit commit<CR>", { silent = true, noremap = true })
      vim.keymap.set("n", "<leader>gp", ":Neogit pull<CR>", { silent = true, noremap = true })
      vim.keymap.set("n", "<leader>gP", ":Neogit push<CR>", { silent = true, noremap = true })
      vim.keymap.set("n", "<leader>gb", ":Telescope git_branches<CR>", { silent = true, noremap = true })
      vim.keymap.set("n", "<leader>gB", ":G blame<CR>", { silent = true, noremap = true })

      neogit.setup({
        disable_commit_confirmation = true,
        disable_signs = false,
        disable_context_highlighting = false,
        disable_builtin_notifications = false,
        signs = {
          section = { "", "" },
          item = { "", "" },
          hunk = { "", "" },
        },
        integrations = {
          diffview = true,
        },
      })
    end,
  },
}
