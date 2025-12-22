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
K.n('k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Move up', noremap = true, expr = true })
K.n('j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Move down', noremap = true, expr = true })

-- ── Text manipulation ───────────────────────────────────────────────
K.d('<', { 'n', 'v' }, '<gv', 'Indent Left')
K.d('>', { 'n', 'v' }, '>gv', 'Indent Right')
K.d('<C-k>', { 'n', 'v' }, ":m '<-2<CR>gv=gv", 'Move Block Up')
K.d('<C-j>', { 'n', 'v' }, ":m '>+1<CR>gv=gv", 'Move Block Down')

-- ── Other operations ────────────────────────────────────────────────
K.nl('o', function() require('snacks').gitbrowse() end, 'Open repo in browser')
K.n('<C-s>', ':w!<cr>', { desc = 'Save', noremap = true })
K.n('<esc><esc>', ':nohlsearch<cr>', { desc = 'Clear Search Highlighting' })

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

local b = function() return require 'telescope.builtin' end
local lws = function() return b().lsp_workspace_symbols() end
local ldws = function() return b().lsp_dynamic_workspace_symbols() end

K.n('<C-l>', ':lua vim.lsp.buf.signature_help()<CR>', { desc = 'Signature' })
K.n('K', ':lua vim.lsp.buf.hover()<CR>', { desc = 'Hover Documentation' })
K.ld('ca', 'n', ':lua vim.lsp.buf.code_action()<CR>', 'Code Action')
K.ld('cci', 'n', function() b().lsp_incoming_calls() end, 'Incoming calls')
K.ld('cco', 'n', function() b().lsp_outgoing_calls() end, 'Outgoing calls')
K.ld('cd', 'n', function() b().lsp_definitions() end, 'Definitions')
K.ld('cf', { 'n', 'x' }, ':lua vim.lsp.buf.format()<CR>', 'Format')
K.ld('cg', 'n', ':lua require("neogen").generate()<CR>', 'Generate annotations')
K.ld('ci', 'n', function() b().lsp_implementations() end, 'Implementations')
K.ld('cp', 'n', function() b().lsp_type_definitions() end, 'Type Definition')
K.ld('cr', 'n', vim.lsp.buf.rename, 'Rename')
K.ld('cs', 'n', ':Telescope lsp_document_symbols<CR>', 'LSP Document Symbols')
K.ld('ct', 'n', function() b().treesitter() end, 'treesitter')
K.ld('cws', 'n', function() lws() end, 'Workspace Symbols')
K.ld('cwd', 'n', function() ldws() end, 'Dynamic Workspace Symbols')

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

local lazy_plugins = function()
  return require('telescope').extensions.lazy_plugins.lazy_plugins()
end

K.nl('f', function() require('fff').find_files() end, 'Find Files')
K.nl(',', ':Telescope buffers<cr>', 'Find existing buffers')

K.nl('sd', ':Telescope diagnostics<cr>', 'Search Diagnostics')
K.nl('sf', ':Telescope grep_string<cr>', 'Grep String')
K.nl('sh', ':Telescope help_tags<cr>', 'Help tags')
K.nl('sk', ':Telescope keymaps<cr>', 'Search Keymaps')
K.nl('so', ':Telescope oldfiles<CR>', 'Old Files')
K.nl('sp', function() lazy_plugins() end, 'Lazy Plugins')
K.nl('sq', ':Telescope quickfix<cr>', 'Quickfix')
K.nl('ss', ':Telescope treesitter<cr>', 'Treesitter')
K.nl('sx', ':Telescope import<cr>', 'Telescope: Import')

-- ── Trouble operations ──────────────────────────────────────────────
-- Convention is 'x' followed by the operation
K.nl('xd', ':Trouble diagnostics<cr>', 'Document Diagnostics')
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
  if vim.fn.confirm('Force save and quit?', '&Yes\n&No', 2) == 1 then vim.cmd 'wq!' end
end, 'Quit with force saving')
K.nl('qw', ':wq<CR>', 'Write and quit')
K.nl('qQ', function()
  if vim.fn.confirm('Force quit without saving?', '&Yes\n&No', 2) == 1 then
    vim.cmd 'q!'
  end
end, 'Force quit without saving')

-- That concludes the keymaps section of the config.
