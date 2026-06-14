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
K.n('<Esc><Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

-- Disable arrow keys in normal mode; use hjkl or count motions instead.
-- mini.keymap (init.lua Editor section) nudges away from hjkl spam with notifications.
for _, key in ipairs {
  '<Up>',
  '<Down>',
  '<Left>',
  '<Right>',
  '<C-Up>',
  '<C-Down>',
  '<C-Left>',
  '<C-Right>',
} do
  K.d(key, 'n', '<Nop>', 'Disabled (use hjkl / word motions)')
end

-- ── Buffer operations ───────────────────────────────────────────────
-- Mappings for buffer management operations like switching, deleting, etc.
-- Convention: All mappings start with 'b' followed by the operation
K.nl('ba', function()
  -- `%bd|e#|bd#` errors with E194 when there's no alternate buffer.
  -- Iterate explicitly so single-buffer state is a no-op.
  local cur = vim.api.nvim_get_current_buf()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if b ~= cur and vim.api.nvim_buf_is_loaded(b) then
      pcall(vim.api.nvim_buf_delete, b, { force = false })
    end
  end
end, 'Close all except current')
K.nl('bd', '<cmd>lua MiniBufremove.delete()<CR>', 'Delete buf')
K.nl('bh', '<cmd>bprev<CR>', 'Prev buf')
K.nl('bj', '<cmd>bfirst<CR>', 'First buf')
K.nl('bk', '<cmd>blast<CR>', 'Last buf')
K.nl('bl', '<cmd>bnext<CR>', 'Next buf')
K.nl('bn', '<cmd>enew<CR>', 'New buf')
K.nl('bw', '<cmd>lua MiniBufremove.wipeout()<CR>', 'Wipeout')

-- ── Code & LSP operations ───────────────────────────────────────────
-- Mappings for code and LSP operations like code actions, formatting, etc.
-- Convention: All mappings start with 'c' followed by the operation
-- unless it's a generic operation like signature help or hover

K.n('<C-l>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', { desc = 'Signature' })
K.ld('cf', { 'n', 'x' }, '<cmd>lua vim.lsp.buf.format()<CR>', 'Format')

-- ── Trouble operations ──────────────────────────────────────────────
-- Convention is 'x' followed by the operation
K.nl('xc', '<cmd>Trouble cascade<CR>', 'Cascade (most severe)')
K.nl('xl', '<cmd>Trouble loclist<CR>', 'Location List')
K.nl('xq', '<cmd>Trouble quickfix<CR>', 'Quickfix')
K.nl('xt', '<cmd>Trouble test<CR>', 'Test (split preview)')
K.nl('xx', '<cmd>Trouble diagnostics<CR>', 'Diagnostics')

-- ── Toggle settings ─────────────────────────────────────────────────
-- Convention is 't' followed by the operation
K.nl('tf', '<cmd>ToggleFormat<CR>', 'Toggle autoformat on save')
K.nl('te', function()
  if MiniFiles then MiniFiles.open() end
end, 'File Explorer (cwd)')
K.n('-', function()
  if MiniFiles then MiniFiles.open(vim.api.nvim_buf_get_name(0)) end
end, { desc = 'File Explorer (current file)' })
K.nl('tl', ToggleBackground, 'Toggle Light/Dark Mode')

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

-- ── Snacks keymaps ──────────────────────────────────────────────────
-- Deferred: keymaps.lua loads before vim.pack.add, so Snacks is not yet
-- available at require time. vim.schedule runs after init.lua completes.
vim.schedule(function()
  if not Snacks then return end
  local s = Snacks
  local sp = Snacks.picker

  -- Code & LSP (Snacks-powered pickers + rename)
  -- Convention: 'c' prefix, matching the non-Snacks LSP keymaps above
  K.ld('cci', 'n', function() sp.lsp_incoming_calls() end, 'Incoming calls')
  K.ld('cco', 'n', function() sp.lsp_outgoing_calls() end, 'Outgoing calls')
  K.ld('cd', 'n', function() sp.lsp_definitions() end, 'Definitions')
  K.ld('ci', 'n', function() sp.lsp_implementations() end, 'Implementations')
  K.ld('cp', 'n', function() sp.lsp_type_definitions() end, 'Type Definition')
  K.ld('cr', 'n', function() s.rename.rename_file() end, 'Rename file')
  K.ld('cs', 'n', function() sp.lsp_symbols() end, 'LSP Document Symbols')
  K.ld('ct', 'n', function() sp.treesitter() end, 'Treesitter')
  K.ld('cws', 'n', function() sp.lsp_workspace_symbols() end, 'Workspace Symbols')

  -- Search / Picker
  -- Convention: 's' prefix; 'f' and ',' for the two most common pickers
  K.nl('f', function() sp.files() end, 'Find Files')
  K.nl(',', function() sp.buffers() end, 'Find existing buffers')
  K.nl('sd', function() sp.diagnostics() end, 'Search Diagnostics')
  K.nl('sf', function() sp.grep_word() end, 'Grep String')
  K.nl('sg', function() sp.grep() end, 'Live Grep')
  K.nl('sh', function() sp.help() end, 'Help tags')
  K.nl('sk', function() sp.keymaps() end, 'Search Keymaps')
  K.nl('sn', function() sp.notifications() end, 'Notification History')
  K.nl('so', function() sp.recent() end, 'Old Files')
  K.nl('sq', function() sp.qflist() end, 'Quickfix')
  K.nl('ss', function() sp.lines() end, 'Search Buffer Lines')

  -- Toggle (Snacks-powered)
  K.nl('tn', function() s.notifier.hide() end, 'Dismiss Notifications')
  K.nl('tt', function() s.terminal() end, 'Toggle Terminal')
end)

-- That concludes the keymaps section of the config.
