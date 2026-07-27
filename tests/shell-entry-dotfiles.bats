#!/usr/bin/env bats
#
# Tests for the DOTFILES bootstrap in base/bashrc and base/zshrc.
#
# Both files must DEFAULT DOTFILES to $HOME/.dotfiles without stomping an
# inherited value: ./install exports DOTFILES="${BASEDIR}" so the repo can be
# installed from any checkout, and tests/*.bats point it at a fixture. An
# unconditional `export DOTFILES="$HOME/.dotfiles"` silently overrode both.
#
# Sourcing the rc files wholesale is not viable here (they pull in starship,
# antidote and ssh-add), so these tests eval the real assignment line lifted
# out of each file — a revert to the unconditional form fails them.

setup()
{
  export DOTFILES_REPO="$PWD"
}

# Extract the DOTFILES assignment as written in the file under test.
dotfiles_line()
{
  grep -m1 '^export DOTFILES=' "$DOTFILES_REPO/base/$1"
}

@test "bashrc has exactly one DOTFILES assignment" {
  run bash -c 'grep -c "^export DOTFILES=" "$DOTFILES_REPO/base/bashrc"'
  [ "$status" -eq 0 ]
  [ "$output" -eq 1 ]
}

@test "zshrc has exactly one DOTFILES assignment" {
  run bash -c 'grep -c "^export DOTFILES=" "$DOTFILES_REPO/base/zshrc"'
  [ "$status" -eq 0 ]
  [ "$output" -eq 1 ]
}

@test "bashrc defaults DOTFILES to \$HOME/.dotfiles when unset" {
  line="$(dotfiles_line bashrc)"
  run env -u DOTFILES HOME=/tmp/fake-home bash -c "$line"'; echo "$DOTFILES"'
  [ "$status" -eq 0 ]
  [ "$output" = "/tmp/fake-home/.dotfiles" ]
}

@test "zshrc defaults DOTFILES to \$HOME/.dotfiles when unset" {
  line="$(dotfiles_line zshrc)"
  run env -u DOTFILES HOME=/tmp/fake-home bash -c "$line"'; echo "$DOTFILES"'
  [ "$status" -eq 0 ]
  [ "$output" = "/tmp/fake-home/.dotfiles" ]
}

@test "bashrc keeps an inherited DOTFILES (./install, bats fixtures)" {
  line="$(dotfiles_line bashrc)"
  run env DOTFILES=/tmp/inherited-dotfiles HOME=/tmp/fake-home \
    bash -c "$line"'; echo "$DOTFILES"'
  [ "$status" -eq 0 ]
  [ "$output" = "/tmp/inherited-dotfiles" ]
}

@test "zshrc keeps an inherited DOTFILES (./install, bats fixtures)" {
  line="$(dotfiles_line zshrc)"
  run env DOTFILES=/tmp/inherited-dotfiles HOME=/tmp/fake-home \
    bash -c "$line"'; echo "$DOTFILES"'
  [ "$status" -eq 0 ]
  [ "$output" = "/tmp/inherited-dotfiles" ]
}

# DOTFILES must be set before the first line that dereferences it, in every
# file that both sets and uses it. Guards the ordering the fix relies on.
@test "every entry point sets DOTFILES before its first use" {
  for f in base/bashrc base/zshrc config/shared.sh config/exports; do
    set_line="$(grep -nE 'DOTFILES(=|:=|:-)' "$DOTFILES_REPO/$f" | head -1 | cut -d: -f1)"
    use_line="$(grep -nE '\$\{?DOTFILES\}?/' "$DOTFILES_REPO/$f" | head -1 | cut -d: -f1)"
    [ -n "$set_line" ]
    [ -n "$use_line" ]
    [ "$set_line" -le "$use_line" ]
  done
}
