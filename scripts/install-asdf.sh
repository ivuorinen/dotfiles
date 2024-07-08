#!/usr/bin/env bash
#
# Install asdf

source "${XDG_CONFIG_HOME}/shared"
source "${DOTFILES}/scripts/shared.sh"

# Installation variables
ASDF_GIT="https://github.com/asdf-vm/asdf.git"
ASDF_PATH="${XDG_DATA_HOME}/asdf"

if [ ! -d "$ASDF_PATH" ]; then
  git clone --depth 1 "$ASDF_GIT" "$ASDF_PATH" \
    --branch v0.14.0

  msg_done "asdf ($ASDF_PATH/) installed"
else
  msg_done "asdf ($ASDF_PATH/) already installed"
fi

export PATH="${ASDF_PATH}/bin:$PATH"

msg "Sourcing asdf in your shell"
. "$ASDF_PATH/asdf.sh"

# Update asdf, and plugins
asdf update

asdf plugin add asdf-plugin-manager https://github.com/asdf-community/asdf-plugin-manager.git
asdf install asdf-plugin-manager latest
asdf global asdf-plugin-manager "$(asdf latest asdf-plugin-manager)"
asdf-plugin-manager version
asdf-plugin-manager add-all

asdf install

# ASDF_INSTALLABLES=(
#     "nodejs:github.com/asdf-vm/asdf-nodejs.git"
#     "1password-cli:github.com/NeoHsu/asdf-1password-cli.git"
#     "age:github.com/threkk/asdf-age.git"
#     "bottom:github.com/carbonteq/asdf-btm.git"
#     "dotenv-linter:github.com/wesleimp/asdf-dotenv-linter.git"
#     "editorconfig-checker:github.com/gabitchov/asdf-editorconfig-checker.git"
#     "eza:github.com/lwiechec/asdf-eza.git"
#     "fd:gitlab.com/wt0f/asdf-fd.git"
#     "github-cli:github.com/bartlomiejdanek/asdf-github-cli.git"
#     "hadolint:github.com/devlincashman/asdf-hadolint.git"
#     "kubectl:github.com/asdf-community/asdf-kubectl.git"
#     "lazygit:github.com/nklmilojevic/asdf-lazygit.git"
#     "pipx:github.com/yozachar/asdf-pipx.git"
#     "pre-commit:github.com/jonathanmorley/asdf-pre-commit.git"
#     "ripgrep:gitlab.com/wt0f/asdf-ripgrep.git"
#     "semgrep:github.com/brentjanderson/asdf-semgrep.git"
#     "terraform-ls:github.com/asdf-community/asdf-hashicorp.git"
#     "vault:github.com/asdf-community/asdf-hashicorp.git"
#     "shellcheck:github.com/luizm/asdf-shellcheck.git"
#     "shfmt:github.com/luizm/asdf-shfmt.git"
#     "terraform-lsp:github.com/bartlomiejdanek/asdf-terraform-lsp.git"
#     "terragrunt:github.com/ohmer/asdf-terragrunt.git"
#     "tf-summarize:github.com/adamcrews/asdf-tf-summarize.git"
#     "yamllint:github.com/ericcornelissen/asdf-yamllint.git"
#     "yq:github.com/sudermanjr/asdf-yq.git"
# )
#
# msg "Installing asdf plugins, if not already installed"
# for item in "${ASDF_INSTALLABLES[@]}"; do
#   CMD=$(echo "${item}" | awk -F ":" '{print $1}')
#   URL=$(echo "${item}" | awk -F ":" '{print $2}')
#   asdf plugin add "${CMD}" "https://${URL}"
#   asdf install "${CMD}" latest
#   asdf global "${CMD}" "$(asdf latest "${CMD}")"
# done

msg "Reshim asdf"
asdf reshim
