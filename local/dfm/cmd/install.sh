#!/usr/bin/env bash
# Installation functions for dfm, the dotfile manager
#
# @author Ismo Vuorinen <https://github.com/ivuorinen>
# @license MIT

# @description Install all packages in the correct order
function all()
{
  lib::log "Installing all packages..."
  fonts
  brew
  cargo
}

# @description Install fonts
function fonts()
{
  lib::log "Installing fonts..."
  # implement fonts installation
}

# Install Homebrew and set it up.
#
# @description Installs Homebrew
function brew()
{
  lib::log "Installing Homebrew..."
  # implement Homebrew installation
}

# @description Install Rust and cargo packages.
function cargo()
{
  lib::log "Installing Rust and cargo packages..."
  # implement Rust and cargo packages installation
}
