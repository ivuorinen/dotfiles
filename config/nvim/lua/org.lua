-- nvim-orgmode stack. The plugin specs live in init.lua's vim.pack.add list.
-- orgmode owns the <leader>o prefix: its global maps (a, c) and buffer-local
-- maps (A, r, w, o, t, …) live there, so the bindings below use keys it leaves
-- free.
-- https://github.com/nvim-orgmode/orgmode
-- https://nvim-orgmode.github.io

-- ~/orgfiles is the GTD root and the org-roam directory, shared with beorg on
-- the phone; ~/orgfiles/AGENTS.md describes its layout and tools/ scripts.
-- Capture templates and TODO states below mirror beorg's ~/orgfiles/init.org,
-- so change both together.
local root = vim.fn.expand '~/orgfiles'
local real_root = vim.fn.resolve(root)

-- GTD contexts: capture key, agenda key and tag share one table.
local contexts = {
  { key = 'h', name = 'Home', tag = '@home' },
  { key = 'k', name = 'Work', tag = '@work' },
  { key = 'c', name = 'Computer', tag = '@computer' },
  { key = 'e', name = 'Errands', tag = '@errands' },
}
local capture_templates = {
  t = {
    description = 'Inbox',
    template = '* TODO %?\nCaptured: %U',
    target = root .. '/inbox.org',
  },
  n = {
    description = 'Next action',
    template = '* NEXT %?\nCaptured: %U',
    target = root .. '/next-actions.org',
  },
  w = {
    description = 'Waiting for',
    template = '* WAITING %?\nWaiting for:\nFollow up:',
    target = root .. '/waiting-for.org',
  },
  p = {
    description = 'Project intake',
    template = '* TODO %? :project:\nOutcome:\nNext action:',
    target = root .. '/projects-inbox.org',
  },
  s = {
    description = 'Someday',
    template = '* SOMEDAY %?\nReconsider when:',
    target = root .. '/someday.org',
  },
}
local agenda_commands = {
  n = {
    description = 'GTD: Next actions',
    types = {
      {
        type = 'tags_todo',
        match = '+TODO="NEXT"',
        org_agenda_files = { root .. '/next-actions.org' },
      },
    },
  },
  w = {
    description = 'GTD: Waiting for',
    types = {
      {
        type = 'tags_todo',
        match = '+TODO="WAITING"',
        org_agenda_files = { root .. '/waiting-for.org' },
      },
    },
  },
}
for _, ctx in ipairs(contexts) do
  capture_templates[ctx.key] = {
    description = 'Next @' .. ctx.name,
    template = '* NEXT %? :' .. ctx.tag .. ':\nCaptured: %U',
    target = root .. '/next-actions.org',
  }
  agenda_commands[ctx.key] = {
    description = 'GTD: Next @' .. ctx.name,
    types = {
      {
        type = 'tags_todo',
        match = '+' .. ctx.tag .. '+TODO="NEXT"',
        org_agenda_files = { root .. '/next-actions.org' },
      },
    },
  }
end

