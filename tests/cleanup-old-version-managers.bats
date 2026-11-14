#!/usr/bin/env bats
#
# scripts/cleanup-old-version-managers.sh deletes files, so every test runs it
# against a scratch HOME and XDG tree. DOTFILES is a fake checkout whose
# shared.sh defines only what the script calls, because the real one sources
# config/exports, which rebuilds PATH and would drop the stubs below. brew is
# a stub on PATH, so no test can uninstall a real package.

setup()
{
  SCRIPT="$BATS_TEST_DIRNAME/../scripts/cleanup-old-version-managers.sh"
  FAKE="$BATS_TEST_TMPDIR/dotfiles"
  STUBS="$BATS_TEST_TMPDIR/stubs"
  HOME_DIR="$BATS_TEST_TMPDIR/home"
  LOCK="$HOME_DIR/.config/homebrew/Brewfile.lock.json"
  mkdir -p "$FAKE/config" "$STUBS" "$HOME_DIR/.config/homebrew"

  cat > "$FAKE/config/shared.sh" << 'EOF'
LIB_E_INVALID_ARGUMENT=1
logger::error() { echo "ERROR: $*" >&2; }
EOF
  printf '#!/bin/sh\nprintf "%%s\\n" "$*"\n' > "$STUBS/msgr"
  # `brew list PKG` fails, so every package reads as not installed.
  printf '#!/bin/sh\n[ "$1" = list ] && exit 1\nexit 0\n' > "$STUBS/brew"
  chmod +x "$STUBS/msgr" "$STUBS/brew"

  printf '{}\n' > "$LOCK"
  printf 'HOMEBREW_NO_ENV_HINTS=1\n' > "$HOME_DIR/.config/homebrew/brew.env"
}

run_cleanup()
{
  run env PATH="$STUBS:$PATH" HOME="$HOME_DIR" DOTFILES="$FAKE" \
    XDG_CONFIG_HOME="$HOME_DIR/.config" \
    XDG_DATA_HOME="$HOME_DIR/.local/share" \
    XDG_BIN_HOME="$HOME_DIR/.local/bin" \
    bash "$SCRIPT" "$@"
}

@test "cleanup-old-version-managers: removes the Homebrew Bundle lock file" {
  run_cleanup
  [ "$status" -eq 0 ]
  [ ! -e "$LOCK" ]
  [[ "$output" == *"Removed Homebrew Bundle lock file: $LOCK"* ]]
  # Only the lock file: brew.env sits next to it and stays.
  [ -f "$HOME_DIR/.config/homebrew/brew.env" ]
}

@test "cleanup-old-version-managers: --dry-run keeps the lock file" {
  run_cleanup --dry-run
  [ "$status" -eq 0 ]
  [ -f "$LOCK" ]
  [[ "$output" == *"[DRY RUN] Would remove Homebrew Bundle lock file: $LOCK"* ]]
}

@test "cleanup-old-version-managers: a missing lock file is not reported" {
  rm "$LOCK"
  run_cleanup
  [ "$status" -eq 0 ]
  [[ "$output" != *"Homebrew Bundle lock file"* ]]
}
