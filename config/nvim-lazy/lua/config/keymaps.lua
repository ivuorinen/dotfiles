-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local wk = require("which-key")

-- ╭──────────────────────────────────────────────────────────╮
-- │                       Comment box                        │
-- ╰──────────────────────────────────────────────────────────╯
wk.add({
  { "<Leader>bc", group = "□ Comment box" },
  { "<Leader>bcb", "<Cmd>CBccbox<CR>", desc = "Box Title" },
  { "<Leader>bcd", "<Cmd>CBd<CR>", desc = "Remove a box" },
  { "<Leader>bcl", "<Cmd>CBline<CR>", desc = "Simple Line" },
  { "<Leader>bcm", "<Cmd>CBllbox14<CR>", desc = "Marked" },
  { "<Leader>bct", "<Cmd>CBllline<CR>", desc = "Titled Line" },
})
