#!/usr/bin/env bats
#
# dfm-lib is the shared library every dfm-* subcommand sources. The
# bootstrap split is the part most likely to degrade silently: picking the
# expensive path for a menu invocation only makes `dfm` slow, and picking
# the cheap path for a real action leaves the subcommand without the
# environment config/exports provides. Neither failure produces an error.
#
# dfm_bootstrap_for's branch is tested by stubbing the two bootstrap
# functions and asserting which one fires — the dispatch decision is the
# contract, and observing it through environment side effects would test
# config/exports instead.

setup()
{
  DOTFILES="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  export DOTFILES
  DFM_LIB="$DOTFILES/local/bin/dfm-lib"
}

@test "dfm-lib: sources cleanly with no arguments" {
  run bash -c 'source "$0"' "$DFM_LIB"
  [ "$status" -eq 0 ]
}

@test "dfm-lib: is not executable, signalling source-don't-run" {
  # The missing exec bit is what keeps `dfm lib` from resolving to it.
  [ ! -x "$DFM_LIB" ]
}

@test "dfm_bootstrap_for: no argument takes the cheap path" {
  run bash -c 'source "$0"; dfm_bootstrap_min() { echo min; }; dfm_bootstrap() { echo full; }; dfm_bootstrap_for' "$DFM_LIB"
  [ "$status" -eq 0 ]
  [ "$output" = "min" ]
}

@test "dfm_bootstrap_for: help takes the cheap path" {
  for arg in help -h --help; do
    run bash -c 'source "$0"; dfm_bootstrap_min() { echo min; }; dfm_bootstrap() { echo full; }; dfm_bootstrap_for "$1"' "$DFM_LIB" "$arg"
    [ "$status" -eq 0 ]
    [ "$output" = "min" ] || {
      echo "arg '$arg' did not take the cheap path: $output"
      return 1
    }
  done
}

@test "dfm_bootstrap_for: a real action takes the full path" {
  for arg in install brew upkeep fmt; do
    run bash -c 'source "$0"; dfm_bootstrap_min() { echo min; }; dfm_bootstrap() { echo full; }; dfm_bootstrap_for "$1"' "$DFM_LIB" "$arg"
    [ "$status" -eq 0 ]
    [ "$output" = "full" ] || {
      echo "arg '$arg' did not take the full path: $output"
      return 1
    }
  done
}

# dfm must run on stock macOS bash 3.2 — it is what `dfm install all` uses to
# install a newer bash — so it carries no version guard. CI has no bash 3.2,
# so bash-4-only syntax is rejected statically: associative and nameref
# declarations, mapfile/readarray, case-modifying expansions, `|&`, `&>>` and
# `;;&`. Comment lines are skipped.
bash4_syntax()
{
  grep -nE '(^|[^[:alnum:]_])(local|declare|typeset) +-[a-zA-Z]*[An]|(^|[^[:alnum:]_])(mapfile|readarray)([^[:alnum:]_]|$)|\$\{[A-Za-z_][A-Za-z0-9_]*(,,?|\^\^?)\}|\|&|&>>|;;&' "$@" \
    | grep -vE '^([^:]+:)?[0-9]+:[[:space:]]*#'
}

@test "bash-4 syntax check: finds a planted associative array" {
  # Known-positive control: an empty result below means nothing only while
  # this still fires.
  printf 'f()\n{\n  local -A x\n  mapfile -t y < z\n}\n' > "$BATS_TEST_TMPDIR/planted"
  run bash4_syntax "$BATS_TEST_TMPDIR/planted"
  [ "$status" -eq 0 ]
  [[ "$output" == *"local -A x"* ]]
  [[ "$output" == *"mapfile -t y"* ]]
}

@test "dfm files use no bash-4-only syntax" {
  run bash4_syntax "$DOTFILES/local/bin/dfm" "$DOTFILES"/local/bin/dfm-*
  [ "$status" -eq 1 ] || {
    echo "bash-4-only syntax found:"
    echo "$output"
    return 1
  }
}

@test "dfm runs actions under /bin/bash 3.2" {
  /bin/bash -c '((BASH_VERSINFO[0] < 4))' || skip "/bin/bash is 4+"
  run env DOTFILES="$DOTFILES" /bin/bash "$DOTFILES/local/bin/dfm-helpers" path
  [ "$status" -eq 0 ]
  [ -n "$output" ]

  local fake="$BATS_TEST_TMPDIR/dotfiles"
  mkdir -p "$fake/config/secrets.d" "$fake/config/fish/secrets.d"
  : > "$fake/config/shared.sh"
  printf "export A_TOKEN='x'\n" > "$fake/config/secrets.d/a.sh"
  printf "set -x A_TOKEN 'x'\n" > "$fake/config/fish/secrets.d/a.fish"
  run env DOTFILES="$fake" /bin/bash "$DOTFILES/local/bin/dfm-secrets" list
  [ "$status" -eq 0 ]
  [[ "$output" == *"A_TOKEN"* ]]
}

@test "dfm-lib: exports DFM so subcommands can re-dispatch" {
  run bash -c 'source "$0"; echo "${DFM:-UNSET}"' "$DFM_LIB"
  [ "$status" -eq 0 ]
  [ "$output" != "UNSET" ]
}

# dfm_menu renders a section's menu from its #USAGE header, the same spec the
# completions are generated from.
@test "dfm_menu: lists each subcommand with its args and help" {
  local spec="$BATS_TEST_TMPDIR/dfm-demo"
  cat > "$spec" << 'EOF'
#!/usr/bin/env bash
#USAGE cmd "demo" help="Demo section" {
#USAGE   cmd "plain" help="No arguments"
#USAGE   cmd "takes" help="Takes things: an arg and a flag" {
#USAGE     alias "t"
#USAGE     arg "<thing>" help="The thing"
#USAGE     flag "--force" help="Force it"
#USAGE   }
#USAGE }
#
#USAGE   cmd "after" help="Past the header, never read"
EOF
  run bash -c 'source "$0"; dfm_bootstrap_min; dfm_menu "$1"' "$DFM_LIB" "$spec"
  [ "$status" -eq 0 ]
  [[ "$output" == *"  dfm demo <command>"* ]]
  # The name column widens to the longest entry (23 characters here); flags
  # are shown as optional.
  [[ "$output" == *"  plain                   No arguments"* ]]
  [[ "$output" == *"  takes <thing> [--force] Takes things: an arg and a flag"* ]]
  [[ "$output" != *"after"* ]]
  [[ "$output" != *"alias"* ]]
}

@test "dfm_menu: a section without subcommands is titled with its args" {
  local spec="$BATS_TEST_TMPDIR/dfm-solo"
  cat > "$spec" << 'EOF'
#!/usr/bin/env bash
#USAGE cmd "solo" help="Show one thing" {
#USAGE   arg "[name]" help="Name of the thing"
#USAGE }
EOF
  run bash -c 'source "$0"; dfm_bootstrap_min; dfm_menu "$1"' "$DFM_LIB" "$spec"
  [ "$status" -eq 0 ]
  [[ "$output" == *"  dfm solo [name]"* ]]
  [[ "$output" == *"  Show one thing"* ]]
  [[ "$output" != *"<command>"* ]]
}
