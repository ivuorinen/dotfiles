# shellcheck shell=bash
# Shared path predicates for the PreToolUse guards. Sourced, never executed.
#
# One copy of the protected-path list and the secrets predicate, because the
# hand-kept copies in pre-edit-block.sh, pre-ctx-write-guard.sh and the rule
# prose drifted apart repeatedly (N-091, audit-2631ff95, audit-19fe64a4).
# tests/protected-paths-parity.bats checks every `paths:` entry in
# .claude/rules/vendored-files.md against the three hooks that source this.

# Vendored files, lock files and submodule trees: never edited in place. The
# list is the source; PROTECTED_RE and the glob check below are both built from
# it, so a path is added in one place.
PROTECTED_PATHS=(
  yarn.lock
  .yarn
  tools/dotbot
  tools/dotbot-include
  tools/antidote
  config/cheat/cheatsheets/community
  config/cheat/cheatsheets/tldr
  config/fish/functions/fisher.fish
  config/fish/functions/bass.fish
  config/fish/functions/__bass.py
  config/fish/functions/__z_add.fish
  config/fish/functions/__z_clean.fish
  .claude/skills/graphify
  # Not vendored, but a write to either switches off the hook chain without
  # any flag the bypass scan can see: removing .git/hooks/commit-msg, or a
  # hooksPath line appended to .git/config (agent-loopholes-63eb3265).
  .git/hooks
  .git/config
)

# Unanchored on the left so it matches absolute paths (Edit/Write payloads) and
# relative ones (Bash and sandbox code). The right edge is bounded so
# `tools/dotbot` does not also claim a sibling such as `tools/dotbotx`.
# shellcheck disable=SC2034 # consumed by the scripts that source this file
PROTECTED_RE="($(printf '%s\n' "${PROTECTED_PATHS[@]}" | sed 's/\./\\./g' | paste -sd '|' -))([^[:alnum:]._-]|\$)"

