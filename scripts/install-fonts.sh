#!/usr/bin/env bash
set -euo pipefail
# @description Install fonts from GitHub releases (cross-platform)

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

# shellcheck source=../config/shared.sh
source "${DOTFILES}/config/shared.sh"

# ── Font Registry ──────────────────────────────────────────────
# Format: display_name|check_pattern|github_repo|version|asset_pattern
# Add new fonts by appending a line to this array.
FONTS=(
  "JetBrainsMono NF|JetBrainsMonoNL|ryanoasis/nerd-fonts|latest|JetBrainsMono.zip"
  "OpenDyslexic NF|OpenDyslexic|ryanoasis/nerd-fonts|latest|OpenDyslexic.zip"
  "Monaspace|Monaspace|githubnext/monaspace|latest|monaspace-*.zip"
  "FiraCode|FiraCode|tonsky/FiraCode|latest|Fira_Code_*.zip"
)

# ── Configuration ──────────────────────────────────────────────
FORCE=0

# Detect font directory per OS
detect_font_dir()
{
  case "$(uname -s)" in
    Darwin)
      echo "$HOME/Library/Fonts"
      ;;
    *)
      echo "${HOME}/.local/share/fonts"
      ;;
  esac
}

FONT_DIR="$(detect_font_dir)"

# ── Usage ──────────────────────────────────────────────────────
usage()
{
  cat << EOF
Usage: $(basename "$0") [--force] [--help]

Install fonts from GitHub releases.

Options:
  --force    Re-download and reinstall all fonts
  --help     Show this help message
EOF
  exit 0
}

# ── GitHub API ─────────────────────────────────────────────────
# Fetch latest release JSON from GitHub API.
# Prefers gh CLI (handles auth/rate limits), falls back to curl.
# $1 - github repo (owner/repo)
fetch_release_json()
{
  local repo="$1"
  if command -v gh > /dev/null 2>&1; then
    gh api "repos/${repo}/releases/latest" 2> /dev/null
  else
    curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" 2> /dev/null
  fi
}

# Find asset download URL matching a glob pattern.
# $1 - release JSON (stdin or string)
# $2 - asset glob pattern
find_asset_url()
{
  local json="$1"
  local pattern="$2"

  # Extract asset names and URLs, find matching pattern
  echo "$json" \
    | grep -o '"browser_download_url":\s*"[^"]*"' \
    | sed 's/"browser_download_url":\s*"//;s/"$//' \
    | while IFS= read -r url; do
      local name
      name="$(basename "$url")"
      # shellcheck disable=SC2254
      case "$name" in
        $pattern)
          echo "$url"
          return 0
          ;;
      esac
    done
}

# ── Font Installation ──────────────────────────────────────────
# Check if a font is already installed.
# $1 - check pattern glob
is_font_installed()
{
  local pattern="$1"
  # shellcheck disable=SC2086
  compgen -G "${FONT_DIR}/${pattern}"* > /dev/null 2>&1
}

# Install a single font from GitHub releases.
# $1 - display name
# $2 - check pattern
# $3 - github repo
# $4 - version (currently only "latest" supported)
# $5 - asset pattern
install_font()
{
  local name="$1"
  local check="$2"
  local repo="$3"
  local version="$4"
  local asset_pat="$5"

  # Check if already installed
  if [[ "$FORCE" -eq 0 ]] && is_font_installed "$check"; then
    msgr msg "$name — already installed, skipping"
    return 0
  fi

  msgr run "Installing $name from $repo..."

  # Fetch release info
  local json
  json=$(fetch_release_json "$repo") || {
    msgr warn "Failed to fetch release info for $repo — skipping"
    return 0
  }

  # Find download URL
  local url
  url=$(find_asset_url "$json" "$asset_pat") || true
  if [[ -z "$url" ]]; then
    msgr err "No asset matching '$asset_pat' in $repo release"
    return 0
  fi

  # Download to temp dir
  local tmp_dir
  tmp_dir=$(mktemp -d)
  local zip_file="${tmp_dir}/font.zip"

  curl -fsSL -o "$zip_file" "$url" || {
    msgr warn "Failed to download $url — skipping"
    rm -rf "$tmp_dir"
    return 0
  }

  # Extract font files
  mkdir -p "$FONT_DIR"
  local extract_dir="${tmp_dir}/extracted"
  unzip -qo "$zip_file" -d "$extract_dir" || {
    msgr warn "Failed to extract $zip_file — skipping"
    rm -rf "$tmp_dir"
    return 0
  }

  # Copy font files (flatten nested dirs)
  local count=0
  while IFS= read -r -d '' font_file; do
    cp "$font_file" "$FONT_DIR/"
    ((count++)) || true
  done < <(find "$extract_dir" -type f \
    \( -iname '*.ttf' -o -iname '*.otf' -o -iname '*.woff2' \) \
    -print0)

  # Clean up
  rm -rf "$tmp_dir"

  if [[ "$count" -gt 0 ]]; then
    msgr run_done "$name — installed $count font files"
  else
    msgr warn "$name — no font files found in archive"
  fi
}

# ── Main ───────────────────────────────────────────────────────
main()
{
  # Parse arguments
  for arg in "$@"; do
    case "$arg" in
      --force)
        FORCE=1
        ;;
      --help | -h)
        usage
        ;;
      *)
        msgr err "Unknown option: $arg"
        usage
        ;;
    esac
  done

  # Check dependencies
  for cmd in curl unzip; do
    if ! command -v "$cmd" > /dev/null 2>&1; then
      msgr err "$cmd is required but not installed"
      exit 1
    fi
  done

  msgr run "Installing fonts to $FONT_DIR"

  # Process each font
  for entry in "${FONTS[@]}"; do
    IFS='|' read -r name check repo version asset_pat <<< "$entry"
    install_font "$name" "$check" "$repo" "$version" "$asset_pat"
  done

  # Refresh font cache on Linux
  if [[ "$(uname -s)" != "Darwin" ]] && command -v fc-cache > /dev/null 2>&1; then
    msgr run "Refreshing font cache..."
    fc-cache -f
    msgr run_done "Font cache refreshed"
  fi

  msgr yay "Font installation complete!"
}

main "$@"
