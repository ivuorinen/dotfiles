-- These are my utility functions
-- I use to make my life bit easier

-- ╭─────────────────────────────────────────────────────────╮
-- │            Function shortcuts for keymap set            │
-- ╰─────────────────────────────────────────────────────────╯

-- Keymap set shortcut
--@type vim.keymap.set
local s = vim.keymap.set

-- Keymap shortcut functions
K = {}

-- Handle description
---@param desc string|table? Optional description. Can be a string or a table.
---@return table -- The description as a table.
local function handleDesc(desc)
  if type(desc) == "string" then
    -- Convert string to table with `desc` as a key
    -- If the string is empty, just return as an empty description
    return { desc = desc }
  elseif type(desc) == "table" then
    -- If desc doesn't have 'desc' key, combine it with
    -- others with empty description
    if not desc.desc then
      desc.desc = '?'
      return desc
    end
    -- Use the table as is
    return desc
  else
    -- Default to an empty table if `desc` is nil or an unsupported type
    return { desc = '?' }
  end
end

-- Normal mode keymaps
---@param key string rhs, required
---@param cmd string|function lhs, required
---@param opts table? Options, optional
K.n = function(key, cmd, opts)
  opts = handleDesc(opts or {})
  s('n', key, cmd, opts)
end

-- Leader keymap shortcut function
-- It prepends '<leader>' to the key
---@param key string rhs, required, but will be prepended with '<leader>'
---@param cmd string|function lhs, required
---@param opts table|string? Options (or just description), optional
K.nl = function(key, cmd, opts)
  opts = handleDesc(opts)
  K.n('<leader>' .. key, cmd, opts)
end

-- Keymap shortcut function with mode defined, good for sorting by rhs
---@param key string rhs, required
---@param mode string|string[] one of n, v, x, or table of modes { 'n', 'v' }
---@param cmd string|function lhs, required
---@param opts string|table description, required
K.d = function(key, mode, cmd, opts)
  opts = handleDesc(opts or {})
  s(mode, key, cmd, opts)
end

-- Leader based keymap shortcut function with mode defined
---@param key string rhs, required, but will be prepended with '<leader>'
---@param mode string|string[] one of n, v, x, or table of modes { 'n', 'v' }
---@param cmd string|function lhs, required
---@param opts string|table description (or opts), required
K.ld = function(key, mode, cmd, opts)
  opts = handleDesc(opts or {})
  s(mode, '<leader>' .. key, cmd, opts)
end

-- ╭─────────────────────────────────────────────────────────╮
-- │            Options related helper functions             │
-- ╰─────────────────────────────────────────────────────────╯

-- Toggle background between light and dark
function ToggleBackground()
  vim.o.bg = vim.o.bg == "light" and "dark" or "light"
end
