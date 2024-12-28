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
  asdf
}

# @description Install fonts
function fonts()
{
  lib::log "Installing fonts..."
  # implement fonts installation
}

# Install asdf and set it up.
#
# @description Install asdf
function asdf()
{
  lib::log "Installing asdf..."
  # implement asdf installation
}

# Install Homebrew and set it up.
#
# @description Installs Homebrew
function brew()
{
  lib::log "Installing Homebrew..."
  # implement Homebrew installation
}
