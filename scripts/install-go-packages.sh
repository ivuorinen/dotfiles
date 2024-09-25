#!/usr/bin/env bash
# Install Go packages
#
# shellcheck source=shared.sh

echo "This file ($0) has been deprecated in favor of asdf. Please use asdf instead."
exit 0

eval "$DOTFILES/config/shared.sh"

# Enable verbosity with VERBOSE=1
VERBOSE="${VERBOSE:-0}"

msg_run "Installing go packages"

! x-have "go" && msg "go hasn't been installed yet." && exit 0

packages=(
  # A shell parser, formatter, and interpreter with bash support; includes shfmt
  mvdan.cc/sh/v3/cmd/shfmt@latest
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
  # Static checker for GitHub Actions workflow files
  github.com/rhysd/actionlint/cmd/actionlint@latest
  # simple terminal UI for git commands
  github.com/jesseduffield/lazygit@latest
  # Cleans up your $HOME from those pesky dotfiles
  github.com/doron-cohen/antidot@latest
)

# Function to install go packages
install_packages()
{
  for pkg in "${packages[@]}"; do
    # Trim spaces
    pkg=${pkg// /}
    # Skip comments
    if [[ ${pkg:0:1} == "#" ]]; then continue; fi

    msg_nested "Installing go package: $pkg"
    go install "$pkg"
    echo ""
  done
}

# Function to install completions and run actions for selected packages
post_install()
{
  msg_run "Installing completions for selected packages"

  if command -v git-profile &> /dev/null; then
    git-profile completion zsh > "$ZSH_CUSTOM_COMPLETION_PATH/_git-profile" \
      && msg_ok "Installed completions for git-profile"
  fi

  if command -v antidot &> /dev/null; then
    antidot update \
      && msg_ok "Updated antidot database"
  fi
}

# Function to clear go cache
clear_go_cache()
{
  msg_run "Clearing go cache"
  go clean -cache -modcache
}

main()
{
  install_packages
  post_install
  clear_go_cache
  msg_ok "Done"
}

main "$@"
