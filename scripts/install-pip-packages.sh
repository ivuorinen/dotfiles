#!/usr/bin/env bash
# Install python/pip packages.
#
# shellcheck source=shared.sh
source "$HOME/.dotfiles/scripts/shared.sh"

msg "Starting to install pip packages"

[[ $(x-have "python3") == "1" ]] && {
  msg_err "Could not find python3, something really weird is going on." && exit 1
}

msg_nested "Upgrading pip"
python3 -m pip install --user --upgrade pip

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
  python3 -m pip install --user --upgrade "$pkg"

  echo ""
done

msg_yay "Run pip package installations"
