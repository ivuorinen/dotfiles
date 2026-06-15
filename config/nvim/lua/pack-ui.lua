--
-- Minimalistic vim.pack UI (TUI dashboard for plugin management)
--
-- Commands:
--   :Pack            open the dashboard
--   :Pack check      open + immediately check remote for updates
--   :Pack update     close + run vim.pack.update() (all plugins)
--   :Pack clean      close + remove all non-active (orphaned) plugins
--
-- Keymaps (buffer-local, active while the window is open):
--   U        update all plugins (closes UI, runs vim.pack.update)
--   u        update plugin under cursor
--   C        check remote for new commits
--   X        clean non-active plugins (orphans)
--   D        delete plugin under cursor (non-active only)
--   L        open the vim.pack update log
--   <CR>     toggle plugin details / commit list
--   A        show all commits when details are expanded
--   ]]       jump to next plugin entry
--   [[       jump to previous plugin entry
--   ?        toggle keymap help
--   q / Esc  close window
--
-- Original author: Andreas Schneider (asn) <asn@cryptomilk.org>
-- Source: https://git.cryptomilk.org/users/asn/dotfiles.git/plain/
--         dot_config/nvim/lua/plugins/pack-ui.lua
-- Adapted and improved for ivuorinen's dotfiles.
--

local api = vim.api
local ns = api.nvim_create_namespace 'pack_ui'

-- Maximum number of commits shown before truncation in the expanded view.
local MAX_COMMITS_PREVIEW = 10

-- ── Highlights ───────────────────────────────────────────────────────

local function setup_highlights()
  local links = {
    PackUiHeader = 'Title',
    PackUiButton = 'Function',
    PackUiPluginLoaded = 'String',
    PackUiPluginNotLoaded = 'Comment',
    PackUiPluginMissing = 'ErrorMsg',
    PackUiUpdateAvailable = 'DiagnosticInfo',
    PackUiBreaking = 'DiagnosticWarn',
    PackUiVersion = 'Number',
    PackUiSectionHeader = 'Label',
    PackUiSeparator = 'FloatBorder',
    PackUiDetail = 'Comment',
    PackUiHelp = 'SpecialComment',
  }
  for group, target in pairs(links) do
    api.nvim_set_hl(0, group, { link = target, default = true })
  end
end

setup_highlights()

-- ColorScheme events can invoke `highlight clear`, wiping `default` groups.
-- Reapply so the UI is always styled regardless of theme changes.
api.nvim_create_autocmd('ColorScheme', {
  group = api.nvim_create_augroup('PackUiHighlights', { clear = true }),
  callback = setup_highlights,
})

-- ── State ────────────────────────────────────────────────────────────

local state = {
  bufnr = nil,
  winid = nil,
  win_autocmd_id = nil,
  line_to_plugin = {},
  plugin_lines = {},
  expanded = {},
  show_help = false,
  updates = {},
  breaking = {},
  unreleased_breaking = {},
  show_all_commits = {},
  latest_ref = {},
  checking = false,
  check_id = 0,
}

-- tag_cache is invalidated on every close because installed tags change
-- after update operations. ref_cache persists for the session — the remote
-- default branch is stable and re-resolution is expensive.
local tag_cache = {}
local ref_cache = {}

-- ── Helpers ──────────────────────────────────────────────────────────

-- For versioned plugins, return the installed git tag. Session-cached so
-- git is only called once per plugin per open; cleared on close to avoid
-- showing stale versions after an update.
local function get_installed_tag(path)
  if not path then return nil end
  if tag_cache[path] ~= nil then return tag_cache[path] or nil end
  local result = vim
    .system(
      { 'git', '-C', path, 'describe', '--tags', '--exact-match', 'HEAD' },
      { text = true }
    )
    :wait()
  if result.code == 0 then
    local tag = vim.trim(result.stdout)
    tag_cache[path] = tag
    return tag
  end
  tag_cache[path] = false
  return nil
end

local function get_version_str(p)
  local v = p.spec.version
  if v == nil then return '' end
  if type(v) == 'string' then return v end
  return tostring(v)
end

-- Parse semver from a tag string; returns {major, minor, patch} or nil.
local function parse_semver(tag)
  if not tag then return nil end
  local major, minor, patch = tag:match '^v?(%d+)%.(%d+)%.(%d+)'
  if major then return { tonumber(major), tonumber(minor), tonumber(patch) } end
  return nil
end

local function parse_commits(stdout)
  local commits = {}
  if stdout and stdout ~= '' then
    for line in stdout:gmatch '[^\n]+' do
      table.insert(commits, line)
    end
  end
  return commits
end

-- Resolve the remote default branch ref for a git repo.
-- Tries symbolic-ref → origin/main → origin/master in order.
-- Calls callback(ref) or callback(nil) on complete failure.
local function resolve_remote_ref(path, callback)
  if ref_cache[path] ~= nil then
    callback(ref_cache[path] or nil)
    return
  end
  vim.system(
    { 'git', '-C', path, 'symbolic-ref', 'refs/remotes/origin/HEAD' },
    { text = true },
    function(r)
      if r.code == 0 then
        local ref = vim.trim(r.stdout)
        ref_cache[path] = ref
        callback(ref)
        return
      end
      vim.system(
        { 'git', '-C', path, 'rev-parse', '--verify', 'origin/main' },
        { text = true },
        function(r2)
          if r2.code == 0 then
            ref_cache[path] = 'origin/main'
            callback 'origin/main'
          else
            vim.system(
              { 'git', '-C', path, 'rev-parse', '--verify', 'origin/master' },
              { text = true },
              function(r3)
                if r3.code == 0 then
                  ref_cache[path] = 'origin/master'
                  callback 'origin/master'
                else
                  ref_cache[path] = false
                  callback(nil)
                end
              end
            )
          end
        end
      )
    end
  )
end

local function git_log(path, range, callback)
  vim.system(
    { 'git', '-C', path, 'log', '--oneline', range },
    { text = true },
    function(res) callback(parse_commits(res.code == 0 and res.stdout or '')) end
  )
end

-- Forward declaration: check_updates calls render before it is defined.
local render

-- ── Update checking ──────────────────────────────────────────────────

local function check_updates()
  if state.checking then return end
  state.check_id = state.check_id + 1
  local my_check_id = state.check_id
  state.checking = true
  state.updates = {}
  state.breaking = {}
  state.unreleased_breaking = {}
  state.latest_ref = {}
  render()

  local plugins = vim.pack.get(nil, { info = true })
  local pending = #plugins
  if pending == 0 then
    state.checking = false
    render()
    return
  end

  local function finish_one(name, new_commits, is_breaking, unreleased)
    if state.check_id ~= my_check_id then return end
    if name and new_commits then
      state.updates[name] = new_commits
      if is_breaking then state.breaking[name] = true end
      if unreleased and #unreleased > 0 then
        state.unreleased_breaking[name] = unreleased
      end
    end
    pending = pending - 1
    if pending == 0 then state.checking = false end
    vim.schedule(render)
  end

  for _, p in ipairs(plugins) do
    local name = p.spec.name
    local path = p.path

    if not path or vim.fn.isdirectory(path) ~= 1 then
      finish_one(nil, nil, nil, nil)
    elseif get_version_str(p) ~= '' then
      -- Versioned plugin: fetch tags and compare installed vs latest semver.
      vim.system({ 'git', '-C', path, 'fetch', '--quiet', '--tags' }, {}, function(fr)
        if fr.code ~= 0 then
          finish_one(nil, nil, nil, nil)
          return
        end
        vim.system(
          { 'git', '-C', path, 'tag', '--sort=-version:refname' },
          { text = true },
          function(tr)
            if tr.code ~= 0 then
              finish_one(nil, nil, nil, nil)
              return
            end
            local latest_tag = nil
            for line in tr.stdout:gmatch '[^\n]+' do
              if parse_semver(line) then
                latest_tag = line
                break
              end
            end
            state.latest_ref[name] = latest_tag
            local installed_tag = get_installed_tag(path)
            if not latest_tag or latest_tag == installed_tag then
              finish_one(name, {}, false, nil)
              return
            end
            local installed_sv = parse_semver(installed_tag)
            local latest_sv = parse_semver(latest_tag)
            local is_breaking = installed_sv
              and latest_sv
              and latest_sv[1] > installed_sv[1]
            local range = (installed_tag or 'HEAD') .. '..' .. latest_tag
            git_log(
              path,
              range,
              function(commits) finish_one(name, commits, is_breaking, nil) end
            )
          end
        )
      end)
    else
      -- Unversioned plugin: compare HEAD against remote default branch.
      resolve_remote_ref(path, function(ref)
        if not ref then
          finish_one(nil, nil, nil, nil)
          return
        end
        vim.system({ 'git', '-C', path, 'fetch', '--quiet' }, {}, function(fr)
          if fr.code ~= 0 then
            finish_one(nil, nil, nil, nil)
            return
          end
          git_log(path, 'HEAD..' .. ref, function(commits)
            -- Detect breaking commits: conventional `type!:` or `BREAKING CHANGE`.
            local breaking = {}
            for _, c in ipairs(commits) do
              if c:match 'BREAKING' or c:match '%a[%w%(%)]*!:' then
                table.insert(breaking, c)
              end
            end
            finish_one(name, commits, false, breaking)
          end)
        end)
      end)
    end
  end
end

-- ── Lifecycle ────────────────────────────────────────────────────────

local function reset_state()
  state.winid = nil
  state.bufnr = nil
  state.expanded = {}
  state.show_help = false
  state.updates = {}
  state.breaking = {}
  state.unreleased_breaking = {}
  state.show_all_commits = {}
  state.latest_ref = {}
  state.checking = false
  -- Increment to invalidate any in-flight check_updates callbacks.
  state.check_id = state.check_id + 1
  -- Invalidate tag cache: installed tags change after update operations.
  tag_cache = {}
end

local function close()
  -- Remove autocmd before closing to prevent races on re-open.
  if state.win_autocmd_id then
    pcall(api.nvim_del_autocmd, state.win_autocmd_id)
    state.win_autocmd_id = nil
  end
  if state.winid and api.nvim_win_is_valid(state.winid) then
    api.nvim_win_close(state.winid, true)
  end
  -- Buffer has bufhidden=wipe; destroyed automatically when window closes.
  reset_state()
end

-- ── Navigation ───────────────────────────────────────────────────────

local function plugin_at_cursor()
  if not state.winid or not api.nvim_win_is_valid(state.winid) then return nil end
  local row = api.nvim_win_get_cursor(state.winid)[1]
  return state.line_to_plugin[row]
end

local function jump_plugin(direction)
  if not state.winid or not api.nvim_win_is_valid(state.winid) then return end
  local row = api.nvim_win_get_cursor(state.winid)[1]
  local lines = vim.tbl_keys(state.line_to_plugin)
  table.sort(lines)
  if direction > 0 then
    for _, ln in ipairs(lines) do
      if ln > row then
        api.nvim_win_set_cursor(state.winid, { ln, 0 })
        return
      end
    end
  else
    for i = #lines, 1, -1 do
      if lines[i] < row then
        api.nvim_win_set_cursor(state.winid, { lines[i], 0 })
        return
      end
    end
  end
end

-- ── Rendering ────────────────────────────────────────────────────────

render = function()
  if not state.bufnr or not api.nvim_buf_is_valid(state.bufnr) then return end

  local lines = {}
  local hls = {}
  local new_line_to_plugin = {}
  local new_plugin_lines = {}

  local function add(text, hl_group)
    table.insert(lines, text)
    if hl_group then
      local ln0 = #lines - 1 -- 0-based for extmarks
      table.insert(hls, { ln0, 0, #text, hl_group })
    end
  end

  local function add_span(ln0, col_start, col_end, hl_group)
    table.insert(hls, { ln0, col_start, col_end, hl_group })
  end

  -- Header
  local header = ' vim.pack'
  if state.checking then header = header .. '  (checking…)' end
  add(header, 'PackUiHeader')
  add(' ? for help · q/Esc to close', 'PackUiHelp')
  add ''

  local plugins = vim.pack.get(nil, { info = true })
  table.sort(plugins, function(a, b) return (a.spec.name or '') < (b.spec.name or '') end)

  for _, p in ipairs(plugins) do
    local name = p.spec.name or '(unknown)'
    local path = p.path
    local is_missing = not path or vim.fn.isdirectory(path) ~= 1
    local has_updates = state.updates[name] and #state.updates[name] > 0

    local ln = #lines + 1 -- 1-based line number for cursor→plugin mapping
    new_line_to_plugin[ln] = name
    new_plugin_lines[name] = ln

    local icon, icon_hl
    if is_missing then
      icon = '✗'
      icon_hl = 'PackUiPluginMissing'
    elseif has_updates then
      icon = '↑'
      icon_hl = 'PackUiUpdateAvailable'
    elseif p.active then
      icon = '●'
      icon_hl = 'PackUiPluginLoaded'
    else
      icon = '○'
      icon_hl = 'PackUiPluginNotLoaded'
    end

    local installed_tag = (not is_missing and get_version_str(p) ~= '')
        and get_installed_tag(path)
      or nil
    local ver_display = installed_tag and (' [' .. installed_tag .. ']') or ''
    local latest = state.latest_ref[name]
    if latest and latest ~= installed_tag then
      ver_display = ver_display .. ' → ' .. latest
    end

    local breaking = state.breaking[name]
    local brk_suffix = breaking and '  ⚠ BREAKING' or ''
    local line_text = ' ' .. icon .. ' ' .. name .. ver_display .. brk_suffix

    local ln0 = #lines -- 0-based for extmarks
    add(line_text)
    -- Icon: byte 1 .. 1+#icon (icon bytes, not display width)
    add_span(ln0, 1, 1 + #icon, icon_hl)
    if ver_display ~= '' then
      local ver_start = 1 + #icon + 1 + #name
      add_span(ln0, ver_start, ver_start + #ver_display, 'PackUiVersion')
    end
    if breaking then
      local brk_start = #line_text - #brk_suffix
      add_span(ln0, brk_start, #line_text, 'PackUiBreaking')
    end

    if state.expanded[name] then
      local updates = state.updates[name]
      if updates and #updates > 0 then
        local show_all = state.show_all_commits[name]
        local display = show_all and updates
          or { table.unpack(updates, 1, MAX_COMMITS_PREVIEW) }
        for _, commit in ipairs(display) do
          add('    ' .. commit, 'PackUiDetail')
        end
        if not show_all and #updates > MAX_COMMITS_PREVIEW then
          add(
            ('    … %d more  (press A to show all)'):format(
              #updates - MAX_COMMITS_PREVIEW
            ),
            'PackUiDetail'
          )
        end
      end

      local unreleased = state.unreleased_breaking[name]
      if unreleased then
        add('  Breaking commits:', 'PackUiBreaking')
        for _, c in ipairs(unreleased) do
          add('    ' .. c, 'PackUiBreaking')
        end
      end

      if path then add('  path: ' .. path, 'PackUiDetail') end
    end
  end

  if state.show_help then
    add ''
    add(' Keymaps:', 'PackUiHelp')
    add('   U       Update all plugins', 'PackUiHelp')
    add('   u       Update plugin under cursor', 'PackUiHelp')
    add('   C       Check remote for new commits', 'PackUiHelp')
    add('   X       Clean non-active plugins', 'PackUiHelp')
    add('   D       Delete plugin under cursor (non-active only)', 'PackUiHelp')
    add('   L       Open update log file', 'PackUiHelp')
    add('   <CR>    Toggle plugin details', 'PackUiHelp')
    add('   A       Show all commits (expanded view)', 'PackUiHelp')
    add('   ]]      Jump to next plugin', 'PackUiHelp')
    add('   [[      Jump to previous plugin', 'PackUiHelp')
    add('   q/Esc   Close window', 'PackUiHelp')
    add('   ?       Toggle this help', 'PackUiHelp')
  end

  state.line_to_plugin = new_line_to_plugin
  state.plugin_lines = new_plugin_lines

  vim.bo[state.bufnr].modifiable = true
  api.nvim_buf_set_lines(state.bufnr, 0, -1, false, lines)
  vim.bo[state.bufnr].modifiable = false

  api.nvim_buf_clear_namespace(state.bufnr, ns, 0, -1)
  for _, hl in ipairs(hls) do
    api.nvim_buf_set_extmark(state.bufnr, ns, hl[1], hl[2], {
      end_col = hl[3],
      hl_group = hl[4],
    })
  end
end

-- ── Keymaps ──────────────────────────────────────────────────────────

local function setup_keymaps()
  local buf = state.bufnr
  local opts = { buffer = buf, silent = true, nowait = true }

  vim.keymap.set('n', 'q', close, opts)
  vim.keymap.set('n', '<Esc>', close, opts)

  vim.keymap.set('n', '?', function()
    state.show_help = not state.show_help
    render()
  end, opts)

  vim.keymap.set('n', 'U', function()
    close()
    vim.pack.update()
  end, opts)

  vim.keymap.set('n', 'u', function()
    local name = plugin_at_cursor()
    if not name then return end
    close()
    vim.pack.update { name }
  end, opts)

  vim.keymap.set('n', 'C', check_updates, opts)

  vim.keymap.set('n', 'X', function()
    local all = vim.pack.get(nil, { info = false })
    local orphans = {}
    for _, p in ipairs(all) do
      if not p.active then table.insert(orphans, p.spec.name) end
    end
    if #orphans == 0 then
      vim.notify('PackUI: no orphaned plugins to remove', vim.log.levels.INFO)
      return
    end
    close()
    local ok, err = pcall(vim.pack.del, orphans)
    if not ok then vim.notify('PackUI: ' .. tostring(err), vim.log.levels.ERROR) end
  end, opts)

  vim.keymap.set('n', 'D', function()
    local name = plugin_at_cursor()
    if not name then return end
    local all = vim.pack.get(nil, { info = false })
    for _, p in ipairs(all) do
      if p.spec.name == name then
        if p.active then
          vim.notify(
            'PackUI: plugin is active — use X to clean orphans or U to update',
            vim.log.levels.WARN
          )
        else
          close()
          vim.pack.del { name }
        end
        return
      end
    end
  end, opts)

  vim.keymap.set('n', 'L', function()
    local log_path = vim.fn.stdpath 'log' .. '/pack.log'
    if vim.fn.filereadable(log_path) == 1 then
      close()
      vim.cmd.edit(log_path)
    else
      vim.notify('PackUI: log not found: ' .. log_path, vim.log.levels.WARN)
    end
  end, opts)

  vim.keymap.set('n', '<CR>', function()
    local name = plugin_at_cursor()
    if not name then return end
    state.expanded[name] = not state.expanded[name]
    render()
  end, opts)

  vim.keymap.set('n', 'A', function()
    local name = plugin_at_cursor()
    if not name then return end
    state.show_all_commits[name] = not state.show_all_commits[name]
    render()
  end, opts)

  vim.keymap.set('n', ']]', function() jump_plugin(1) end, opts)
  vim.keymap.set('n', '[[', function() jump_plugin(-1) end, opts)
end

-- ── Window ───────────────────────────────────────────────────────────

local function open()
  if state.winid and api.nvim_win_is_valid(state.winid) then
    api.nvim_set_current_win(state.winid)
    return
  end

  local width = math.floor(vim.o.columns * 0.7)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  state.bufnr = api.nvim_create_buf(false, true)
  vim.bo[state.bufnr].buftype = 'nofile'
  vim.bo[state.bufnr].bufhidden = 'wipe'
  vim.bo[state.bufnr].swapfile = false
  vim.bo[state.bufnr].filetype = 'pack-ui'
  vim.bo[state.bufnr].modifiable = false

  state.winid = api.nvim_open_win(state.bufnr, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' vim.pack ',
    title_pos = 'center',
  })

  vim.wo[state.winid].wrap = false
  vim.wo[state.winid].cursorline = true

  setup_keymaps()
  render()

  local captured_winid = state.winid
  state.win_autocmd_id = api.nvim_create_autocmd('WinClosed', {
    buffer = state.bufnr,
    once = true,
    callback = function(ev)
      -- tonumber replaces the private vim._tointeger used in the original.
      if tonumber(ev.match) ~= captured_winid then return end
      state.win_autocmd_id = nil
      reset_state()
    end,
  })
end

-- ── Commands ─────────────────────────────────────────────────────────

vim.api.nvim_create_user_command('Pack', function(opts)
  open()
  if opts.args == 'check' then
    check_updates()
  elseif opts.args == 'update' then
    close()
    vim.pack.update()
  elseif opts.args == 'clean' then
    local all = vim.pack.get(nil, { info = false })
    local orphans = {}
    for _, p in ipairs(all) do
      if not p.active then table.insert(orphans, p.spec.name) end
    end
    if #orphans > 0 then
      close()
      local ok, err = pcall(vim.pack.del, orphans)
      if not ok then vim.notify('PackUI: ' .. tostring(err), vim.log.levels.ERROR) end
    end
  end
end, {
  nargs = '?',
  complete = function() return { 'check', 'update', 'clean' } end,
  desc = 'Open vim.pack plugin manager UI',
})
