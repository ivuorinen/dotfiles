#!/usr/bin/env bash
# @description Install cargo/rust packages.

msgr run "Starting to install rust/cargo packages"

# If we have cargo install-update, use it first
if command -v cargo-install-update &> /dev/null; then
  msgr run "Updating cargo packages with cargo install-update"
  cargo install-update -a
  msgr run_done "Done with cargo install-update"
fi

[[ -z "$ASDF_CRATE_DEFAULT_PACKAGES_FILE" ]] \
  && ASDF_CRATE_DEFAULT_PACKAGES_FILE="$DOTFILES/config/asdf/cargo-packages"

# Packages are defined in $DOTFILES/config/asdf/cargo-packages, one per line
# Skip comments and empty lines
packages=()
while IFS= read -r line; do
  # Skip comments
  if [[ ${line:0:1} == "#" ]]; then continue; fi
  if [[ ${line:0:1} == "/" ]]; then continue; fi
  # Skip empty lines
  if [[ -z "$line" ]]; then continue; fi
  packages+=("$line")
done < "$ASDF_CRATE_DEFAULT_PACKAGES_FILE"

# Number of jobs to run in parallel, this helps to keep the system responsive
BUILD_JOBS=$(nproc --ignore=2 2> /dev/null || sysctl -n hw.ncpu 2> /dev/null || echo 1)

# Function to install cargo packages
install_packages()
{
  for pkg in "${packages[@]}"; do
    # Trim spaces
    pkg=${pkg// /}
    # Skip comments
    if [[ ${pkg:0:1} == "#" ]]; then continue; fi

    msgr run "Installing cargo package $pkg"
    cargo install --jobs $BUILD_JOBS "$pkg"
    msgr run_done "Done installing $pkg"
    echo ""
  done
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
  msgr done "Done removing cargo cache"
}

main()
{
  install_packages
  msgr done "Installed cargo packages!"
  post_install_steps
}

main "$@"
