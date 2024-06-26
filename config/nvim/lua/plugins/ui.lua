-- luacheck: globals vim
return {
  -- Neotree configuration
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          always_show = {
            ".github",
            ".gitignore",
            ".editorconfig",
            ".python-version",
            ".nvmrc",
            ".env",
            ".env.example",
          },
        },
      },
    },
  },
  -- Cloak allows you to overlay *'s over defined patterns in defined files.
  -- https://github.com/laytan/cloak.nvim
  { "laytan/cloak.nvim" },
  -- Not UFO in the sky, but an ultra fold in Neovim.
  -- https://github.com/kevinhwang91/nvim-ufo/
  {
    "kevinhwang91/nvim-ufo",
    lazy = false,
    enabled = true,
    dependencies = {
      "kevinhwang91/promise-async",
      { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" },
      {
        "luukvbaal/statuscol.nvim",
        config = function()
          local builtin = require("statuscol.builtin")
          require("statuscol").setup({
            relculright = true,
            segments = {
              { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
              { text = { "%s" }, click = "v:lua.ScSa" },
              { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
            },
          })
        end,
      },
    },
    init = function()
      vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
      vim.o.foldcolumn = "1" -- '0' is not bad
      vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
    end,
    opts = {
      open_fold_hl_timeout = 150,
      close_fold_kinds_for_ft = { "imports", "comment" },
      preview = {
        win_config = {
          border = { "", "─", "", "", "", "─", "", "" },
          winhighlight = "Normal:Folded",
          winblend = 0,
        },
        mappings = {
          scrollU = "<C-u>",
          scrollD = "<C-d>",
          jumpTop = "[",
          jumpBot = "]",
        },
      },
      provider_selector = function(_, _, _) -- bufnr, filetype, buftype
        return { "treesitter", "indent" }
      end,
      fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (" 󰁂 %d "):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end,
    },
  },
  -- Indent guides for Neovim
  -- https://github.com/lukas-reineke/indent-blankline.nvim
  { "lukas-reineke/indent-blankline.nvim" },
  -- Git integration for buffers
  -- https://github.com/lewis6991/gitsigns.nvim
  { "lewis6991/gitsigns.nvim" },
  -- Close buffer without messing up with the window.
  -- https://github.com/famiu/bufdelete.nvim
  { "famiu/bufdelete.nvim" },
  -- Neovim plugin for locking a buffer to a window
  -- https://github.com/stevearc/stickybuf.nvim
  { "stevearc/stickybuf.nvim", opts = {} },
  -- A pretty window for previewing, navigating and editing your LSP locations
  -- https://github.com/DNLHC/glance.nvim
  { "dnlhc/glance.nvim" },
  -- Automatically expand width of the current window.
  -- Maximizes and restore it. And all this with nice animations!
  -- https://github.com/anuvyklack/windows.nvim
  {
    "anuvyklack/windows.nvim",
    dependencies = {
      "anuvyklack/middleclass",
      "anuvyklack/animation.nvim",
    },
    config = function()
      vim.o.winwidth = 15
      vim.o.winminwidth = 10
      vim.o.equalalways = false
      require("windows").setup()
    end,
  },
}
