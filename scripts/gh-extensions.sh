#!/usr/bin/env bash
# Install GitHub CLI extensions

if ! command -v gh &> /dev/null; then
  echo "gh (GitHub Client) could not be found, please install it first"
  exit 1
fi

extensions=(
  # GitHub CLI extension for reviewing Dependabot PRs.
  einride/gh-dependabot
  # A GitHub CLI extension that provides summary pull request metrics.
  hectcastro/gh-metrics
  # being an extension to view the overall health of an organization's use of actions
  rsese/gh-actions-status
  # GitHub CLI extension for label management
  heaths/gh-label
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
  # GitHub CLI extension to generate montage from GitHub user avatars
  andyfeller/gh-montage
  # Organisation specific extension for gh cli to retrieve different statistics
  VildMedPap/gh-orgstats
  # GitHub CLI extension for generating a report on repository dependencies.
  andyfeller/gh-dependency-report
  # gh cli extension to generate account/organization/enterprise reports
  stoe/gh-report
)

for ext in "${extensions[@]}"; do
  # Skip comments
  if [[ ${ext:0:1} == "#" ]]; then continue; fi

  echo "-> Installing $ext"
  gh extensions install "$ext"
done
