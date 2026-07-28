#!/usr/bin/env bats

# dfm cleanup is one of the two sections tests/dfm.bats never reaches.
#
# ONLY the menu and dispatch surface is tested here, and deliberately so.
# Every action subcommand runs a real destructive tool — `mise prune`,
# `docker system prune`, `brew cleanup` — and dfm cannot be isolated with a
# stubbed PATH: it sources config/exports during bootstrap, which rebuilds
# PATH from scratch and drops any stub directory prepended by the caller.
#
# That is not hypothetical. An earlier version of this file stubbed mise and
# docker on PATH and called the subcommands; the stubs were bypassed, the real
# `mise prune` ran, and it deleted the bats version the suite was executing
# from, killing the run partway through.
#
# Covering the actions needs isolation dfm does not currently offer — a
# --dry-run flag, or an injectable command prefix. Until then these tests stop
# at the boundary where dfm decides what to do, before it does it.

setup()
{
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  DFM="$REPO/local/bin/dfm"
}

@test "dfm cleanup: bare invocation lists every subcommand" {
  run env DOTFILES="$REPO" "$DFM" cleanup
  [ "$status" -eq 0 ]
  for entry in all brew caches docker mise old-vms; do
    [[ "$output" == *"$entry"* ]] || {
      echo "missing menu entry: $entry"
      return 1
    }
  done
}

@test "dfm cleanup: the menu describes what each entry does" {
  run env DOTFILES="$REPO" "$DFM" cleanup
  [[ "$output" == *"Prune unused tool versions"* ]]
  [[ "$output" == *"version manager directories"* ]]
}

@test "dfm cleanup: an unknown subcommand shows the menu instead of acting" {
  run env DOTFILES="$REPO" "$DFM" cleanup definitely-not-a-subcommand
  [[ "$output" == *"all"* ]]
  [[ "$output" == *"brew"* ]]
}

@test "dfm cleanup: the menu entries match the USAGE spec" {
  # Guards the drift that hid `dfm ssh` from the docs: the menu array and the
  # #USAGE block are maintained by hand and can disagree.
  run env DOTFILES="$REPO" "$DFM" cleanup
  spec=$(grep -oE '^#USAGE   cmd "[a-z-]+"' "$REPO/local/bin/dfm-cleanup" | sed 's/.*"\(.*\)"/\1/' | sort)
  for entry in $spec; do
    [[ "$output" == *"$entry"* ]] || {
      echo "USAGE declares '$entry' but the menu does not list it"
      return 1
    }
  done
}
