--[[
  Keymappings for nvim experience.

  I use combination of both nvim default vim.api.nvim_set_keymap
  and WhichKey register. Slowly migrating to the WhichKey system,
  and tweaking the groupings as I go.
--]]
-- luacheck: globals vim CAPABILITIES

local wk = require("which-key")

--  ╭──────────────────────────────────────────────────────────╮
--  │ Register keybindings                                     │
--  ╰──────────────────────────────────────────────────────────╯

--  ╭──────────────────────────────────────────────────────────╮
--  │ Register in all modes, prefix <leader>                   │
--  ╰──────────────────────────────────────────────────────────╯
wk.register({
  b = {
    name = "+buffer",
    n = { "<cmd>tabnew<cr>", "[n]ew tab" },
    a = {
      name = "+annotate"
      -- defined in plugins/neogen.lua
    },
    c = {
      name = "+comments",
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
      name = "+delete buffers",
      h = {
        "<CMD>lua require('close_buffers').delete({type = 'hidden'})<CR>",
        "Delete hidden buffers",
      },
    },
    t = { ":TabnineToggle<cr>", "Toggle TabNine" },
  },
  D = {
    name = "+Diagnostics (Trouble)",
    t = { ":TroubleToggle<CR>", "[D]iagnostics [t]oggle" },
    -- Quick navigation between diagonostics.
    f = { ":lua vim.diagnostic.open_float()<CR>", "[D]iagnostics: Open [f]loat" },
    n = { ":lua vim.diagnostic.goto_next()<CR>", "[D]iagnostics: [n]ext" },
    p = { ":lua vim.diagnostic.goto_prev()<CR>", "[D]iagnostics: [p]rev" },
    ---
    x = { function() require("trouble").open() end, "Open Trouble" },
    w = { function() require("trouble").open("workspace_diagnostics") end, "Workspace diagnostics" },
    d = { function() require("trouble").open("document_diagnostics") end, "Document diagnostics" },
    q = { function() require("trouble").open("quickfix") end, "Quickfix" },
    l = { function() require("trouble").open("loclist") end, "Loclist" },
    r = { function() require("trouble").open("lsp_references") end, "LSP References" },
  },
  e = {
    function() vim.cmd("Neotree focus source=filesystem position=left") end,
    "Toggle the sidebar tree",
  },
  f = {
    name = "+find",
    -- Find recursively files across the root folder subfiles.
    f = { ':lua require("telescope.builtin").find_files()<cr>', "[f]ind [f]iles" },
    -- Find recursively a text across the root folder subfiles.
    g = { ':lua require("telescope.builtin").live_grep()<cr>', "[f]ind text with [g]rep" },
  },
  h = {
    name = "+harpoon",
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
    name = "+help/Conceal/Treesitter",
    c = {
      name = "+conceal",
      h = { ":set conceallevel=1<cr>", "hide/conceal" },
      s = { ":set conceallevel=0<cr>", "show/unconceal" },
    },
    t = {
      name = "+treesitter",
      t = { vim.treesitter.inspect_tree, "show tree" },
      c = { ":=vim.treesitter.get_captures_at_cursor()<cr>", "show capture" },
      n = { ":=vim.treesitter.get_node():type()<cr>", "show node" },
    },
  },
  o = {
    g = {
      -- defined in plugins/gitsigns.lua
      name = "+git",
      b = {
        name = "+blame",
      },
    },
  },
  p = {
    name = "+plugins",
    i = { function() require("lazy").install() end, "plugins [i]nstall" },
    s = { function() require("lazy").home() end, "plugins [s]tatus" },
    S = { function() require("lazy").sync() end, "plugins [S]ync" },
    u = { function() require("lazy").check() end, "plugins Check [u]pdates" },
    U = { function() require("lazy").update() end, "plugins [U]pdate" },
  },
  q = {
    name = "+quit",
    q = { ":qa<cr>", "quit: [q]uit all" },
    f = { ":qa!<cr>", "quit: all with [f]orce" },
  },
  r = {
    -- defined in plugins/refactoring-nvim.lua
    name = "+refactor",
  },
  t = {
    name = "+telescope",
    -- Find recursively TODOs, NOTEs, FIXITs, ... across the root folder subfiles.
    t = { ":TodoTelescope<cr>", "[t]elescope: [t]odo" },
  },
  x = { ":Bdelete<CR>", "Close current buffer" },
}, { prefix = "<leader>" })

--
--  ╭──────────────────────────────────────────────────────────╮
--  │ Normal mode, prefix <leader>                             │
--  ╰──────────────────────────────────────────────────────────╯
wk.register({
  b = { name = "Buffer" },
}, { mode = "n", prefix = "<leader>" })

--
--  ╭──────────────────────────────────────────────────────────╮
--  │ Insert mode, prefix <leader>                             │
--  ╰──────────────────────────────────────────────────────────╯
wk.register({
  b = { name = "Buffer" },
}, { mode = "i", prefix = "<leader>" })

--
--  ╭──────────────────────────────────────────────────────────╮
--  │ Insert mode, no prefix                                   │
--  ╰──────────────────────────────────────────────────────────╯
wk.register({
  ["<C-s>"] = { "<cmd>w<cr>", "Save file" },
  ["<C-Home>"] = { "<Home>", "Do just Home on CTRL + Home" },
}, { mode = "i", prefix = "" })

--
--  ╭──────────────────────────────────────────────────────────╮
--  │ All modes, no prefix                                     │
--  ╰──────────────────────────────────────────────────────────╯
wk.register({
  ["<C-s>"] = { "<cmd>w<cr>", "Save file" },
  ["<C-End>"] = { "<End>", "Do just End on CTRL + End" },
}, { prefix = "" })

--
--  ╭──────────────────────────────────────────────────────────╮
--  │ Other keymappings, still to move                         │
--  ╰──────────────────────────────────────────────────────────╯

local key = vim.api.nvim_set_keymap
local remap = { noremap = true, silent = true }

-- Go to the next block.
--key('n', '<C-Down>', 'g%', remap )

-- Loop through brackets blocks.
--key('n', '<C-Up>', 'z%', remap )

-- Move lines normally like an IDE when line wraps
key("i", "<Down>", [[v:count ? 'j' : '<c-o>gj']], { expr = true, noremap = true, silent = true })
key("i", "<Up>", [[v:count ? 'k' : '<c-o>gk']], { expr = true, noremap = true, silent = true })
key("n", "<Down>", [[v:count ? 'j' : 'gj']], { expr = true, noremap = true, silent = true })
key("n", "<Up>", [[v:count ? 'k' : 'gk']], { expr = true, noremap = true, silent = true })

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

-- Indent the current visual selection.
key("v", "<", "<gv", remap)
key("v", ">", ">gv", remap)

-- Set 'Backspace' as 'delete selection' for the visual selection.
key("v", "<BS>", '"_di', remap)
