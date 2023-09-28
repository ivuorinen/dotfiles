#!/usr/bin/env bash
# Install python/pip packages.
#
# shellcheck source=shared.sh
source "$HOME/.dotfiles/scripts/shared.sh"

msg "Starting to install pip packages"

! have pip && {
  msg_err "Could not find pip, something really terrible is going on." && exit 1
}

packages=(
  "pipx"
  "libtmux"
)

for pkg in "${packages[@]}"; do
  # Trim spaces
  pkg=${pkg// /}
  # Skip comments
  if [[ ${pkg:0:1} == "#" ]]; then continue; fi

  msg_nested "Installing pip package: $pkg"
  python3 -m pip install --user "$pkg"

  echo ""
done

msg_yay "Run pip package installation"
