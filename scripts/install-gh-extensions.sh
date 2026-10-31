#!/usr/bin/env bash
set -euo pipefail
# @description Install GitHub CLI extensions
#USAGE about "Install GitHub CLI extensions"
#
# shellcheck source="shared.sh"
source "${DOTFILES}/config/shared.sh"

msgr run "Installing gh (GitHub Client) extensions"

# A missing gh is a skip, not a failure: say so in a warning, so the caller's
# success message does not follow an error.
if ! command -v gh &> /dev/null; then
  msgr warn "gh (GitHub Client) not found, skipping extensions"
  exit 0
fi

# "<owner/repo> <pin>" — each extension is third-party code that gh runs, so
# every entry is pinned: a release tag for binary extensions, a full commit
# SHA for script extensions (gh clones those). `gh extension list` shows the
# installed versions. gh leaves an installed extension alone, so a changed pin
# takes effect only after `gh extension remove <name>`.
extensions=(
  # Report on repository dependencies
  "andyfeller/gh-dependency-report v0.5.0"
  # Montage from GitHub user avatars
  "andyfeller/gh-montage 93491361febeab8038c95d3ca717e8b5d542a80e"
  # Changelogs in the keep-a-changelog format
  "chelnak/gh-changelog v0.15.3"
  # Delete local branches with no upstream and no unpushed commits
  "davidraviv/gh-clean-branches 85fcbd7e3d956b63a547f6c7de3f8aec2f96a7f8"
  # Terminal dashboard for pull requests and issues
  "dlvhdr/gh-dash v4.24.1"
  # Clone every repository in an organization, optionally by topic
  "matt-bartel/gh-clone-org ed1bec58e997a8ecb8a451ea6ac2ef1e91367487"
  # Health of an organization's GitHub Actions use
  "rsese/gh-actions-status v1.3.1"
)

# Install each extension at its pinned version
install_extensions()
{
  local entry repo pin
  for entry in "${extensions[@]}"; do
    read -r repo pin <<< "$entry"
    msgr nested "Installing $repo@$pin"
    gh extension install "$repo" --pin "$pin"
    echo ""
  done
  return 0
}

# Install all GitHub CLI extensions
main()
{
  install_extensions \
    && msgr run_done "Done"
  return 0
}

main "$@"