require('orgmode').setup {
  -- Agenda files are also refile targets, so list them instead of globbing:
  -- beorg overwrites calendar.org and reminders.org.
  org_agenda_files = {
    root .. '/inbox.org',
    root .. '/next-actions.org',
    root .. '/waiting-for.org',
    root .. '/someday.org',
    root .. '/recurring.org',
    root .. '/projects-inbox.org',
    root .. '/projects/*.org',
    root .. '/learn-orgmode.org',
    root .. '/daily/*.org',
    root .. '/roam/**/*',
  },
  org_default_notes_file = root .. '/inbox.org',
  org_todo_keywords = {
    'TODO',
    'NEXT',
    'WAITING',
    'SOMEDAY',
    '|',
    'DONE',
    'CANCELLED',
  },
  org_tags_column = -77,
  org_adapt_indentation = false,
  org_capture_templates = capture_templates,
  org_agenda_custom_commands = agenda_commands,
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
      filter = 'tag:@work sched>=0 sched<7 -is:done',
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
-- The whole of ~/orgfiles is the roam directory, so project notes, dailies and
-- the GTD lists are nodes; new notes still go to roam/.
local roam_target = 'roam/%<%Y%m%d%H%M%S>-%[slug].org'
require('org-roam').setup {
  -- <leader>oR, not <leader>or: orgmode maps <leader>or to refile in org,
  -- agenda and capture buffers.
  bindings = { prefix = '<leader>oR' },
  directory = root,
  templates = {
    d = { description = 'default', template = '%?', target = roam_target },
  },
  immediate = { target = roam_target },
  extensions = {
    dailies = {
      directory = 'daily',
      templates = {
        d = {
          description = 'Daily Inbox',
          template = '* %?\nCaptured: %U',
          target = '%<%Y-%m-%d>.org',
          headline = 'Inbox',
        },
        n = {
          description = 'Daily Note',
          template = '* %?',
          target = '%<%Y-%m-%d>.org',
          headline = 'Notes',
        },
        t = {
          description = 'Daily Task',
          template = '* TODO %?',
          target = '%<%Y-%m-%d>.org',
          headline = 'Tasks',
        },
        r = {
          description = 'Daily Review',
          template = '* %?\nWins:\nChallenges:\nTomorrow:',
          target = '%<%Y-%m-%d>.org',
          headline = 'Daily Review',
        },
      },
    },
  },
}

-- org-roam.nvim's %[slug] turns every non-alphanumeric *byte* into "_", so
-- Finnish titles lose their letters. It has no slug option and upstream main is
-- unchanged (checked 2026-11-13), so replace the function it calls. The tools'
-- slug is the single rule for notes and project files: NFKD, ASCII, hyphens.
local roam_utils = require 'org-roam.utils'
local upstream_slug = roam_utils.title_to_slug
roam_utils.title_to_slug = function(title)
  local out = vim.fn.system { 'python3', root .. '/tools/org_gtd.py', 'slug', title }
  if vim.v.shell_error ~= 0 then return upstream_slug(title) end
  return vim.trim(out)
end

-- GTD commands. The stdlib Python tools in ~/orgfiles/tools do the file work
-- and print JSON; these wrappers only pick, confirm and open.

---@param file string script name in tools/
---@param args string[]
---@return table|nil decoded JSON, nil after an error was shown
local function run_json(file, args)
  local cmd = { 'python3', root .. '/tools/' .. file, '--root', root }
  vim.list_extend(cmd, args)
  local out = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify(vim.trim(out), vim.log.levels.ERROR, { title = file })
    return nil
  end
  local ok, result = pcall(vim.json.decode, out)
  if not ok or type(result) ~= 'table' then
    vim.notify('Invalid JSON from ' .. file .. ': ' .. out, vim.log.levels.ERROR)
    return nil
  end
  return result
end

-- The tools rewrite files under root, so they never run over unsaved edits.
-- Buffers may name the symlink or the iCloud path behind it.
local function buffers_clean()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].modified then
      local name = vim.api.nvim_buf_get_name(buf)
      if vim.startswith(name, root .. '/') or vim.startswith(name, real_root .. '/') then
        return false
      end
    end
  end
  return true
end

-- Reload buffers the tools changed and let org-roam index new IDs.
local function refresh()
  vim.cmd 'silent! checktime'
  local load = require('org-roam').database:load { force = 'scan' }
  load:catch(function(err)
    local message = tostring(err)
    vim.notify(message, vim.log.levels.ERROR, { title = 'org-roam' })
  end)
end

local function edit(relative)
  local path = root .. '/' .. relative
  vim.cmd.edit(vim.fn.fnameescape(path))
end

---@param quiet? boolean skip the warning about unsaved buffers
local function sync_links(quiet)
  if not buffers_clean() then
    if not quiet then
      vim.notify('Save the modified buffers under ~/orgfiles first', vim.log.levels.WARN)
    end
    return false
  end
  if not run_json('org_links.py', { 'sync' }) then return false end
  refresh()
  return true
end

local function command(name, fn, desc)
  vim.api.nvim_create_user_command(name, fn, { desc = desc })
end

-- Initialize the same daily document used by beorg, including root ID.
vim.api.nvim_create_user_command('RoamDaily', function(opts)
  local day = opts.args ~= '' and opts.args or os.date '%Y-%m-%d'
  local result = vim.fn.system {
    'python3',
    root .. '/tools/org_daily.py',
    '--root',
    root,
    'ensure',
    day,
  }
  if vim.v.shell_error ~= 0 then
    vim.notify(result, vim.log.levels.ERROR)
    return
  end
  edit('daily/' .. day .. '.org')
  vim.cmd 'RoamUpdate! sync'
end, { nargs = '?', desc = 'Open or create Org-roam daily note' })

for name, file in pairs {
  GtdInbox = 'inbox.org',
  GtdNext = 'next-actions.org',
  GtdWaiting = 'waiting-for.org',
  GtdSomeday = 'someday.org',
  GtdRecurring = 'recurring.org',
  GtdProjectInbox = 'projects-inbox.org',
} do
  command(name, function() edit(file) end, 'GTD: open ' .. file)
end

command('GtdNewProject', function()
  vim.ui.input({ prompt = 'Project title: ' }, function(title)
    if not title or vim.trim(title) == '' then return end
    local result = run_json('org_gtd.py', { 'new-project', title })
    if result then
      edit(result.path)
      refresh()
    end
  end)
end, 'GTD: create a project note in projects/')

command('GtdFindProject', function()
  local projects = run_json('org_links.py', { 'list-projects' })
  if not projects then return end
  vim.ui.select(projects, {
    prompt = 'Open project: ',
    format_item = function(item) return item.title end,
  }, function(item)
    if item then edit(item.path) end
  end)
end, 'GTD: open an active project note')

