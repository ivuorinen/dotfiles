local s = vim.keymap.set
-- Normal mode keymaps
local n = function(key, cmd, opts) s('n', key, cmd, opts) end
-- Visual mode keymaps
local v = function(key, cmd, opts) s('v', key, cmd, opts) end

-- Leader keymap shortcut function
-- It prepends '<leader>' to the key
local nl = function(key, cmd, opts) n('<leader>' .. key, cmd, opts) end
-- Local leader keymap shortcut function
-- It prepends '<leader>' to the key and uses desc from opts
local nld = function(key, cmd, desc) nl(key, cmd, { desc = desc }) end
-- Leader keymap shortcut function for visual mode
local xld = function(key, cmd, desc) s('x', '<leader>' .. key, cmd, { desc = desc }) end

-- Disable arrow keys in normal mode
n('<left>', ':echo "Use h to move!!"<CR>')
n('<right>', ':echo "Use l to move!!"<CR>')
n('<up>', ':echo "Use k to move!!"<CR>')
n('<down>', ':echo "Use j to move!!"<CR>')

n('<C-s>', ':w!<cr>', { desc = 'Save', noremap = true })
n('<esc><esc>', ':nohlsearch<cr>', { desc = 'Clear Search Highlighting' })

-- Buffer keymaps
nld('bd', ':lua MiniBufremove.delete()<CR>', 'Delete')
nld('bh', ':bprev<cr>', 'Prev')
nld('bj', ':bfirst<cr>', 'First')
nld('bk', ':blast<cr>', 'Last')
nld('bl', ':bnext<cr>', 'Next')
nld('bw', ':lua MiniBufremove.wipeout()<CR>', 'Wipeout')

-- Code
nld('cg', ':lua require("neogen").generate()<CR>', 'Generate annotations')
nld('cf', ':lua vim.lsp.buf.format({ async = false })<cr>', 'Format')

-- LSPSaga
nld('ca', ':Lspsaga code_action<cr>', 'Code Action')
nld('cd', ':Lspsaga show_line_diagnostics<cr>', 'Line Diagnostics')
nld('cci', ':Lspsaga incoming_calls<cr>', 'Incoming Calls')
nld('cco', ':Lspsaga outgoing_calls<cr>', 'Outgoing Calls')
nld('ci', ':Lspsaga implement<cr>', 'Implementations')
nld('cl', ':Lspsaga show_cursor_diagnostics<cr>', 'Show Cursor Diagnostics')
nld('cp', ':Lspsaga peek_definition<cr>', 'Peek Definition')
nld('cr', ':Lspsaga rename<cr>', 'Rename')
nld('cR', ':Lspsaga rename ++project<cr>', 'Rename Project wide')
nld('cs', ':Lspsaga signature_help<cr>', 'Signature Documentation')
nld('ct', ':Lspsaga peek_type_definition<cr>', 'Peek Type Definition')
nld('cu', ':Lspsaga preview_definition<cr>', 'Preview Definition')
nld('cv', ':Lspsaga diagnostic_jump_prev<cr>', 'Diagnostic Jump Prev')
nld('cw', ':Lspsaga diagnostic_jump_next<cr>', 'Diagnostic Jump Next')

-- CommentBox keymaps
nld('cbb', '<Cmd>CBccbox<CR>', 'CB: Box Title')
nld('cbd', '<Cmd>CBd<CR>', 'CB: Remove a box')
nld('cbl', '<Cmd>CBline<CR>', 'CB: Simple Line')
nld('cbm', '<Cmd>CBllbox14<CR>', 'CB: Marked')
nld('cbt', '<Cmd>CBllline<CR>', 'CB: Titled Line')

-- Harpoon keymaps
nld('ha', ':lua require("harpoon"):list():add()<cr>', 'harpoon file')
nld('hn', ':lua require("harpoon"):list():next()<cr>', 'harpoon to next')
nld('hp', ':lua require("harpoon"):list():prev()<cr>', 'harpoon to prev')

