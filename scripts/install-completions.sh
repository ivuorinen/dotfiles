#!/usr/bin/env bash
# @description Generate shell completions, markdown docs, and manpages from usage specs
#
# Requires: usage (https://usage.jdx.dev/) installed via mise
# Generates: fish/bash/zsh completions, markdown docs, manpages

set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

# shellcheck source=shared.sh
source "$DOTFILES/scripts/shared.sh"

# Output directories
FISH_DIR="$DOTFILES/config/fish/completions"
BASH_DIR="$DOTFILES/config/bash/completions.d"
ZSH_DIR="$DOTFILES/config/zsh/completions.d"
MD_DIR="$DOTFILES/local/md"
MAN_DIR="$DOTFILES/local/man/man1"

# Ensure output directories exist
mkdir -p "$FISH_DIR" "$BASH_DIR" "$ZSH_DIR" "$MD_DIR" "$MAN_DIR"

# Check for usage CLI
if ! command -v usage &> /dev/null; then
  echo "Error: usage CLI not found. Install with: mise use -g usage" >&2
  exit 1
fi

count=0
errors=0

# Process all .usage.kdl files
for spec in "$DOTFILES"/local/bin/*.usage.kdl "$DOTFILES"/scripts/*.usage.kdl; do
  [[ -f "$spec" ]] || continue

  # Extract bin name from filename: foo.usage.kdl -> foo, install-foo.sh.usage.kdl -> install-foo.sh
  basename_spec=$(basename "$spec")
  bin_name="${basename_spec%.usage.kdl}"

  echo "Generating for: $bin_name"

  # Completions
  if usage generate completion fish "$bin_name" -f "$spec" > "$FISH_DIR/$bin_name.fish" 2>&1; then
    :
  else
    echo "  WARN: fish completion failed for $bin_name" >&2
    rm -f "$FISH_DIR/$bin_name.fish"
    ((errors++)) || true
  fi

  if usage generate completion bash "$bin_name" -f "$spec" > "$BASH_DIR/$bin_name.bash" 2>&1; then
    :
  else
    echo "  WARN: bash completion failed for $bin_name" >&2
    rm -f "$BASH_DIR/$bin_name.bash"
    ((errors++)) || true
  fi

  if usage generate completion zsh "$bin_name" -f "$spec" > "$ZSH_DIR/_$bin_name" 2>&1; then
    :
  else
    echo "  WARN: zsh completion failed for $bin_name" >&2
    rm -f "$ZSH_DIR/_$bin_name"
    ((errors++)) || true
  fi

  # Markdown docs
  if usage generate markdown -f "$spec" --out-file "$MD_DIR/$bin_name.md" 2>&1; then
    :
  else
    echo "  WARN: markdown generation failed for $bin_name" >&2
    rm -f "$MD_DIR/$bin_name.md"
    ((errors++)) || true
  fi

  # Manpages
  if usage generate manpage -f "$spec" --out-file "$MAN_DIR/$bin_name.1" 2>&1; then
    :
  else
    echo "  WARN: manpage generation failed for $bin_name" >&2
    rm -f "$MAN_DIR/$bin_name.1"
    ((errors++)) || true
  fi

  ((count++)) || true
done

echo ""
echo "Done: processed $count specs ($errors warnings)"

if ((errors > 0)); then
  exit 1
fi
