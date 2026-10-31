#!/usr/bin/env bash
set -euo pipefail
# @description Install herdr workflow plugins
#USAGE about "Install herdr workflow plugins"
#
# herdr has no declarative plugin manifest. Its registry (~/.config/herdr/
# plugins.json) records absolute paths and a resolved commit per plugin, so it
# is machine-local state, not a lockfile — syncing it through the dotfiles repo
# would carry one machine's paths onto another. This script is the portable
# half: the list of plugins to install. Each machine builds its own checkout
# under ~/.config/herdr/plugins/github/ at its own path.
#
# shellcheck source="shared.sh"
source "${DOTFILES}/config/shared.sh"

msgr run "Installing herdr plugins"

# A missing herdr is a skip, not a failure: say so in a warning.
if ! command -v herdr &> /dev/null; then
  msgr warn "herdr not found, skipping plugins"
  exit 0
fi

# "<plugin-id> <owner/repo> <ref>" — the id is what herdr registers, which is
# not always derivable from the repo name (kryptamine/herdr-auto-title
# registers as herdr.auto-title). Each plugin is built from source and run,
# so every entry is pinned: a tag where the project publishes one, otherwise
# a full commit SHA. `herdr plugin list --json` shows each plugin's
# requested_ref and resolved_commit.
plugins=(
  "herdr-navigator thanhdat77/herdr-navigator v0.3.6"
  "sessionizer andrewchng/herdr-sessionizer 9aba5d0e4e14eca1a6d5be0a69e828b8a72c0e5c"
  "branch-cleanup dutifuldev/herdr-branch-cleanup 8b6774e60008f971f16894e95d074caf9342d96b"
  "herdr.auto-title kryptamine/herdr-auto-title 636286baf931fa71966083d1e8294fc4a38f11fb"
)

install_plugins()
{
  local installed entry id repo ref

  # Reinstalling replaces the managed checkout and re-runs the build, which for
  # these Rust plugins is minutes of cargo. Ask once, then skip what is there.
  installed="$(herdr plugin list --json 2> /dev/null || echo '[]')"

  for entry in "${plugins[@]}"; do
    read -r id repo ref <<< "$entry"

    if grep -q "\"plugin_id\"[[:space:]]*:[[:space:]]*\"${id}\"" <<< "$installed"; then
      msgr nested "$id already installed, skipping"
      continue
    fi

    msgr nested "Installing $repo"
    herdr plugin install "$repo" ${ref:+--ref "$ref"} --yes
    echo ""
  done
  return 0
}

main()
{
  install_plugins \
    && msgr run_done "Done"
  return 0
}

main "$@"
