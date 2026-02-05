#!/usr/bin/env bash
set -euo pipefail
# @description Install Go packages
#
# shellcheck source=shared.sh
source "$DOTFILES/config/shared.sh"

# Enable verbosity with VERBOSE=1
VERBOSE="${VERBOSE:-0}"

msgr run "Installing go packages"

! x-have "go" && msgr err "go hasn't been installed yet." && exit 0

# Go packages to install
packages=(
  github.com/dotzero/git-profile@latest           # Switch between git user profiles
  github.com/google/yamlfmt/cmd/yamlfmt@latest     # Format yaml files
  github.com/cheat/cheat/cmd/cheat@latest          # Interactive cheatsheets on the CLI
  github.com/charmbracelet/glow@latest             # Render markdown on the CLI
  github.com/junegunn/fzf@latest                   # General-purpose fuzzy finder
  github.com/charmbracelet/gum@latest              # Glamorous shell scripts
  github.com/joshmedeski/sesh/v2@latest            # Terminal session manager
)

# Function to install go packages
install_packages()
{
  for pkg in "${packages[@]}"; do
    # Strip inline comments and trim whitespace
    pkg="${pkg%%#*}"
    pkg="${pkg// /}"
    [[ -z "$pkg" ]] && continue

    msgr nested "Installing go package: $pkg"
    go install "$pkg"
    echo ""
  done
}

# Function to install completions and run actions for selected packages
post_install()
{
  msgr run "Installing completions for selected packages"

  if command -v git-profile &> /dev/null; then
    git-profile completion zsh > "$ZSH_CUSTOM_COMPLETION_PATH/_git-profile" \
      && msgr run_done "Installed completions for git-profile"
  fi
}

# Function to clear go cache
clear_go_cache()
{
  msgr run "Clearing go cache"
  go clean -cache -modcache
}

main()
{
  install_packages
  post_install
  clear_go_cache
  msgr run_done "Done"
}

main "$@"
