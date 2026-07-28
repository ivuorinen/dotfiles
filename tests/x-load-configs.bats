#!/usr/bin/env bats

# x-load-configs sources ~/.config/{exports,alias} plus -secret and
# per-host variants. The load order and the host suffix are the contract, so
# HOME is redirected and HOSTNAME is forced to a known value.

setup()
{
  LOADER="$BATS_TEST_DIRNAME/../local/bin/x-load-configs"
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/.config"
}

teardown()
{
  rm -rf "$TMP"
}

load()
{
  run env HOME="$TMP" DOTFILES="$REPO" HOSTNAME="testbox" VERBOSE=1 "$LOADER"
}

@test "x-load-configs: succeeds when no config files exist" {
  load
  [ "$status" -eq 0 ]
}

@test "x-load-configs: sources the base exports file" {
  printf 'AUDIT_MARKER=1\n' > "$TMP/.config/exports"
  load
  [ "$status" -eq 0 ]
  [[ "$output" == *"Sourced"* ]]
  [[ "$output" == *"$TMP/.config/exports"* ]]
}

@test "x-load-configs: sources the host-specific variant" {
  printf 'A=1\n' > "$TMP/.config/exports-testbox"
  load
  [[ "$output" == *"exports-testbox"* ]]
}

@test "x-load-configs: sources the secret variants" {
  printf 'A=1\n' > "$TMP/.config/exports-secret"
  printf 'A=1\n' > "$TMP/.config/exports-testbox-secret"
  load
  [[ "$output" == *"exports-secret"* ]]
  [[ "$output" == *"exports-testbox-secret"* ]]
}

@test "x-load-configs: sources alias files too" {
  printf 'alias zz=ls\n' > "$TMP/.config/alias"
  load
  [[ "$output" == *"$TMP/.config/alias"* ]]
}

@test "x-load-configs: host file for another host is not sourced" {
  printf 'A=1\n' > "$TMP/.config/exports-otherbox"
  load
  [[ "$output" != *"Sourced $TMP/.config/exports-otherbox"* ]]
}

@test "x-load-configs: reports the host it resolved" {
  load
  [[ "$output" == *"testbox"* ]]
}

@test "x-load-configs: strips the domain from a fully qualified hostname" {
  run env HOME="$TMP" DOTFILES="$REPO" HOSTNAME="testbox.example.com" VERBOSE=1 "$LOADER"
  [ "$status" -eq 0 ]
  [[ "$output" == *"testbox"* ]]
  [[ "$output" != *"testbox.example.com"* ]]
}

@test "x-load-configs: is silent without VERBOSE" {
  printf 'A=1\n' > "$TMP/.config/exports"
  run env HOME="$TMP" DOTFILES="$REPO" HOSTNAME="testbox" "$LOADER"
  [ "$status" -eq 0 ]
  [[ "$output" != *"Sourced"* ]]
}

@test "x-load-configs: a missing DOTFILES directory is a hard error" {
  run env HOME="$TMP" DOTFILES="$TMP/no-such-dotfiles" "$LOADER"
  [ "$status" -eq 1 ]
  [[ "$output" == *"does not exist"* ]]
}
