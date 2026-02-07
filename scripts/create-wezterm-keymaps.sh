#!/usr/bin/env bash
# @description Create file containing key mappings for wezterm
# Usage: ./create-wezterm-keymaps.sh
#
# shellcheck source=shared.sh
source "${DOTFILES}/config/shared.sh"
DEST="$HOME/.dotfiles/docs/wezterm-keybindings.md"

main()
{
  msg "Generating wezterm keybindings documentation"

  {
    printf "# wezterm keybindings\n\n"
    printf "\`\`\`txt\n"
  } > "$DEST"

  wezterm show-keys >> "$DEST"

  printf "\`\`\`\n\n- Generated on %s\n" "$(date)" >> "$DEST"

  msg "wezterm keybindings documentation generated at $DEST"
  return 0
}

main "$@"
