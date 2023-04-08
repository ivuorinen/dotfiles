#!/usr/bin/env bash
# Install Go packages
#
# shellcheck source=shared.sh
source "$HOME/.dotfiles/scripts/shared.sh"

if ! command -v go &> /dev/null; then
  msg "go hasn't been installed yet."
else
  packages=(
    # sysadmin/scripting utilities, distributed as a single binary
    github.com/skx/sysbox@latest
    github.com/dotzero/git-profile@latest
    github.com/google/yamlfmt/cmd/yamlfmt@latest
    github.com/ericchiang/pup@latest
    github.com/suntong/html2md@latest
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

fi
