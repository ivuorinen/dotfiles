--[[
  Keymappings for nvim experience.

  I use combination of both nvim default vim.api.nvim_set_keymap
  and WhichKey register. Slowly migrating to the WhichKey system,
  and tweaking the groupings as I go.
--]]

local key = vim.api.nvim_set_keymap
local remap = { noremap = true, silent = true }

local wk = require("which-key")

--  ╭──────────────────────────────────────────────────────────╮
--  │ Register keybindings                                     │
--  ╰──────────────────────────────────────────────────────────╯

-- Register in all modes, prefix <leader>
wk.register({
  b = {
    name = "Buffer",
    n = {
      "<cmd>tabnew<cr>",
      "New tab",
    },
    c = {
      name = "Comments",
      b = {
        "<cmd>lua require('comment-box').lbox()<cr>",
        "Left aligned fixed size box with left aligned text",
      },
      c = {
        "<cmd>lua require('comment-box').ccbox()<cr>",
        desc = "Centered adapted box with centered text",
      },
      l = {
        "<cmd>lua require('comment-box').cline()<cr>",
        desc = "Centered line",
      },
    },
    d = {
      name = "Delete buffers",
      h = {
        "<CMD>lua require('close_buffers').delete({type = 'hidden'})<CR>",
        "Delete hidden buffers",
      },
    },
  },
  D = {
    name = "[D]iagnostics (Trouble)",
    t = { ":TroubleToggle<CR>", "[D]iagnostics [t]oggle" },
    -- Quick navigation between diagonostics.
    f = { ":lua vim.diagnostic.open_float()<CR>", "[D]iagnostics: Open [f]loat" },
    n = { ":lua vim.diagnostic.goto_next()<CR>", "[D]iagnostics: [n]ext" },
    p = { ":lua vim.diagnostic.goto_prev()<CR>", "[D]iagnostics: [p]rev" },
  },
  f = {
    name = "[f]ind",
    -- Find recursively files across the root folder subfiles.
    f = { ':lua require("telescope.builtin").find_files()<cr>', "[f]ind [f]iles" },
    -- Find recursively a text across the root folder subfiles.
    g = { ':lua require("telescope.builtin").live_grep()<cr>', "[f]ind text with [g]rep" },
  },
  h = {
    name = "[h]arpoon",
    a = { "<cmd>lua require('harpoon.mark').add_file()<cr>", "[h]arpoon: [A]dd file" },
    r = { "<cmd>lua require('harpoon.mark').rm_file()<cr>", "[h]arpoon: [r]emove file" },
    m = { "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", "[h]arpoon: harpoon [m]enu" },
    n = { "<cmd>lua require('harpoon.ui').nav_next()<cr>", "[h]arpoon: [n]ext file" },
    p = { "<cmd>lua require('harpoon.ui').nav_prev()<cr>", "[h]arpoon: [p]revious file" },
    ["1"] = { "<cmd> lua require('harpoon.ui').nav_file(1)<cr>", "[h]arpoon: file 1" },
    ["2"] = { "<cmd> lua require('harpoon.ui').nav_file(2)<cr>", "[h]arpoon: file 2" },
    ["3"] = { "<cmd> lua require('harpoon.ui').nav_file(3)<cr>", "[h]arpoon: file 3" },
  },
  --- Remap debugging to "H" from LV default of "h"
  H = {
    name = "[H]elp/Conceal/Telescope",
    c = {
      name = "[c]onceal",
      h = { ":set conceallevel=1<cr>", "hide/conceal" },
      s = { ":set conceallevel=0<cr>", "show/unconceal" },
    },
    t = {
      name = "Treesitter",
      t = { vim.treesitter.inspect_tree, "show tree" },
      c = { ":=vim.treesitter.get_captures_at_cursor()<cr>", "show capture" },
      n = { ":=vim.treesitter.get_node():type()<cr>", "show node" },
    },
  },
  p = {
    name = "[p]lugins",
    i = { function() require("lazy").install() end, "[p]lugins [i]nstall" },
    s = { function() require("lazy").home() end, "[p]lugins [s]tatus" },
    S = { function() require("lazy").sync() end, "[p]lugins [S]ync" },
    u = { function() require("lazy").check() end, "[p]lugins Check [u]pdates" },
    U = { function() require("lazy").update() end, "[p]lugins [U]pdate" },
  },
  q = {
    name = "[q]uit",
    q = { ":qa<cr>", "[q]uit: [q]uit all" },
    f = { ":qa!<cr>", "[q]uit: all with [f]orce" },
  },
  t = {
    name = "[t]elescope",
    -- Find recursively TODOs, NOTEs, FIXITs, ... across the root folder subfiles.
    t = { ":TodoTelescope<cr>", "[t]elescope: [t]odo" },
  },
  x = { ":Bdelete<CR>", "[x]: Close current buffer" },
}, { prefix = "<leader>" })

