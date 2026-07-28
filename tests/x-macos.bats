#!/usr/bin/env bats

# The x-macos-* wrappers each drive a macOS system command. They are grouped
# here because the contract is identical in shape: the right command with the
# right arguments, and — for the Finder pair — the specific boolean written,
# since hide and show differ only by that value and a swap would be silent.
#
# Every underlying tool is stubbed, so these run on Linux CI too.

setup()
{
  BIN="$BATS_TEST_DIRNAME/../local/bin"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin"
  CALLS="$TMP/calls"
  : > "$CALLS"
  for tool in dscacheutil killall defaults sudo; do
    cat > "$TMP/bin/$tool" << STUB
#!/usr/bin/env bash
printf '$tool %s\n' "\$*" >> "$CALLS"
STUB
    chmod +x "$TMP/bin/$tool"
  done
  # sudo must run through to the stubbed tool, not just record.
  cat > "$TMP/bin/sudo" << STUB
#!/usr/bin/env bash
printf 'sudo %s\n' "\$*" >> "$CALLS"
"\$@"
STUB
  chmod +x "$TMP/bin/sudo"
}

# x-macos-updatedb is deliberately absent from this file: it invokes
# /usr/libexec/locate.updatedb by absolute path, which PATH stubbing cannot
# intercept, and running it for real would rebuild the locate database.

teardown()
{
  rm -rf "$TMP"
}

@test "x-macos-flush: flushes the directory service cache" {
  run env PATH="$TMP/bin:$PATH" "$BIN/x-macos-flush"
  [ "$status" -eq 0 ]
  grep -q 'dscacheutil -flushcache' "$CALLS"
}

@test "x-macos-flushdns: flushes the cache and restarts mDNSResponder" {
  run env PATH="$TMP/bin:$PATH" "$BIN/x-macos-flushdns"
  [ "$status" -eq 0 ]
  grep -q 'dscacheutil -flushcache' "$CALLS"
  grep -q 'killall -HUP mDNSResponder' "$CALLS"
}

@test "x-macos-flushdns: uses sudo for both steps" {
  run env PATH="$TMP/bin:$PATH" "$BIN/x-macos-flushdns"
  [ "$(grep -c '^sudo ' "$CALLS")" -eq 2 ]
}

@test "x-macos-show: writes the true boolean" {
  run env PATH="$TMP/bin:$PATH" "$BIN/x-macos-show"
  [ "$status" -eq 0 ]
  grep -q 'AppleShowAllFiles -bool true' "$CALLS"
}

@test "x-macos-hide: writes the false boolean" {
  run env PATH="$TMP/bin:$PATH" "$BIN/x-macos-hide"
  [ "$status" -eq 0 ]
  grep -q 'AppleShowAllFiles -bool false' "$CALLS"
}

@test "x-macos-show and x-macos-hide are not the same command" {
  run env PATH="$TMP/bin:$PATH" "$BIN/x-macos-show"
  run env PATH="$TMP/bin:$PATH" "$BIN/x-macos-hide"
  [ "$(grep -c 'bool true' "$CALLS")" -eq 1 ]
  [ "$(grep -c 'bool false' "$CALLS")" -eq 1 ]
}

@test "x-macos-hide: restarts Finder" {
  run env PATH="$TMP/bin:$PATH" "$BIN/x-macos-hide"
  grep -q 'killall Finder' "$CALLS"
}

@test "x-macos-hide: survives Finder not running" {
  # killall exits non-zero when nothing matches; set -e must not abort.
  cat > "$TMP/bin/killall" << 'STUB'
#!/usr/bin/env bash
exit 1
STUB
  chmod +x "$TMP/bin/killall"
  run env PATH="$TMP/bin:$PATH" "$BIN/x-macos-hide"
  [ "$status" -eq 0 ]
}
