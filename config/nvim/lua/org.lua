-- nvim-orgmode stack. The plugin specs live in init.lua's vim.pack.add list.
-- orgmode owns the <leader>o prefix: its global maps (a, c) and buffer-local
-- maps (A, r, w, o, t, …) live there, so the bindings below use keys it leaves
-- free.
-- https://github.com/nvim-orgmode/orgmode
-- https://nvim-orgmode.github.io
require('orgmode').setup {
  org_agenda_files = '~/orgfiles/**/*',
  org_default_notes_file = '~/orgfiles/refile.org',
  mappings = {
    -- <leader>oa opens org-super-agenda below. orgmode sets its global maps on
    -- a deferred timer, so leaving org_agenda on <prefix>a would overwrite
    -- that binding once init.lua finishes.
    global = { org_agenda = '<prefix>O' },
    -- <C-Space> is the tmux prefix, so it never reaches Neovim inside tmux.
    -- <prefix>X for the [X] it writes; <prefix>x is orgmode's clock group.
    org = { org_toggle_checkbox = '<prefix>X' },
  },
}

-- orgmode derives its agenda and TODO/DONE colours from the fg of Error,
-- WarningMsg and DiffAdd, then lightens them. warm-burnout and oasis style
-- those groups by background, which left scheduled items at 1.09:1 and the
-- oasis dark TODO keyword at 1.00:1. The Diagnostic groups reach WCAG AA in
-- every family here, so take the colours from them, again after each flip.
local org_hl = {
  ['@org.agenda.scheduled'] = 'DiagnosticOk',
  ['@org.agenda.scheduled_past'] = 'DiagnosticWarn',
  ['@org.agenda.deadline'] = 'DiagnosticError',
  ['@org.agenda.deadline.upcoming'] = 'DiagnosticWarn',
  ['@org.agenda.time_grid'] = 'DiagnosticWarn',
  ['@org.keyword.todo'] = 'DiagnosticError',
  ['@org.keyword.done'] = 'DiagnosticOk',
}
local function org_colors()
  for group, src in pairs(org_hl) do
    local fg = vim.api.nvim_get_hl(0, { name = src, link = false }).fg
    vim.api.nvim_set_hl(
      0,
      group,
      { fg = fg, bold = group:find('keyword', 1, true) ~= nil }
    )
  end
end
org_colors()
vim.api.nvim_create_autocmd('ColorScheme', { callback = org_colors })

-- Orgmode: Bullets — replaces the heading asterisks with unicode characters.
-- https://github.com/nvim-orgmode/org-bullets.nvim
require('org-bullets').setup()

-- Visual-mode emphasis in org buffers. Each line of the selection is wrapped in
-- the markers, or unwrapped when every line already carries them.
local function selection()
  local mode = vim.fn.mode()
  local segs = vim.fn.getregionpos(vim.fn.getpos 'v', vim.fn.getpos '.', { type = mode })
  vim.api.nvim_feedkeys(vim.keycode '<Esc>', 'nx', false)
  return segs, mode
end

