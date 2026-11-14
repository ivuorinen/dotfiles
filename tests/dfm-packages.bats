#!/usr/bin/env bats
# Tests for local/bin/dfm-packages.
#
# Every action runs `mise bootstrap packages …`, which installs system
# packages, so mise is always a stub that records its arguments. The fake
# DOTFILES has an empty config/shared.sh: the full bootstrap sources it instead
# of the real config/exports, so PATH stays as the test sets it and the stub is
# the mise dfm runs. is-sudoer is a stub in the fake tree too.

setup()
{
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  DFM="$REPO/local/bin/dfm"
  FAKE="$BATS_TEST_TMPDIR/dotfiles"
  STUBS="$BATS_TEST_TMPDIR/stubs"
  CALLS="$BATS_TEST_TMPDIR/calls"
  mkdir -p "$FAKE/config" "$FAKE/local/bin" "$STUBS"
  : > "$FAKE/config/shared.sh"
  : > "$CALLS"
  mise_stub 0
  sudoer_stub 0
}

# mise_stub STATUS — mise on PATH that records its arguments and exits STATUS.
mise_stub()
{
  printf '#!/bin/sh\necho "mise $*" >> "%s"\nexit %s\n' "$CALLS" "$1" > "$STUBS/mise"
  chmod +x "$STUBS/mise"
}

# sudoer_stub STATUS — is-sudoer in the fake tree, exiting STATUS.
sudoer_stub()
{
  printf '#!/bin/sh\nexit %s\n' "$1" > "$FAKE/local/bin/is-sudoer"
  chmod +x "$FAKE/local/bin/is-sudoer"
}

run_packages()
{
  run env PATH="$STUBS:$PATH" DOTFILES="$FAKE" "$DFM" packages "$@"
}

@test "dfm packages: the menu lists apply, status and upgrade" {
  run_packages
  [ "$status" -eq 0 ]
  [[ "$output" == *"dfm packages <command>"* ]]
  [[ "$output" == *"apply"* ]]
  [[ "$output" == *"status"* ]]
  [[ "$output" == *"upgrade"* ]]
  [[ "$output" != *"prune"* ]]
}

@test "dfm packages apply: applies every declared package" {
  run_packages apply
  [ "$status" -eq 0 ]
  grep -qx 'mise bootstrap packages apply --yes' "$CALLS"
}

@test "dfm packages apply: a failing apply fails the command" {
  mise_stub 1
  run_packages apply
  [ "$status" -eq 1 ]
}

@test "dfm packages apply: a user without sudo rights is warned, not prompted" {
  sudoer_stub 1
  run_packages apply
  [ "$status" -eq 0 ]
  [[ "$output" == *"no sudo rights"* ]]
  [ ! -s "$CALLS" ]
}

@test "dfm packages status: reports a difference with exit 1" {
  run_packages status
  [ "$status" -eq 0 ]
  grep -qx 'mise bootstrap packages status --missing' "$CALLS"
  mise_stub 1
  run_packages status
  [ "$status" -eq 1 ]
}

@test "dfm packages upgrade: upgrades the declared packages" {
  run_packages upgrade
  [ "$status" -eq 0 ]
  grep -qx 'mise bootstrap packages upgrade --yes' "$CALLS"
}

@test "dfm packages: without mise it says how to get it" {
  # A PATH with only what the dispatcher needs to start, and no mise.
  local bin="$BATS_TEST_TMPDIR/bin" tool
  mkdir -p "$bin"
  for tool in bash dirname readlink; do
    ln -s "$(command -v "$tool")" "$bin/$tool"
  done
  run env PATH="$bin" DOTFILES="$FAKE" "$DFM" packages apply
  [ "$status" -eq 1 ]
  [[ "$output" == *"mise not found"* ]]
  [[ "$output" == *"dfm install mise"* ]]
}
