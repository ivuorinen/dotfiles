#!/usr/bin/env bash
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
function all()
{
  lib::log "Installing all packages..."
  fonts
  brew
  cargo
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
function fonts()
{
  lib::log "Installing fonts..."
  # implement fonts installation
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
function brew()
{
  lib::log "Installing Homebrew..."
  # implement Homebrew installation
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
function cargo()
{
  lib::log "Installing Rust and cargo packages..."
  # implement Rust and cargo packages installation
}