local function surround(buf, segs, before, after, toggle)
  local parts, wrapped = {}, toggle
  for _, seg in ipairs(segs) do
    local lnum, s, e = seg[1][2], seg[1][3], seg[2][3]
    local line = vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, true)[1]
    -- Emphasis may not start or end with whitespace, so the markers go
    -- inside any the selection picked up.
    local lead, body, trail = line:sub(s, e):match '^(%s*)(.-)(%s*)$'
    if body ~= '' then
      table.insert(
        parts,
        { lnum = lnum, s = s, e = e, lead = lead, body = body, trail = trail }
      )
      wrapped = wrapped
        and #body >= #before + #after
        and vim.startswith(body, before)
        and vim.endswith(body, after)
    end
  end
  for _, p in ipairs(parts) do
    local body = wrapped and p.body:sub(#before + 1, -#after - 1)
      or before .. p.body .. after
    vim.api.nvim_buf_set_text(
      buf,
      p.lnum - 1,
      p.s - 1,
      p.lnum - 1,
      p.e,
      { p.lead .. body .. p.trail }
    )
  end
end

-- Fence the selected lines in a source block, or remove the fence when the
-- selection starts and ends on one. A fence is the whole keyword: #+BEGIN_SRC
-- may carry a language after whitespace, #+END_SRC nothing at all.
local function src_block(segs)
  local s, e = segs[1][1][2], segs[#segs][1][2]
  local first, last = vim.fn.getline(s), vim.fn.getline(e)
  if
    s < e
    and first:lower():match '^%s*#%+begin_src%f[%s%z]'
    and last:lower():match '^%s*#%+end_src%s*$'
  then
    vim.api.nvim_buf_set_lines(0, e - 1, e, true, {})
    vim.api.nvim_buf_set_lines(0, s - 1, s, true, {})
  else
    local indent = first:match '^%s*'
    vim.api.nvim_buf_set_lines(0, e, e, true, { indent .. '#+END_SRC' })
    vim.api.nvim_buf_set_lines(0, s - 1, s - 1, true, { indent .. '#+BEGIN_SRC' })
  end
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'org',
  callback = function(ev)
    K.d('<C-b>', 'x', function() surround(ev.buf, selection(), '*', '*', true) end, {
      buffer = ev.buf,
      desc = 'org: bold',
    })
    K.d('<C-i>', 'x', function() surround(ev.buf, selection(), '/', '/', true) end, {
      buffer = ev.buf,
      desc = 'org: italic',
    })
    K.d('<C-e>', 'x', function()
      local segs, mode = selection()
      if mode == 'V' then
        src_block(segs)
      else
        surround(ev.buf, segs, '~', '~', true)
      end
    end, { buffer = ev.buf, desc = 'org: code (source block when linewise)' })
    K.d('<C-k>', 'x', function()
      -- Read the selection before the prompt: an async vim.ui.input ends
      -- visual mode before its callback runs, and another buffer may be
      -- current by then, so the edit names this one.
      local segs = selection()
      vim.ui.input({ prompt = 'URL: ' }, function(url)
        if url and url ~= '' then
          surround(ev.buf, segs, '[[' .. url .. '][', ']]', false)
        end
      end)
    end, { buffer = ev.buf, desc = 'org: link' })
  end,
})

-- Orgmode: Virtual Clocktime — sums logbook clocktime as virtual text.
-- https://github.com/hugginsio/org-virtual-clocktime.nvim
require('org-virtual-clocktime').setup {}

-- Orgmode: Super Agenda — customizable agenda view.
-- https://github.com/hamidi-dev/org-super-agenda.nvim
require('org-super-agenda').setup {
  custom_views = {
    work_week = {
      name = 'Work This Week',
      keymap = '<leader>oW',
      filter = 'tag:work sched>=0 sched<7 -is:done',
    },
    personal = {
      name = 'Personal',
      keymap = '<leader>op',
      filter = 'tag:personal -is:done',
    },
    overdue = {
      name = 'Overdue',
      filter = 'is:overdue -is:done',
    },
  },
}
K.nl('oa', '<cmd>OrgSuperAgenda<cr>', 'orgmode super agenda')
K.nl('oS', '<cmd>OrgSuperAgenda!<cr>', 'orgmode super agenda fullscreen')

-- Orgmode: Org Roam — plain-text personal knowledge management.
-- https://github.com/chipsenkbeil/org-roam.nvim
require('org-roam').setup {
  -- <leader>oR, not <leader>or: orgmode maps <leader>or to refile in org,
  -- agenda and capture buffers.
  bindings = { prefix = '<leader>oR' },
  directory = '~/orgfiles/roam',
}

-- Experimental LSP support; orgmode ships the lsp/org.lua config.
vim.lsp.enable 'org'
