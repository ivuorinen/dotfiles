#!/usr/bin/env bash
#
# Install asdf
source "${DOTFILES}/config/shared.sh"

export ASDF_DIR="${XDG_BIN_HOME}/asdf"
export PATH="${ASDF_DIR}/bin:$PATH"

msg "Sourcing asdf in your shell"
. "$ASDF_DIR/asdf.sh"

# Function to update asdf and plugins
update_asdf()
{
  asdf update

  asdf plugin add asdf-plugin-manager https://github.com/asdf-community/asdf-plugin-manager.git
  asdf install asdf-plugin-manager latest
  asdf global asdf-plugin-manager "$(asdf latest asdf-plugin-manager)"
  asdf-plugin-manager version
  asdf-plugin-manager add-all

  asdf install
}

ASDF_INSTALLABLES=(
  "1password-cli:github.com/NeoHsu/asdf-1password-cli.git"
  "age:github.com/threkk/asdf-age.git"
  "bottom:github.com/carbonteq/asdf-btm.git"
  "dotenv-linter:github.com/wesleimp/asdf-dotenv-linter.git"
  "editorconfig-checker:github.com/gabitchov/asdf-editorconfig-checker.git"
  "eza:github.com/lwiechec/asdf-eza.git"
  "fd:gitlab.com/wt0f/asdf-fd.git"
  "github-cli:github.com/bartlomiejdanek/asdf-github-cli.git"
  "golang:github.com/asdf-community/asdf-golang.git"
  "hadolint:github.com/devlincashman/asdf-hadolint.git"
  "kubectl:github.com/asdf-community/asdf-kubectl.git"
  "lazygit:github.com/nklmilojevic/asdf-lazygit.git"
  "nodejs:github.com/asdf-vm/asdf-nodejs.git"
  "pipx:github.com/yozachar/asdf-pipx.git"
  "pre-commit:github.com/jonathanmorley/asdf-pre-commit.git"
  "ripgrep:gitlab.com/wt0f/asdf-ripgrep.git"
  "semgrep:github.com/brentjanderson/asdf-semgrep.git"
  "shellcheck:github.com/luizm/asdf-shellcheck.git"
  "shfmt:github.com/luizm/asdf-shfmt.git"
  "terraform-ls:github.com/asdf-community/asdf-hashicorp.git"
  "terraform-lsp:github.com/bartlomiejdanek/asdf-terraform-lsp.git"
  "terragrunt:github.com/ohmer/asdf-terragrunt.git"
  "tf-summarize:github.com/adamcrews/asdf-tf-summarize.git"
  "vault:github.com/asdf-community/asdf-hashicorp.git"
  "yamllint:github.com/ericcornelissen/asdf-yamllint.git"
  "yq:github.com/sudermanjr/asdf-yq.git"
)

# Function to install asdf plugins
install_asdf_plugins()
{
  msg "Installing asdf plugins, if not already installed"
  for item in "${ASDF_INSTALLABLES[@]}"; do
    CMD=$(echo "${item}" | awk -F ":" '{print $1}')
    URL=$(echo "${item}" | awk -F ":" '{print $2}')
    asdf plugin add "${CMD}" "https://${URL}"
    asdf install "${CMD}" latest
    asdf global "${CMD}" "$(asdf latest "${CMD}")"
  done
}

main()
{
  update_asdf
  install_asdf_plugins
  msg "Reshim asdf"
  asdf reshim
}

main "$@"
