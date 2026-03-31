require 'utils'

-- ╭─────────────────────────────────────────────────────────╮
-- │                         Keymaps                         │
-- ╰─────────────────────────────────────────────────────────╯

-- ── Splits ──────────────────────────────────────────────────────────
K.n('<C-w>,', ':vertical resize -10<CR>', { desc = 'V Resize -' })
K.n('<C-w>.', ':vertical resize +10<CR>', { desc = 'V Resize +' })
K.n('<C-w>-', ':resize -10<CR>', { desc = 'H Resize -' })
K.n('<C-w>+', ':resize +10<CR>', { desc = 'H Resize +' })

-- ── Deal with word wrap ─────────────────────────────────────────────
K.n('k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Move up', noremap = true, expr = true })
K.n('j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Move down', noremap = true, expr = true })

-- ── Text manipulation ───────────────────────────────────────────────
K.d('<', { 'n', 'v' }, '<gv', 'Indent Left')
K.d('>', { 'n', 'v' }, '>gv', 'Indent Right')
K.d('<C-k>', { 'n', 'v' }, ":m '<-2<CR>gv=gv", 'Move Block Up')
K.d('<C-j>', { 'n', 'v' }, ":m '>+1<CR>gv=gv", 'Move Block Down')

-- ── Other operations ────────────────────────────────────────────────
K.n('<C-s>', ':w!<cr>', { desc = 'Save', noremap = true })

-- ── Buffer operations ───────────────────────────────────────────────
-- Mappings for buffer management operations like switching, deleting, etc.
-- Convention: All mappings start with 'b' followed by the operation
K.nl('ba', ':%bd|e#|bd#<cr>', 'Close all except current')
K.nl('bd', ':lua MiniBufremove.delete()<CR>', 'Delete buf')
K.nl('bh', ':bprev<cr>', 'Prev buf')
K.nl('bj', ':bfirst<cr>', 'First buf')
K.nl('bk', ':blast<cr>', 'Last buf')
K.nl('bl', ':bnext<cr>', 'Next buf')
K.nl('bw', ':lua MiniBufremove.wipeout()<CR>', 'Wipeout')

-- ── Code & LSP operations ───────────────────────────────────────────
-- Mappings for code and LSP operations like code actions, formatting, etc.
-- Convention: All mappings start with 'c' followed by the operation
-- unless it's a generic operation like signature help or hover

local b = function() return require 'telescope.builtin' end
local lws = function() return b().lsp_workspace_symbols() end
local ldws = function() return b().lsp_dynamic_workspace_symbols() end

K.n('<C-l>', ':lua vim.lsp.buf.signature_help()<CR>', { desc = 'Signature' })
K.ld('cci', 'n', function() b().lsp_incoming_calls() end, 'Incoming calls')
K.ld('cco', 'n', function() b().lsp_outgoing_calls() end, 'Outgoing calls')
K.ld('cd', 'n', function() b().lsp_definitions() end, 'Definitions')
K.ld('cf', { 'n', 'x' }, ':lua vim.lsp.buf.format()<CR>', 'Format')
K.ld('ci', 'n', function() b().lsp_implementations() end, 'Implementations')
K.ld('cp', 'n', function() b().lsp_type_definitions() end, 'Type Definition')
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

K.nl('f', ':Telescope find_files<cr>', 'Find Files')
K.nl(',', ':Telescope buffers<cr>', 'Find existing buffers')

K.nl('sd', ':Telescope diagnostics<cr>', 'Search Diagnostics')
K.nl('sf', ':Telescope grep_string<cr>', 'Grep String')
K.nl('sg', ':Telescope live_grep<cr>', 'Live Grep')
K.nl('sh', ':Telescope help_tags<cr>', 'Help tags')
K.nl('sk', ':Telescope keymaps<cr>', 'Search Keymaps')
K.nl('sn', ':Noice telescope<cr>', 'Noice Messages')
K.nl('so', ':Telescope oldfiles<CR>', 'Old Files')
K.nl('sp', function() lazy_plugins() end, 'Lazy Plugins')
K.nl('sq', ':Telescope quickfix<cr>', 'Quickfix')
K.nl('ss', ':Telescope treesitter<cr>', 'Treesitter')
K.nl('sx', ':Telescope import<cr>', 'Telescope: Import')

-- ── Trouble operations ──────────────────────────────────────────────
-- Convention is 'x' followed by the operation
K.nl('xc', ':Trouble cascade<cr>', 'Cascade (most severe)')
K.nl('xl', ':Trouble loclist<cr>', 'Location List')
K.nl('xq', ':Trouble quickfix<cr>', 'Quickfix')
K.nl('xt', ':Trouble test<cr>', 'Test (split preview)')
K.nl('xx', ':Trouble diagnostics<cr>', 'Diagnostics')

-- ── Toggle settings ─────────────────────────────────────────────────
-- Convention is 't' followed by the operation
K.nl('te', function() MiniFiles.open() end, 'File Explorer (cwd)')
K.n(
  '-',
  function() MiniFiles.open(vim.api.nvim_buf_get_name(0)) end,
  { desc = 'File Explorer (current file)' }
)
K.nl('tl', ToggleBackground, 'Toggle Light/Dark Mode')
K.nl('tn', ':Noice dismiss<cr>', 'Noice: Dismiss Notification')

-- ── Option toggles ────────────────────────────────────────────────────
-- Convention is 'tm' followed by the option letter
K.nl('tmc', function() vim.o.cursorline = not vim.o.cursorline end, 'Toggle cursorline')
K.nl(
  'tmC',
  function() vim.o.cursorcolumn = not vim.o.cursorcolumn end,
  'Toggle cursorcolumn'
)
K.nl(
  'tmd',
  function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end,
  'Toggle diagnostics'
)
K.nl('tmh', function() vim.o.hlsearch = not vim.o.hlsearch end, 'Toggle hlsearch')
K.nl('tml', function() vim.o.list = not vim.o.list end, 'Toggle list')
K.nl('tmn', function() vim.o.number = not vim.o.number end, 'Toggle number')
K.nl(
  'tmr',
  function() vim.o.relativenumber = not vim.o.relativenumber end,
  'Toggle relativenumber'
)
K.nl('tms', function() vim.o.spell = not vim.o.spell end, 'Toggle spell')
K.nl('tmw', function() vim.o.wrap = not vim.o.wrap end, 'Toggle wrap')
K.nl('tmm', ':RenderMarkdown toggle<CR>', 'Toggle markdown render')

-- ── Quit operations ─────────────────────────────────────────────────
-- Convention is 'q' followed by the operation
K.nl('qf', ':q<CR>', 'Quicker close split')

-- That concludes the keymaps section of the config.
