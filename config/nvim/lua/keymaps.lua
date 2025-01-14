-- vim: set ft=lua ts=2 sw=2 tw=0 et cc=120 :

require 'utils'

-- ╭─────────────────────────────────────────────────────────╮
-- │                         Keymaps                         │
-- ╰─────────────────────────────────────────────────────────╯

-- ── Disable arrow keys in normal mode ───────────────────────────────
K.n('<left>', ':echo "Use h to move!!"<CR>')
K.n('<right>', ':echo "Use l to move!!"<CR>')
K.n('<up>', ':echo "Use k to move!!"<CR>')
K.n('<down>', ':echo "Use j to move!!"<CR>')

-- ── Splits ──────────────────────────────────────────────────────────
K.n('<C-w>,', ':vertical resize -10<CR>', { desc = 'V Resize -' })
K.n('<C-w>.', ':vertical resize +10<CR>', { desc = 'V Resize +' })
K.n('<C-w>-', ':resize -10<CR>', { desc = 'H Resize -' })
K.n('<C-w>+', ':resize +10<CR>', { desc = 'H Resize +' })
K.n('<C-w>=', '<C-w>=', { desc = 'Equal Size Splits' })

-- ── Deal with word wrap ─────────────────────────────────────────────
K.n(
  'k',
  "v:count == 0 ? 'gk' : 'k'",
  { desc = 'Move up', noremap = true, expr = true }
)
K.n(
  'j',
  "v:count == 0 ? 'gj' : 'j'",
  { desc = 'Move down', noremap = true, expr = true }
)

-- ── Text manipulation ───────────────────────────────────────────────
K.d('<', { 'n', 'v' }, '<gv', 'Indent Left')
K.d('>', { 'n', 'v' }, '>gv', 'Indent Right')
K.d('<C-k>', { 'n', 'v' }, ":m '<-2<CR>gv=gv", 'Move Block Up')
K.d('<C-j>', { 'n', 'v' }, ":m '>+1<CR>gv=gv", 'Move Block Down')

-- ── Other operations ────────────────────────────────────────────────
K.nl('o', function() require('snacks').gitbrowse() end, 'Open repo in browser')
K.n('<C-s>', ':w!<cr>', { desc = 'Save', noremap = true })
K.n('<esc><esc>', ':nohlsearch<cr>', { desc = 'Clear Search Highlighting' })

-- ── ToggleTerm ──────────────────────────────────────────────────────
K.d('<F1>', 'n', ':FloatermToggle<CR>', 'Toggle Floaterm')
K.d('<F1>', 'i', '<Esc>:FloatermToggle<CR>', 'Toggle Floaterm')
K.d('<F1>', 't', '<C-\\><C-n>:FloatermToggle<CR>', 'Toggle Floaterm')

-- ── Test operations ─────────────────────────────────────────────────
K.nl('an', ':silent TestNearest<CR>', 'Test Nearest')
K.nl('af', ':silent TestFile<CR>', 'Test File')
K.nl('as', ':silent TestSuite<CR>', 'Test Suite')
K.nl('al', ':silent TestLast<CR>', 'Test Last')
K.nl('av', ':silent TestVisit<CR>', 'Test Visit')

-- ── Buffer operations ───────────────────────────────────────────────
-- Mappings for buffer management operations like switching, deleting, etc.
-- Convention: All mappings start with 'b' followed by the operation
K.nl('ba', ':%bd|e#|bd#<cr>', 'Close all except current')
K.nl('bd', ':lua MiniBufremove.delete()<CR>', 'Delete')
K.nl('bh', ':bprev<cr>', 'Prev')
K.nl('bj', ':bfirst<cr>', 'First')
K.nl('bk', ':blast<cr>', 'Last')
K.nl('bl', ':bnext<cr>', 'Next')
K.nl('bw', ':lua MiniBufremove.wipeout()<CR>', 'Wipeout')

-- ── Code & LSP operations ───────────────────────────────────────────
-- Mappings for code and LSP operations like code actions, formatting, etc.
-- Convention: All mappings start with 'c' followed by the operation
-- unless it's a generic operation like signature help or hover
K.n('<C-l>', ':lua vim.lsp.buf.signature_help()<CR>', { desc = 'Signature' })
K.n('K', ':Lspsaga hover_doc<cr>', { desc = 'Hover Documentation' })
K.ld('ca', 'n', ':Lspsaga code_action<cr>', 'Code Action')
K.ld('cci', 'n', ':Lspsaga incoming_calls<cr>', 'Incoming Calls')
K.ld('cco', 'n', ':Lspsaga outgoing_calls<cr>', 'Outgoing Calls')
K.ld('cd', 'n', ':Lspsaga show_line_diagnostics<cr>', 'Line Diagnostics')
-- K.ld('cf', { 'n', 'x' }, ':lua vim.lsp.buf.format()<CR>', 'Format')
K.ld('cg', 'n', ':lua require("neogen").generate()<CR>', 'Generate annotations')
K.ld('ci', 'n', ':Lspsaga implement<cr>', 'Implementations')
K.ld('cl', 'n', ':Lspsaga show_cursor_diagnostics<cr>', 'Cursor Diagnostics')
K.ld('cp', 'n', ':Lspsaga peek_definition<cr>', 'Peek Definition')
K.ld('cr', 'n', ':Lspsaga rename<cr>', 'Rename')
K.ld('cR', 'n', ':Lspsaga rename ++project<cr>', 'Rename Project wide')
K.ld('cs', 'n', ':Telescope lsp_document_symbols<CR>', 'LSP Document Symbols')
K.ld('ct', 'n', ':Lspsaga peek_type_definition<cr>', 'Peek Type Definition')
K.ld('cT', 'n', ':Telescope lsp_type_definitions<CR>', 'LSP Type Definitions')
K.ld('cu', 'n', ':Lspsaga preview_definition<cr>', 'Preview Definition')
K.ld('cv', 'n', ':Lspsaga diagnostic_jump_prev<cr>', 'Diagnostic Jump Prev')
K.ld('cw', 'n', ':Lspsaga diagnostic_jump_next<cr>', 'Diagnostic Jump Next')

