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
  logger::error "usage CLI not found. Install with: mise use -g usage"
  exit "$LIB_E_COMMAND_NOT_FOUND"
fi

count=0
errors=0

generate_for_spec()
{
  local spec="$1"
  local bin_name="$2"

  logger::info "Generating for: $bin_name"

  # Completions
  if usage generate completion fish "$bin_name" -f "$spec" > "$FISH_DIR/$bin_name.fish" 2>&1; then
    :
  else
    logger::warn "fish completion failed for $bin_name"
    rm -f "$FISH_DIR/$bin_name.fish"
    ((errors++)) || true
  fi

  if usage generate completion bash "$bin_name" -f "$spec" > "$BASH_DIR/$bin_name.bash" 2>&1; then
    :
  else
    logger::warn "bash completion failed for $bin_name"
    rm -f "$BASH_DIR/$bin_name.bash"
    ((errors++)) || true
  fi

  if usage generate completion zsh "$bin_name" -f "$spec" > "$ZSH_DIR/_$bin_name" 2>&1; then
    :
  else
    logger::warn "zsh completion failed for $bin_name"
    rm -f "$ZSH_DIR/_$bin_name"
    ((errors++)) || true
  fi

  # Markdown docs
  if usage generate markdown -f "$spec" --out-file "$MD_DIR/$bin_name.md" 2>&1; then
    :
  else
    logger::warn "markdown generation failed for $bin_name"
    rm -f "$MD_DIR/$bin_name.md"
    ((errors++)) || true
  fi

  # Manpages
  if usage generate manpage -f "$spec" --out-file "$MAN_DIR/$bin_name.1" 2>&1; then
    :
  else
    logger::warn "manpage generation failed for $bin_name"
    rm -f "$MAN_DIR/$bin_name.1"
    ((errors++)) || true
  fi

  ((count++)) || true
}

generate_docs_only()
{
  local spec="$1"
  local bin_name="$2"

  logger::info "Generating docs for: $bin_name"

  if usage generate markdown -f "$spec" --out-file "$MD_DIR/$bin_name.md" 2>&1; then
    :
  else
    logger::warn "markdown generation failed for $bin_name"
    rm -f "$MD_DIR/$bin_name.md"
    ((errors++)) || true
  fi

  if usage generate manpage -f "$spec" --out-file "$MAN_DIR/$bin_name.1" 2>&1; then
    :
  else
    logger::warn "manpage generation failed for $bin_name"
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
    x) continue ;; # hand-crafted completion; docs generated below
    *) ;;
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

# x: generate docs + manpage only — fish completion is hand-crafted in
# config/fish/completions/x.fish because subcommands are discovered dynamically.
if [[ -f "$DOTFILES/local/bin/x" ]]; then
  generate_docs_only "$DOTFILES/local/bin/x" "x"
fi

# Process scripts/ inline .sh specs (#USAGE directives embedded in script)
for spec in "$DOTFILES"/scripts/*.sh; do
  [[ -f "$spec" ]] || continue
  bin_name=$(basename "$spec")
  [[ "$bin_name" == "shared.sh" ]] && continue
  generate_for_spec "$spec" "$bin_name"
done

# Third-party tool completions (bash + zsh).
# The whitelisted fish completions in config/fish/completions/ come from each
# CLI's own completion output, not a usage spec, so they are committed as-is.
# Their bash/zsh peers live in the gitignored completions.d dirs and must be
# regenerated per host. Snapshot them from whatever tools this host actually
# has (guarded by command -v) so all three shells reach parity without
# committing host-specific output. The tool list is derived from the tracked
# fish completions, so whitelisting a new fish file is the only step needed to
# pick it up here too. Fish itself is left untouched — it is the source of truth.
while IFS= read -r fish_comp; do
  tool=$(basename "$fish_comp" .fish)
  case "$tool" in
    # fisher is a fish-only plugin manager; x is the repo dispatcher whose
    # completion is hand-crafted (docs-only above). Neither has bash/zsh output.
    fisher | x) continue ;;
    *) ;;
  esac
  command -v "$tool" > /dev/null 2>&1 || continue
  logger::info "Third-party completions: $tool"
  for shell in bash zsh; do
    if [[ "$shell" == "bash" ]]; then
      out="$BASH_DIR/$tool.bash"
    else
      out="$ZSH_DIR/_$tool"
    fi
    # CLIs disagree on the subcommand name; try the known spellings in order
    # (cobra `completion`, mise `completions`, bob `complete`, wezterm
    # `shell-completion`) and keep the first that emits a non-empty result.
    if "$tool" completion "$shell" > "$out" 2> /dev/null && [[ -s "$out" ]]; then
      :
    elif "$tool" completions "$shell" > "$out" 2> /dev/null && [[ -s "$out" ]]; then
      :
    elif "$tool" complete "$shell" > "$out" 2> /dev/null && [[ -s "$out" ]]; then
      :
    elif "$tool" shell-completion --shell "$shell" > "$out" 2> /dev/null && [[ -s "$out" ]]; then
      :
    else
      rm -f "$out"
      logger::warn "no $shell completion command worked for $tool"
    fi
  done
done < <(git -C "$DOTFILES" ls-files config/fish/completions/)

logger::info "Done: processed $count specs ($errors warnings)"

if ((errors > 0)); then
  exit "$LIB_E_EXECUTION_FAILED"
fi