-- LSP
nld('la', ':lua vim.lsp.buf.code_action()<CR>', 'Code Action')
nld('lf', ':lua vim.lsp.buf.format()<CR>', 'Format')
xld('lf', ':lua vim.lsp.buf.format()<CR>', 'Format')
nld('lr', ':lua vim.lsp.buf.rename()<CR>', 'Rename')
nld('lR', ':lua vim.lsp.buf.references()<CR>', 'References')
nld('ls', ':lua require("telescope.builtin").lsp_document_symbols()<CR>', 'Document Symbols')
n('<C-k>', ':lua vim.lsp.buf.signature_help()<CR>', { desc = 'Signature Help' })
n('<C-h>', ':lua vim.lsp.buf.hover()<CR>', { desc = 'Hover' })
n('K', ':Lspsaga hover_doc<cr>', { desc = 'Hover Documentation' })

-- Telescope
nld('f', ':Telescope find_files<cr>', 'Find Files')
nld('sb', ':Telescope buffers<cr>', 'Find existing buffers')
nld('sc', ':Telescope commands<cr>', 'Commands')
nld('sd', ':Telescope diagnostics<cr>', 'Search Diagnostics')
nld('sg', ':Telescope live_grep<cr>', 'Search by Grep')
nld('sh', ':Telescope highlights<cr>', 'List Highlights')
nld('sl', ':Telescope luasnip<CR>', 'Search LuaSnip')
nld('sm', ':Telescope harpoon marks<CR>', 'Harpoon Marks')
nld('sn', ':lua require("telescope").extensions.notify.notify()<CR>', 'Show Notifications')
nld('so', ':Telescope oldfiles<CR>', 'Old Files')
nld('sp', ':lua require("telescope").extensions.lazy_plugins.lazy_plugins()<cr>', 'Lazy Plugins')
nld('sq', ':Telescope quickfix<cr>', 'Quickfix')
nld('srd', ':Telescope lsp_definitions<CR>', 'LSP Definitions')
nld('sri', ':Telescope lsp_implementations<CR>', 'LSP Implementations')
nld('srp', ':Telescope lsp_document_symbols<CR>', 'LSP Document Symbols')
nld('srr', ':Telescope lsp_references<CR>', 'LSP References')
nld('srt', ':Telescope lsp_type_definitions<CR>', 'LSP Type Definitions')
nld('srw', ':Telescope lsp_workspace_symbols<CR>', 'LSP Workspace Symbols')
nld('ss', ':Telescope treesitter<cr>', 'Treesitter')
nld('st', ':TodoTelescope<cr>', 'Search Todos')
nld('sw', ':Telescope grep_string<cr>', 'Grep String')
nld('sx', ':Telescope import', 'Telescope: Import')

-- Trouble
nld('xd', ':Trouble document_diagnostics<cr>', 'Trouble: Document Diagnostics')
nld('xl', ':Trouble loclist<cr>', 'Trouble: Location List')
nld('xq', ':Trouble quickfix<cr>', 'Trouble: Quickfix')
nld('xw', ':Trouble workspace_diagnostics<cr>', 'Trouble: Workspace Diagnostics')
nld('xx', ':Trouble diagnostics<cr>', 'Trouble: Diagnostic')

-- Text manipulation
n('>', '>gv', { desc = 'Indent Right' })
n('<', '<gv', { desc = 'Indent Left' })
n('<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Move Block Down' })
n('<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Move Block Up' })
v('>', '>gv', { desc = 'Indent Right' })
v('<', '<gv', { desc = 'Indent Left' })
v('<A-j>', ":m '>+1<CR>gv=gv", { desc = 'Move Block Down' })
v('<A-k>', ":m '<-2<CR>gv=gv", { desc = 'Move Block Up' })

-- Toggle settings
nld('tc', ':CloakToggle<cr>', 'Cloak: Toggle')
nld('te', ':Neotree toggle<cr>', 'Toggle Neotree')
nld('tl', ':exec &bg=="light" ? "set bg=dark" : "set bg=light"<cr>', 'Toggle Light/Dark Mode')
nld('tn', ':Noice dismiss<cr>', 'Noice: Dismiss Notification')

-- Splits
n('<C-w>,', ':vertical resize -10<CR>', { desc = 'V Resize -' })
n('<C-w>.', ':vertical resize +10<CR>', { desc = 'V Resize +' })

-- Deal with word wrap
n('k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Move up', noremap = true, expr = true })
n('j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Move down', noremap = true, expr = true })

-- Quit
nld('qf', ':q<CR>', 'Quicker close split')
nld('qq', ':wq!<CR>', 'Quit with force saving')
nld('qw', ':wq<CR>', 'Write and quit')

-- vim: set ft=lua ts=2 sw=2 tw=0 et :
