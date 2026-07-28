#!/usr/bin/env bats

# x-compare-versions.py ships its own assertion suite but nothing ran it, so a
# break in the comparison logic surfaced only when a caller misbehaved. The
# first test wires that suite into bats.
#
# These tests also guard the `packaging` import. That dependency went missing
# when mise moved to python 3.14 and the script was dead on this machine until
# it was noticed by hand — every test here fails loudly in that state.
#
# Note the subcommand is `test`, not `--test`: an unrecognised argument falls
# through to main(), which reads stdin, finds nothing and exits 0. That looks
# exactly like a passing suite.

setup()
{
  CV="$BATS_TEST_DIRNAME/../local/bin/x-compare-versions.py"
}

@test "x-compare-versions: its own assertion suite passes" {
  run "$CV" test
  [ "$status" -eq 0 ]
}

@test "x-compare-versions: the packaging dependency is importable" {
  # An explicit check, because every other failure mode here looks the same.
  run bash -c "printf '2.0 >= 1.0\n' | '$CV' 2>&1"
  [ "$status" -eq 0 ]
  [[ "$output" != *"ModuleNotFoundError"* ]]
}

@test "x-compare-versions: a true comparison exits 0" {
  run bash -c "printf '2.5 >= 2.4\n' | '$CV'"
  [ "$status" -eq 0 ]
}

@test "x-compare-versions: a false comparison exits 1" {
  run bash -c "printf '1.9 >= 2.4\n' | '$CV'"
  [ "$status" -eq 1 ]
}

@test "x-compare-versions: equality and inequality operators" {
  run bash -c "printf '2.4 == 2.4\n' | '$CV'"
  [ "$status" -eq 0 ]
  run bash -c "printf '2.4 != 2.4\n' | '$CV'"
  [ "$status" -eq 1 ]
}

@test "x-compare-versions: chained comparisons are all required to hold" {
  run bash -c "printf '1.0 < 2.0 <= 2.0\n' | '$CV'"
  [ "$status" -eq 0 ]
  run bash -c "printf '1.0 > 2.0 < 3.0\n' | '$CV'"
  [ "$status" -eq 1 ]
}

@test "x-compare-versions: prerelease ordering follows PEP 440" {
  # The reason the packaging dependency exists rather than a string compare.
  run bash -c "printf '2.9a < 2.9\n' | '$CV'"
  [ "$status" -eq 0 ]
  run bash -c "printf '3 >= 2.999\n' | '$CV'"
  [ "$status" -eq 0 ]
}

@test "x-compare-versions: a malformed expression exits 1" {
  run bash -c "printf '1.0 <\n' | '$CV'"
  [ "$status" -eq 1 ]
}

@test "x-compare-versions: a trailing token is rejected, not dropped" {
  run bash -c "printf '1.0 < 2.0 junk\n' | '$CV'"
  [ "$status" -eq 1 ]
}

@test "x-compare-versions: every line must hold" {
  run bash -c "printf '1.0 < 2.0\n3.0 < 2.0\n' | '$CV'"
  [ "$status" -eq 1 ]
}

@test "x-compare-versions: blank lines are skipped" {
  run bash -c "printf '\n1.0 < 2.0\n\n' | '$CV'"
  [ "$status" -eq 0 ]
}
