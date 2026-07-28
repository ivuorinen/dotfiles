#!/usr/bin/env bats

# dfm ssh is the second section tests/dfm.bats never reaches, and the one the
# repo documented nowhere until this session.
#
# Only the menu and dispatch surface is covered. Every action reads the user's
# real ~/.ssh, appends to allowed_signers, or fetches github.com/<user>.keys,
# and dfm cannot be isolated with a stubbed PATH — it sources config/exports
# during bootstrap, which rebuilds PATH and drops the stub directory. Calling
# an action here would touch real SSH configuration.

setup()
{
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  DFM="$REPO/local/bin/dfm"
}

@test "dfm ssh: bare invocation lists every subcommand" {
  run env DOTFILES="$REPO" "$DFM" ssh
  [ "$status" -eq 0 ]
  [[ "$output" == *"signers"* ]]
  [[ "$output" == *"check"* ]]
  [[ "$output" == *"github"* ]]
}

@test "dfm ssh: the menu explains that check writes nothing" {
  run env DOTFILES="$REPO" "$DFM" ssh
  [[ "$output" == *"Dry run"* ]]
  [[ "$output" == *"write nothing"* ]]
}

@test "dfm ssh: the menu documents the github user argument" {
  run env DOTFILES="$REPO" "$DFM" ssh
  [[ "$output" == *"github <user>"* ]]
}

@test "dfm ssh: an unknown subcommand shows the menu instead of acting" {
  run env DOTFILES="$REPO" "$DFM" ssh definitely-not-a-subcommand
  [ "$status" -eq 0 ]
  [[ "$output" == *"signers"* ]]
}

@test "dfm ssh: the section is reachable through the dispatcher" {
  # dfm-ssh is resolved dynamically as dfm-<section>; this is the regression
  # that left it working but absent from every document.
  run env DOTFILES="$REPO" "$DFM" ssh
  [ "$status" -eq 0 ]
  [[ "$output" != *"not a dfm command"* ]]
}

@test "dfm ssh: appears in the top-level dfm listing" {
  run env DOTFILES="$REPO" "$DFM"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ssh"* ]]
}

@test "dfm ssh: the menu entries match the USAGE spec" {
  run env DOTFILES="$REPO" "$DFM" ssh
  spec=$(grep -oE '^#USAGE   cmd "[a-z-]+"' "$REPO/local/bin/dfm-ssh" | sed 's/.*"\(.*\)"/\1/' | sort -u)
  for entry in $spec; do
    [[ "$output" == *"$entry"* ]] || {
      echo "USAGE declares '$entry' but the menu does not list it"
      return 1
    }
  done
}
