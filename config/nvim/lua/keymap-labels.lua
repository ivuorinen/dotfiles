-- Descriptions for maps that plugins and Neovim register without one, so
-- :map, mini.clue and docs/nvim-keybindings.md can name them. Keyed by mode,
-- then lhs. A map that is missing or already described is left alone, and
-- labels follow the keys, so a map moved in its plugin's config loses its own.

local matchit = {
  ['%'] = 'Go to matching bracket (matchit)',
  ['[%'] = 'Previous unmatched group (matchit)',
  [']%'] = 'Next unmatched group (matchit)',
  ['g%'] = 'Reverse matching bracket (matchit)',
  ['a%'] = 'Select matching group (matchit)',
}
local surround = { s = 'Surround (mini.surround)' }

local global = {
  n = vim.tbl_extend('force', matchit, surround, { ['&'] = 'Repeat last :s substitute' }),
  x = vim.tbl_extend('force', matchit, surround),
  o = vim.tbl_extend('force', matchit, surround),
  s = surround,
}

-- orgmode's text objects. The headline and subtree wording is orgmode's own
-- help_desc; its ftplugin adds the markup pairs.
local org_textobj = {
  ih = 'Select inner headline (orgmode)',
  ah = 'Select around headline (orgmode)',
  ir = 'Select inner subtree (orgmode)',
  ar = 'Select around subtree (orgmode)',
  Oh = 'Select inner headline from root headline (orgmode)',
  OH = 'Select around headline from root headline (orgmode)',
  Or = 'Select inner subtree from root headline (orgmode)',
  OR = 'Select around subtree from root headline (orgmode)',
}
local org_markup = {
  ['*'] = 'bold',
  ['='] = 'verbatim',
  ['/'] = 'italic',
  ['+'] = 'strikethrough',
  ['~'] = 'code',
  ['_'] = 'underline',
}
for char, name in pairs(org_markup) do
  org_textobj['i' .. char] = 'Select inside ' .. name .. ' markers (orgmode)'
  org_textobj['a' .. char] = 'Select around ' .. name .. ' markers (orgmode)'
end
local org = { x = org_textobj, o = org_textobj }

-- Rewrite each map with its description. maparg + mapset keep the rhs or Lua
-- callback and every flag. maparg prefers a buffer-local map in the current
-- buffer, so buffer_local picks which kind may be relabelled.
local function label(maps, buffer_local)
  for mode, descs in pairs(maps) do
    for lhs, desc in pairs(descs) do
      local m = vim.fn.maparg(lhs, mode, false, true)
      if m.lhs and (m.desc or '') == '' and (m.buffer == 1) == buffer_local then
        m.desc = desc
        vim.fn.mapset(m)
      end
    end
  end
end

-- matchit loads from the runtime plugin/ directory after init.lua, and the
-- event loop can tick before that, so wait for startup to finish.
vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function() label(global, false) end,
})

-- orgmode's ftplugin runs after this config's FileType hooks.
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'org',
  callback = function(ev)
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(ev.buf) then
        vim.api.nvim_buf_call(ev.buf, function() label(org, true) end)
      end
    end)
  end,
})
