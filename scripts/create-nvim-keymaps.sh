#!/usr/bin/env bash
set -euo pipefail
# @description Create file containing key mappings for Neovim
#USAGE about "Generate Neovim keybindings documentation"
# Usage: ./create-nvim-keymaps.sh
#
# shellcheck source=shared.sh
source "${DOTFILES}/config/shared.sh"
DEST="${DOTFILES}/docs/nvim-keybindings.md"

# Generate Neovim keybindings documentation. The writer lives in the Neovim
# config (config/nvim/lua/keymaps-doc.lua), next to the maps it documents.
main()
{
  msg "Generating Neovim keybindings documentation"

  # -c runs before VimEnter, where keymap-labels describes the global maps, so
  # write from a VimEnter autocmd of our own, defined after the config's.
  # ++nested lets the scratch buffers it opens fire FileType. A Lua error there
  # does not fail nvim, so quit with an error code.
  KEYMAPS_DEST="$DEST" nvim --headless \
    -c 'autocmd VimEnter * ++once ++nested lua local ok, err = pcall(require("keymaps-doc").write, vim.env.KEYMAPS_DEST); if not ok then io.stderr:write(tostring(err), "\n"); vim.cmd.cquit() end; vim.cmd "qa!"'
  if command -v markdown-table-formatter > /dev/null; then
    markdown-table-formatter "$DEST"
  fi

  msg "Neovim keybindings documentation generated at $DEST"
  return 0
}

main "$@"
