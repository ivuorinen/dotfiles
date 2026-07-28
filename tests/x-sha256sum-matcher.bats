#!/usr/bin/env bats

# x-sha256sum-matcher answers match/no-match through its exit code, and takes
# two different routes to that answer: a byte compare when quiet, real hashing
# when verbose. Both routes are asserted, because a divergence between them
# would be invisible from either alone.

setup()
{
  MATCHER="$BATS_TEST_DIRNAME/../local/bin/x-sha256sum-matcher"
  TMP="$(mktemp -d)"
  printf 'identical contents\n' > "$TMP/a"
  printf 'identical contents\n' > "$TMP/b"
  printf 'different contents\n' > "$TMP/c"
  # Same length as a/b so a length-only comparison would wrongly pass.
  printf 'identical contentX\n' > "$TMP/d"
}

teardown()
{
  rm -rf "$TMP"
}

@test "matcher: identical files exit 0" {
  run "$MATCHER" "$TMP/a" "$TMP/b"
  [ "$status" -eq 0 ]
}

@test "matcher: differing files exit 1" {
  run "$MATCHER" "$TMP/a" "$TMP/c"
  [ "$status" -eq 1 ]
}

@test "matcher: same-length differing files exit 1" {
  run "$MATCHER" "$TMP/a" "$TMP/d"
  [ "$status" -eq 1 ]
}

@test "matcher: the verbose hashing route agrees with the quiet route" {
  run "$MATCHER" -v "$TMP/a" "$TMP/b"
  [ "$status" -eq 0 ]
  run "$MATCHER" -v "$TMP/a" "$TMP/d"
  [ "$status" -eq 1 ]
}

@test "matcher: verbose prints both digests and they are equal for a match" {
  run "$MATCHER" -v "$TMP/a" "$TMP/b"
  [ "$status" -eq 0 ]
  [[ "$output" == *"SHA256 for"* ]]
  # Two identical 64-hex digests must appear.
  digests=$(printf '%s\n' "$output" | grep -oE '[0-9a-f]{64}' | sort -u | wc -l)
  [ "$digests" -eq 1 ]
}

@test "matcher: verbose prints two distinct digests for a mismatch" {
  run "$MATCHER" -v "$TMP/a" "$TMP/d"
  [ "$status" -eq 1 ]
  digests=$(printf '%s\n' "$output" | grep -oE '[0-9a-f]{64}' | sort -u | wc -l)
  [ "$digests" -eq 2 ]
}

@test "matcher: quiet mode says nothing on a match" {
  run "$MATCHER" "$TMP/a" "$TMP/b"
  [ -z "$output" ]
}

@test "matcher: the mismatch message goes to stderr" {
  run bash -c "'$MATCHER' '$TMP/a' '$TMP/c' 2>&1 >/dev/null"
  [[ "$output" == *"do not match"* ]]
}

@test "matcher: a missing file is reported and exits 1" {
  run "$MATCHER" "$TMP/a" "$TMP/no-such-file"
  [ "$status" -eq 1 ]
  [[ "$output" == *"does not exist"* ]]
}

@test "matcher: --help exits 0 and prints usage" {
  run "$MATCHER" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "matcher: an unknown option exits 1" {
  run "$MATCHER" --bogus "$TMP/a" "$TMP/b"
  [ "$status" -eq 1 ]
}

@test "matcher: wrong argument count exits 1" {
  run "$MATCHER" "$TMP/a"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Two file arguments required"* ]]
}
