#!/usr/bin/env zsh
# Install Go packages

source "$HOME/.dotfiles/scripts/shared.sh"

if ! command -v go &> /dev/null; then
  msg "go hasn't been installed yet."
  exit 0
fi

packages=(
  # sysadmin/scripting utilities, distributed as a single binary
  github.com/skx/sysbox@latest
)

for pkg in "${packages[@]}"; do
  # Trim spaces
  pkg=${pkg// /}
  # Skip comments
  if [[ ${pkg:0:1} == "#" ]]; then continue; fi

  msg_run "Installing go package:" "$pkg"
  go install "$pkg"
  echo ""
done

msg_ok "Done"
