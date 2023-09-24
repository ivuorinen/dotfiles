#!/usr/bin/env bash
# Install NerdFonts
#
# shellcheck source="shared.sh"
source "$HOME/.dotfiles/scripts/shared.sh"

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

if [ ! -d "$TMP_PATH" ]; then
  git clone --filter=blob:none --sparse "$GIT_REPO" "$TMP_PATH"
fi

cd "$TMP_PATH" || {
  msg_err "No such folder $TMP_PATH"
  exit 1
}

for ext in "${fonts[@]}"; do
  # Trim spaces
  ext=${ext// /}
  # Skip comments
  if [[ ${ext:0:1} == "#" ]]; then continue; fi

  msg_run "Adding $ext to sparse-checkout"
  git sparse-checkout add "patched-fonts/$ext"
  echo ""
done

msg "Starting to install NerdFonts..."

./install.sh -s ${fonts[*]}

msg_ok "Done"
