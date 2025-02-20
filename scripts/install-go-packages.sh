#!/usr/bin/env bash
# @description Install Go packages
#
# shellcheck source=shared.sh
source "$DOTFILES/config/shared.sh"

# Enable verbosity with VERBOSE=1
VERBOSE="${VERBOSE:-0}"

msgr run "Installing go packages"

! x-have "go" && msgr err "go hasn't been installed yet." && exit 0

[[ -z "$ASDF_GOLANG_DEFAULT_PACKAGES_FILE" ]] && \
  ASDF_GOLANG_DEFAULT_PACKAGES_FILE="$DOTFILES/config/asdf/golang-packages"

# Packages are defined in $DOTFILES/config/asdf/golang-packages, one per line
# Skip comments and empty lines
packages=()
if [[ -f "$ASDF_GOLANG_DEFAULT_PACKAGES_FILE" ]]; then
  while IFS= read -r line; do
    # Skip comments
    if [[ ${line:0:1} == "#" ]]; then continue; fi
    if [[ ${line:0:1} == "/" ]]; then continue; fi
    # Skip empty lines
    if [[ -z "$line" ]]; then continue; fi
    packages+=("$line")
  done < "$ASDF_GOLANG_DEFAULT_PACKAGES_FILE"
fi

# Function to install go packages
install_packages()
{
  for pkg in "${packages[@]}"; do
    # Trim spaces
    pkg=${pkg// /}
    # Skip comments
    if [[ ${pkg:0:1} == "#" ]]; then continue; fi

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

  if command -v antidot &> /dev/null; then
    antidot update \
      && msgr run_done "Updated antidot database"
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
