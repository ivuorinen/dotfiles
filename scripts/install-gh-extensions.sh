#!/usr/bin/env bash
# @description Install GitHub CLI extensions
#
# shellcheck source="shared.sh"
source "${DOTFILES}/config/shared.sh"

# Enable verbosity with VERBOSE=1
VERBOSE="${VERBOSE:-0}"

msgr run "Installing gh (GitHub Client) extensions"

if ! command -v gh &> /dev/null; then
  msgr err "gh (GitHub Client) could not be found, please install it first"
  exit 0
fi

extensions=(
  # GitHub CLI extension for generating a report on repository dependencies.
  andyfeller/gh-dependency-report
  # GitHub CLI extension to generate montage from GitHub user avatars
  andyfeller/gh-montage
  # An opinionated GitHub Cli extension for creating
  # changelogs that adhere to the keep a changelog specification.
  chelnak/gh-changelog
  # Safely deletes local branches with no upstream and no un-pushed commits
  davidraviv/gh-clean-branches
  # A beautiful CLI dashboard for GitHub 🚀
  dlvhdr/gh-dash
  # A github-cli extension script to clone all repositories
  # in an organization, optionally filtering by topic.
  matt-bartel/gh-clone-org
  # being an extension to view the overall health of
  # an organization's use of actions
  rsese/gh-actions-status
)

# Function to install GitHub CLI extensions
install_extensions()
{
  for ext in "${extensions[@]}"; do
    # Trim spaces
    ext=${ext// /}
    # Skip comments
    if [[ ${ext:0:1} == "#" ]]; then continue; fi

    msgr nested "Installing $ext"
    gh extension install "$ext"
    echo ""
  done
}

main()
{
  install_extensions
  msgr run_done "Done"
}

main "$@"
