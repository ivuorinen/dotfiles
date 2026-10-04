#!/usr/bin/env bats
#
# Tests for config/zsh/antidote.zsh, plus the zshrc and alias lines that
# changed with it.
#
# antidote is replaced by a stub function file so the tests run offline and
# can force bundle success or failure.

setup()
{
  REPO="$PWD"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/antidote/functions" "$TMP/cfg"
  printf 'some/plugin\n' > "$TMP/cfg/plugins.txt"
}

teardown()
{
  rm -rf "$TMP"
}

# Write the stub antidote function body (autoload -Uz reads it as a function).
stub_antidote()
{
  printf '%s\n' "$1" > "$TMP/antidote/functions/antidote"
}

source_antidote()
{
  run env DOTFILES="$REPO" ANTIDOTE_DIR="$TMP/antidote" \
    ANTIDOTE_HOME="$TMP/home" ANTIDOTE_PLUGINS="$TMP/cfg/plugins" \
    zsh -f -c 'source "$DOTFILES/config/zsh/antidote.zsh"; echo "rc=$? bundled=${BUNDLED:-0}"'
}

@test "empty antidote directory (uninitialised submodule) warns and skips" {
  rm -rf "$TMP/antidote/functions"
  source_antidote
  [ "$status" -eq 0 ]
  [[ "$output" == *"antidote missing"* ]]
  [[ "$output" == *"rc=0"* ]]
  [ ! -e "$TMP/cfg/plugins.zsh" ]
}

@test "failed bundle leaves no bundle file behind" {
  stub_antidote 'return 1'
  source_antidote
  [ "$status" -eq 0 ]
  [ ! -e "$TMP/cfg/plugins.zsh" ]
  [ ! -e "$TMP/cfg/plugins.zsh.tmp" ]
}

@test "successful bundle is written and sourced" {
  stub_antidote "print 'typeset -g BUNDLED=1'"
  source_antidote
  [ "$status" -eq 0 ]
  [[ "$output" == *"bundled=1"* ]]
  [ -s "$TMP/cfg/plugins.zsh" ]
}

@test "0-byte bundle newer than the plugin list is rebuilt" {
  stub_antidote "print 'typeset -g BUNDLED=1'"
  touch -t 202001010000 "$TMP/cfg/plugins.txt"
  : > "$TMP/cfg/plugins.zsh"
  source_antidote
  [ "$status" -eq 0 ]
  [[ "$output" == *"bundled=1"* ]]
  [ -s "$TMP/cfg/plugins.zsh" ]
}

# Runs only base/zshrc's gpg-agent ssh block, with a stub gpgconf so the
# result does not depend on the host's gnupg install. Extra arguments go to
# env(1) ahead of zsh, to set or unset SSH_AUTH_SOCK.
gpg_ssh_block()
{
  mkdir -p "$TMP/gpgbin"
  printf '#!/bin/sh\necho %s\n' "$TMP/S.gpg-agent.ssh" > "$TMP/gpgbin/gpgconf"
  chmod +x "$TMP/gpgbin/gpgconf"
  # "$@" first: env stops reading options (-u) at its first NAME=value.
  run env "$@" PATH="$TMP/gpgbin:$PATH" zsh -fc "
    source <(sed -n '/gpg-agent serves ssh keys/,/^fi\$/p' '$REPO/base/zshrc')
    print -r -- \"sock=\$SSH_AUTH_SOCK\"
    print -r -- \"preexec=\${preexec_functions[*]}\""
}

@test "zshrc: gpg-agent takes an unclaimed SSH_AUTH_SOCK and repoints pinentry per command" {
  gpg_ssh_block -u SSH_AUTH_SOCK
  [ "$status" -eq 0 ]
  [[ "$output" == *"sock=$TMP/S.gpg-agent.ssh"* ]]
  [[ "$output" == *"preexec="*"_gpg_ssh_updatetty"* ]]
}

@test "zshrc: an agent already in SSH_AUTH_SOCK wins and no per-command hook runs" {
  gpg_ssh_block SSH_AUTH_SOCK=/tmp/other-agent.sock
  [ "$status" -eq 0 ]
  [[ "$output" == *"sock=/tmp/other-agent.sock"* ]]
  [[ "$output" != *"_gpg_ssh_updatetty"* ]]
}

@test "config/alias keys host alias files on SHORT_HOST, not hostname" {
  run grep -n 'alias-\$(hostname)' "$REPO/config/alias"
  [ "$status" -eq 1 ]
  run grep -c 'alias-\$SHORT_HOST' "$REPO/config/alias"
  [ "$output" -eq 2 ]
}

@test "fish keys host exports on SHORT_HOST, ignoring an inherited HOSTNAME" {
  run grep -n 'hosts/\$HOSTNAME' "$REPO/config/fish/exports.fish"
  [ "$status" -eq 1 ]
  line="$(grep -m1 '^set -gx SHORT_HOST' "$REPO/config/fish/exports.fish")"
  [ -n "$line" ]
  run env HOSTNAME=inherited.example.org fish -N -c "$line; echo \$SHORT_HOST"
  [ "$status" -eq 0 ]
  [ "$output" = "$(hostname -s)" ]
}
