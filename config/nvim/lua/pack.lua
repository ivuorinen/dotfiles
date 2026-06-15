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

-- Close the vim.pack confirm buffer (filetype nvim-pack) with q or Esc.
-- :w confirms and runs the update; closing cancels via Neovim's own on_cancel.
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('nvim_pack_close', { clear = true }),
  pattern = 'nvim-pack',
  callback = function(event)
    local close = '<cmd>close<cr>'
    local opts = { buffer = event.buf, silent = true }
    vim.keymap.set(
      'n',
      'q',
      close,
      vim.tbl_extend('force', opts, { desc = 'Cancel update' })
    )
    vim.keymap.set(
      'n',
      '<Esc>',
      close,
      vim.tbl_extend('force', opts, { desc = 'Cancel update' })
    )
  end,
})
