-- ╭─────────────────────────────────────────────────────────╮
-- │                       Autogroups                        │
-- ╰─────────────────────────────────────────────────────────╯

local augroup = vim.api.nvim_create_augroup -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd -- Create autocommand

-- Highlight on yank
-- See `:help vim.hl.on_yank()`
autocmd('TextYankPost', {
  callback = function() vim.hl.on_yank() end,
  group = augroup('YankHighlight', { clear = true }),
  pattern = '*',
})

-- Set the numberwidth to the maximum line number.
--
-- This fixes the issue where the line numbers jump
-- around when moving between lines relative line numbers enabled.
autocmd({ 'BufEnter', 'BufWinEnter', 'TabEnter' }, {
  group = augroup('numberwidth-adjust', { clear = true }),
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
    'qf',
    'snacks_notif',
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
    'trouble',
    'qf',
    'help',
    'man',
    'lspinfo',
    'snacks_notif',
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

-- Disable mini.completion in Snacks.picker buffers (input + list)
autocmd('FileType', {
  group = augroup('minicompletion-picker-disable', { clear = true }),
  pattern = { 'snacks_picker_input', 'snacks_picker_list' },
  callback = function(event) vim.b[event.buf].minicompletion_disable = true end,
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
    format = function(diagnostic) return diagnostic.message end,
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
          local remaining = vim.tbl_filter(
            function(c)
              return c.id ~= event2.data.client_id
                and c:supports_method(
                  vim.lsp.protocol.Methods.textDocument_documentHighlight,
                  event2.buf
                )
            end,
            vim.lsp.get_clients { bufnr = event2.buf }
          )
          if #remaining == 0 then
            vim.api.nvim_buf_call(
              event2.buf,
              function() vim.lsp.buf.clear_references() end
            )
            vim.api.nvim_clear_autocmds {
              group = 'lsp-highlight-refs',
              buffer = event2.buf,
            }
          end
        end,
      })
    end
  end,
})

-- Gracefully handle the *less-universal* LSP requests when the attached
-- server doesn't support them. nvim 0.11's default `grt` (type def) and
-- `gri` (implementation) call vim.lsp.buf.* which spam "… is not supported"
-- on servers like bashls/yamlls that lack those capabilities. The other two
-- defaults (`grr` references, `gra` code action) are supported by virtually
-- every LSP and don't need wrapping.
local lsp_method_map = {
  grt = vim.lsp.protocol.Methods.textDocument_typeDefinition,
  gri = vim.lsp.protocol.Methods.textDocument_implementation,
}
autocmd('LspAttach', {
  group = augroup('lsp-capability-keymaps', { clear = true }),
  callback = function(event)
    for lhs, method in pairs(lsp_method_map) do
      vim.keymap.set('n', lhs, function()
        if #vim.lsp.get_clients { bufnr = event.buf, method = method } > 0 then
          if method == vim.lsp.protocol.Methods.textDocument_typeDefinition then
            vim.lsp.buf.type_definition()
          else
            vim.lsp.buf.implementation()
          end
        else
          vim.notify(method .. ' not supported by attached LSP', vim.log.levels.INFO)
        end
      end, { buffer = event.buf, desc = 'LSP ' .. method .. ' (capability-checked)' })
    end
  end,
})

-- Set filetype for SSH config directory
-- Pattern handles directories with files like:
-- .dotfiles/ssh/config.d/*, .ssh/config.local, .ssh/config.work,
-- .ssh/shared.d/*, .ssh/local.d/*
autocmd({ 'BufRead', 'BufNewFile' }, {
  group = augroup('ssh-filetype', { clear = true }),
  desc = 'Set filetype for SSH config directory',
  pattern = {
    '*/.ssh/config.d/*',
    '*/.ssh/shared.d/*',
    '*/.ssh/local.d/*',
    '*/.ssh/config.local',
    '*/.ssh/config.work',
  },
  command = 'set filetype=sshconfig',
})

-- ── vim.pack Lifecycle ───────────────────────────────────────────────
-- autogroups.lua is required before vim.pack.add in init.lua, so
-- PackChanged is registered in time to fire on first-install events.
autocmd('PackChanged', {
  group = augroup('pack-changed', { clear = true }),
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'arborist' and (kind == 'install' or kind == 'update') then
      if not ev.data.active then vim.cmd.packadd 'arborist' end
      vim.cmd 'ArboristUpdate'
    end
  end,
})

-- ── Sessions (mini.sessions) ─────────────────────────────────────────
-- Auto-read session for cwd on startup (no file args, interactive only).
-- Headless invocations (CI, scripts, :checkhealth) skip both read and
-- write to avoid polluting ~/.local/share/nvim/sessions/ with junk entries.
autocmd('VimEnter', {
  group = augroup('auto-session', { clear = true }),
  nested = true,
  callback = function()
    if vim.fn.argc() > 0 then return end
    if #vim.api.nvim_list_uis() == 0 then return end
    local sessions = require 'mini.sessions'
    local cwd = vim.fn.getcwd()
    local name = cwd:gsub('[/\\]', '%%')
    local ok = pcall(sessions.read, name, { force = true })
    if not ok then
      -- No session yet — will be created on exit
      vim.g.mini_sessions_current = name
    end
  end,
})

-- Auto-write session for cwd on exit (interactive only)
autocmd('VimLeavePre', {
  group = augroup('auto-session-write', { clear = true }),
  callback = function()
    if #vim.api.nvim_list_uis() == 0 then return end
    local sessions = require 'mini.sessions'
    local cwd = vim.fn.getcwd()
    local name = cwd:gsub('[/\\]', '%%')
    sessions.write(name, { force = true })
  end,
})

-- ── Linting (nvim-lint) ──────────────────────────────────────────────
-- Linter name → TOOL_CONFIGS key. Linters absent from this map run unconditionally.
local LINTER_GATES = {
  ansible_lint = 'ansible_lint',
  golangci_lint = 'golangci_lint',
  hadolint = 'hadolint',
  ruff = 'ruff',
  tflint = 'tflint',
  yamllint = 'yamllint',
}
-- Filetypes where biome applies
local biome_fts = {
  javascript = true,
  javascriptreact = true,
  typescript = true,
  typescriptreact = true,
  json = true,
  jsonc = true,
}
autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
  group = augroup('nvim-lint', { clear = true }),
  callback = function(args)
    local lint = require 'lint'
    local ft = vim.bo[args.buf].filetype
    if biome_fts[ft] and HasConfig('biome', args.buf) then lint.try_lint 'biomejs' end
    local names = {}
    for _, name in ipairs(lint.linters_by_ft[ft] or {}) do
      local gate = LINTER_GATES[name]
      if gate == nil or HasConfig(gate, args.buf) then table.insert(names, name) end
    end
    if #names > 0 then lint.try_lint(names) end
  end,
})

-- ── Formatting commands ──────────────────────────────────────────────
vim.api.nvim_create_user_command('ToggleFormat', function()
  vim.g.autoformat_enabled = not vim.g.autoformat_enabled
  vim.notify('Autoformat: ' .. (vim.g.autoformat_enabled and 'on' or 'off'))
end, { desc = 'Toggle autoformat on save' })
