#!/usr/bin/env bats

# dfm cleanup is one of the two sections tests/dfm.bats never reaches.
#
# Every action runs a real destructive tool — `mise prune`, `docker system
# prune`, `brew cleanup` — so the action tests must never reach the real one.
# With DOTFILES pointing at the repo that cannot be guaranteed: the full
# bootstrap sources config/exports, which rebuilds PATH and drops a stub
# directory prepended by the caller. An earlier version of this file did
# exactly that; the stubs were bypassed, the real `mise prune` ran, and it
# deleted the bats version the suite was executing from.
#
# The action tests therefore run against a fake DOTFILES whose
# config/shared.sh is empty: the bootstrap sources that instead of the real
# exports, PATH stays as the test set it, and the stubs first on it are the
# tools dfm runs. Each stub records its arguments and every test asserts the
# record, which is also the proof that no real tool ran.

setup()
{
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  DFM="$REPO/local/bin/dfm"
}

# stub TOOL STATUS — TOOL first on PATH, recording its arguments, exiting STATUS.
stub()
{
  printf '#!/bin/sh\necho "%s $*" >> "%s"\nexit %s\n' "$1" "$CALLS" "$2" > "$STUBS/$1"
  chmod +x "$STUBS/$1"
}

stub_env()
{
  FAKE="$BATS_TEST_TMPDIR/dotfiles"
  STUBS="$BATS_TEST_TMPDIR/stubs"
  CALLS="$BATS_TEST_TMPDIR/calls"
  mkdir -p "$FAKE/config" "$FAKE/scripts" "$STUBS"
  : > "$FAKE/config/shared.sh"
  : > "$CALLS"
  printf '#!/bin/sh\necho "old-vms $*" >> "%s"\n' "$CALLS" \
    > "$FAKE/scripts/cleanup-old-version-managers.sh"
  local tool
  for tool in mise uv docker; do
    stub "$tool" 0
  done
}

run_cleanup()
{
  run env PATH="$STUBS:$PATH" DOTFILES="$FAKE" "$DFM" cleanup "$@"
}

@test "dfm cleanup: bare invocation lists every subcommand" {
  run env DOTFILES="$REPO" "$DFM" cleanup
  [ "$status" -eq 0 ]
  for entry in all caches docker mise old-vms; do
    [[ "$output" == *"$entry"* ]] || {
      echo "missing menu entry: $entry"
      return 1
    }
  done
  # No brew step: brew cleanup/autoremove can remove kegs mise poured.
  [[ "$output" != *"brew"* ]]
}

@test "dfm cleanup: the menu describes what each entry does" {
  run env DOTFILES="$REPO" "$DFM" cleanup
  [[ "$output" == *"Prune unused tool versions"* ]]
  [[ "$output" == *"version manager directories"* ]]
}

@test "dfm cleanup: an unknown subcommand shows the menu instead of acting" {
  run env DOTFILES="$REPO" "$DFM" cleanup definitely-not-a-subcommand
  [ "$status" -eq 2 ]
  [[ "$output" == *"all"* ]]
  [[ "$output" == *"caches"* ]]
}

@test "dfm cleanup caches: succeeds and reports it when both tools succeed" {
  stub_env
  run_cleanup caches
  [ "$status" -eq 0 ]
  [[ "$output" == *"Cache cleanup complete"* ]]
  grep -qx 'mise cache clean' "$CALLS"
  grep -qx 'uv cache clean' "$CALLS"
}

@test "dfm cleanup caches: a failing tool fails the step without the success line" {
  stub_env
  stub mise 1
  run_cleanup caches
  [ "$status" -eq 1 ]
  [[ "$output" != *"Cache cleanup complete"* ]]
  [[ "$output" == *"Cache cleanup failed"* ]]
  # uv still runs after mise failed.
  grep -qx 'uv cache clean' "$CALLS"
}

@test "dfm cleanup docker: a failing prune fails the step" {
  stub_env
  stub docker 1
  run_cleanup docker
  [ "$status" -eq 1 ]
  [[ "$output" != *"Docker cleanup complete"* ]]
  grep -qx 'docker system prune -f' "$CALLS"
}

@test "dfm cleanup mise: a failing prune fails the step" {
  stub_env
  stub mise 1
  run_cleanup mise
  [ "$status" -eq 1 ]
  [[ "$output" == *"mise cleanup failed"* ]]
  grep -qx 'mise prune --yes' "$CALLS"
}

@test "dfm cleanup all: one failing step fails the whole run" {
  stub_env
  stub uv 1
  run_cleanup all
  [ "$status" -eq 1 ]
  [[ "$output" == *"Cleanup finished with errors"* ]]
  grep -qx 'old-vms ' "$CALLS"
}

@test "dfm cleanup old-vms: passes --dry-run to the script" {
  stub_env
  run_cleanup old-vms --dry-run
  [ "$status" -eq 0 ]
  grep -qx 'old-vms --dry-run' "$CALLS"
}
