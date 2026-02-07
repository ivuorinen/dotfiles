#!/usr/bin/env bash
set -euo pipefail
# @description Install NerdFonts
#
# shellcheck source="shared.sh"
source "$DOTFILES/config/shared.sh"

GIT_REPO="https://github.com/ryanoasis/nerd-fonts.git"
TMP_PATH="$XDG_CACHE_HOME/nerd-fonts"

msgr run "Starting to install NerdFonts"

fonts=(
  JetBrainsMono
  OpenDyslexic
)

# Function to clone or update the NerdFonts repository
clone_or_update_repo()
{
  if [[ ! -d "$TMP_PATH/.git" ]]; then
    rm -rf "$TMP_PATH"
    git clone --quiet --filter=blob:none --sparse --depth=1 "$GIT_REPO" "$TMP_PATH"
  fi

  cd "$TMP_PATH" || {
    msgr err "No such folder $TMP_PATH"
    exit 1
  }
  return 0
}

# Function to add fonts to sparse-checkout
add_fonts_to_sparse_checkout()
{
  for font in "${fonts[@]}"; do
    # Trim spaces
    font=${font// /}
    # Skip comments
    if [[ ${font:0:1} == "#" ]]; then continue; fi

    msgr run "Adding $font to sparse-checkout"
    git sparse-checkout add "patched-fonts/$font"
    echo ""
  done
  return 0
}

# Function to install NerdFonts
install_fonts()
{
  msgr run "Starting to install NerdFonts..."
  # shellcheck disable=SC2048,SC2086
  ./install.sh -q -s ${fonts[*]}
  msgr run_done "Done"
  return 0
}

# Remove the temporary nerd-fonts clone directory
remove_tmp_path()
{
  rm -rf "$TMP_PATH"
  return 0
}

# Clone, sparse-checkout, install fonts, and clean up
main()
{
  clone_or_update_repo
  add_fonts_to_sparse_checkout
  install_fonts
  remove_tmp_path
  return 0
}

main "$@"
