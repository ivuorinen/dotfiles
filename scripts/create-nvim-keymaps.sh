#!/usr/bin/env bash
# Create file containing key mappings for Neovim
# Usage: ./create-nvim-keymaps.sh
#
# shellcheck source=shared.sh
source "${DOTFILES}/config/shared.sh"
DEST="$HOME/.dotfiles/docs/nvim-keybindings.md"

main()
{
  msg "Generating Neovim keybindings documentation"

  {
    printf "# nvim keybindings\n\n"
    printf "\`\`\`txt"
  } > "$DEST"

  nvim -c "redir! >> $DEST" -c 'silent verbose map' -c 'redir END' -c 'q'

  printf "\n\`\`\`\n\n- Generated on %s\n" "$(date)" >> "$DEST"

  # Remove lines with "Last set from" from the file
  sed -e '/^	Last set from/d' "$DEST" > "${DEST}.tmp" && mv "${DEST}.tmp" "$DEST"

  msg "Neovim keybindings documentation generated at $DEST"
}

main "$@"
