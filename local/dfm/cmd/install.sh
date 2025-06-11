#!/usr/bin/env bash
set -euo pipefail

# Default paths can be overridden via environment variables
: "${DOTFILES:=$HOME/.dotfiles}"
: "${BREWFILE:=$DOTFILES/config/homebrew/Brewfile}"
: "${TEMP_DIR:=$(mktemp -d)}"
: "${DFM_MAX_RETRIES:=3}"

# Remove temp folder on exit
trap 'rm -rf "$TEMP_DIR"' EXIT

# Installation functions for dfm, the dotfile manager
#
# @author Ismo Vuorinen <https://github.com/ivuorinen>
# @license MIT

# Installs all required packages in the correct order.
#
# Description:
#   Orchestrates the installation process for the dotfile manager by sequentially invoking
#   the installation routines for fonts, Homebrew, and Rust (cargo). It logs the start of the
#   overall installation process before calling each respective function.
#
# Globals:
#   lib::log - Function used to log installation progress messages.
#
# Arguments:
#   None.
#
# Outputs:
#   Logs an informational message indicating the start of the installation process.
#
# Returns:
#   None.
#
# Example:
#   all
#
# @description
#   Parse command line options controlling installation steps.
parse_options()
{
  NO_AUTOMATION=0
  SKIP_FONTS=0
  SKIP_BREW=0
  SKIP_CARGO=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --no-automation)
        NO_AUTOMATION=1
        ;;
      --no-fonts)
        SKIP_FONTS=1
        ;;
      --no-brew)
        SKIP_BREW=1
        ;;
      --no-cargo)
        SKIP_CARGO=1
        ;;
      *)
        lib::error "Unknown option: $1"
        return 1
        ;;
    esac
    shift
  done
}

# @description
#   Install all configured components by calling each individual
#   installation routine unless skipped via options.
function all() {
  parse_options "$@"

  lib::log "Installing all packages..."

  if [[ $SKIP_FONTS -eq 0 ]]; then
    fonts
  fi

  if [[ $SKIP_BREW -eq 0 ]]; then
    brew
  fi

  if [[ $SKIP_CARGO -eq 0 ]]; then
    cargo
  fi
}

# Installs fonts required by the dotfile manager.
#
# Globals:
#   None.
#
# Arguments:
#   None.
#
# Outputs:
#   Logs a message to STDOUT indicating that the font installation process has started.
#
# Returns:
#   None.
#
# Example:
#   fonts
#
# @description Install all configured fonts from helper script, prompting the user unless automation is disabled.
function fonts() {

  : "${SKIP_FONTS:=0}"
  : "${NO_AUTOMATION:=0}"

  if [[ $SKIP_FONTS -eq 1 ]]; then
    lib::log "Skipping fonts installation"
    return 0
  fi

  if [[ $NO_AUTOMATION -eq 0 ]]; then
    utils::interactive::confirm "Install fonts?" || return 0
  fi

  lib::log "Installing fonts..."
  local script="${DOTFILES}/scripts/install-fonts.sh"

  if [[ ! -x "$script" ]]; then
    lib::error "Font installation script not found: $script"
    return 1
  fi

  bash "$script"
}

# Install Homebrew and set it up.
#
# Installs the Homebrew package manager on macOS.
#
# Globals:
#   lib::log - Logging utility used to report installation progress.
#
# Outputs:
#   Logs a message indicating the start of the Homebrew installation process.
#
# Example:
#   brew
#
# @description Install Homebrew and declared packages using the Brewfile.
function brew() {

  : "${SKIP_BREW:=0}"
  : "${NO_AUTOMATION:=0}"


  if [[ $SKIP_BREW -eq 1 ]]; then
    lib::log "Skipping Homebrew installation"
    return 0
  fi

  if [[ $NO_AUTOMATION -eq 0 ]]; then
    utils::interactive::confirm "Install Homebrew packages?" || return 0
  fi

  lib::log "Installing Homebrew..."
  if ! utils::is_installed brew; then
    lib::log "Homebrew not found, installing..."

    local installer="$TEMP_DIR/homebrew-install.sh"
    utils::retry "$DFM_MAX_RETRIES" \
      curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh \
      -o "$installer"

    NONINTERACTIVE=1 bash "$installer"
  fi

  if utils::is_installed brew; then
    brew bundle install --file="$BREWFILE" --force --quiet
  else
    lib::error "Homebrew installation failed"
    return 1
  fi
}

# Installs Rust and cargo packages.
#
# Description:
#   Logs the start of the installation process for Rust and cargo packages.
#   The installation logic is intended to be implemented where indicated.
#
# Globals:
#   Uses lib::log for logging the installation process.
#
# Example:
#   cargo
#
# @description Install Rust tooling and cargo packages using helper scripts.
function cargo() {

  : "${SKIP_CARGO:=0}"
  : "${NO_AUTOMATION:=0}"


  if [[ $SKIP_CARGO -eq 1 ]]; then
    lib::log "Skipping Rust and cargo installation"
    return 0
  fi

  if [[ $NO_AUTOMATION -eq 0 ]]; then
    utils::interactive::confirm "Install Rust and cargo packages?" || return 0
  fi

  lib::log "Installing Rust and cargo packages..."
  if ! utils::is_installed cargo; then
    lib::log "Rust not found, installing rustup..."

    local installer="$TEMP_DIR/rustup-init.sh"
    utils::retry "$DFM_MAX_RETRIES" \
      curl https://sh.rustup.rs -sSf -o "$installer"
    sh "$installer" -y
    source "$HOME/.cargo/env"
  fi

  local script="${DOTFILES}/scripts/install-cargo-packages.sh"
  if [[ -x "$script" ]]; then
    bash "$script"
  else
    lib::error "Cargo packages script not found: $script"
    return 1
  fi
}
