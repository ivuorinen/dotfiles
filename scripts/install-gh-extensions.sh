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
# installed versions; install_extensions reinstalls any that differ.
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

# Install each extension at its pinned version. `gh extension install` exits 0
# for an extension that is already installed without applying --pin, so an
# installed one at another version is removed first. `gh extension list` prints
# "gh <name>\t<owner/repo>\t<version>", the version being the release tag or
# the first 8 characters of the commit for a script extension. A failed
# remove or install is reported and the rest still run; the function then
# returns 1, because main calls it in an && list, where set -e does not stop
# on a failure and only the return value reaches the exit status.
install_extensions()
{
  local entry repo pin installed version failed=0
  installed="$(gh extension list 2> /dev/null || true)"
  for entry in "${extensions[@]}"; do
    read -r repo pin <<< "$entry"
    version="$(awk -F '\t' -v repo="$repo" '$2 == repo { print $3 }' <<< "$installed")"
    if [[ "$version" == "$pin" || "$version" == "${pin:0:8}" ]]; then
      msgr nested "$repo already at $version"
      continue
    fi
    if [[ -n "$version" ]]; then
      msgr nested "Replacing $repo $version with $pin"
      gh extension remove "${repo#*/gh-}" || {
        msgr err "Failed to remove $repo"
        failed=1
        continue
      }
    fi
    msgr nested "Installing $repo@$pin"
    gh extension install "$repo" --pin "$pin" || {
      msgr err "Failed to install $repo"
      failed=1
    }
    echo ""
  done
  return "$failed"
}

# Install all GitHub CLI extensions
main()
{
  install_extensions \
    && msgr run_done "Done"
}

main "$@"
