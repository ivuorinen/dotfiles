#!/usr/bin/env bats
#
# Tests for local/bin/x-secure-input-lock — specifically the secure_input_pid
# parser, which turns `ioreg -l` output into the PID holding secure input.
# The script guards main() behind a BASH_SOURCE check so it can be sourced here
# without running. Parser runs inside `run bash -c` so the script's `set -e`
# stays isolated from the bats shell.

setup()
{
  export DOTFILES="$PWD"
  SCRIPT="$DOTFILES/local/bin/x-secure-input-lock"
  export SCRIPT
}

parse()
{
  run bash -c "source '$SCRIPT' >/dev/null 2>&1 || true; printf '%s\n' \"\$1\" | secure_input_pid || true" _ "$1"
}

@test "secure_input_pid extracts the held pid" {
  parse 'foo "kCGSSessionSecureInputPID"=4242 bar'
  [ "$status" -eq 0 ]
  [ "$output" = "4242" ]
}

@test "secure_input_pid tolerates spaces around =" {
  parse '"kCGSSessionSecureInputPID" = 512'
  [ "$output" = "512" ]
}

@test "secure_input_pid ignores a zero pid (not held)" {
  parse '"kCGSSessionSecureInputPID"=0'
  [ -z "$output" ]
}

@test "secure_input_pid is empty when the key is absent" {
  parse 'no secure input claim in this line'
  [ -z "$output" ]
}

@test "secure_input_pid returns the first non-zero pid across sessions" {
  parse '"kCGSSessionSecureInputPID"=0 ... "kCGSSessionSecureInputPID"=777'
  [ "$output" = "777" ]
}
