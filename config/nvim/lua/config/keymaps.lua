-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local wk = require("which-key")

-- ╭──────────────────────────────────────────────────────────╮
-- │                       Comment box                        │
-- ╰──────────────────────────────────────────────────────────╯
wk.register({
  ["<Leader>"] = {
    b = {
      c = {
        name = "□ Comment boxes",
        b = { "<Cmd>CBccbox<CR>", "Box Title" },
        t = { "<Cmd>CBllline<CR>", "Titled Line" },
        l = { "<Cmd>CBline<CR>", "Simple Line" },
        m = { "<Cmd>CBllbox14<CR>", "Marked" },
        d = { "<Cmd>CBd<CR>", "Remove a box" },
      },
    },
  },
})
