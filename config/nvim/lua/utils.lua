-- ╭─────────────────────────────────────────────────────────╮
-- │            Function shortcuts for keymap set            │
-- ╰─────────────────────────────────────────────────────────╯

-- Keymap set shortcut
local s = vim.keymap.set

-- Keymap shortcut functions
K = {}

-- Handle description
---@param desc string|table? Optional description. Can be a string or a table.
---@return table -- The description as a table.
local function handleDesc(desc)
  if type(desc) == 'string' then
    return { desc = desc }
  elseif type(desc) == 'table' then
    if desc.desc then return desc end
    -- Clone instead of mutating: callers may share a single opts table
    -- across multiple K.n() calls and we don't want a leftover desc='?'.
    return vim.tbl_extend('force', desc, { desc = '?' })
  else
    return { desc = '?' } -- nil or unsupported type: surface as unlabelled binding
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
function ToggleBackground() vim.o.bg = vim.o.bg == 'light' and 'dark' or 'light' end

-- ╭─────────────────────────────────────────────────────────╮
-- │              LSP Related helper functions               │
-- ╰─────────────────────────────────────────────────────────╯

-- Get the license key for intelephense
---@return string|nil -- The license key for intelephense
function GetIntelephenseLicense()
  local p = os.getenv 'HOME' .. '/intelephense/license.txt'

  local f = io.open(p, 'rb')
  if not f then return nil end

  local content = f:read '*a'
  f:close()
  local stripped = string.gsub(content, '%s+', '')
  return stripped == '' and nil or stripped
end

-- ╭─────────────────────────────────────────────────────────╮
-- │          Project tool-configuration detection           │
-- ╰─────────────────────────────────────────────────────────╯

-- Marker files per tool, keyed by logical name. Used to detect whether
-- a project has opted into a given formatter/linter before running it.
-- Shared between conform (via Gated()) and nvim-lint (via HasConfig()
-- in lua/autogroups.lua's LINTER_GATES). Extend this table to gate a
-- new tool; keys are referenced by string from consumers.
---@type table<string, string[]>
TOOL_CONFIGS = {
  ansible_lint = { '.ansible-lint', '.ansible-lint.yml', '.ansible-lint.yaml' },
  biome = { 'biome.json', 'biome.jsonc' },
  golangci_lint = {
    '.golangci.yml',
    '.golangci.yaml',
    '.golangci.toml',
    '.golangci.json',
  },
  hadolint = { '.hadolint.yaml', '.hadolint.yml' },
  prettier = {
    '.prettierrc',
    '.prettierrc.json',
    '.prettierrc.json5',
    '.prettierrc.yml',
    '.prettierrc.yaml',
    '.prettierrc.toml',
    '.prettierrc.js',
    '.prettierrc.cjs',
    '.prettierrc.mjs',
    'prettier.config.js',
    'prettier.config.cjs',
    'prettier.config.mjs',
  },
  -- pyproject.toml without [tool.ruff] is a false positive; toggle
  -- format off with <leader>tf in those rare projects.
  ruff = { 'ruff.toml', '.ruff.toml', 'pyproject.toml' },
  stylua = { 'stylua.toml', '.stylua.toml' },
  taplo = { 'taplo.toml', '.taplo.toml' },
  tflint = { '.tflint.hcl' },
  yamllint = { '.yamllint', '.yamllint.yml', '.yamllint.yaml' },
}

-- Does the buffer's file tree contain a config for `tool`? Walks
-- upward from the buffer's file via vim.fs.root until a marker in
-- TOOL_CONFIGS[tool] is found or the filesystem root is reached.
-- Returns false for unknown tool names (fail-closed).
---@param tool string key in TOOL_CONFIGS
---@param bufnr integer? buffer handle; defaults to current (0)
---@return boolean
function HasConfig(tool, bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr or 0)
  return vim.fs.root(bufname, TOOL_CONFIGS[tool] or {}) ~= nil
end

-- conform formatter spec builder that gates the formatter on
-- HasConfig(). Intended for use inside conform.setup's `formatters`
-- table, e.g. `formatters = { prettier = Gated 'prettier' }`. The
-- returned table is shallow-merged by conform with the built-in
-- formatter spec, so cmd/args/cwd/etc. are preserved.
---@param tool string key in TOOL_CONFIGS
---@return { condition: fun(self: any, ctx: { buf: integer }): boolean }
function Gated(tool)
  return {
    condition = function(_, ctx) return HasConfig(tool, ctx.buf) end,
  }
end
