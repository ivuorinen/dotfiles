#!/usr/bin/env bats
# The deja guard in config/fish/functions/deja.fish and config/exports.

setup()
{
  export DOTFILES_REPO="$PWD"
  STUB="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$STUB"
  printf '#!/bin/sh\nprintf "%%s\\n" "$@"\n' > "$STUB/deja"
  chmod +x "$STUB/deja"
}

# config/exports rebuilds PATH when sourced, so take only the function.
run_sh_deja()
{
  run env PATH="$STUB:$PATH" bash -c \
    'eval "$(sed -n "/^deja()\$/,/^}\$/p" "$DOTFILES_REPO/config/exports")"; deja "$@"' _ "$@"
}

run_fish_deja()
{
  command -v fish > /dev/null || skip "fish not installed"
  run env PATH="$STUB:$PATH" fish --no-config -c \
    'source "$DOTFILES_REPO/config/fish/functions/deja.fish"; deja $argv' -- "$@"
}

@test "deja guard refuses install and update, framed or not" {
  for runner in run_sh_deja run_fish_deja; do
    for args in "install --auto" "update" "--framed install pi-auto"; do
      # shellcheck disable=SC2086 # split the argument list on purpose
      $runner $args
      [ "$status" -eq 1 ]
      [[ "$output" == *"rewrites configs the dotfiles manage"* ]]
    done
  done
}

@test "deja guard passes every other command through unchanged" {
  for runner in run_sh_deja run_fish_deja; do
    $runner recall "two words" --limit 3
    [ "$status" -eq 0 ]
    [ "$output" = "$(printf '%s\n' recall "two words" --limit 3)" ]
  done
}
