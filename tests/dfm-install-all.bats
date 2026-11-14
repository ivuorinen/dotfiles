#!/usr/bin/env bats
# Tests for `dfm install all` (local/bin/dfm-install).
#
# Every installer it calls comes from a fake DOTFILES tree (stub scripts and
# an is-sudoer stub) or from stubs first on PATH (mise, gh), and each records
# its call. The fake tree's config/shared.sh is empty, so the full bootstrap
# never runs the real config/exports and PATH stays as the test set it.

setup()
{
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  DFM="$REPO/local/bin/dfm"
  FAKE="$BATS_TEST_TMPDIR/dotfiles"
  STUBS="$BATS_TEST_TMPDIR/stubs"
  CALLS="$BATS_TEST_TMPDIR/calls"
  mkdir -p "$FAKE/config" "$FAKE/local/bin" "$FAKE/scripts" "$STUBS"
  : > "$FAKE/config/shared.sh"
  : > "$CALLS"
  local s
  for s in install-xcode-cli-tools install-fonts install-cheat-test install-gh-extensions install-completions; do
    script_stub "$s" 0
  done
  sudoer_stub 0
  mise_stub 0
  printf '#!/bin/sh\nexit 0\n' > "$STUBS/gh"
  chmod +x "$STUBS/gh"
}

# script_stub NAME STATUS — scripts/NAME.sh records its run and exits STATUS.
script_stub()
{
  printf '#!/bin/sh\necho "%s" >> "%s"\nexit %s\n' "$1" "$CALLS" "$2" > "$FAKE/scripts/$1.sh"
}

sudoer_stub()
{
  printf '#!/bin/sh\nexit %s\n' "$1" > "$FAKE/local/bin/is-sudoer"
  chmod +x "$FAKE/local/bin/is-sudoer"
}

# mise_stub STATUS — mise records its arguments; `bootstrap` exits STATUS.
mise_stub()
{
  printf '#!/bin/sh\necho "mise $*" >> "%s"\n[ "$1" = bootstrap ] && exit %s\nexit 0\n' \
    "$CALLS" "$1" > "$STUBS/mise"
  chmod +x "$STUBS/mise"
}

run_all()
{
  run env PATH="$STUBS:$PATH" DOTFILES="$FAKE" "$DFM" install all < /dev/null
}

@test "dfm install all: runs mise bootstrap, the tools and the installers" {
  run_all
  [ "$status" -eq 0 ]
  [[ "$output" == *"All done!"* ]]
  grep -qx 'mise bootstrap --yes --skip tools' "$CALLS"
  grep -qx 'mise install --yes' "$CALLS"
  grep -qx 'mise reshim' "$CALLS"
  grep -qx 'install-cheat-test' "$CALLS"
  grep -qx 'install-gh-extensions' "$CALLS"
  grep -qx 'install-completions' "$CALLS"
  # The bootstrap (packages, macOS defaults, login shell) runs before the tools.
  [ "$(grep -n 'mise bootstrap' "$CALLS" | cut -d: -f1)" -lt "$(grep -n 'mise install' "$CALLS" | cut -d: -f1)" ]
}

@test "dfm install all: fonts come from install-fonts.sh on Linux only" {
  run_all
  if [[ $OSTYPE == darwin* ]]; then
    ! grep -qx 'install-fonts' "$CALLS"
  else
    grep -qx 'install-fonts' "$CALLS"
  fi
}

@test "dfm install all: a user without sudo rights skips the packages part" {
  sudoer_stub 1
  run_all
  [ "$status" -eq 0 ]
  grep -qx 'mise bootstrap --yes --skip tools,packages' "$CALLS"
  [[ "$output" == *"system packages (no sudo rights)"* ]]
}

@test "dfm install all: a failed step is named and fails the run" {
  script_stub install-cheat-test 1
  run_all
  [ "$status" -eq 1 ]
  [[ "$output" == *"Completed with 1 failed step(s)"* ]]
  [[ "$output" == *"cheat databases"* ]]
  [[ "$output" != *"All done!"* ]]
  # Every later step still ran.
  grep -qx 'install-gh-extensions' "$CALLS"
  grep -qx 'install-completions' "$CALLS"
}

@test "dfm install cheat-databases: a failing script fails the step even when a later one passes" {
  script_stub install-cheat-a 1
  script_stub install-cheat-test 0
  run env PATH="$STUBS:$PATH" DOTFILES="$FAKE" "$DFM" install cheat-databases < /dev/null
  [ "$status" -eq 1 ]
  [[ "$output" == *"install-cheat-a.sh failed"* ]]
  grep -qx 'install-cheat-a' "$CALLS"
  grep -qx 'install-cheat-test' "$CALLS"
}

@test "dfm install all: a failed mise bootstrap fails the run but the tools still install" {
  mise_stub 1
  run_all
  [ "$status" -eq 1 ]
  [[ "$output" == *"mise bootstrap"* ]]
  grep -qx 'mise install --yes' "$CALLS"
}
