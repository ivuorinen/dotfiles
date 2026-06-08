-- vim.pack management commands

local _names_cache = nil

-- List plugin names from nvim-pack-lock.json for tab-completion (session-cached).
local function _pack_names()
  if _names_cache then return _names_cache end
  local lock = vim.fn.stdpath 'config' .. '/nvim-pack-lock.json'
  if vim.fn.filereadable(lock) == 0 then return {} end
  local ok, data = pcall(vim.fn.json_decode, table.concat(vim.fn.readfile(lock), '\n'))
  if not ok or type(data) ~= 'table' or type(data.plugins) ~= 'table' then return {} end
  _names_cache = vim.tbl_keys(data.plugins)
  return _names_cache
end

local function _complete(lead)
  local names = {}
  for _, name in ipairs(_pack_names()) do
    if name:find('^' .. vim.pesc(lead)) then table.insert(names, name) end
  end
  return names
end

-- Update all installed vim.pack plugins (optionally a single name).
vim.api.nvim_create_user_command(
  'PackUpdate',
  function(opts) vim.pack.update(opts.args ~= '' and { opts.args } or nil) end,
  {
    nargs = '?',
    complete = _complete,
    desc = 'Update vim.pack plugins (all if no argument given)',
  }
)

-- Remove a vim.pack plugin by name.
vim.api.nvim_create_user_command(
  'PackRemove',
  function(opts) vim.pack.del { opts.args } end,
  {
    nargs = 1,
    complete = _complete,
    desc = 'Remove a vim.pack plugin by name',
  }
)

-- List all plugins in a floating window; inactive (orphans) shown first.
vim.api.nvim_create_user_command('PackList', function()
  local all = vim.pack.get(nil, { info = false })
  local inactive, active = {}, {}
  for _, p in ipairs(all) do
    if p.active then
      table.insert(active, p.spec.name)
    else
      table.insert(inactive, p.spec.name)
    end
  end
  table.sort(inactive)
  table.sort(active)

  local lines = {}
  if #inactive > 0 then
    table.insert(lines, ('NOT USED (%d):'):format(#inactive))
    for _, n in ipairs(inactive) do
      table.insert(lines, '  ' .. n)
    end
    if #active > 0 then table.insert(lines, '') end
  end
  table.insert(lines, ('USED (%d):'):format(#active))
  for _, n in ipairs(active) do
    table.insert(lines, '  ' .. n)
  end

  local max_len = 0
  for _, line in ipairs(lines) do
    max_len = math.max(max_len, #line)
  end
  local w = math.max(1, math.min(math.max(max_len + 4, 34), vim.o.columns - 4))
  local h = math.max(1, math.min(#lines, vim.o.lines - 6))

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false

  vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = w,
    height = h,
    row = math.floor((vim.o.lines - h) / 2),
    col = math.floor((vim.o.columns - w) / 2),
    style = 'minimal',
    border = 'rounded',
    title = ' PackList ',
    title_pos = 'center',
  })
  vim.keymap.set(
    'n',
    'q',
    '<cmd>close<cr>',
    { buffer = buf, silent = true, desc = 'Close' }
  )
end, { desc = 'List vim.pack plugins; inactive (orphans) first' })
