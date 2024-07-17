#!/usr/bin/env bash
# Create file containing key mappings for Neovim
# Usage: ./create-nvim-keymaps.sh

eval "$HOME/.dotfiles/scripts/shared.sh"

DEST="$HOME/.dotfiles/docs/nvim-keybindings.md"

{
  printf "# nvim keybindings\n";
  printf "\n";
  printf "\`\`\`txt";
} > "$DEST"

NVIM_APPNAME="nvim-kickstart" nvim -c "redir! >> $DEST" -c 'silent verbose map' -c 'redir END' -c 'q'

printf "\n\`\`\`\n\n- Generated on %s\n" "$(date)" >> "$DEST"

# Remove lines with "Last set from" from the file
sed -e '/^	Last set from/d' "$DEST" > "$DEST.tmp" && mv "$DEST.tmp" "$DEST"
