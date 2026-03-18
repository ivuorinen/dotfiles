#!/usr/bin/env bash
set -euo pipefail
# @description Remove old version manager installations replaced by mise.
# This script targets specific known directories — NOT which/command -v,
# because nvim's Mason installs some of the same tool names.
#
# shellcheck source=shared.sh
source "$DOTFILES/config/shared.sh"

DRY_RUN="${1:-}"

remove_dir()
{
  local dir="$1"
  local label="$2"
  if [ -d "$dir" ]; then
    if [ "$DRY_RUN" = "--dry-run" ]; then
      msgr warn "[DRY RUN] Would remove $label: $dir"
    else
      msgr run "Removing $label: $dir"
      rm -rf "$dir"
      msgr run_done "Removed $label"
    fi
  else
    msgr ok "$label not found (already clean): $dir"
  fi
}

remove_file()
{
  local file="$1"
  local label="$2"
  if [ -f "$file" ]; then
    if [ "$DRY_RUN" = "--dry-run" ]; then
      msgr warn "[DRY RUN] Would remove $label: $file"
    else
      rm -f "$file"
      msgr run_done "Removed $label: $file"
    fi
  fi
}

msgr msg "Cleaning up old version manager installations..."
msgr msg "Mason binaries in \$XDG_DATA_HOME/nvim/mason/ will NOT be touched."

# --- Version manager data directories ---

# nvm (Node Version Manager)
remove_dir "$XDG_DATA_HOME/nvm" "nvm data"

# fnm (Fast Node Manager)
remove_dir "$XDG_DATA_HOME/fnm" "fnm data"

# pyenv
remove_dir "$XDG_DATA_HOME/pyenv" "pyenv data"

# goenv
remove_dir "$XDG_DATA_HOME/goenv" "goenv data"

# bob-nvim (neovim version manager — mise manages neovim now)
remove_dir "$XDG_DATA_HOME/bob" "bob-nvim data"

# --- Cargo-installed tool binaries ---
# These were installed via `cargo install` into $CARGO_HOME/bin.
# mise now manages them via ubi/cargo backends into its own install dirs.
# Only remove from the OLD cargo bin location, not from XDG_BIN_HOME.

CARGO_BIN="${XDG_DATA_HOME}/cargo/bin"
CARGO_MANAGED_TOOLS=(
  bkt bottom btm difft difftastic eza fd rg ripgrep
  tree-sitter tmux-sessionizer zoxide bob
  cargo-install-update cargo-cache
)
for tool in "${CARGO_MANAGED_TOOLS[@]}"; do
  remove_file "$CARGO_BIN/$tool" "cargo-installed $tool"
done

# --- Go-installed tool binaries ---
# go install puts binaries in $GOBIN (= $XDG_BIN_HOME) or $GOPATH/bin.
# Only remove from $GOPATH/bin if it differs from XDG_BIN_HOME.
GO_BIN="${XDG_DATA_HOME}/go/bin"
GO_MANAGED_TOOLS=(
  yamlfmt cheat glow fzf gum sesh git-profile
)
if [ "$GO_BIN" != "$XDG_BIN_HOME" ] && [ -d "$GO_BIN" ]; then
  for tool in "${GO_MANAGED_TOOLS[@]}"; do
    remove_file "$GO_BIN/$tool" "go-installed $tool"
  done
fi

# --- npm global binaries ---
# These were installed via `npm install -g` into the nvm/fnm node prefix.
# Since we removed nvm/fnm data dirs above, these are already gone.

# --- Python tools via uv tool ---
# uv tool binaries go to ~/.local/bin/ (XDG_BIN_HOME).
# mise pipx backend installs to a different location.
# We leave XDG_BIN_HOME alone and let mise take precedence via PATH.

# --- Homebrew-installed version managers ---
# These will be removed when `brew bundle cleanup` runs after Brewfile update.
if command -v brew &> /dev/null; then
  BREW_REMOVE=(
    pyenv pyenv-pip-migrate pyenv-virtualenv goenv cargo-binstall
    act age ansible ansible-lint awscli bat bats-core checkov
    choose-rust cmake gdu gh grype jq onefetch pinact shellcheck
    tfenv tflint tfsec uv virtualenv wakatime-cli
  )
  for pkg in "${BREW_REMOVE[@]}"; do
    if brew list "$pkg" &> /dev/null; then
      if [ "$DRY_RUN" = "--dry-run" ]; then
        msgr warn "[DRY RUN] Would brew uninstall $pkg"
      else
        msgr run "Uninstalling brew package: $pkg"
        brew uninstall --ignore-dependencies "$pkg" || true
        msgr run_done "Uninstalled $pkg"
      fi
    fi
  done
fi

msgr yay "Cleanup complete! Run 'mise install' to set up tools via mise."
