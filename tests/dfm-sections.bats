#!/usr/bin/env bats

# Menu and dispatch coverage for the dfm sections tests/dfm.bats does not
# reach. As in tests/dfm-cleanup.bats, the action subcommands are left alone:
# they format files in the repo, regenerate docs, install packages, or touch
# the real secrets directory, and dfm cannot be isolated with a stubbed PATH
# because it sources config/exports during bootstrap and rebuilds PATH from
# scratch.
#
# The parity test below is the valuable one. Each section's menu array and its
# #USAGE block are maintained by hand in the same file, and they have drifted
# before — that drift is what hid `dfm ssh` from the generated docs.

setup()
{
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  DFM="$REPO/local/bin/dfm"
}

usage_cmds()
{
  grep -oE '^#USAGE   cmd "[a-z0-9-]+"' "$REPO/local/bin/dfm-$1" \
    | sed 's/.*"\(.*\)"/\1/'
}

@test "dfm sections: every USAGE-declared subcommand appears in its menu" {
  for section in check dotfiles helpers secrets tests; do
    run env DOTFILES="$REPO" "$DFM" "$section"
    [ "$status" -eq 0 ] || {
      echo "dfm $section exited $status"
      return 1
    }
    for entry in $(usage_cmds "$section"); do
      [[ "$output" == *"$entry"* ]] || {
        echo "dfm-$section: USAGE declares '$entry' but the menu does not list it"
        return 1
      }
    done
  done
}

@test "dfm sections: an unknown subcommand shows the menu instead of acting" {
  for section in check dotfiles helpers secrets tests; do
    run env DOTFILES="$REPO" "$DFM" "$section" definitely-not-a-subcommand
    first=$(usage_cmds "$section" | head -1)
    [[ "$output" == *"$first"* ]] || {
      echo "dfm $section with a bogus argument did not fall back to the menu"
      return 1
    }
  done
}

@test "dfm scripts: lists the install scripts it can run" {
  # This menu is built from scripts/install-*.sh at runtime rather than from a
  # USAGE block, so parity is against the directory instead.
  run env DOTFILES="$REPO" "$DFM" scripts
  [ "$status" -eq 0 ]
  for f in "$REPO"/scripts/install-*.sh; do
    name=$(basename "$f" .sh)
    name="${name#install-}"
    [[ "$output" == *"$name"* ]] || {
      echo "scripts/ has $name but the menu does not list it"
      return 1
    }
  done
}

@test "dfm scripts: labels come from the script's @description" {
  # A script whose @description line went missing would still be listed, but
  # with an empty label — the menu would say nothing about what it does.
  run env DOTFILES="$REPO" "$DFM" scripts
  [[ "$output" == *"Install essential apt packages"* ]]
  [[ "$output" == *"Install GitHub CLI extensions"* ]]
}

@test "dfm check arch: reports the architecture" {
  # Read-only, so it is safe to run for real.
  run env DOTFILES="$REPO" "$DFM" check arch
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "dfm check host: reports the hostname" {
  run env DOTFILES="$REPO" "$DFM" check host
  [ "$status" -eq 0 ]
  [[ "$output" == *"$(hostname -s)"* ]]
}

@test "dfm helpers path: lists the PATH entries" {
  run env DOTFILES="$REPO" "$DFM" helpers path
  [ "$status" -eq 0 ]
  [[ "$output" == *"/bin"* ]]
}

@test "dfm apt: matches whether apt exists on this system" {
  run env DOTFILES="$REPO" "$DFM" apt
  if command -v apt > /dev/null 2>&1; then
    for entry in $(usage_cmds apt); do
      [[ "$output" == *"$entry"* ]] || {
        echo "apt exists but the menu is missing '$entry'"
        return 1
      }
    done
  else
    [[ "$output" == *"not available on this system"* ]]
  fi
}

@test "dfm brew: matches whether brew exists on this system" {
  run env DOTFILES="$REPO" "$DFM" brew
  if command -v brew > /dev/null 2>&1; then
    for entry in $(usage_cmds brew); do
      [[ "$output" == *"$entry"* ]] || {
        echo "brew exists but the menu is missing '$entry'"
        return 1
      }
    done
  else
    [[ "$output" == *"not available on this system"* ]]
  fi
}

@test "dfm: a tool-gated section never runs its action when the tool is absent" {
  # The gate sits at the top of the section function, so it must also stop a
  # direct `dfm apt upkeep` — not just the bare menu invocation.
  if command -v apt > /dev/null 2>&1; then
    skip "apt is installed on this machine"
  fi
  run env DOTFILES="$REPO" "$DFM" apt upkeep
  [[ "$output" == *"not available on this system"* ]]
}
