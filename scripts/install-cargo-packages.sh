#!/usr/bin/env bash
set -euo pipefail
# @description Install cargo/rust packages.
#
# shellcheck source=shared.sh
source "$DOTFILES/config/shared.sh"

msgr run "Starting to install rust/cargo packages"

# Track packages already managed by cargo install-update
declare -A installed_packages

# If we have cargo install-update, use it first
if command -v cargo-install-update &> /dev/null; then
  msgr run "Updating cargo packages with cargo install-update"
  # Show output in real-time (via stderr) while capturing it for parsing
  update_output=$(cargo install-update -a 2>&1 | tee /dev/stderr)
  msgr run_done "Done with cargo install-update"

  # Parse installed package names from the update output
  while IFS= read -r pkg_name; do
    [[ -n "$pkg_name" ]] && installed_packages["$pkg_name"]=1
  done < <(echo "$update_output" | awk '/v[0-9]+\.[0-9]+/ { print $1 }')
fi

# Cargo packages to install
packages=(
  cargo-update       # A cargo subcommand for checking and applying updates to installed executables
  cargo-cache        # Cargo cache management utility
  tree-sitter-cli    # An incremental parsing system for programming tools
  bkt                # A subprocess caching utility
  difftastic         # A structural diff that understands syntax
  fd-find            # A simple, fast and user-friendly alternative to 'find'
  ripgrep            # Recursively searches directories for a regex pattern while respecting your gitignore
  bob-nvim           # A version manager for neovim
  bottom             # A cross-platform graphical process/system monitor
  eza                # A modern alternative to ls
  tmux-sessionizer   # A tool for opening git repositories as tmux sessions
  zoxide             # A smarter cd command
)

# Number of jobs to run in parallel, this helps to keep the system responsive
BUILD_JOBS=$(nproc --ignore=2 2> /dev/null || sysctl -n hw.ncpu 2> /dev/null || echo 1)

# Function to install cargo packages
install_packages()
{
  for pkg in "${packages[@]}"; do
    # Skip packages already handled by cargo install-update
    if [[ -n "${installed_packages[$pkg]+x}" ]]; then
      msgr ok "Skipping $pkg (already installed)"
      continue
    fi

    msgr run "Installing cargo package $pkg"
    cargo install --jobs "$BUILD_JOBS" "$pkg"
    msgr run_done "Done installing $pkg"
    echo ""
  done
  return 0
}

# Function to perform additional steps for installed cargo packages
post_install_steps()
{
  msgr run "Now doing the next steps for cargo packages"

  # use bob to install latest stable nvim
  if command -v bob &> /dev/null; then
    bob use stable && x-path-append "$XDG_DATA_HOME/bob/nvim-bin"
  fi

  msgr run "Removing cargo cache"
  cargo cache --autoclean
  msgr "done" "Done removing cargo cache"
  return 0
}

# Install cargo packages and run post-install steps
main()
{
  install_packages
  msgr "done" "Installed cargo packages!"
  post_install_steps
  return 0
}

main "$@"
