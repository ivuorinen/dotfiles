#!/usr/bin/env bats

# zap deletes files recursively from the current tree. Every test runs inside
# a temp directory: a bug in the selection logic must not be able to reach the
# repository.

setup()
{
  ZAP="$BATS_TEST_DIRNAME/../local/bin/zap"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/nested/deeper"
  touch "$TMP/.DS_Store" "$TMP/nested/.DS_Store"
  touch "$TMP/mod.pyc" "$TMP/nested/deeper/other.pyc"
  touch "$TMP/keep.txt" "$TMP/nested/keep.py"
}

teardown()
{
  rm -rf "$TMP"
}

@test "zap ds: removes .DS_Store recursively" {
  run bash -c "cd '$TMP' && '$ZAP' ds"
  [ "$status" -eq 0 ]
  [ ! -e "$TMP/.DS_Store" ]
  [ ! -e "$TMP/nested/.DS_Store" ]
}

@test "zap ds: leaves .pyc and ordinary files alone" {
  bash -c "cd '$TMP' && '$ZAP' ds"
  [ -e "$TMP/mod.pyc" ]
  [ -e "$TMP/keep.txt" ]
  [ -e "$TMP/nested/keep.py" ]
}

@test "zap pyc: removes .pyc recursively and keeps .py" {
  run bash -c "cd '$TMP' && '$ZAP' pyc"
  [ "$status" -eq 0 ]
  [ ! -e "$TMP/mod.pyc" ]
  [ ! -e "$TMP/nested/deeper/other.pyc" ]
  [ -e "$TMP/nested/keep.py" ]
}

@test "zap pyc: leaves .DS_Store alone" {
  bash -c "cd '$TMP' && '$ZAP' pyc"
  [ -e "$TMP/.DS_Store" ]
}

@test "zap all: removes both kinds and keeps the rest" {
  run bash -c "cd '$TMP' && '$ZAP' all"
  [ "$status" -eq 0 ]
  [ ! -e "$TMP/.DS_Store" ]
  [ ! -e "$TMP/mod.pyc" ]
  [ -e "$TMP/keep.txt" ]
  [ -e "$TMP/nested/keep.py" ]
}

@test "zap: unknown target exits 1 with usage on stderr" {
  run bash -c "cd '$TMP' && '$ZAP' bogus 2>&1 >/dev/null"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "zap: no argument exits 1 and deletes nothing" {
  run bash -c "cd '$TMP' && '$ZAP'"
  [ "$status" -eq 1 ]
  [ -e "$TMP/.DS_Store" ]
  [ -e "$TMP/mod.pyc" ]
}
