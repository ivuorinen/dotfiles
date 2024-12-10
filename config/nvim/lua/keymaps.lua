-- ╭─────────────────────────────────────────────────────────╮
-- │            Function shortcuts for keymap set            │
-- ╰─────────────────────────────────────────────────────────╯
-- vim: set ft=lua ts=2 sw=2 tw=0 et cc=80 :

-- Keymap set shortcut
--@type vim.keymap.set
local s = vim.keymap.set

-- Handle description
---@param desc string|table? Optional description. Can be a string or a table.
---@return table -- The description as a table.
local function handleDesc(desc)
  if type(desc) == "string" then
    -- Convert string to table with `desc` as a key
    -- If the string is empty, just return as an empty description
    return { desc = desc }
  elseif type(desc) == "table" then
    -- If desc doesn't have 'desc' key, combine it with
    -- others with empty description
    if not desc.desc then
      desc.desc = ''
      return desc
    end
    -- Use the table as is
    return desc
  else
    -- Default to an empty table if `desc` is nil or an unsupported type
    return { desc = '' }
  end
end

-- Normal mode keymaps
---@param key string rhs, required
---@param cmd string|function lhs, required
---@param opts table? Options, optional
local n = function(key, cmd, opts) s('n', key, cmd, opts) end

-- Leader keymap shortcut function
-- It prepends '<leader>' to the key
---@param key string rhs, required, but will be prepended with '<leader>'
---@param cmd string|function lhs, required
---@param opts table|string? Options (or just description), optional
local nl = function(key, cmd, opts)
  opts = handleDesc(opts)
  n('<leader>' .. key, cmd, opts)
end

-- Local leader keymap shortcut function
-- It prepends '<leader>' to the key and uses desc from opts
---@param key string rhs, required, but will be prepended with '<leader>'
---@param cmd string|function lhs, required
---@param opts table|string description, required
local nld = function(key, cmd, opts)
  opts = handleDesc(opts)
  nl(key, cmd, opts)
end

-- Keymap shortcut function with mode defined, good for sorting by rhs
---@param key string rhs, required
---@param mode string|string[] one of n, v, x, or table of modes { 'n', 'v' }
---@param cmd string|function lhs, required
---@param opts string|table description, required
local d = function(key, mode, cmd, opts)
  opts = handleDesc(opts)
  s(mode, key, cmd, opts)
end

-- Leader based keymap shortcut function with mode defined
---@param key string rhs, required, but will be prepended with '<leader>'
---@param mode string|string[] one of n, v, x, or table of modes { 'n', 'v' }
---@param cmd string|function lhs, required
---@param opts string|table description (or opts), required
local ld = function(key, mode, cmd, opts)
  opts = handleDesc(opts)
  s(mode, '<leader>' .. key, cmd, opts)
end

-- ╭─────────────────────────────────────────────────────────╮
-- │                         Keymaps                         │
-- ╰─────────────────────────────────────────────────────────╯

-- Disable arrow keys in normal mode
n('<left>', ':echo "Use h to move!!"<CR>')
n('<right>', ':echo "Use l to move!!"<CR>')
n('<up>', ':echo "Use k to move!!"<CR>')
n('<down>', ':echo "Use j to move!!"<CR>')

n('<C-s>', ':w!<cr>', { desc = 'Save', noremap = true })
n('<esc><esc>', ':nohlsearch<cr>', { desc = 'Clear Search Highlighting' })

-- Buffer operations
-- Mappings for buffer management operations like switching, deleting, etc.
-- Convention: All mappings start with 'b' followed by the operation
nld('ba', ':%bd|e#|bd#<cr>', 'Close all except current')
nld('bd', ':lua MiniBufremove.delete()<CR>', 'Delete')
nld('bh', ':bprev<cr>', 'Prev')
nld('bj', ':bfirst<cr>', 'First')
nld('bk', ':blast<cr>', 'Last')
nld('bl', ':bnext<cr>', 'Next')
nld('bw', ':lua MiniBufremove.wipeout()<CR>', 'Wipeout')

-- Code
nld('cg', ':lua require("neogen").generate()<CR>', 'Generate annotations')

-- LSP
n('<C-l>', ':lua vim.lsp.buf.signature_help()<CR>', { desc = 'Signature' })
n('K', ':Lspsaga hover_doc<cr>', { desc = 'Hover Documentation' })
ld('ca', 'n', ':Lspsaga code_action<cr>', 'Code Action')
ld('cci', 'n', ':Lspsaga incoming_calls<cr>', 'Incoming Calls')
ld('cco', 'n', ':Lspsaga outgoing_calls<cr>', 'Outgoing Calls')
ld('cd', 'n', ':Lspsaga show_line_diagnostics<cr>', 'Line Diagnostics')
ld('cf', { 'n', 'x' }, ':lua vim.lsp.buf.format()<CR>', 'Format')
ld('ci', 'n', ':Lspsaga implement<cr>', 'Implementations')
ld('cl', 'n', ':Lspsaga show_cursor_diagnostics<cr>', 'Cursor Diagnostics')
ld('cp', 'n', ':Lspsaga peek_definition<cr>', 'Peek Definition')
ld('cr', 'n', ':Lspsaga rename<cr>', 'Rename')
ld('cR', 'n', ':Lspsaga rename ++project<cr>', 'Rename Project wide')
ld('cs', 'n', ':Telescope lsp_document_symbols<CR>', 'LSP Document Symbols')
ld('ct', 'n', ':Lspsaga peek_type_definition<cr>', 'Peek Type Definition')
ld('cT', 'n', ':Telescope lsp_type_definitions<CR>', 'LSP Type Definitions')
ld('cu', 'n', ':Lspsaga preview_definition<cr>', 'Preview Definition')
ld('cv', 'n', ':Lspsaga diagnostic_jump_prev<cr>', 'Diagnostic Jump Prev')
ld('cw', 'n', ':Lspsaga diagnostic_jump_next<cr>', 'Diagnostic Jump Next')

