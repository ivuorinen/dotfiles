require 'utils'

-- ╭─────────────────────────────────────────────────────────╮
-- │                         Keymaps                         │
-- ╰─────────────────────────────────────────────────────────╯

-- ── Splits ──────────────────────────────────────────────────────────
K.n('<C-w>,', '<cmd>vertical resize -10<CR>', { desc = 'V Resize -' })
K.n('<C-w>.', '<cmd>vertical resize +10<CR>', { desc = 'V Resize +' })
K.n('<C-w>-', '<cmd>resize -10<CR>', { desc = 'H Resize -' })
K.n('<C-w>+', '<cmd>resize +10<CR>', { desc = 'H Resize +' })

-- ── Deal with word wrap ─────────────────────────────────────────────
K.n('k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Move up', noremap = true, expr = true })
K.n('j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Move down', noremap = true, expr = true })

-- ── Text manipulation ───────────────────────────────────────────────
K.d('<', { 'n', 'v' }, '<gv', 'Indent Left')
K.d('>', { 'n', 'v' }, '>gv', 'Indent Right')
K.d('<C-k>', { 'n', 'v' }, "<cmd>m '<-2<CR>gv=gv", 'Move Block Up')
K.d('<C-j>', { 'n', 'v' }, "<cmd>m '>+1<CR>gv=gv", 'Move Block Down')

-- ── Other operations ────────────────────────────────────────────────
K.n('<C-s>', '<cmd>w!<CR>', { desc = 'Save', noremap = true })

-- ── Buffer operations ───────────────────────────────────────────────
-- Mappings for buffer management operations like switching, deleting, etc.
-- Convention: All mappings start with 'b' followed by the operation
K.nl('ba', function() vim.cmd '%bd|e#|bd#' end, 'Close all except current')
K.nl('bd', '<cmd>lua MiniBufremove.delete()<CR>', 'Delete buf')
K.nl('bh', '<cmd>bprev<CR>', 'Prev buf')
K.nl('bj', '<cmd>bfirst<CR>', 'First buf')
K.nl('bk', '<cmd>blast<CR>', 'Last buf')
K.nl('bl', '<cmd>bnext<CR>', 'Next buf')
K.nl('bw', '<cmd>lua MiniBufremove.wipeout()<CR>', 'Wipeout')

-- ── Code & LSP operations ───────────────────────────────────────────
-- Mappings for code and LSP operations like code actions, formatting, etc.
-- Convention: All mappings start with 'c' followed by the operation
-- unless it's a generic operation like signature help or hover

local b = function() return require 'telescope.builtin' end
local lws = function() return b().lsp_workspace_symbols() end
local ldws = function() return b().lsp_dynamic_workspace_symbols() end

K.n('<C-l>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', { desc = 'Signature' })
K.ld('cci', 'n', function() b().lsp_incoming_calls() end, 'Incoming calls')
K.ld('cco', 'n', function() b().lsp_outgoing_calls() end, 'Outgoing calls')
K.ld('cd', 'n', function() b().lsp_definitions() end, 'Definitions')
K.ld('cf', { 'n', 'x' }, '<cmd>lua vim.lsp.buf.format()<CR>', 'Format')
K.ld('ci', 'n', function() b().lsp_implementations() end, 'Implementations')
K.ld('cp', 'n', function() b().lsp_type_definitions() end, 'Type Definition')
K.ld('cs', 'n', '<cmd>Telescope lsp_document_symbols<CR>', 'LSP Document Symbols')
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

K.nl('f', '<cmd>Telescope find_files<CR>', 'Find Files')
K.nl(',', '<cmd>Telescope buffers<CR>', 'Find existing buffers')

K.nl('sd', '<cmd>Telescope diagnostics<CR>', 'Search Diagnostics')
K.nl('sf', '<cmd>Telescope grep_string<CR>', 'Grep String')
K.nl('sg', '<cmd>Telescope live_grep<CR>', 'Live Grep')
K.nl('sh', '<cmd>Telescope help_tags<CR>', 'Help tags')
K.nl('sk', '<cmd>Telescope keymaps<CR>', 'Search Keymaps')
K.nl('sn', '<cmd>Noice telescope<CR>', 'Noice Messages')
K.nl('so', '<cmd>Telescope oldfiles<CR>', 'Old Files')
K.nl('sp', function() lazy_plugins() end, 'Lazy Plugins')
K.nl('sq', '<cmd>Telescope quickfix<CR>', 'Quickfix')
K.nl('ss', '<cmd>Telescope treesitter<CR>', 'Treesitter')
K.nl('sx', '<cmd>Telescope import<CR>', 'Telescope: Import')

-- ── Trouble operations ──────────────────────────────────────────────
-- Convention is 'x' followed by the operation
K.nl('xc', '<cmd>Trouble cascade<CR>', 'Cascade (most severe)')
K.nl('xl', '<cmd>Trouble loclist<CR>', 'Location List')
K.nl('xq', '<cmd>Trouble quickfix<CR>', 'Quickfix')
K.nl('xt', '<cmd>Trouble test<CR>', 'Test (split preview)')
K.nl('xx', '<cmd>Trouble diagnostics<CR>', 'Diagnostics')

-- ── Toggle settings ─────────────────────────────────────────────────
-- Convention is 't' followed by the operation
K.nl('te', function()
  if MiniFiles then MiniFiles.open() end
end, 'File Explorer (cwd)')
K.n('-', function()
  if MiniFiles then MiniFiles.open(vim.api.nvim_buf_get_name(0)) end
end, { desc = 'File Explorer (current file)' })
K.nl('tl', ToggleBackground, 'Toggle Light/Dark Mode')
K.nl('tn', '<cmd>Noice dismiss<CR>', 'Noice: Dismiss Notification')

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
K.nl('tmm', '<cmd>RenderMarkdown toggle<CR>', 'Toggle markdown render')

-- ── Quit operations ─────────────────────────────────────────────────
-- Convention is 'q' followed by the operation
K.nl('qf', '<cmd>q<CR>', 'Quicker close split')
K.nl('qq', function()
  if vim.fn.confirm('Force save and quit?', '&Yes\n&No', 2) == 1 then vim.cmd 'wq!' end
end, 'Quit with force saving')
K.nl('qw', '<cmd>wq<CR>', 'Write and quit')
K.nl('qQ', function()
  if vim.fn.confirm('Force quit without saving?', '&Yes\n&No', 2) == 1 then
    vim.cmd 'q!'
  end
end, 'Force quit without saving')

-- That concludes the keymaps section of the config.
