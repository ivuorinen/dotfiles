#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

# scripts/install-xcode-cli-tools.sh on a fresh Mac: `xcode-select -p` exits 2
# until the Command Line Tools exist, and the script must reach the install
# prompt rather than die under set -e, then wait a bounded time. Every
# system tool it touches is a PATH stub, and DOTFILES points at a scratch
# tree whose shared.sh is empty so the real environment is never loaded.

setup()
{
  SCRIPT="$BATS_TEST_DIRNAME/../scripts/install-xcode-cli-tools.sh"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin" "$TMP/dotfiles/config" "$TMP/dev/usr/bin"
  : > "$TMP/dotfiles/config/shared.sh"
  printf '#!/bin/sh\n' > "$TMP/dev/usr/bin/swift"
  chmod +x "$TMP/dev/usr/bin/swift"
  CALLS="$TMP/calls"
  : > "$CALLS"

  # -p reports the developer dir only from the READY_AFTER-th call on, the
  # way it starts working once the installer has finished.
  cat > "$TMP/bin/xcode-select" << STUB
#!/usr/bin/env bash
if [ "\$1" = "-p" ]; then
  printf 'p\n' >> "$TMP/p-calls"
  n=\$(wc -l < "$TMP/p-calls")
  [ "\$n" -gt "\${READY_AFTER:-0}" ] || exit 2
  printf '%s\n' "$TMP/dev"
  exit 0
fi
printf 'xcode-select %s\n' "\$*" >> "$CALLS"
STUB

  # Only the password prompt is logged; the keep-alive loop calls sudo -n.
  cat > "$TMP/bin/sudo" << STUB
#!/usr/bin/env bash
[ "\$1" = "-v" ] && printf 'sudo -v\n' >> "$CALLS"
exit 0
STUB

  # Real `display dialog` reports only OK on stdout; Cancel is AppleScript
  # error -128 on stderr with exit 1.
  cat > "$TMP/bin/osascript" << 'STUB'
#!/usr/bin/env bash
if [ "${DIALOG_BUTTON:-OK}" = OK ]; then
  printf 'button returned:OK\n'
  exit 0
fi
printf '6:22: execution error: User canceled. (-128)\n' >&2
exit 1
STUB

  printf '#!/bin/sh\nprintf "Darwin\\n"\n' > "$TMP/bin/uname"
  printf '#!/bin/sh\nexit 0\n' > "$TMP/bin/sleep"
  printf '#!/bin/sh\nprintf "%%s\\n" "$*"\n' > "$TMP/bin/msgr"
  chmod +x "$TMP/bin/"*
}

teardown()
{
  rm -rf "$TMP"
}

xcode()
{
  run env PATH="$TMP/bin:$PATH" DOTFILES="$TMP/dotfiles" "$@" bash "$SCRIPT"
}

@test "install-xcode-cli-tools: installed tools need no sudo and no prompt" {
  xcode READY_AFTER=0
  [ "$status" -eq 0 ]
  [[ "$output" == *"You have swift from xcode-select"* ]]
  [ ! -s "$CALLS" ]
}

@test "install-xcode-cli-tools: missing tools reach the install prompt" {
  # xcode-select -p exits 2 here; a bare call used to end the script.
  xcode READY_AFTER=3
  [ "$status" -eq 0 ]
  grep -q '^sudo -v$' "$CALLS"
  grep -q '^xcode-select --install$' "$CALLS"
}

@test "install-xcode-cli-tools: gives up when the tools never appear" {
  xcode READY_AFTER=999999 XCODE_INSTALL_TIMEOUT=3
  [ "$status" -eq 1 ]
  [[ "$output" == *"Timed out after 3s"* ]]
  grep -q '^xcode-select --install$' "$CALLS"
}

@test "install-xcode-cli-tools: a cancelled dialog stops without installing" {
  xcode READY_AFTER=999999 DIALOG_BUTTON=Cancel
  [ "$status" -eq 1 ]
  [[ "$output" == *"cancelled the installation"* ]]
  [[ "$output" != *"(-128)"* ]]
  run ! grep -q 'xcode-select --install' "$CALLS"
}