-- ── CommentBox operations ───────────────────────────────────────────
-- Mappings for creating and managing comment boxes
-- Convention: All mappings start with 'cb' followed by the box type
K.nl('cbb', '<Cmd>CBccbox<CR>', 'CB: Box Title')
K.nl('cbd', '<Cmd>CBd<CR>', 'CB: Remove a box')
K.nl('cbl', '<Cmd>CBline<CR>', 'CB: Simple Line')
K.nl('cbm', '<Cmd>CBllbox14<CR>', 'CB: Marked')
K.nl('cbt', '<Cmd>CBllline<CR>', 'CB: Titled Line')

-- ── Telescope operations ────────────────────────────────────────────
-- Mappings for Telescope operations like finding files, buffers, etc.
-- Convention: All mappings start with 's' followed by the operation
-- unless it's a generic operation like searching or finding buffers
K.nl('f', ':Telescope fd --hidden=true<cr>', 'Find Files')
K.nl(',', ':Telescope buffers<cr>', 'Find existing buffers')
K.nl(
  '/',
  function()
    require('telescope.builtin').current_buffer_fuzzy_find(
      require('telescope.themes').get_dropdown {
        winblend = 20,
        previewer = true,
      }
    )
  end,
  'Fuzzily search in current buffer'
)

K.nl('pm', ':PhpactorContextMenu<cr>', 'PHPactor: Context Menu')
K.nl('pn', ':PhpactorClassNew<cr>', 'PHPactor: Class New')
K.nl('ps', ':PhpactorClassSearch<cr>', 'PHPactor: Class Search')
K.nl('pt', ':PhpactorTransform<cr>', 'PHPactor: Transform')

K.nl('sc', ':Telescope commands<cr>', 'Commands')
K.nl('sd', ':Telescope diagnostics<cr>', 'Search Diagnostics')
K.nl('sg', ':Telescope live_grep<cr>', 'Search by Grep')
K.nl('sh', ':Telescope help_tags<cr>', 'Help tags')
K.nl('sk', ':Telescope keymaps<cr>', 'Search Keymaps')
K.nl('sl', ':Telescope luasnip<CR>', 'Search LuaSnip')
K.nl('so', ':Telescope oldfiles<CR>', 'Old Files')
K.nl(
  'sp',
  ':lua require("telescope").extensions.lazy_plugins.lazy_plugins()<cr>',
  'Lazy Plugins'
)
K.nl('sq', ':Telescope quickfix<cr>', 'Quickfix')
K.nl('ss', ':Telescope treesitter<cr>', 'Treesitter')
K.nl('sw', ':Telescope grep_string<cr>', 'Grep String')
K.nl('sx', ':Telescope import<cr>', 'Telescope: Import')

-- ── Trouble operations ──────────────────────────────────────────────
-- Convention is 'x' followed by the operation
K.nl('xd', ':Trouble document_diagnostics<cr>', 'Document Diagnostics')
K.nl('xl', ':Trouble loclist<cr>', 'Location List')
K.nl('xq', ':Trouble quickfix<cr>', 'Quickfix')
K.nl('xw', ':Trouble workspace_diagnostics<cr>', 'Workspace Diagnostics')
K.nl('xx', ':Trouble diagnostics<cr>', 'Diagnostic')

-- ── Toggle settings ─────────────────────────────────────────────────
-- Convention is 't' followed by the operation
K.nl('tc', ':CloakToggle<cr>', 'Cloak: Toggle')
K.nl('te', ':Neotree toggle<cr>', 'Toggle Neotree')
K.nl('tl', ToggleBackground, 'Toggle Light/Dark Mode')
K.nl('tn', ':Noice dismiss<cr>', 'Noice: Dismiss Notification')

-- ── Quit operations ─────────────────────────────────────────────────
-- Convention is 'q' followed by the operation
K.nl('qf', ':q<CR>', 'Quicker close split')
K.nl('qq', function()
  if vim.fn.confirm('Force save and quit?', '&Yes\n&No', 2) == 1 then
    vim.cmd 'wq!'
  end
end, 'Quit with force saving')
K.nl('qw', ':wq<CR>', 'Write and quit')
K.nl('qQ', function()
  if vim.fn.confirm('Force quit without saving?', '&Yes\n&No', 2) == 1 then
    vim.cmd 'q!'
  end
end, 'Force quit without saving')

-- ── Flash.nvim keymaps ──────────────────────────────────────────────
local nxo = { 'n', 'x', 'o' }
local fj = function() return require('flash').jump() end
local ft = function() return require('flash').treesitter() end
local fx = function() return require('flash').toggle() end
K.d('zk', nxo, fj, { desc = 'Flash' })
K.d('Zk', nxo, ft, { desc = 'Flash Treesitter' })
K.d('<m-s>', 'c', fx, { desc = 'Toggle Flash Search' })

-- That concludes the keymaps section of the config.
