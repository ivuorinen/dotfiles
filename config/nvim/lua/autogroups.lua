-- ╭─────────────────────────────────────────────────────────╮
-- │                       Autogroups                        │
-- ╰─────────────────────────────────────────────────────────╯

local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

-- ── Highlight on yank ───────────────────────────────────────────────
-- See `:help vim.highlight.on_yank()`
autocmd('TextYankPost', {
  callback = function() vim.highlight.on_yank() end,
  group = augroup('YankHighlight', { clear = true }),
  pattern = '*',
})

-- ── Windows to close with "q" ───────────────────────────────────────
autocmd('FileType', {
  group = augroup('close_with_q', { clear = true }),
  pattern = {
    'PlenaryTestPopup',
    'checkhealth',
    'dbout',
    'gitsigns.blame',
    'grug-far',
    'help',
    'lspinfo',
    'man',
    'neotest-output',
    'neotest-output-panel',
    'neotest-summary',
    'notify',
    'qf',
    'spectre_panel',
    'startuptime',
    'tsplayground',
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<cr>', {
      buffer = event.buf,
      silent = true,
      desc = 'Quit buffer',
    })
  end,
})

-- ── make it easier to close man-files when opened inline ────────────
autocmd('FileType', {
  group = augroup('man_unlisted', { clear = true }),
  pattern = { 'man' },
  callback = function(event) vim.bo[event.buf].buflisted = false end,
})

-- ── wrap and check for spell in text filetypes ──────────────────────
autocmd('FileType', {
  group = augroup('wrap_spell', { clear = true }),
  pattern = { 'text', 'plaintex', 'typst', 'gitcommit', 'markdown' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- ── Fix conceallevel for json files ─────────────────────────────────
autocmd({ 'FileType' }, {
  group = augroup('json_conceal', { clear = true }),
  pattern = { 'json', 'jsonc', 'json5' },
  callback = function() vim.opt_local.conceallevel = 0 end,
})

-- ── Set filetype for SSH config directory ───────────────────────────
autocmd({ 'BufRead', 'BufNewFile' }, {
  desc = 'Set filetype for SSH config directory',
  pattern = '*/?.ssh/{config|shared}.d/*',
  command = 'set filetype=sshconfig',
})

autocmd('FileType', {
  group = augroup('set_filetype', { clear = true }),
  pattern = { 'Dockerfile', 'Dockerfile.*' },
  callback = function() vim.bo.filetype = 'dockerfile' end,
})

autocmd('BufWritePre', {
  group = augroup('Format', { clear = true }),
  pattern = '*', -- All files
  callback = function()
    if not vim.g.disable_autoformat then
      vim.lsp.buf.format({ async = false })
    end
  end,
})

-- vim: ts=2 sts=2 sw=2 et
