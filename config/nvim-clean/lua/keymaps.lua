vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = false })

-- twilight
vim.api.nvim_set_keymap("n", "tw", ":Twilight<enter>", { noremap = false })

-- buffers
vim.api.nvim_set_keymap("n", "bk", ":blast<enter>", { desc = "Last", noremap = false })
vim.api.nvim_set_keymap("n", "bj", ":bfirst<enter>", { desc = "First", noremap = false })
vim.api.nvim_set_keymap("n", "bh", ":bprev<enter>", { desc = "Prev", noremap = false })
vim.api.nvim_set_keymap("n", "bl", ":bnext<enter>", { desc = "Next", noremap = false })
vim.api.nvim_set_keymap("n", "bd", ":bdelete<enter>", { desc = "Delete", noremap = false })

-- files
vim.api.nvim_set_keymap("n", "QQ", ":q!<enter>", { desc = "Quickly Quit", noremap = false })
vim.api.nvim_set_keymap("n", "WW", ":w!<enter>", { desc = "Force write", noremap = false })
vim.api.nvim_set_keymap("n", "E", "$", { noremap = false })
vim.api.nvim_set_keymap("n", "B", "^", { noremap = false })
vim.api.nvim_set_keymap("n", "tT", ":TransparentToggle<CR>", { desc = "Toggle Transparency", noremap = true })
vim.api.nvim_set_keymap("n", "ss", ":noh<CR>", { noremap = true })

-- splits
vim.api.nvim_set_keymap("n", "<C-W>,", ":vertical resize -10<CR>", { desc = "V Resize -", noremap = true })
vim.api.nvim_set_keymap("n", "<C-W>.", ":vertical resize +10<CR>", { desc = "V Resize +", noremap = true })

-- Quicker close split
vim.keymap.set("n", "<leader>qf", ":q<CR>", { desc = "Quicker close split", silent = true, noremap = true })

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Noice
vim.api.nvim_set_keymap("n", "<leader>nn", ":Noice dismiss<CR>", { desc = "Noice dismiss", noremap = true })

vim.keymap.set("n", "<leader>xe", "<cmd>GoIfErr<cr>", { desc = "Go If Error", silent = true, noremap = true })

-- TIP: Disable arrow keys in normal mode
vim.keymap.set("n", "<left>", '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set("n", "<right>", '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set("n", "<up>", '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set("n", "<down>", '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Old habits
vim.keymap.set("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>qq", "<cmd>wq!<CR>", { desc = "[qq] Quickly Quit" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.highlight.on_yank() end,
  group = highlight_group,
  pattern = "*",
})
