#!/usr/bin/env bats

# x-apply-uhk-layout installs a udev hwdb rule with sudo and rebuilds the
# hwdb database. Only the guard that runs BEFORE any of that is covered: the
# tests assert it refuses a missing source file and that nothing reaches
# sudo, using a recording sudo stub that would expose a regression removing
# the guard.
#
# The install path itself is deliberately not exercised. It writes to
# /etc/udev/hwdb.d and triggers udev, which is not something a test suite
# should do to the machine running it.

setup()
{
  UHK="$BATS_TEST_DIRNAME/../local/bin/x-apply-uhk-layout"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin" "$TMP/dotfiles/local/bin" "$TMP/dotfiles/config/udev"
  SUDO_CALLS="$TMP/sudo-calls"
  : > "$SUDO_CALLS"
  cat > "$TMP/bin/sudo" << STUB
#!/usr/bin/env bash
printf 'sudo %s\n' "\$*" >> "$SUDO_CALLS"
STUB
  chmod +x "$TMP/bin/sudo"
  # A DOTFILES tree with msgr but no hwdb rule.
  cp "$BATS_TEST_DIRNAME/../local/bin/msgr" "$TMP/dotfiles/local/bin/msgr"
}

teardown()
{
  rm -rf "$TMP"
}

@test "x-apply-uhk-layout: refuses when the hwdb rule is missing" {
  run env PATH="$TMP/bin:$PATH" DOTFILES="$TMP/dotfiles" "$UHK"
  [ "$status" -eq 1 ]
}

@test "x-apply-uhk-layout: works without msgr installed on PATH" {
  # The DOTFILES tree is the only place msgr has to be. Calling a bare `msgr`
  # would need the install symlink on PATH, which defeats the fallback the
  # script does for exactly that case — and is why this failed on CI, where
  # nothing is installed, while passing on a machine that has run ./install.
  for tool in bash env dirname; do
    ln -sf "$(command -v "$tool")" "$TMP/bin/$tool"
  done
  run env PATH="$TMP/bin" DOTFILES="$TMP/dotfiles" "$UHK"
  [ "$status" -eq 1 ]
  [[ "$output" != *"command not found"* ]]
}

@test "x-apply-uhk-layout: names the missing rule file" {
  run env PATH="$TMP/bin:$PATH" DOTFILES="$TMP/dotfiles" bash -c "'$UHK' 2>&1"
  [ "$status" -eq 1 ]
  [[ "$output" == *"hwdb rule not found"* ]]
  [[ "$output" == *"90-uhk-iso-key.hwdb"* ]]
}

@test "x-apply-uhk-layout: touches nothing with sudo when the rule is missing" {
  # The guard must come before the install, or a fresh checkout without the
  # rule would still run sudo cp and systemd-hwdb update.
  run env PATH="$TMP/bin:$PATH" DOTFILES="$TMP/dotfiles" "$UHK"
  [ ! -s "$SUDO_CALLS" ]
}

@test "x-apply-uhk-layout: the rule it installs exists in this repo" {
  # The guard above only proves the failure path. This proves the real
  # DOTFILES tree actually ships the file the script expects.
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  [ -f "$REPO/config/udev/90-uhk-iso-key.hwdb" ]
}
