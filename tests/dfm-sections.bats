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

@test "dfm sections: an unknown subcommand exits 2 with the menu instead of acting" {
  for section in check dotfiles helpers secrets tests theme; do
    run env DOTFILES="$REPO" "$DFM" "$section" definitely-not-a-subcommand
    [ "$status" -eq 2 ] || {
      echo "dfm $section with a bogus argument exited $status, not 2"
      return 1
    }
    [[ "$output" == *"unknown command: dfm $section definitely-not-a-subcommand"* ]] || {
      echo "dfm $section did not name the unknown command"
      return 1
    }
    first=$(usage_cmds "$section" | head -1)
    [[ "$output" == *"$first"* ]] || {
      echo "dfm $section with a bogus argument did not fall back to the menu"
      return 1
    }
  done
}

@test "dfm sections: a help flag shows the menu with exit 0" {
  for flag in help -h --help; do
    run env DOTFILES="$REPO" "$DFM" check "$flag"
    [ "$status" -eq 0 ]
    [[ "$output" == *"dfm check <command>"* ]]
  done
}

@test "dfm helpers aliases: a missing or unknown shell exits 2" {
  run env DOTFILES="$REPO" "$DFM" helpers aliases
  [ "$status" -eq 2 ]
  [[ "$output" == *"Usage: dfm helpers aliases"* ]]
  run env DOTFILES="$REPO" "$DFM" helpers aliases tcsh
  [ "$status" -eq 2 ]
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
  [[ "$output" == *"Install fonts from GitHub releases"* ]]
  [[ "$output" == *"Install GitHub CLI extensions"* ]]
}

@test "dfm check arch: reports the architecture" {
  # Read-only, so it is safe to run for real.
  run env DOTFILES="$REPO" "$DFM" check arch
  [ "$status" -eq 0 ]
  [ "$output" = "$(uname -m)" ]
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

# reset-nvim deletes nvim's XDG directories and relinks the config. Everything
# it touches lives under BATS_TEST_TMPDIR: HOME, the four XDG roots, a fake
# DOTFILES (whose empty shared.sh keeps PATH as set here) and a mise stub, so
# the `dfm install mise` it ends with installs nothing.
@test "dfm dotfiles reset-nvim: clears the XDG nvim dirs and relinks the config" {
  local t="$BATS_TEST_TMPDIR" d
  local fake="$t/dotfiles"
  mkdir -p "$fake/config/nvim" "$t/home" "$t/stubs"
  : > "$fake/config/shared.sh"
  printf '#!/bin/sh\nexit 0\n' > "$t/stubs/mise"
  chmod +x "$t/stubs/mise"
  for d in data state cache config; do
    mkdir -p "$t/$d/nvim"
    : > "$t/$d/nvim/old"
  done

  run env PATH="$t/stubs:$PATH" HOME="$t/home" DOTFILES="$fake" \
    XDG_DATA_HOME="$t/data" XDG_STATE_HOME="$t/state" \
    XDG_CACHE_HOME="$t/cache" XDG_CONFIG_HOME="$t/config" \
    "$DFM" dotfiles reset-nvim < /dev/null
  [ "$status" -eq 0 ]
  [ ! -e "$t/data/nvim" ]
  [ ! -e "$t/state/nvim" ]
  [ ! -e "$t/cache/nvim" ]
  [ -L "$t/config/nvim" ]
  [ "$(readlink "$t/config/nvim")" = "$fake/config/nvim" ]
}

# A read-only parent makes rm fail. The command stops there instead of
# reporting the delete and relinking over a config it could not remove.
@test "dfm dotfiles reset-nvim: a failed delete stops before relinking" {
  [ "$(id -u)" -ne 0 ] || skip "root ignores the read-only directory"
  local t="$BATS_TEST_TMPDIR" d
  local fake="$t/dotfiles"
  mkdir -p "$fake/config/nvim" "$t/home" "$t/stubs"
  : > "$fake/config/shared.sh"
  printf '#!/bin/sh\nexit 0\n' > "$t/stubs/mise"
  chmod +x "$t/stubs/mise"
  for d in data state cache config; do
    mkdir -p "$t/$d/nvim"
  done
  chmod 555 "$t/state"

  run env PATH="$t/stubs:$PATH" HOME="$t/home" DOTFILES="$fake" \
    XDG_DATA_HOME="$t/data" XDG_STATE_HOME="$t/state" \
    XDG_CACHE_HOME="$t/cache" XDG_CONFIG_HOME="$t/config" \
    "$DFM" dotfiles reset-nvim < /dev/null
  chmod 755 "$t/state"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Failed to delete nvim's data, state, cache or config"* ]]
  [[ "$output" != *"Deleted nvim's data"* ]]
  [ ! -L "$t/config/nvim" ]
}
