-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap.set

--         ╭──────────────────────────────────────────────────────────╮
--         │                       Comment box                        │
--         ╰──────────────────────────────────────────────────────────╯
local cb = require("comment-box")

-- left aligned fixed size box with left aligned text
keymap({ "n", "v" }, "<Leader>bcb", cb.lbox, { desc = "Comment: Left aligned" })
-- centered adapted box with centered text
keymap({ "n", "v" }, "<Leader>bcc", cb.ccbox, { desc = "Comment: Centered" })

-- centered line
keymap("n", "<Leader>bcl", cb.cline, { desc = "Comment: Centered line" })
keymap("i", "<M-l>", cb.cline, { desc = "Comment: Centered line" })
