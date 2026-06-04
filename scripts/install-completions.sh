#!/usr/bin/env bash
# @description Generate shell completions, markdown docs, and manpages from usage specs
#USAGE about "Generate shell completions, markdown docs, and manpages from usage specs"
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

generate_for_spec()
{
  local spec="$1"
  local bin_name="$2"

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
}

# Process local/bin inline specs (#USAGE or //USAGE directives embedded in script)
for spec in "$DOTFILES"/local/bin/*; do
  [[ -f "$spec" ]] || continue
  grep -q '#USAGE\|//USAGE' "$spec" 2> /dev/null || continue
  bin_name=$(basename "$spec")
  # The dfm dispatcher and its dfm-* subcommands are handled by the
  # dedicated assembly step below: each dfm-* carries only a nested
  # "cmd <section> { ... }" fragment, which is not a valid standalone
  # root spec, so they must be stitched into one combined dfm spec
  # rather than generated individually.
  case "$bin_name" in
    dfm | dfm-*) continue ;;
  esac
  generate_for_spec "$spec" "$bin_name"
done

# Assemble the unified dfm dispatcher spec from per-subcommand fragments.
# Each dfm-* owns its own "cmd <section> { ... }" #USAGE subtree; stitched
# under the dispatcher's root directives (about/author + the dispatcher-
# level help command) they form one spec, so the single `dfm` completion,
# markdown, and manpage still cover every section.
if [[ -f "$DOTFILES/local/bin/dfm" ]]; then
  # The combined spec must be named "dfm" (usage derives the spec's
  # name/bin from the file's basename) and lead with a shebang (usage
  # only extracts #USAGE directives when the file looks like a script;
  # a file starting with #USAGE is parsed as raw KDL and rejected).
  dfm_spec_dir=$(mktemp -d)
  dfm_spec="$dfm_spec_dir/dfm"
  {
    printf '#!/usr/bin/env bash\n'
    # `|| true`: under `set -e` a grep with no match exits 1 and would abort
    # the whole generator. A dfm-* with no #USAGE simply contributes nothing.
    grep '^#USAGE' "$DOTFILES/local/bin/dfm" || true
    for section in install brew apt check dotfiles helpers docs scripts tests secrets cleanup; do
      sub="$DOTFILES/local/bin/dfm-$section"
      [[ -f "$sub" ]] || continue
      grep '^#USAGE' "$sub" || true
    done
  } > "$dfm_spec"
  generate_for_spec "$dfm_spec" "dfm"
  rm -rf "$dfm_spec_dir"
fi

# Process scripts/ inline .sh specs (#USAGE directives embedded in script)
for spec in "$DOTFILES"/scripts/*.sh; do
  [[ -f "$spec" ]] || continue
  bin_name=$(basename "$spec")
  [[ "$bin_name" == "shared.sh" ]] && continue
  generate_for_spec "$spec" "$bin_name"
done

echo ""
echo "Done: processed $count specs ($errors warnings)"

if ((errors > 0)); then
  exit 1
fi
