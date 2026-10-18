#!/usr/bin/env bash
set -euo pipefail
# @description Remove arborist.nvim's leftover parsers, queries and state.
#USAGE about "Remove arborist.nvim leftovers so nvim-treesitter rebuilds its own parsers"
# arborist.nvim was replaced by nvim-treesitter (main) in #781. Its parsers and
# queries under site/ shadow the ones nvim-treesitter builds, so remove them
# along with its lock file and cache. nvim-treesitter installs into the same
# site/ directories, so its parsers go too; they rebuild on the next file open.
# Close every nvim before running.
#
# Ensure DOTFILES is set even when script is invoked directly
if [[ -z "${DOTFILES:-}" ]]; then
  DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
  export DOTFILES
fi
# shellcheck source=config/shared.sh
source "$DOTFILES/config/shared.sh"

readonly _DRY_RUN_FLAG='--dry-run'
DRY_RUN=""
if [[ $# -gt 1 ]]; then
  logger::error "Usage: $0 [--dry-run]"
  exit "$LIB_E_INVALID_ARGUMENT"
fi
if [[ $# -eq 1 ]]; then
  if [[ "$1" != "$_DRY_RUN_FLAG" ]]; then
    logger::error "Usage: $0 [--dry-run]"
    exit "$LIB_E_INVALID_ARGUMENT"
  fi
  DRY_RUN="$_DRY_RUN_FLAG"
fi

remove_path()
{
  local path="$1"
  if [[ ! -e "$path" ]]; then
    msgr ok "Not found (already clean): $path"
    return 0
  fi
  if [[ "$DRY_RUN" = "$_DRY_RUN_FLAG" ]]; then
    msgr warn "[DRY RUN] Would remove: $path"
  else
    rm -rf "$path"
    msgr run_done "Removed: $path"
  fi
  return 0
}

NVIM_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
NVIM_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/nvim"

msgr msg "Removing arborist.nvim leftovers..."
remove_path "$NVIM_DATA/site/parser"
remove_path "$NVIM_DATA/site/queries"
remove_path "$NVIM_DATA/arborist-lock.json"
remove_path "$NVIM_CACHE/arborist"

msgr yay "Done. Open nvim; nvim-treesitter installs parsers as files open."
