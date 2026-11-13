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
  [[ "${lines[0]}" == *"-c tools/dotbot-defaults.yaml dotbot-links.yaml"* ]]
  [[ "${lines[1]}" == *"-c tools/dotbot-defaults.yaml $BASE/hosts/testhost/install.conf.yaml --except shell"* ]]
  [[ "${lines[1]}" != *"snap"* ]]
  [ "${#lines[@]}" -eq 2 ]
}

@test "install: full run applies the host overlay with every directive" {
  run -0 bash "$BASE/install"
  run -0 cat "$LOG"
  [[ "${lines[0]}" == *"-c tools/dotbot-defaults.yaml dotbot-links.yaml install.conf.yaml"* ]]
  [[ "${lines[1]}" == *"-c tools/dotbot-defaults.yaml $BASE/hosts/testhost/install.conf.yaml"* ]]
  [[ "${lines[1]}" != *"--except"* ]]
}

@test "install: never loads a plugin directory" {
  # dotbot runs several -c files in order; the include plugin that used to
  # chain them broke on dotbot 1.24 and is gone.
  run -0 bash "$BASE/install"
  run -0 bash "$BASE/install" --links
  run -0 cat "$LOG"
  [[ "$output" != *"--plugin"* ]]
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

# A failed task in the main run (a `dfm install all` step that exits non-zero)
# used to stop ./install under `set -e`, skipping the host overlay and the
# after.d hooks that run on every install. Both must still run, and install
# must still report the failure.
@test "install: a failing main run still applies the host overlay and after.d hooks" {
  cat > "$BASE/tools/dotbot/bin/dotbot" << 'EOF'
#!/usr/bin/env bash
echo "$*" >> "$LOG"
case " $* " in
  *" install.conf.yaml "*) exit 1 ;;
esac
EOF
  mkdir -p "$BASE/hosts/testhost/after.d"
  printf '#!/usr/bin/env bash\ntouch "%s"\n' "$BATS_TEST_TMPDIR/after-ran" \
    > "$BASE/hosts/testhost/after.d/10-marker"
  chmod +x "$BASE/hosts/testhost/after.d/10-marker"

  run bash "$BASE/install"
  [ "$status" -eq 1 ]
  [ -e "$BATS_TEST_TMPDIR/after-ran" ]
  run -0 cat "$LOG"
  [[ "${lines[1]}" == *"$BASE/hosts/testhost/install.conf.yaml"* ]]
}

@test "install: a failing host overlay is reported after the after.d hooks" {
  cat > "$BASE/tools/dotbot/bin/dotbot" << 'EOF'
#!/usr/bin/env bash
echo "$*" >> "$LOG"
case "$*" in
  */hosts/testhost/install.conf.yaml*) exit 3 ;;
esac
EOF
  mkdir -p "$BASE/hosts/testhost/after.d"
  printf '#!/usr/bin/env bash\ntouch "%s"\n' "$BATS_TEST_TMPDIR/after-ran" \
    > "$BASE/hosts/testhost/after.d/10-marker"
  chmod +x "$BASE/hosts/testhost/after.d/10-marker"

  run bash "$BASE/install"
  [ "$status" -eq 3 ]
  [ -e "$BATS_TEST_TMPDIR/after-ran" ]
}
