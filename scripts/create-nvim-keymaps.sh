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

  {
    printf "# nvim keybindings\n\n"
    printf "\`\`\`txt"
  } > "$DEST"

  nvim -c "redir! >> \"$DEST\"" -c 'silent verbose map' -c 'redir END' -c 'q'

  printf "\n\`\`\`\n\n- Generated on %s\n" "$(date)" >> "$DEST"

  # Remove unnecessary information from the output and the last line
  sed -E \
    -e 's/<Lua [^:]+: ([^:>]+):[0-9]+>/\1/' \
    -e '/^	Last set from/d' "$DEST" \
    > "${DEST}.tmp" \
    && mv "${DEST}.tmp" "$DEST"

  msg "Neovim keybindings documentation generated at $DEST"
  return 0
}

main "$@"
