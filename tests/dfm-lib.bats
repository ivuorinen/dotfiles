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

# The bash-4 guard runs on stock macOS bash 3.2. Reached without a terminal
# (a test run, CI), it must refuse instead of installing anything. brew and
# mise stubs first on PATH record any call, so an install attempt fails the
# test rather than touching the machine.
@test "dfm_bootstrap: bash 3.2 without a terminal refuses and installs nothing" {
  /bin/bash -c '((BASH_VERSINFO[0] < 4))' || skip "/bin/bash is 4+"
  local stubs="$BATS_TEST_TMPDIR/stubs"
  mkdir -p "$stubs"
  for tool in brew mise; do
    printf '#!/bin/sh\necho "%s $*" >> "%s/calls"\n' "$tool" "$stubs" > "$stubs/$tool"
    chmod +x "$stubs/$tool"
  done
  run env PATH="$stubs:/usr/bin:/bin" /bin/bash -c 'source "$0"; dfm_bootstrap' "$DFM_LIB" < /dev/null
  [ "$status" -eq 1 ]
  [[ "$output" == *"dfm requires bash 4.0+"* ]]
  [[ "$output" == *"mise bootstrap packages apply brew:bash"* ]]
  [ ! -e "$stubs/calls" ]
}

@test "dfm-lib: exports DFM so subcommands can re-dispatch" {
  run bash -c 'source "$0"; echo "${DFM:-UNSET}"' "$DFM_LIB"
  [ "$status" -eq 0 ]
  [ "$output" != "UNSET" ]
}
