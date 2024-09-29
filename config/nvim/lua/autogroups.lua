-- ╭─────────────────────────────────────────────────────────╮
-- │                       Autogroups                        │
-- ╰─────────────────────────────────────────────────────────╯

local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

-- ── Highlight on yank ───────────────────────────────────────────────
-- See `:help vim.highlight.on_yank()`
local highlight_group = augroup('YankHighlight', { clear = true })
autocmd('TextYankPost', {
  callback = function() vim.highlight.on_yank() end,
  group = highlight_group,
  pattern = '*',
})

-- ── Windows to close with "q" ───────────────────────────────────────
autocmd('FileType', {
  callback = function() vim.keymap.set('n', '<esc>', ':bd<CR>', { buffer = true, silent = true }) end,
  pattern = {
    'help',
    'startuptime',
    'qf',
    'lspinfo',
    'man',
    'checkhealth',
  },
})

-- vim: ts=2 sts=2 sw=2 et
