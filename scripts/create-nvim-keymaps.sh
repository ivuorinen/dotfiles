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

--- Escape for inside backtick code spans (Key, Command columns)
local function esc_code(s)
  s = s:gsub("<lt>", "<")
  s = s:gsub("|", "\\|")
  s = s:gsub("`", "'")
  s = s:gsub("==", "=\xE2\x80\x8B=")
  s = s:gsub("~~", "~\xE2\x80\x8B~")
  return s
end

--- Escape for plain text (Description column)
local function esc_text(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  s = s:gsub("|", "&#124;")
  s = s:gsub("=", "&#61;")
  s = s:gsub("~", "&#126;")
  return s
end

-- Fallback descriptions for keymaps without desc
local matchit = {
  ["%"] = "Go to matching bracket (matchit)",
  ["[%"] = "Previous unmatched group (matchit)",
  ["]%"] = "Next unmatched group (matchit)",
  ["g%"] = "Reverse matching bracket (matchit)",
  ["a%"] = "Select matching group (matchit)",
}
local fallback_desc = {
  n = vim.tbl_extend("force", matchit, {
    ["s"] = "Surround (mini.surround)",
    ["&"] = "Repeat last :s substitute",
  }),
  v = vim.tbl_extend("force", matchit, {
    ["s"] = "Surround (mini.surround)",
  }),
  x = vim.tbl_extend("force", matchit, {
    ["s"] = "Surround (mini.surround)",
  }),
  s = {
    ["s"] = "Surround (mini.surround)",
  },
  o = vim.tbl_extend("force", matchit, {
    ["s"] = "Surround (mini.surround)",
  }),
}

f:write("# Neovim Keybindings\n\n")

for _, mode in ipairs(modes) do
  local maps = vim.api.nvim_get_keymap(mode.char)
  if #maps > 0 then
    table.sort(maps, function(a, b)
      return a.lhs < b.lhs
    end)

    -- Filter out <Plug> mappings first
    local filtered = {}
    for _, map in ipairs(maps) do
      local lhs = map.lhs or ""
      if not lhs:find("<Plug>") then
        filtered[#filtered + 1] = map
      end
    end

    if #filtered > 0 then
      f:write("## " .. mode.name .. " Mode\n\n")
      f:write("| Key | Description | Command |\n")
      f:write("|-----|-------------|---------|\n")

      local mode_fb = fallback_desc[mode.char] or {}
      for _, map in ipairs(filtered) do
        local key = esc_code(map.lhs or "")
        local raw_desc = map.desc or mode_fb[map.lhs] or ""
        local desc = esc_text(raw_desc)
        local cmd = map.rhs or ""
        if cmd == "" then
          cmd = "<Lua callback>"
        end
        cmd = esc_code(cmd)
        f:write(string.format(
          "| `%s` | %s | `%s` |\n", key, desc, cmd
        ))
      end

      f:write("\n")
    end
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