-- Normal mode, prefix <leader>
wk.register({
  b = { name = "Buffer" },
}, { mode = "n", prefix = "<leader>" })

-- Insert mode, prefix <leader>
wk.register({
  b = { name = "Buffer" },
}, { mode = "i", prefix = "<leader>" })

-- Go to the next block.
--key('n', '<C-Down>', 'g%', remap )

-- Loop through brackets blocks.
--key('n', '<C-Up>', 'z%', remap )

-- Do just End on CTRL + End.
key("i", "<C-End>", "<End>", remap)
key("n", "<C-End>", "<End>", remap)

-- Do just Home on CTRL + Home.
key("i", "<C-Home>", "<End>", remap)

-- Highlight the word after pressing enter.
key(
  "n",
  "<CR>",
  [[:let searchTerm = '\v<'.expand("<cword>").'>' <bar> let @/ = searchTerm <bar> echo '/'.@/ <bar> call histadd("search", searchTerm) <bar> set hls<cr>]],
  remap
)

-- Highlight the visual selection after pressing enter.
key(
  "v",
  "<CR>",
  [["*y:silent! let searchTerm = '\V'.substitute(escape(@*, '\/'), "\n", '\\n', "g") <bar> let @/ = searchTerm <bar> echo '/'.@/ <bar> call histadd("search", searchTerm) <bar> set hls<cr>]],
  remap
)

-- Toggle highlight of search
key("n", "<C-c>", ":set hlsearch!<CR>", remap)

-- Toggle the sidebar tree of the root folder.
key("n", "<leader>e", "", {
  noremap = true,
  silent = true,
  desc = "Open NeoTree without warnings",
  callback = function() vim.cmd("Neotree toggle source=filesystem position=left") end,
})

-- Try to correct the current word.
key("i", "<C-b>", "ea<C-x><C-s>", remap)

-- Toggle built-in nvim spell checking.
key("n", "<F5>", ":setlocal spell!<CR>", remap)

-- Move lines normally like an IDE when line wraps
key("i", "<Down>", [[v:count ? 'j' : '<c-o>gj']], { expr = true, noremap = true, silent = true })
key("i", "<Up>", [[v:count ? 'k' : '<c-o>gk']], { expr = true, noremap = true, silent = true })
key("n", "<Down>", [[v:count ? 'j' : 'gj']], { expr = true, noremap = true, silent = true })
key("n", "<Up>", [[v:count ? 'k' : 'gk']], { expr = true, noremap = true, silent = true })

-- Set 'CTRL + v' as 'paster'
-- key('', '<C-v>', 'map"_d<Esc>i', remap )
key("v", "<C-v>", "p", remap)

-- Set 'CTRL + x' as 'cut'
key("v", "<C-x>", "mad`ai<Right>", { silent = true })

-- Set 'CTRL + c' as 'copier'
key("v", "<C-c>", "may`ai", remap)
key("i", "<C-v>", "<Esc>:Registers<CR>", remap)

-- Set 'CTRL + s as save'
key("n", "<C-s>", "<cmd>w<cr>", remap)

-- Create mark.
key("n", "'", "`", remap)

-- Move normaly bottom and up with C+Up and C+Down.
key("i", "<C-Up>", "<C-o>gk", remap)
key("i", "<C-Down>", "<C-o>gj", remap)
key("n", "<C-Up>", "gk", remap)
key("n", "<C-Down>", "gj", remap)

-- Set 'CTRL + z' as 'undo'
key("i", "<C-z>", "<Esc>ui", remap)

-- Set 'CTRL + y' as 'redo'
key("i", "<C-y>", "<Esc><C-r>", remap)

-- Set 'SHIFT + arrows' as 'select' like modern text-editor.
key("n", "<S-Up>", "v<Up>", remap)
key("n", "<S-Down>", "v<Down>", remap)
key("n", "<S-Left>", "v<Left>", remap)
key("n", "<S-Right>", "v<Right>", remap)
key("v", "<S-Up>", "<Up>", remap)
key("v", "<S-Down>", "<Down>", remap)
key("v", "<S-Left>", "<Left>", remap)
key("v", "<S-Right>", "<Right>", remap)
key("i", "<S-Up>", "<Esc>v<Up>", remap)
key("i", "<S-Down>", "<C-o>v<Down>", remap)
key("i", "<S-Left>", "<Esc>v<Left>", remap)
key("i", "<S-Right>", "<C-o>v<Right>", remap)

-- Set 'SHIFT + special-keys' as 'select' like a modern text editor.
key("i", "<S-Home>", "<Esc>v<Home>", remap)
key("i", "<S-End>", "<C-o>v<End><Left>", remap)
key("n", "<S-Home>", "v<Home>", remap)
key("n", "<S-End>", "v<End><Left>", remap)
key("n", "<S-PageUp>", "", remap)
key("n", "<S-PageDown>", "<Esc>:call Visual_Scroll_Down()<CR>i<Right><Left>", remap)

-- Indent the current visual selection.
key("v", "<", "<gv", remap)
key("v", ">", ">gv", remap)

-- Set 'Backspace' as 'delete selection' for the visual selection.
key("v", "<BS>", '"_di', remap)

---

-- Barbar keymappings

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Move to previous/next
map("n", "<C-,>", "<Cmd>BufferPrevious<CR>", opts)
map("n", "<C-.>", "<Cmd>BufferNext<CR>", opts)
-- Re-order to previous/next
map("n", "<C-<>", "<Cmd>BufferMovePrevious<CR>", opts)
map("n", "<C->>", "<Cmd>BufferMoveNext<CR>", opts)
-- Goto buffer in position...
map("n", "<C-1>", "<Cmd>BufferGoto 1<CR>", opts)
map("n", "<C-2>", "<Cmd>BufferGoto 2<CR>", opts)
map("n", "<C-3>", "<Cmd>BufferGoto 3<CR>", opts)
map("n", "<C-4>", "<Cmd>BufferGoto 4<CR>", opts)
map("n", "<C-5>", "<Cmd>BufferGoto 5<CR>", opts)
map("n", "<C-6>", "<Cmd>BufferGoto 6<CR>", opts)
map("n", "<C-7>", "<Cmd>BufferGoto 7<CR>", opts)
map("n", "<C-8>", "<Cmd>BufferGoto 8<CR>", opts)
map("n", "<C-9>", "<Cmd>BufferGoto 9<CR>", opts)
map("n", "<C-0>", "<Cmd>BufferLast<CR>", opts)
-- Pin/unpin buffer
map("n", "<C-p>", "<Cmd>BufferPin<CR>", opts)

-- Close buffer
-- map('n', '<C-c>', '<Cmd>BufferClose<CR>', opts)

-- Wipeout buffer
--                 :BufferWipeout
-- Close commands
--                 :BufferCloseAllButCurrent
--                 :BufferCloseAllButPinned
--                 :BufferCloseAllButCurrentOrPinned
--                 :BufferCloseBuffersLeft
--                 :BufferCloseBuffersRight
-- Magic buffer-picking mode
map("n", "<C-p>", "<Cmd>BufferPick<CR>", opts)
-- Sort automatically by...
map("n", "<Space>bb", "<Cmd>BufferOrderByBufferNumber<CR>", opts)
map("n", "<Space>bd", "<Cmd>BufferOrderByDirectory<CR>", opts)
map("n", "<Space>bl", "<Cmd>BufferOrderByLanguage<CR>", opts)
map("n", "<Space>bw", "<Cmd>BufferOrderByWindowNumber<CR>", opts)

-- Other:
-- :BarbarEnable - enables barbar (enabled by default)
-- :BarbarDisable - very bad command, should never be used