# Path normalisation applied before either predicate matches. Each step closes a
# spelling that named a protected file without the literal string
# (agent-loopholes-88c3bb49, agent-loopholes-6cb6e566):
#   - lower-case: macOS APFS is case-insensitive, so ./YARN.LOCK is yarn.lock
#   - quotes and backslashes dropped: the shell removes them (secre""ts.d)
#   - a brace expansion becomes `*`, so the glob check below sees it
#   - `//`, `/./`, a leading `./` and `dir/../` collapse lexically
_PP_NORM_SED='
s/\{[^}]*\}/*/g
s#/+#/#g
:dot
s#/\./#/#
t dot
s#(^|[[:space:]=])\./#\1#g
:up
s#[^/[:space:]]+/\.\./##
t up
'

# _pp_normalise TEXT [parsed] — with `parsed`, TEXT comes from the shell
# parser in bash-policy.sh, which already removed quoting and escapes. Its
# remaining quotes and backslashes are literal characters: the regex argument
# in `rg 'secrets\.d' docs` names no path, and stripping its backslash turned
# it into one (agent-hooks-84fa86e9).
_pp_normalise()
{
  if [[ ${2:-} == parsed ]]; then
    printf '%s\n' "$1" | tr '[:upper:]' '[:lower:]' | sed -E "$_PP_NORM_SED"
    return 0
  fi
  printf '%s\n' "$1" | tr '[:upper:]' '[:lower:]' | tr -d "\"'\\\\" | sed -E "$_PP_NORM_SED"
}

# _pp_glob_hits TEXT PATH... — succeed when a token in TEXT carrying a glob
# metacharacter (`*`, `?`, `[`) could expand to one of PATHs.
#
# The literal predicates match text the hook sees, but the shell expands globs
# afterwards: `secret?.d` and `yarn.l?ck` name the protected files without the
# literal string (agent-loopholes-6cb6e566). Each token is split on `/` and
# compared component-wise against each PATH, with the token's component as the
# pattern (`[[ secrets.d == secret?.d ]]`), at every offset so a leading
# directory prefix does not matter.
#
# At least one compared component must carry a literal character. A component
# made only of `*`/`?` matches every name, and allowing it alone would refuse
# `rm build/*` for matching yarn.lock. So `tools/*` still counts (the `tools`
# component is literal) while a bare `*` does not.
#
# ponytail: a bare `*` in the protected directory itself (`cd tools; rm -rf *`)
# and names built from variables or command substitution are not seen; text
# matching cannot resolve them.
_pp_glob_hits()
{
  local text=$1 tok want_path i j k n m ok literal tail
  local -a comps want
  shift
  while IFS= read -r tok; do
    IFS=/ read -ra comps <<< "$tok"
    n=${#comps[@]}
    for want_path in "$@"; do
      IFS=/ read -ra want <<< "$want_path"
      m=${#want[@]}
      for ((i = 0; i + m <= n; i++)); do
        ok=1
        literal=0
        for ((j = 0; j < m; j++)); do
          # shellcheck disable=SC2053 # the token is the pattern on purpose
          if [[ ${want[j]} != ${comps[i + j]} ]]; then
            ok=0
            break
          fi
          [[ ${comps[i + j]} == *[!*?]* ]] && literal=1
          # A wildcard-only component standing for `secrets.d` counts only
          # when a literal file name follows it (`config/fish/*/github.fish`).
          # `ls config/*`, `fish_indent --write config/fish/*/*.fish` and the
          # Glob `config/fish/**/*.fish` were refused as secrets reads
          # (agent-hooks-84fa86e9). ponytail: `cat config/fish/*/*.fish`
          # passes too, since it is the same token shape.
          if [[ ${want[j]} == secrets.d && ${comps[i + j]} != *[!*?]* ]]; then
            tail=0
            for ((k = i + j + 1; k < n; k++)); do
              if [[ ${comps[k]} == *[*?[]* ]]; then
                tail=0
                break
              fi
              tail=1
            done
            if ((tail == 0)); then
              ok=0
              break
            fi
          fi
        done
        if [[ $ok -eq 1 && $literal -eq 1 ]]; then
          return 0
        fi
      done
    done
  done < <(printf '%s\n' "$text" | grep -oE '[^[:space:];|&<>()`=]*[*?[][^[:space:];|&<>()`=]*')
  return 1
}

# protected_referenced TEXT — succeed when TEXT names a protected path, by
# literal spelling or by a glob that could expand to one.
protected_referenced()
{
  local text
  text=$(_pp_normalise "$1")
  [[ "$text" =~ $PROTECTED_RE ]] && return 0
  _pp_glob_hits "$text" "${PROTECTED_PATHS[@]}"
}

# secrets_referenced TEXT — succeed when TEXT names a secrets.d tree or any
# file in one other than a `*.example` template or README.md.
#
# Covers both credential trees — config/fish/secrets.d/ (fish) and
# config/secrets.d/ (bash/zsh) — because the fish-only predicates it replaces
# left the .sh tree unguarded (agent-loopholes-da375736). A bare directory, a
# glob (`secrets.d/*.fish`) or a variable (`secrets.d/$f`) all count: each
# expands to real secret files at run time. A glob in the tree's own name
# (`secret?.d`, `config/fish/*/github.fish`) counts too, via _pp_glob_hits.
#
# The matches are captured before the exemption filter runs: piping grep -o
# straight into grep -q lets the reader exit early, and under a caller's
# `set -o pipefail` the writer's SIGPIPE would turn a hit into a miss.
#
# With a second argument `parsed`, TEXT is parser output and keeps its literal
# quotes and backslashes (see _pp_normalise); a quote then ends a path, as in
# `open("config/secrets.d/x.example")`.
secrets_referenced()
{
  local text refs
  text=$(_pp_normalise "$1" "${2:-}")
  if refs=$(printf '%s\n' "$text" | grep -oE 'secrets\.d(/[^[:space:]`;|&<>()"'"'"']*)?'); then
    printf '%s\n' "$refs" | grep -qvE '^secrets\.d/([[:alnum:]._-]+\.example|readme\.md)$' && return 0
  fi
  _pp_glob_hits "$text" secrets.d config/secrets.d fish/secrets.d
}
