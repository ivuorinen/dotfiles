#!/usr/bin/env bash
# Install NerdFonts
#
# shellcheck source="shared.sh"
source "$DOTFILES/config/shared.sh"

GIT_REPO="https://github.com/ryanoasis/nerd-fonts.git"
TMP_PATH="$XDG_CACHE_HOME/nerd-fonts"

msg "-- NerdFonts --"

fonts=(
  Hack
  IntelOneMono
  JetBrainsMono
  OpenDyslexic
  SpaceMono
)

# Function to clone or update the NerdFonts repository
clone_or_update_repo()
{
  if [ ! -d "$TMP_PATH" ]; then
    git clone --quiet --filter=blob:none --sparse "$GIT_REPO" "$TMP_PATH"
  fi

  cd "$TMP_PATH" || msg_err "No such folder $TMP_PATH"
}

# Function to add fonts to sparse-checkout
add_fonts_to_sparse_checkout()
{
  for font in "${fonts[@]}"; do
    # Trim spaces
    font=${font// /}
    # Skip comments
    if [[ ${font:0:1} == "#" ]]; then continue; fi

    msg_run "Adding $font to sparse-checkout"
    git sparse-checkout add "patched-fonts/$font"
    echo ""
  done
}

# Function to install NerdFonts
install_fonts()
{
  msg "Starting to install NerdFonts..."
  ./install.sh -q -s ${fonts[*]}
  msg_ok "Done"
}

remove_tmp_path()
{
  rm -rf "$TMP_PATH"
}

main()
{
  clone_or_update_repo
  add_fonts_to_sparse_checkout
  install_fonts
  remove_tmp_path
}

main "$@"
