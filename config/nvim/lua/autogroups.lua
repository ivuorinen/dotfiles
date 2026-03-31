-- ╭─────────────────────────────────────────────────────────╮
-- │                       Autogroups                        │
-- ╰─────────────────────────────────────────────────────────╯

local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

-- Highlight on yank
-- See `:help vim.highlight.on_yank()`
autocmd('TextYankPost', {
  callback = function() vim.highlight.on_yank() end,
  group = augroup('YankHighlight', { clear = true }),
  pattern = '*',
})

-- Set the numberwidth to the maximum line number.
--
-- This fixes the issue where the line numbers jump
-- around when moving between lines relative line numbers enabled.
autocmd({ 'BufEnter', 'BufWinEnter', 'TabEnter' }, {
  callback = function()
    local max_line_count = vim.fn.line '$'
    -- Only adjust if the file is large enough to matter
    if max_line_count > 99 then vim.opt.numberwidth = #tostring(max_line_count) + 1 end
  end,
})

-- Windows to close with "q"
autocmd('FileType', {
  group = augroup('close_with_q', { clear = true }),
  pattern = {
    'PlenaryTestPopup',
    'checkhealth',
    'dbout',
    'help',
    'lspinfo',
    'man',
    'notify',
    'qf',
    'startuptime',
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

-- make it easier to close man-files when opened inline
autocmd('FileType', {
  group = augroup('man_unlisted', { clear = true }),
  pattern = { 'man' },
  callback = function(event) vim.bo[event.buf].buflisted = false end,
})

-- Pin special buffers to their window (replaces stickybuf.nvim)
autocmd('FileType', {
  group = augroup('winfixbuf', { clear = true }),
  pattern = {
    'neo-tree',
    'trouble',
    'qf',
    'help',
    'man',
    'lspinfo',
    'notify',
    'startuptime',
  },
  callback = function() vim.wo.winfixbuf = true end,
})

-- wrap and check for spell in text filetypes
autocmd('FileType', {
  group = augroup('wrap_spell', { clear = true }),
  pattern = {
    'text',
    'plaintex',
    'typst',
    'gitcommit',
    'markdown',
    'asciidoc',
    'rst',
    'tex',
  },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Fix conceallevel for json files
autocmd({ 'FileType' }, {
  group = augroup('json_conceal', { clear = true }),
  pattern = { 'json', 'jsonc', 'json5' },
  callback = function() vim.opt_local.conceallevel = 0 end,
})

-- ── Diagnostic Config ────────────────────────────────────────────────
vim.diagnostic.config {
  severity_sort = true,
  float = { border = 'rounded', source = 'if_many' },
  underline = { severity = vim.diagnostic.severity.ERROR },
  signs = vim.g.have_nerd_font and {
    text = {
      [vim.diagnostic.severity.ERROR] = '󰅚 ',
      [vim.diagnostic.severity.WARN] = '󰀪 ',
      [vim.diagnostic.severity.INFO] = '󰋽 ',
      [vim.diagnostic.severity.HINT] = '󰌶 ',
    },
  } or {},
  virtual_text = {
    source = 'if_many',
    spacing = 2,
    format = function(diagnostic)
      local diagnostic_message = {
        [vim.diagnostic.severity.ERROR] = diagnostic.message,
        [vim.diagnostic.severity.WARN] = diagnostic.message,
        [vim.diagnostic.severity.INFO] = diagnostic.message,
        [vim.diagnostic.severity.HINT] = diagnostic.message,
      }
      return diagnostic_message[diagnostic.severity]
    end,
  },
}

-- ── LSP Highlight (cursor word) ─────────────────────────────────────
local lsp_detach_augroup = augroup('lsp-detach', { clear = true })
autocmd('LspAttach', {
  group = augroup('lsp-highlight', { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if
      client
      and client:supports_method(
        vim.lsp.protocol.Methods.textDocument_documentHighlight,
        event.buf
      )
    then
      local highlight_augroup = augroup('lsp-highlight-refs', { clear = false })
      autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })
      autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })
      autocmd('LspDetach', {
        group = lsp_detach_augroup,
        buffer = event.buf,
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds {
            group = 'lsp-highlight-refs',
            buffer = event2.buf,
          }
        end,
      })
    end
  end,
})

-- Set filetype for SSH config directory
-- Pattern handles directories with files like:
-- .dotfiles/ssh/config.d/*, .ssh/config.local, .ssh/config.work,
-- .ssh/shared.d/*, .ssh/local.d/*
autocmd({ 'BufRead', 'BufNewFile' }, {
  desc = 'Set filetype for SSH config directory',
  pattern = {
    '*/?.ssh/{config|shared|local}.d/*',
    '*/?.ssh/config.local',
    '*/?.ssh/config.work',
  },
  command = 'set filetype=sshconfig',
})
