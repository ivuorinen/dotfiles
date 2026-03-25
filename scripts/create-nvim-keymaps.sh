#!/usr/bin/env bash
set -euo pipefail
# @description Create file containing key mappings for Neovim
# Usage: ./create-nvim-keymaps.sh
#
# shellcheck source=shared.sh
source "${DOTFILES}/config/shared.sh"
DEST="$HOME/.dotfiles/docs/nvim-keybindings.md"

# Generate Neovim keybindings documentation
main()
{
  msg "Generating Neovim keybindings documentation"

  local tmpfile
  tmpfile=$(mktemp /tmp/nvim-keymaps-XXXX.lua)

  cat > "$tmpfile" << 'LUAEOF'
local dest = vim.env.KEYMAPS_DEST
local f = io.open(dest, "w")
if not f then
  vim.api.nvim_err_writeln("Cannot open " .. dest)
  vim.cmd("cq")
end

-- Force-load all lazy.nvim plugins so their keymaps are registered
local ok, lazy = pcall(require, "lazy")
if ok then
  for _, plugin in ipairs(lazy.plugins()) do
    pcall(lazy.load, { plugins = { plugin.name } })
  end
end

local modes = {
  { char = "n", name = "Normal" },
  { char = "i", name = "Insert" },
  { char = "v", name = "Visual + Select" },
  { char = "x", name = "Visual" },
  { char = "s", name = "Select" },
  { char = "o", name = "Operator-pending" },
  { char = "c", name = "Command-line" },
  { char = "t", name = "Terminal" },
}

--- Escape pipe characters for markdown tables
local function esc(s)
  return s:gsub("|", "\\|")
end

f:write("# Neovim Keybindings\n\n")

for _, mode in ipairs(modes) do
  local maps = vim.api.nvim_get_keymap(mode.char)
  if #maps > 0 then
    table.sort(maps, function(a, b)
      return a.lhs < b.lhs
    end)

    f:write("## " .. mode.name .. " Mode\n\n")
    f:write("| Key | Description | Command |\n")
    f:write("|-----|-------------|---------|\n")

    for _, map in ipairs(maps) do
      local key = esc(map.lhs or "")
      local desc = esc(map.desc or "")
      local cmd = map.rhs or ""
      if cmd == "" then
        cmd = "<Lua callback>"
      end
      cmd = esc(cmd)
      f:write(string.format("| `%s` | %s | %s |\n", key, desc, cmd))
    end

    f:write("\n")
  end
end

f:write(string.format("- Generated on %s\n", os.date("%Y-%m-%d")))
f:close()
vim.cmd("q")
LUAEOF

  KEYMAPS_DEST="$DEST" nvim --headless -c "luafile $tmpfile" 2> /dev/null

  rm -f "$tmpfile"
  npx --yes markdown-table-formatter "$DEST"

  msg "Neovim keybindings documentation generated at $DEST"
  return 0
}

main "$@"
