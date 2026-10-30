-- Writes docs/nvim-keybindings.md from the running Neovim: the global maps, the
-- buffer-local maps every buffer gets, and those an org buffer adds.
-- scripts/create-nvim-keymaps.sh runs it headless from a VimEnter autocmd, after
-- lua/keymap-labels.lua has labelled the global maps that lack a description.
-- It opens scratch buffers and enters insert mode, so it is not meant for an
-- interactive session.
local M = {}

local modes = {
  { char = 'n', name = 'Normal' },
  { char = 'i', name = 'Insert' },
  { char = 'v', name = 'Visual + Select' },
  { char = 'x', name = 'Visual' },
  { char = 's', name = 'Select' },
  { char = 'o', name = 'Operator-pending' },
  { char = 'c', name = 'Command-line' },
  { char = 't', name = 'Terminal' },
}

--- Escape for inside backtick code spans (Key, Command columns)
local function esc_code(s)
  s = s:gsub('<lt>', '<')
  s = s:gsub('|', '\\|')
  s = s:gsub('`', "'")
  s = s:gsub('==', '=\xE2\x80\x8B=')
  s = s:gsub('~~', '~\xE2\x80\x8B~')
  return s
end

--- Escape for plain text (Description column)
local function esc_text(s)
  s = s:gsub('&', '&amp;')
  s = s:gsub('<', '&lt;')
  s = s:gsub('>', '&gt;')
  s = s:gsub('|', '&#124;')
  s = s:gsub('=', '&#61;')
  s = s:gsub('~', '&#126;')
  return s
end

--- Write one table per mode, holding the maps maps_for(mode_char) returns.
--- The scope prefix keeps each section's headings unique (markdownlint MD024).
local function write_modes(f, scope, maps_for)
  for _, mode in ipairs(modes) do
    -- <Plug> maps are internal, and mini.clue's buffer-local triggers only
    -- open its popup.
    local filtered = vim.tbl_filter(
      function(map)
        return not (map.lhs or ''):find '<Plug>'
          and not (map.desc or ''):find '^Query keys after'
      end,
      maps_for(mode.char)
    )

    if #filtered > 0 then
      table.sort(filtered, function(a, b) return a.lhs < b.lhs end)
      f:write('### ' .. scope .. mode.name .. ' Mode\n\n')
      f:write '| Key | Description | Command |\n'
      f:write '|-----|-------------|---------|\n'
      for _, map in ipairs(filtered) do
        local cmd = map.rhs or ''
        if cmd == '' then cmd = '<Lua callback>' end
        f:write(
          ('| `%s` | %s | `%s` |\n'):format(
            esc_code(map.lhs or ''),
            esc_text(map.desc or ''),
            esc_code(cmd)
          )
        )
      end
      f:write '\n'
    end
  end
end

---@param dest string path of the markdown file to write
function M.write(dest)
  local f = assert(io.open(dest, 'w'))

  -- vim.pack loads every plugin at startup, but some register their global
  -- maps on a timer (orgmode uses vim.defer_fn). Run the event loop briefly so
  -- the snapshot sees them.
  vim.wait(200)

  f:write '# Neovim Keybindings\n\n## Global\n\n'
  write_modes(f, '', function(m) return vim.api.nvim_get_keymap(m) end)

  -- Buffer-local maps that every file buffer gets. blink.cmp attaches its
  -- completion keys to the buffer, so enter insert mode once first.
  vim.cmd.edit(vim.fn.tempname() .. '.txt')
  vim.api.nvim_feedkeys('i', 'x', false)
  vim.cmd.stopinsert()
  local every = {}
  f:write '## Every buffer\n\nBuffer-local maps that every file buffer gets.\n\n'
  write_modes(f, 'Every buffer: ', function(m)
    local maps = vim.api.nvim_buf_get_keymap(0, m)
    for _, map in ipairs(maps) do
      every[m .. map.lhs .. (map.desc or '')] = true
    end
    return maps
  end)

  vim.cmd.edit(vim.fn.tempname() .. '.org')
  vim.wait(200)
  f:write '## Org buffers\n\nBuffer-local maps an org buffer adds to those above.\n\n'
  write_modes(f, 'Org buffers: ', function(m)
    return vim.tbl_filter(
      function(map) return not every[m .. map.lhs .. (map.desc or '')] end,
      vim.api.nvim_buf_get_keymap(0, m)
    )
  end)

  f:write(('- Generated on %s\n'):format(os.date '%Y-%m-%d'))
  f:close()
end

return M
