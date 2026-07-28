#!/usr/bin/env bats

# x-empty-trash and afk branch on the operating system. x-empty-trash runs
# `sudo rm -rf` on macOS, so its non-Darwin refusal is the safety-critical
# path and is asserted without ever reaching the deletion. uname is stubbed to
# drive both branches from either host.

setup()
{
  EMPTY_TRASH="$BATS_TEST_DIRNAME/../local/bin/x-empty-trash"
  AFK="$BATS_TEST_DIRNAME/../local/bin/afk"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin"
  CALLS="$TMP/calls"
  : > "$CALLS"
  # A sudo stub records instead of deleting, so a regression that removes the
  # OS guard is caught without touching the real filesystem.
  cat > "$TMP/bin/sudo" << STUB
#!/usr/bin/env bash
printf 'sudo %s\n' "\$*" >> "$CALLS"
STUB
  chmod +x "$TMP/bin/sudo"
  # Sealed PATH so the host's real loginctl cannot satisfy the first branch
  # and hide the fallback.
  for tool in bash env cat grep; do
    ln -sf "$(command -v "$tool")" "$TMP/bin/$tool"
  done
  STUB_PATH="$TMP/bin"
}

teardown()
{
  rm -rf "$TMP"
}

stub_uname()
{
  cat > "$TMP/bin/uname" << STUB
#!/usr/bin/env bash
echo "$1"
STUB
  chmod +x "$TMP/bin/uname"
}

@test "x-empty-trash: refuses to run off macOS" {
  stub_uname Linux
  run env PATH="$TMP/bin:$PATH" "$EMPTY_TRASH"
  [ "$status" -eq 1 ]
  [[ "$output" == *"macOS-only"* ]]
}

@test "x-empty-trash: deletes nothing off macOS" {
  stub_uname Linux
  run env PATH="$TMP/bin:$PATH" "$EMPTY_TRASH"
  [ ! -s "$CALLS" ]
}

@test "x-empty-trash: the refusal goes to stderr" {
  stub_uname Linux
  run env PATH="$TMP/bin:$PATH" bash -c "'$EMPTY_TRASH' 2>&1 >/dev/null"
  [[ "$output" == *"macOS-only"* ]]
}

@test "x-empty-trash: targets the trash paths on macOS" {
  stub_uname Darwin
  run env PATH="$TMP/bin:$PATH" HOME="$TMP/home" "$EMPTY_TRASH"
  [ "$status" -eq 0 ]
  grep -q '.Trash' "$CALLS"
  grep -q '.Trashes' "$CALLS"
}

@test "afk: uses osascript on macOS" {
  stub_uname Darwin
  cat > "$TMP/bin/osascript" << STUB
#!/usr/bin/env bash
printf 'osascript %s\n' "\$*" >> "$CALLS"
STUB
  chmod +x "$TMP/bin/osascript"
  run env PATH="$TMP/bin:$PATH" "$AFK"
  [ "$status" -eq 0 ]
  grep -q 'osascript' "$CALLS"
}

@test "afk: prefers loginctl on Linux" {
  stub_uname Linux
  cat > "$TMP/bin/loginctl" << STUB
#!/usr/bin/env bash
printf 'loginctl %s\n' "\$*" >> "$CALLS"
STUB
  chmod +x "$TMP/bin/loginctl"
  run env PATH="$STUB_PATH" "$AFK"
  [ "$status" -eq 0 ]
  grep -q 'loginctl lock-session' "$CALLS"
}

@test "afk: falls back to xdg-screensaver when loginctl is absent" {
  stub_uname Linux
  cat > "$TMP/bin/xdg-screensaver" << STUB
#!/usr/bin/env bash
printf 'xdg-screensaver %s\n' "\$*" >> "$CALLS"
STUB
  chmod +x "$TMP/bin/xdg-screensaver"
  run env PATH="$STUB_PATH" "$AFK"
  [ "$status" -eq 0 ]
  grep -q 'xdg-screensaver lock' "$CALLS"
}
