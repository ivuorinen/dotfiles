#!/usr/bin/env bash
# Create file containing key mappings for Neovim
# Usage: ./create-nvim-keymaps.sh

source "$HOME/.dotfiles/scripts/shared.sh"
source "$HOME/.dotfiles/config/exports"
source "$HOME/.dotfiles/config/alias"
source "$HOME/.dotfiles/config/functions"

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