command('GtdLinkProject', function()
  local name = vim.api.nvim_buf_get_name(0)
  if vim.fn.resolve(name) ~= vim.fn.resolve(root .. '/next-actions.org') then
    vim.notify(
      'Run :GtdLinkProject on a NEXT heading in next-actions.org',
      vim.log.levels.WARN
    )
    return
  end
  if not buffers_clean() then
    vim.notify('Save the modified buffers under ~/orgfiles first', vim.log.levels.WARN)
    return
  end
  -- The tool applies the line number to the file on disk, so take in what the
  -- phone synced first; the prompt names the heading in case the reload moved it.
  vim.cmd 'checktime'
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local heading_line = vim.fn.search('^\\* ', 'bcnW')
  local heading = vim.fn.getline(heading_line):gsub('%s+:[^%s]+:%s*$', '')
  local projects = run_json('org_links.py', { 'list-projects' })
  if not projects then return end
  vim.ui.select(projects, {
    prompt = 'Link "' .. heading:gsub('^%*+%s*', '') .. '" to project: ',
    format_item = function(item) return item.title end,
  }, function(item)
    if not item or not buffers_clean() then return end
    local args = { 'link', '--line', tostring(line), '--project-id', item.id }
    if run_json('org_links.py', args) then refresh() end
  end)
end, 'GTD: link the NEXT action under the cursor to a project')

command('GtdSyncLinks', function()
  if sync_links() then vim.notify 'GTD project links are in sync' end
end, 'GTD: sync project and NEXT action links')

command('GtdAudit', function()
  local r = run_json('org_gtd.py', { 'audit' })
  if not r then return end
  local lines = {
    'GTD audit ' .. r.date,
    'Inbox: ' .. r.inbox_count,
    'Active projects: ' .. r.total_active_projects,
    'NEXT actions: ' .. r.next_actions,
    'NEXT actions without a project: ' .. #r.unlinked_next_actions,
    'Waiting for: ' .. #r.waiting_for,
    'Someday: ' .. r.someday_count,
    '',
    'Projects without a NEXT action:',
  }
  for _, item in ipairs(r.projects_without_next) do
    table.insert(lines, '- ' .. item.title)
  end
  table.insert(lines, '')
  table.insert(lines, 'Scheduled or due within 7 days:')
  for _, item in ipairs(r.scheduled_7_days) do
    local overdue = item.overdue and ' OVERDUE' or ''
    table.insert(lines, '- ' .. item.date .. overdue .. ' ' .. item.title)
  end
  vim.cmd 'botright new'
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
end, 'GTD: show the audit of lists and projects')

command('GtdPromoteProjects', function()
  if not buffers_clean() then
    vim.notify('Save the modified buffers under ~/orgfiles first', vim.log.levels.WARN)
    return
  end
  local preview = run_json('org_gtd.py', { 'promote' })
  if not preview then return end
  if #preview.projects == 0 then
    vim.notify 'No :project: headings in projects-inbox.org'
    return
  end
  local titles = vim.tbl_map(function(item) return item.title end, preview.projects)
  vim.ui.select({ 'Cancel', 'Promote: ' .. table.concat(titles, ', ') }, {
    prompt = 'Create ' .. #titles .. ' project note(s) from projects-inbox.org?',
  }, function(_, idx)
    if idx ~= 2 or not buffers_clean() then return end
    if run_json('org_gtd.py', { 'promote', '--apply' }) and not sync_links() then
      refresh()
    end
  end)
end, 'GTD: turn :project: entries in projects-inbox.org into project notes')

command('GtdWeekly', function()
  if not sync_links() then return end
  local result = run_json('org_gtd.py', { 'weekly' })
  if result then
    edit(result.path)
    refresh()
  end
end, "GTD: sync links, then write and open this week's review")

-- Saving next-actions.org or a project note syncs the links. Scheduled so the
-- tools run after the write finishes; `pending` folds several writes (:wa) into
-- one run. The weekly review is only written by :GtdWeekly.
local pending = false
vim.api.nvim_create_autocmd('BufWritePost', {
  group = vim.api.nvim_create_augroup('gtd-links', { clear = true }),
  pattern = '*.org',
  desc = 'GTD: sync project links after saving next-actions.org or a project',
  callback = function(ev)
    local path = vim.fn.resolve(vim.api.nvim_buf_get_name(ev.buf))
    local projects = real_root .. '/projects/'
    local is_project = vim.startswith(path, projects)
      and not path:sub(#projects + 1):find('/', 1, true)
    if path ~= real_root .. '/next-actions.org' and not is_project then return end
    if pending then return end
    pending = true
    vim.schedule(function()
      pending = false
      sync_links(true)
    end)
  end,
})

-- Experimental LSP support; orgmode ships the lsp/org.lua config.
vim.lsp.enable 'org'
