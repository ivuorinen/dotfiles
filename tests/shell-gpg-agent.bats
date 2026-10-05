#!/usr/bin/env bats
#
# Tests for the gpg-agent blocks in base/bashrc and config/fish/config.fish:
# GPG_TTY and the bash PROMPT_COMMAND hook that re-points pinentry at the
# current tty.
#
# Sourcing the rc files wholesale pulls in starship, antidote and ssh-add (see
# tests/shell-entry-dotfiles.bats), so these tests eval the real blocks lifted
# out of each file — a revert of any guard fails them.

setup()
{
  export DOTFILES_REPO="$PWD"
  BLOCK="$(sed -n '/^# pinentry prompts on this tty/,/^  unset _gpg_ssh_sock$/p' \
    "$DOTFILES_REPO/base/bashrc")"$'\nfi'
  STUB="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$STUB"
  printf '#!/bin/sh\necho /tmp/gpg-agent.ssh\n' > "$STUB/gpgconf"
  chmod +x "$STUB/gpgconf"
}

@test "bashrc: the gpg-agent block is found" {
  [[ "$BLOCK" == *GPG_TTY* ]]
  [[ "$BLOCK" == *_gpg_ssh_updatetty* ]]
}

@test "bashrc: GPG_TTY is not exported without a terminal" {
  # `tty` prints "not a tty" and exits 1 without one; that string was
  # exported as GPG_TTY in IDE subprocesses and BASH_ENV shells.
  run bash -c "unset GPG_TTY; PATH=/usr/bin:/bin; $BLOCK"$'\n''declare -p GPG_TTY 2> /dev/null || echo unset' \
    < /dev/null
  [ "$status" -eq 0 ]
  [ "$output" = "unset" ]
}

@test "fish: GPG_TTY is not exported without a terminal" {
  # `fish -i` with no terminal is still interactive, so the
  # `status is-interactive` guard alone exported "not a tty".
  command -v fish > /dev/null || skip "fish not installed"
  fish_block="$(sed -n '/if set -l gpg_tty (tty/,/^    end$/p' \
    "$DOTFILES_REPO/config/fish/config.fish")"
  [[ "$fish_block" == *GPG_TTY* ]]
  run fish -c "set -gx GPG_TTY stale"$'\n'"$fish_block"$'\n''set -q GPG_TTY; and echo "[$GPG_TTY]"; or echo unset' \
    < /dev/null
  [ "$status" -eq 0 ]
  [ "$output" = "unset" ]
}

@test "bashrc: sourcing twice registers the prompt hook once" {
  run bash -c "unset SSH_AUTH_SOCK; PROMPT_COMMAND=other; PATH=$STUB:\$PATH"$'\n'"$BLOCK"$'\n'"$BLOCK"$'\n''echo "$PROMPT_COMMAND"' \
    < /dev/null
  [ "$status" -eq 0 ]
  [ "$output" = "_gpg_ssh_updatetty;other" ]
}

@test "bashrc: an array PROMPT_COMMAND keeps its other elements" {
  # Bash 5.1+ accepts an array. The scalar assignment rewrites element 0
  # only, so the hook joins the first command and the rest stay as they are.
  run bash -c "unset SSH_AUTH_SOCK; PROMPT_COMMAND=(a b); PATH=$STUB:\$PATH"$'\n'"$BLOCK"$'\n''printf "%s|" "${PROMPT_COMMAND[@]}"' \
    < /dev/null
  [ "$status" -eq 0 ]
  [ "$output" = "_gpg_ssh_updatetty;a|b|" ]
}
