#!/usr/bin/env bats
#
# Tests for config/lib.sh — the centralized logging + error/cleanup
# library. Verifies the level filter, error codes, cleanup helpers, and
# the critical invariant that sourcing is side-effect-free (no set -e,
# no traps) so it is safe to load into interactive shells.

setup()
{
  export DOTFILES="$PWD"
  LIB="$DOTFILES/config/lib.sh"
  export LIB
}

# ── Loading is side-effect-free ───────────────────────────────

@test "sourcing lib.sh does not enable set -e" {
  run bash -c 'source "$LIB"; false; echo survived'
  [ "$status" -eq 0 ]
  [[ "$output" == *"survived"* ]]
}

@test "double-sourcing is a no-op and returns cleanly" {
  run bash -c 'source "$LIB"; source "$LIB"; echo ok'
  [ "$status" -eq 0 ]
  [[ "$output" == *"ok"* ]]
}

# ── Simple logging ────────────────────────────────────────────

@test "lib::log prints a timestamped line to stdout" {
  run bash -c 'source "$LIB"; lib::log hello'
  [ "$status" -eq 0 ]
  [[ "$output" =~ ^\[[0-9]{4}-[0-9]{2}-[0-9]{2}\ [0-9]{2}:[0-9]{2}:[0-9]{2}\]\ hello$ ]]
}

@test "lib::error prefixes ERROR and writes to stderr" {
  run bash -c 'source "$LIB"; lib::error boom 2>&1 1>/dev/null'
  [ "$status" -eq 0 ]
  [[ "$output" == *"ERROR: boom"* ]]
}

# ── Level filtering ───────────────────────────────────────────

@test "logger::debug is suppressed at the default INFO level" {
  run bash -c 'source "$LIB"; logger::debug hidden; logger::info shown'
  [ "$status" -eq 0 ]
  [[ "$output" != *"hidden"* ]]
  [[ "$output" == *"shown"* ]]
  [[ "$output" == *"[INFO]"* ]]
}

@test "logger::debug is shown when LOG_LEVEL=DEBUG" {
  run bash -c 'export LOG_LEVEL=DEBUG; source "$LIB"; logger::debug dbg'
  [ "$status" -eq 0 ]
  [[ "$output" == *"dbg"* ]]
  [[ "$output" == *"[DEBUG]"* ]]
}

@test "logger::warn and logger::error are shown at INFO" {
  run bash -c 'source "$LIB"; logger::warn careful; logger::error nope'
  [ "$status" -eq 0 ]
  [[ "$output" == *"[WARN]"* ]]
  [[ "$output" == *"careful"* ]]
  [[ "$output" == *"[ERROR]"* ]]
  [[ "$output" == *"nope"* ]]
}

@test "logger::log rejects an unknown level" {
  run bash -c 'source "$LIB"; logger::log NOPE x'
  [ "$status" -eq 1 ]
  [[ "$output" == *"Invalid log level: NOPE"* ]]
}

@test "an invalid LOG_LEVEL falls back to INFO with a warning" {
  run bash -c 'export LOG_LEVEL=BOGUS; source "$LIB"; echo "LL=$LOG_LEVEL"'
  [ "$status" -eq 0 ]
  [[ "$output" == *"Invalid LOG_LEVEL: BOGUS"* ]]
  [[ "$output" == *"LL=INFO"* ]]
}

# ── Error codes ───────────────────────────────────────────────

@test "named error codes are exported with expected values" {
  run bash -c 'source "$LIB"; echo "$LIB_E_SUCCESS $LIB_E_INVALID_ARGUMENT $LIB_E_COMMAND_NOT_FOUND $LIB_E_FILE_NOT_FOUND"'
  [ "$status" -eq 0 ]
  [ "$output" = "0 1 2 5" ]
}

# ── Cleanup ───────────────────────────────────────────────────

@test "lib::cleanup removes registered paths" {
  run bash -c 'source "$LIB"; f=$(mktemp); lib::register_cleanup "$f"; lib::cleanup; [[ -e "$f" ]] && echo EXISTS || echo GONE'
  [ "$status" -eq 0 ]
  [[ "$output" == *"GONE"* ]]
}

@test "lib::cleanup also honors a legacy TEMP_DIR" {
  run bash -c 'source "$LIB"; TEMP_DIR=$(mktemp -d); lib::cleanup; [[ -d "$TEMP_DIR" ]] && echo EXISTS || echo GONE'
  [ "$status" -eq 0 ]
  [[ "$output" == *"GONE"* ]]
}
