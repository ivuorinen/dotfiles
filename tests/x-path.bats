#!/usr/bin/env bats

# These tests deliberately shrink PATH to assert path-manipulation behavior.
# On macOS rm lives in /bin, so a test leaving PATH="/usr/bin" breaks bats'
# own post-test cleanup (rm). Save the real PATH and restore it in teardown,
# which runs before that cleanup.
#
# x-path is written to be sourced — mutating PATH in a subprocess would be
# invisible to the caller — so the tests below source it and assert on $PATH
# rather than running it and reading output.
setup()
{
  REAL_PATH="$PATH"
  XPATH="$BATS_TEST_DIRNAME/../local/bin/x-path"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/one" "$TMP/two" "$TMP/three" "$TMP/with space"
  # shellcheck source=/dev/null
  source "$XPATH"
}

teardown()
{
  PATH="$REAL_PATH"
  rm -rf "$TMP"
}

@test "x-path-append adds directory" {
  mkdir -p "$BATS_TMPDIR/dir"
  PATH="/usr/bin"
  VERBOSE=1 source local/bin/x-path-append "$BATS_TMPDIR/dir"
  [ "$PATH" = "/usr/bin:$BATS_TMPDIR/dir" ]
}

@test "x-path-prepend adds directory to start" {
  mkdir -p "$BATS_TMPDIR/dir"
  PATH="/usr/bin:/bin"
  VERBOSE=1 source local/bin/x-path-prepend "$BATS_TMPDIR/dir"
  [ "$PATH" = "$BATS_TMPDIR/dir:/usr/bin:/bin" ]
}

@test "x-path-remove removes directory" {
  mkdir -p "$BATS_TMPDIR/dir"
  PATH="$BATS_TMPDIR/dir:/usr/bin"
  VERBOSE=1 source local/bin/x-path-remove "$BATS_TMPDIR/dir"
  [ "$PATH" = "/usr/bin" ]
}

@test "x-path-append skips missing directory" {
  PATH="/usr/bin"
  VERBOSE=1 source local/bin/x-path-append "$BATS_TMPDIR/no-such"
  [ "$PATH" = "/usr/bin" ]
}

@test "x-path: normalize_dir strips trailing slashes" {
  normalize_dir "/usr/local/bin///"
  [ "$_xpath_nd" = "/usr/local/bin" ]
}

@test "x-path: normalize_dir leaves the root directory alone" {
  normalize_dir "/"
  [ "$_xpath_nd" = "/" ]
}

@test "x-path: normalize_dir passes through a clean path unchanged" {
  normalize_dir "/opt/bin"
  [ "$_xpath_nd" = "/opt/bin" ]
}

@test "x-path: normalize_path_var normalizes every component" {
  PATH="/a/:/b//:/c"
  normalize_path_var
  [ "$PATH" = "/a:/b:/c" ]
}

@test "x-path: remove_from_path removes a middle entry" {
  PATH="/a:/b:/c"
  remove_from_path "/b"
  [ "$PATH" = "/a:/c" ]
}

@test "x-path: remove_from_path removes the first and last entries" {
  PATH="/a:/b:/c"
  remove_from_path "/a"
  remove_from_path "/c"
  [ "$PATH" = "/b" ]
}

@test "x-path: remove_from_path removes adjacent duplicates" {
  # ':/x:/x:' shares the middle colon between the two matches, so a single
  # substitution pass leaves the second copy behind. This is why the
  # implementation loops.
  PATH="/a:/x:/x:/b"
  remove_from_path "/x"
  [ "$PATH" = "/a:/b" ]
}

@test "x-path: remove_from_path removes three in a row" {
  PATH="/x:/x:/x"
  remove_from_path "/x"
  [ "$PATH" = "" ]
}

@test "x-path: append puts the directory last" {
  PATH="/a:/b"
  do_append "$TMP/one"
  [ "$PATH" = "/a:/b:$TMP/one" ]
}

@test "x-path: append moves an entry that is already in PATH to the end" {
  PATH="$TMP/one:/a"
  do_append "$TMP/one"
  [ "$PATH" = "/a:$TMP/one" ]
}

