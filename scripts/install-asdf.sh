#!/usr/bin/env bash
#
# Install asdf and plugins I use
#
# It also updates asdf and the plugins, and then reshim asdf.
#
# Usage: ./install-asdf.sh [both|install|add_plugins]
# Author: Ismo Vuorinen <https://github.com/ivuorinen>
# License: MIT
#
source "${DOTFILES}/config/shared.sh"

export ASDF_DIR="${XDG_BIN_HOME}/asdf"
export PATH="${ASDF_DIR}/bin:$PATH"

msg "Sourcing asdf in your shell"
. "$ASDF_DIR/asdf.sh"

# Function to update asdf and plugins
update_asdf()
{
  asdf plugin add asdf-plugin-manager https://github.com/asdf-community/asdf-plugin-manager.git
  asdf install asdf-plugin-manager latest
  asdf global asdf-plugin-manager "$(asdf latest asdf-plugin-manager)"
  asdf-plugin-manager version
  asdf-plugin-manager add-all

  asdf install

  return 0
}

# Function to install asdf plugins
install_asdf_plugins()
{
  ASDF_INSTALLABLES=(
    "1password-cli:github.com/NeoHsu/asdf-1password-cli.git"
    "age:github.com/threkk/asdf-age.git"
    "bottom:github.com/carbonteq/asdf-btm.git"
    "direnv:github.com/asdf-community/asdf-direnv.git"
    "dotenv-linter:github.com/wesleimp/asdf-dotenv-linter.git"
    "editorconfig-checker:github.com/gabitchov/asdf-editorconfig-checker.git"
    "fd:gitlab.com/wt0f/asdf-fd.git"
    "github-cli:github.com/bartlomiejdanek/asdf-github-cli.git"
    "golang:github.com/asdf-community/asdf-golang.git"
    "hadolint:github.com/devlincashman/asdf-hadolint.git"
    "kubectl:github.com/asdf-community/asdf-kubectl.git"
    "nodejs:github.com/asdf-vm/asdf-nodejs.git"
    "pipx:github.com/yozachar/asdf-pipx.git"
    "pre-commit:github.com/jonathanmorley/asdf-pre-commit.git"
    "python:github.com/asdf-community/asdf-python.git"
    "ripgrep:gitlab.com/wt0f/asdf-ripgrep.git"
    "rust:github.com/code-lever/asdf-rust.git"
    "shellcheck:github.com/luizm/asdf-shellcheck.git"
    "shfmt:github.com/luizm/asdf-shfmt.git"
    "terragrunt:github.com/ohmer/asdf-terragrunt.git"
    "tf-summarize:github.com/adamcrews/asdf-tf-summarize.git"
    "yamllint:github.com/ericcornelissen/asdf-yamllint.git"
    "yq:github.com/sudermanjr/asdf-yq.git"
  )

  msg "Installing asdf plugins"
  for item in "${ASDF_INSTALLABLES[@]}"; do
    CMD=$(echo "${item}" | awk -F ":" '{print $1}')
    URL=$(echo "${item}" | awk -F ":" '{print $2}')

    asdf plugin add "${CMD}" "https://${URL}"
    asdf install "${CMD}" latest
    asdf global "${CMD}" "$(asdf latest "${CMD}")"
  done

  msg "Exporting asdf plugin versions"
  asdf-plugin-manager export > "${XDG_CONFIG_HOME}/asdf/plugin-versions"

  return 0
}

reshim()
{
  msg "Reshim asdf"
  asdf reshim
  return 0
}

# create usage function
usage()
{
  echo "Usage: $0 [both|install|add_plugins]"
  exit 1
}

main()
{
  case $1 in
    "both")
      install_asdf_plugins
      update_asdf
      reshim
      ;;
    "install")
      update_asdf
      reshim
      ;;
    "add_plugins")
      install_asdf_plugins
      reshim
      ;;
    *)
      usage
      ;;
  esac
}

main "$@"