-- CommentBox operations
-- Mappings for creating and managing comment boxes
-- Convention: All mappings start with 'cb' followed by the box type
nld('cbb', '<Cmd>CBccbox<CR>', 'CB: Box Title')
nld('cbd', '<Cmd>CBd<CR>', 'CB: Remove a box')
nld('cbl', '<Cmd>CBline<CR>', 'CB: Simple Line')
nld('cbm', '<Cmd>CBllbox14<CR>', 'CB: Marked')
nld('cbt', '<Cmd>CBllline<CR>', 'CB: Titled Line')


-- Telescope
nld('f', ':Telescope find_files<cr>', 'Find Files')
nld(',', ':Telescope buffers<cr>', 'Find existing buffers')
nld('/', function()
  require('telescope.builtin').current_buffer_fuzzy_find(
    require('telescope.themes').get_dropdown {
      winblend = 20,
      previewer = true,
    }
  )
end, 'Fuzzily search in current buffer')

nld('sc', ':Telescope commands<cr>', 'Commands')
nld('sd', ':Telescope diagnostics<cr>', 'Search Diagnostics')
nld('sg', ':Telescope live_grep<cr>', 'Search by Grep')
nld('sh', ':Telescope highlights<cr>', 'List Highlights')
nld('sk', ':Telescope keymaps<cr>', 'Search Keymaps')
nld('sl', ':Telescope luasnip<CR>', 'Search LuaSnip')
nld('so', ':Telescope oldfiles<CR>', 'Old Files')
nld('sp',
  ':lua require("telescope").extensions.lazy_plugins.lazy_plugins()<cr>',
  'Lazy Plugins')
nld('sq', ':Telescope quickfix<cr>', 'Quickfix')
nld('ss', ':Telescope treesitter<cr>', 'Treesitter')
nld('st', ':TodoTelescope<cr>', 'Search Todos')
nld('sw', ':Telescope grep_string<cr>', 'Grep String')
nld('sx', ':Telescope import<cr>', 'Telescope: Import')

-- Trouble
nld('xd',
  ':Trouble document_diagnostics<cr>', 'Trouble: Document Diagnostics')
nld('xl', ':Trouble loclist<cr>', 'Trouble: Location List')
nld('xq', ':Trouble quickfix<cr>', 'Trouble: Quickfix')
nld('xw',
  ':Trouble workspace_diagnostics<cr>', 'Trouble: Workspace Diagnostics')
nld('xx', ':Trouble diagnostics<cr>', 'Trouble: Diagnostic')

-- Text manipulation
d('<', { 'n', 'v' }, '<gv', 'Indent Left')
d('>', { 'n', 'v' }, '>gv', 'Indent Right')
d('<C-k>', { 'n', 'v' }, ":m '<-2<CR>gv=gv", 'Move Block Up')
d('<C-j>', { 'n', 'v' }, ":m '>+1<CR>gv=gv", 'Move Block Down')

-- Other functionality
nld('o', function() require('snacks').gitbrowse() end, 'Open repo in browser')

-- Toggle settings
local function toggle_background()
  vim.o.bg = vim.o.bg == "light" and "dark" or "light"
end

nld('tc', ':CloakToggle<cr>', 'Cloak: Toggle')
nld('te', ':Neotree toggle<cr>', 'Toggle Neotree')
nld('tl', toggle_background, 'Toggle Light/Dark Mode')
nld('tn', ':Noice dismiss<cr>', 'Noice: Dismiss Notification')

-- Splits
n('<C-w>,', ':vertical resize -10<CR>', { desc = 'V Resize -' })
n('<C-w>.', ':vertical resize +10<CR>', { desc = 'V Resize +' })
n('<C-w>-', ':resize -5<CR>', { desc = 'H Resize -' })
n('<C-w>+', ':resize +5<CR>', { desc = 'H Resize +' })
n('<C-w>=', '<C-w>=', { desc = 'Equal Size Splits' })

-- Deal with word wrap
n('k',
  "v:count == 0 ? 'gk' : 'k'",
  { desc = 'Move up', noremap = true, expr = true })
n('j',
  "v:count == 0 ? 'gj' : 'j'",
  { desc = 'Move down', noremap = true, expr = true })

-- Quit
nld('qf', ':q<CR>', 'Quicker close split')
nld('qq', function()
  if vim.fn.confirm("Force save and quit?", "&Yes\n&No", 2) == 1 then
    vim.cmd('wq!')
  end
end, 'Quit with force saving')
nld('qw', ':wq<CR>', 'Write and quit')
nld('qQ', function()
  if vim.fn.confirm("Force quit without saving?", "&Yes\n&No", 2) == 1 then
    vim.cmd('q!')
  end
end, 'Force quit without saving')
