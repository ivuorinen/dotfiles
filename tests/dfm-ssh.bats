#!/usr/bin/env bats

# dfm ssh is the second section tests/dfm.bats never reaches, and the one the
# repo documented nowhere until this session.
#
# Mostly the menu and dispatch surface. The actions read the user's real
# ~/.ssh and append to allowed_signers, so only the GitHub fetch is exercised:
# dfm-ssh skips the shell environment (dfm_bootstrap_min), so a curl stub first
# on PATH stays the curl it runs, and `github` stops at a failed fetch before
# it reads any local key.

setup()
{
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  DFM="$REPO/local/bin/dfm"
}

@test "dfm ssh github: the fetch is bounded and a failure is reported" {
  local stubs="$BATS_TEST_TMPDIR/stubs"
  mkdir -p "$stubs"
  printf '#!/bin/sh\necho "$*" > "%s/curl-args"\nexit 28\n' "$BATS_TEST_TMPDIR" > "$stubs/curl"
  chmod +x "$stubs/curl"
  run env PATH="$stubs:$PATH" DOTFILES="$REPO" "$DFM" ssh github someone
  [ "$status" -eq 1 ]
  [[ "$output" == *"No keys fetched for 'someone'"* ]]
  [[ "$(cat "$BATS_TEST_TMPDIR/curl-args")" == *"--connect-timeout 10 --max-time 30"* ]]
  [[ "$(cat "$BATS_TEST_TMPDIR/curl-args")" == *"https://github.com/someone.keys"* ]]
}

@test "dfm ssh github: a missing curl is named instead of a network error" {
  # A PATH with only what the dispatcher needs to start, and no curl.
  local bin="$BATS_TEST_TMPDIR/bin" tool
  mkdir -p "$bin"
  for tool in bash dirname readlink; do
    ln -s "$(command -v "$tool")" "$bin/$tool"
  done
  run env PATH="$bin" DOTFILES="$REPO" "$DFM" ssh github someone
  [ "$status" -eq 1 ]
  [[ "$output" == *"curl not found"* ]]
  [[ "$output" != *"No keys fetched"* ]]
}

@test "dfm ssh: bare invocation lists every subcommand" {
  run env DOTFILES="$REPO" "$DFM" ssh
  [ "$status" -eq 0 ]
  [[ "$output" == *"signers"* ]]
  [[ "$output" == *"check"* ]]
  [[ "$output" == *"github"* ]]
}

@test "dfm ssh: the menu explains that check writes nothing" {
  run env DOTFILES="$REPO" "$DFM" ssh
  [[ "$output" == *"Dry run"* ]]
  [[ "$output" == *"write nothing"* ]]
}

@test "dfm ssh: the menu documents the github user argument" {
  run env DOTFILES="$REPO" "$DFM" ssh
  # Optional: the default comes from git's github.user.
  [[ "$output" == *"github [user]"* ]]
}

@test "dfm ssh: an unknown subcommand shows the menu instead of acting" {
  run env DOTFILES="$REPO" "$DFM" ssh definitely-not-a-subcommand
  [ "$status" -eq 2 ]
  [[ "$output" == *"signers"* ]]
}

@test "dfm ssh: the section is reachable through the dispatcher" {
  # dfm-ssh is resolved dynamically as dfm-<section>; this is the regression
  # that left it working but absent from every document.
  run env DOTFILES="$REPO" "$DFM" ssh
  [ "$status" -eq 0 ]
  [[ "$output" != *"not a dfm command"* ]]
}

@test "dfm ssh: appears in the top-level dfm listing" {
  run env DOTFILES="$REPO" "$DFM"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ssh"* ]]
}
