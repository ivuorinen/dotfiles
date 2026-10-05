#!/usr/bin/env bats
# Coverage for ./install's host-overlay dispatch (audit-ba782899): the
# hosts/<host>/install.conf.yaml step must run on `--links` too, minus its
# shell provisioning directives. The real install is copied into a
# throwaway BASEDIR whose dotbot binary only records its arguments, and
# git/hostname are stubbed on PATH so nothing touches the real repo.

bats_require_minimum_version 1.5.0

setup()
{
  BASE="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$BASE/tools/dotbot/bin" "$BASE/hosts/testhost" "$BATS_TEST_TMPDIR/bin"
  cp "${BATS_TEST_DIRNAME}/../install" "$BASE/install"
  printf -- '---\n' > "$BASE/hosts/testhost/install.conf.yaml"

  LOG="$BATS_TEST_TMPDIR/dotbot.log"
  export LOG
  printf '#!/usr/bin/env bash\necho "$*" >> "$LOG"\n' > "$BASE/tools/dotbot/bin/dotbot"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$BATS_TEST_TMPDIR/bin/git"
  printf '#!/usr/bin/env bash\necho testhost\n' > "$BATS_TEST_TMPDIR/bin/hostname"
  chmod +x "$BASE/tools/dotbot/bin/dotbot" "$BATS_TEST_TMPDIR/bin/git" "$BATS_TEST_TMPDIR/bin/hostname"
  export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
  # The stale-credentials check reads $HOME; keep it off the real one.
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME"
}

@test "install --links: applies the host overlay without shell steps" {
  run -0 bash "$BASE/install" --links
  run -0 cat "$LOG"
  [[ "${lines[0]}" == *"-c dotbot-links.yaml"* ]]
  [[ "${lines[1]}" == *"-c $BASE/hosts/testhost/install.conf.yaml --except shell"* ]]
  [[ "${lines[1]}" != *"snap"* ]]
  [ "${#lines[@]}" -eq 2 ]
}

@test "install: full run applies the host overlay with every directive" {
  run -0 bash "$BASE/install"
  run -0 cat "$LOG"
  [[ "${lines[0]}" == *"-c install.conf.yaml"* ]]
  [[ "${lines[1]}" == *"-c $BASE/hosts/testhost/install.conf.yaml"* ]]
  [[ "${lines[1]}" != *"--except"* ]]
}

@test "install --links: a host without an overlay runs only the link config" {
  rm "$BASE/hosts/testhost/install.conf.yaml"
  run -0 bash "$BASE/install" --links
  run -0 cat "$LOG"
  [ "${#lines[@]}" -eq 1 ]
}

@test "install: warns about the plaintext file the old git store helper left" {
  mkdir -p "$HOME/.cache/git"
  : > "$HOME/.cache/git/git-credentials"
  run -0 --separate-stderr bash "$BASE/install" --links
  [[ "$stderr" == *"$HOME/.cache/git/git-credentials holds plaintext tokens"* ]]
  [[ "$stderr" == *"rm '$HOME/.cache/git/git-credentials'"* ]]
  # A warning only: the file is the user's to revoke and delete.
  [ -e "$HOME/.cache/git/git-credentials" ]
}

@test "install: no credentials warning when the old store file is absent" {
  run -0 --separate-stderr bash "$BASE/install" --links
  [[ "$stderr" != *"git-credentials"* ]]
}
