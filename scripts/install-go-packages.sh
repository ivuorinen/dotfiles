#!/usr/bin/env bash
# Install Go packages
#
# shellcheck source=shared.sh
source "$HOME/.dotfiles/scripts/shared.sh"

have go && {
  packages=(
    # sysadmin/scripting utilities, distributed as a single binary
    github.com/skx/sysbox@latest
    # Git Profile allows you to switch between user profiles in git repos
    github.com/dotzero/git-profile@latest
    # An extensible command line tool or library to format yaml files.
    github.com/google/yamlfmt/cmd/yamlfmt@latest
    # Parsing HTML at the command line
    github.com/ericchiang/pup@latest
    # HTML to Markdown converter
    github.com/suntong/html2md@latest
    # cheat allows you to create and view interactive cheatsheets on the cli.
    github.com/cheat/cheat/cmd/cheat@latest
    # Render markdown on the CLI, with pizzazz! 💅
    github.com/charmbracelet/glow@latest
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
} || msg "go hasn't been installed yet."
