#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

# scripts/install-gh-extensions.sh installs every extension at its pin. `gh
# extension install` exits 0 for an extension that is already installed
# without applying --pin, so the script compares `gh extension list` with each
# pin and reinstalls on a mismatch. gh is a PATH stub that serves a fixture
# listing and logs every other call; DOTFILES points at a scratch tree whose
# shared.sh is empty.

setup()
{
  SCRIPT="$BATS_TEST_DIRNAME/../scripts/install-gh-extensions.sh"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin" "$TMP/dotfiles/config"
  : > "$TMP/dotfiles/config/shared.sh"
  CALLS="$TMP/calls"
  : > "$CALLS"

  # Installed: gh-dash at its tag pin, gh-clean-branches at its commit pin
  # (gh shows 8 characters), gh-changelog at an older tag. The rest are absent.
  printf 'gh dash\tdlvhdr/gh-dash\tv4.24.1\n' > "$TMP/list"
  printf 'gh clean-branches\tdavidraviv/gh-clean-branches\t85fcbd7e\n' >> "$TMP/list"
  printf 'gh changelog\tchelnak/gh-changelog\tv0.14.0\n' >> "$TMP/list"

  cat > "$TMP/bin/gh" << STUB
#!/usr/bin/env bash
if [ "\$1 \$2" = "extension list" ]; then cat "$TMP/list"; exit 0; fi
printf 'gh %s\n' "\$*" >> "$CALLS"
STUB
  printf '#!/bin/sh\nprintf "%%s\\n" "$*"\n' > "$TMP/bin/msgr"
  chmod +x "$TMP/bin/"*
}

teardown()
{
  rm -rf "$TMP"
}

# Run the script against the stubs.
run_install()
{
  run env PATH="$TMP/bin:$PATH" DOTFILES="$TMP/dotfiles" bash "$SCRIPT"
}

@test "install-gh-extensions: extensions already at their pin are left alone" {
  run_install
  [ "$status" -eq 0 ]
  run ! grep -q 'dlvhdr/gh-dash' "$CALLS"
  run ! grep -q 'davidraviv/gh-clean-branches' "$CALLS"
}

@test "install-gh-extensions: an installed extension at another version is reinstalled at its pin" {
  run_install
  [ "$status" -eq 0 ]
  grep -qx 'gh extension remove changelog' "$CALLS"
  grep -qx 'gh extension install chelnak/gh-changelog --pin v0.15.3' "$CALLS"
  [ "$(grep -n 'changelog' "$CALLS" | head -1)" = "$(grep -n 'remove changelog' "$CALLS")" ]
}

@test "install-gh-extensions: a missing extension is installed at its pin without a remove" {
  run_install
  [ "$status" -eq 0 ]
  grep -qx 'gh extension install rsese/gh-actions-status --pin v1.3.1' "$CALLS"
  grep -qx 'gh extension install andyfeller/gh-montage --pin 93491361febeab8038c95d3ca717e8b5d542a80e' "$CALLS"
  [ "$(grep -c 'extension remove' "$CALLS")" -eq 1 ]
}