@test "x-path: append keeps the order of its arguments" {
  PATH="/usr/bin"
  do_append "$TMP/one" "$TMP/two" "$TMP/three"
  [ "$PATH" = "/usr/bin:$TMP/one:$TMP/two:$TMP/three" ]
}

@test "x-path: append ignores a repeated argument" {
  PATH="/usr/bin"
  do_append "$TMP/one" "$TMP/one"
  [ "$PATH" = "/usr/bin:$TMP/one" ]
}

@test "x-path: append normalizes before comparing" {
  PATH="/usr/bin"
  do_append "$TMP/one/" "$TMP/one"
  [ "$PATH" = "/usr/bin:$TMP/one" ]
}

@test "x-path: append handles a directory with a space in its name" {
  # The seen-list is colon-delimited for exactly this case; splitting on
  # spaces would treat '/with' and 'space' as separate entries.
  PATH="/usr/bin"
  do_append "$TMP/with space"
  [ "$PATH" = "/usr/bin:$TMP/with space" ]
}

@test "x-path: prepend puts the directory first" {
  PATH="/a:/b"
  do_prepend "$TMP/one"
  [ "$PATH" = "$TMP/one:/a:/b" ]
}

@test "x-path: prepend leaves the first argument leftmost" {
  PATH="/usr/bin"
  do_prepend "$TMP/one" "$TMP/two"
  [ "$PATH" = "$TMP/one:$TMP/two:/usr/bin" ]
}

@test "x-path: prepend moves an existing entry to the front" {
  PATH="/a:$TMP/one"
  do_prepend "$TMP/one"
  [ "$PATH" = "$TMP/one:/a" ]
}

@test "x-path: prepend skips a directory that does not exist" {
  PATH="/usr/bin"
  do_prepend "$TMP/nope"
  [ "$PATH" = "/usr/bin" ]
}

@test "x-path: remove takes the directory out" {
  PATH="/a:$TMP/one:/b"
  do_remove "$TMP/one"
  [ "$PATH" = "/a:/b" ]
}

@test "x-path: remove leaves PATH alone when the entry is absent" {
  PATH="/a:/b"
  do_remove "$TMP/one"
  [ "$PATH" = "/a:/b" ]
}

@test "x-path: remove works on a directory that no longer exists" {
  # Cleaning up after an uninstalled tool is the main reason to run remove,
  # so it must not require the directory to be present.
  PATH="/a:$TMP/gone:/b"
  do_remove "$TMP/gone"
  [ "$PATH" = "/a:/b" ]
}

@test "x-path: remove takes several directories at once" {
  PATH="/a:$TMP/one:/b:$TMP/two"
  do_remove "$TMP/one" "$TMP/two"
  [ "$PATH" = "/a:/b" ]
}

@test "x-path: check reports an existing directory as valid" {
  run do_check "$TMP/one"
  [[ "$output" == *"Valid:   $TMP/one"* ]]
}

@test "x-path: check reports a missing directory as invalid" {
  run do_check "$TMP/nope"
  [[ "$output" == *"Invalid: $TMP/nope"* ]]
}

@test "x-path: check with no arguments walks the whole PATH" {
  PATH="$TMP/one:$TMP/nope"
  run do_check
  [[ "$output" == *"Checking all directories in PATH"* ]]
  [[ "$output" == *"Valid:   $TMP/one"* ]]
  [[ "$output" == *"Invalid: $TMP/nope"* ]]
}

@test "x-path: VERBOSE explains what was skipped" {
  VERBOSE=1
  PATH="/usr/bin"
  run do_append "$TMP/nope"
  [[ "$output" == *"does not exist"* ]]
}

@test "x-path: quiet by default" {
  PATH="/usr/bin"
  run do_append "$TMP/one"
  [ -z "$output" ]
}

@test "x-path: no subcommand prints usage and exits 1" {
  run "$XPATH"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"append"* ]]
}

@test "x-path: an unknown subcommand is rejected" {
  run "$XPATH" frobnicate /tmp
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown command: frobnicate"* ]]
}

@test "x-path: append with no directory prints usage" {
  run "$XPATH" append
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}
