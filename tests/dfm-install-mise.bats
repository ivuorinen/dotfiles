#!/usr/bin/env bats

# `dfm install mise` installs the mise binary through mise.run when none is on
# PATH. mise.run writes ~/.local/bin/mise unless MISE_INSTALL_PATH says
# otherwise, while ensure_mise puts $XDG_BIN_HOME on PATH, so with a custom
# XDG_BIN_HOME the binary used to land where no later step looked for it.
# curl is a stub serving an installer that writes a fake mise to
# MISE_INSTALL_PATH (or mise.run's default), DOTFILES is a scratch tree whose
# shared.sh is empty, and PATH keeps no directory that holds a real mise.

setup()
{
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/dotfiles/config" "$TMP/dotfiles/local/bin" "$TMP/bin" \
    "$TMP/home" "$TMP/xdgbin"
  : > "$TMP/dotfiles/config/shared.sh"
  ln -s "$REPO/local/bin/msgr" "$TMP/dotfiles/local/bin/msgr"
  # dfm-install runs under `env bash`; keep this bash (4+) ahead of a system
  # bash 3.2, which dfm-lib's guard would refuse.
  ln -s "$BASH" "$TMP/bin/bash"

  # The installer goes to -o FILE, or to stdout without it. CURL_FAIL fails
  # the way `curl -f` does, writing nothing; CURL_CUT delivers the whole
  # script and then reports a broken transfer (exit 18), the case where a
  # piped-in installer had already run.
  cat > "$TMP/bin/curl" << 'STUB'
#!/usr/bin/env bash
[ -n "${CURL_FAIL:-}" ] && exit 22
out=/dev/stdout
while [ $# -gt 0 ]; do
  [ "$1" = "-o" ] && out="$2"
  shift
done
cat > "$out" << 'INSTALLER'
p="${MISE_INSTALL_PATH:-$HOME/.local/bin/mise}"
mkdir -p "${p%/*}"
printf '#!/bin/sh\nexit 0\n' > "$p"
chmod +x "$p"
INSTALLER
[ -n "${CURL_CUT:-}" ] && exit 18
exit 0
STUB
  chmod +x "$TMP/bin/curl"

  # The runner's own mise would make ensure_mise return before installing.
  NO_MISE_PATH=""
  local dir
  IFS=: read -ra dirs <<< "$PATH"
  for dir in "${dirs[@]}"; do
    [ -x "$dir/mise" ] && continue
    NO_MISE_PATH="${NO_MISE_PATH:+$NO_MISE_PATH:}$dir"
  done
}

teardown()
{
  rm -rf "$TMP"
}

# Run `dfm install mise`; extra NAME=value arguments go to env.
install_mise()
{
  run env PATH="$TMP/bin:$NO_MISE_PATH" HOME="$TMP/home" DOTFILES="$TMP/dotfiles" \
    GITHUB_TOKEN=test "$@" "$REPO/local/bin/dfm-install" mise
}

@test "dfm install mise: a custom XDG_BIN_HOME receives the mise binary" {
  install_mise XDG_BIN_HOME="$TMP/xdgbin"
  [ "$status" -eq 0 ]
  [ -x "$TMP/xdgbin/mise" ]
  [ ! -e "$TMP/home/.local/bin/mise" ]
  [[ "$output" == *"mise tools installed!"* ]]
}

@test "dfm install mise: a failed installer download fails the step" {
  install_mise XDG_BIN_HOME="$TMP/xdgbin" CURL_FAIL=1
  [ "$status" -ne 0 ]
  [[ "$output" == *"Failed to install mise"* ]]
  [[ "$output" != *"mise tools installed!"* ]]
}

@test "dfm install mise: a transfer cut after the script arrives runs nothing" {
  install_mise XDG_BIN_HOME="$TMP/xdgbin" CURL_CUT=1
  [ "$status" -ne 0 ]
  [[ "$output" == *"Failed to install mise"* ]]
  [ ! -e "$TMP/xdgbin/mise" ]
}

@test "dfm install mise: without XDG_BIN_HOME mise goes to ~/.local/bin" {
  run env -u XDG_BIN_HOME PATH="$TMP/bin:$NO_MISE_PATH" HOME="$TMP/home" \
    DOTFILES="$TMP/dotfiles" GITHUB_TOKEN=test "$REPO/local/bin/dfm-install" mise
  [ "$status" -eq 0 ]
  [ -x "$TMP/home/.local/bin/mise" ]
}
