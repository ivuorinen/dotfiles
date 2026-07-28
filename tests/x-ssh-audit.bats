#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

# x-ssh-audit connects to a list of hosts, reads their sshd configuration and
# reports what is insecure. ssh is stubbed, so no connection is made and no
# remote host is touched — including on the remediation path, which otherwise
# rewrites sshd_config and restarts the daemon.
#
# The script writes its audit tree into the current directory, so the tests
# run in a scratch directory.

setup()
{
  SA="$BATS_TEST_DIRNAME/../local/bin/x-ssh-audit"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin" "$TMP/work"
  CALLS="$TMP/calls"
  : > "$CALLS"
  for tool in sh bash env date sed awk grep cut head wc tr mkdir rm mv cat printf sort basename dirname whoami find; do
    src="$(command -v "$tool")" && ln -sf "$src" "$TMP/bin/$tool"
  done
  # A no-op sleep: the retry loop backs off for seconds at a time, and the
  # unreachable-host tests would otherwise spend all of it waiting.
  printf '#!/usr/bin/env bash\nexit 0\n' > "$TMP/bin/sleep"
  chmod +x "$TMP/bin/sleep"

  # Answers the handful of remote commands the audit runs. SSHD_* let a test
  # describe the host it wants without touching the script.
  cat > "$TMP/bin/ssh" << STUB
#!/usr/bin/env bash
printf 'ssh %s\n' "\$*" >> "$CALLS"
[ -n "\$SSH_DEAD" ] && exit 255
for a in "\$@"; do
  case "\$a" in
    *SSH_OK*) printf 'SSH_OK\n'; exit 0 ;;
    *sshd\ -T*)
      printf 'permitrootlogin %s\n' "\${SSHD_ROOT:-no}"
      printf 'passwordauthentication %s\n' "\${SSHD_PASSWORD:-no}"
      printf 'pubkeyauthentication %s\n' "\${SSHD_PUBKEY:-yes}"
      printf 'x11forwarding no\n'
      printf 'permitemptypasswords no\n'
      exit 0
      ;;
    *ID=*|*os-release*) printf '%s\n' "\${DISTRO:-ubuntu}"; exit 0 ;;
    *reboot-required*) printf 'no\n'; exit 0 ;;
  esac
done
exit 0
STUB
  chmod +x "$TMP/bin/ssh"

  cd "$TMP/work" || return 1
}

teardown()
{
  rm -rf "$TMP"
}

sa()
{
  run env PATH="$TMP/bin" HOME="$TMP/home" "$SA" "$@" < /dev/null
}

# The audit tree is ./ssh-audit/<timestamp>; there is only ever one per run.
audit_dir()
{
  find "$TMP/work/ssh-audit" -maxdepth 1 -mindepth 1 -type d | head -1
}

@test "ssh-audit: no argument prints usage and exits 1" {
  sa
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"hostname:username"* ]]
}

@test "ssh-audit: the usage explains the optional ssh key field" {
  sa
  [[ "$output" == *"ssh_key"* ]]
}

@test "ssh-audit: a missing host list is an error" {
  sa "$TMP/no-such-file"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Input file not found"* ]]
}

@test "ssh-audit: a host list with no usable entries is an error" {
  printf '# only a comment\n\n' > "$TMP/hosts"
  sa "$TMP/hosts"
  [ "$status" -eq 1 ]
  [[ "$output" == *"No valid hosts found"* ]]
}

@test "ssh-audit: loads the hosts it was given" {
  printf 'host-one:alice\nhost-two:bob\n' > "$TMP/hosts"
  sa "$TMP/hosts" no
  [[ "$output" == *"Loaded 2 hosts"* ]]
}

@test "ssh-audit: comments and blank lines are skipped" {
  printf '# a comment\n\nhost-one:alice\n' > "$TMP/hosts"
  sa "$TMP/hosts" no
  [[ "$output" == *"Loaded 1 hosts"* ]]
}

@test "ssh-audit: a hostname with illegal characters is rejected" {
  printf 'bad!host:alice\ngood-host:bob\n' > "$TMP/hosts"
  sa "$TMP/hosts" no
  [[ "$output" == *"Invalid hostname format: bad!host"* ]]
  [[ "$output" == *"Loaded 1 hosts"* ]]
}

@test "ssh-audit: a username that starts with a digit is rejected" {
  printf 'good-host:1alice\nother-host:bob\n' > "$TMP/hosts"
  sa "$TMP/hosts" no
  [[ "$output" == *"Invalid username format: 1alice"* ]]
}

@test "ssh-audit: one bad entry does not discard the good ones" {
  printf 'bad!host:alice\ngood-host:bob\n' > "$TMP/hosts"
  sa "$TMP/hosts" no
  [[ "$output" == *"Skipping invalid entry"* ]]
  [[ "$output" == *"Added host: good-host"* ]]
}

@test "ssh-audit: surrounding whitespace in an entry is trimmed" {
  printf '  spaced-host  :  alice  \n' > "$TMP/hosts"
  sa "$TMP/hosts" no
  [[ "$output" == *"Added host: spaced-host with user: alice"* ]]
}

@test "ssh-audit: an ssh key given for a host is recorded" {
  printf 'host-one:alice:/keys/id_ed25519\n' > "$TMP/hosts"
  sa "$TMP/hosts" no
  [[ "$output" == *"SSH key: /keys/id_ed25519"* ]]
}

@test "ssh-audit: writes a report and a log" {
  printf 'host-one:alice\n' > "$TMP/hosts"
  sa "$TMP/hosts" no
  dir=$(audit_dir)
  [ -s "$dir/report.csv" ]
  [ -s "$dir/log.log" ]
}

@test "ssh-audit: the report starts with a header row" {
  printf 'host-one:alice\n' > "$TMP/hosts"
  sa "$TMP/hosts" no
  head -1 "$(audit_dir)/report.csv" | grep -q '^Timestamp,Hostname,Username'
}

@test "ssh-audit: the report has one row per host" {
  printf 'host-one:alice\nhost-two:bob\n' > "$TMP/hosts"
  sa "$TMP/hosts" no
  [ "$(wc -l < "$(audit_dir)/report.csv")" -eq 3 ]
  grep -q ',host-one,alice,' "$(audit_dir)/report.csv"
  grep -q ',host-two,bob,' "$(audit_dir)/report.csv"
}

@test "ssh-audit: reports password authentication being enabled" {
  printf 'host-one:alice\n' > "$TMP/hosts"
  run env PATH="$TMP/bin" HOME="$TMP/home" SSHD_PASSWORD=yes \
    "$SA" "$TMP/hosts" no < /dev/null
  grep -q ',yes,' "$(audit_dir)/report.csv"
}

@test "ssh-audit: flags root login being permitted" {
  printf 'host-one:alice\n' > "$TMP/hosts"
  run env PATH="$TMP/bin" HOME="$TMP/home" SSHD_ROOT=yes \
    "$SA" "$TMP/hosts" no < /dev/null
  [[ "$output" == *"Root login is not disabled"* ]]
}

@test "ssh-audit: anything but 'no' for root login counts as a finding" {
  # PermitRootLogin has more values than yes and no — prohibit-password and
  # forced-commands-only among them — so the check is "not no", not "is yes".
  printf 'host-one:alice\n' > "$TMP/hosts"
  run env PATH="$TMP/bin" HOME="$TMP/home" SSHD_ROOT=prohibit-password \
    "$SA" "$TMP/hosts" no < /dev/null
  [[ "$output" == *"Root login is not disabled"* ]]
}

@test "ssh-audit: prints a summary" {
  printf 'host-one:alice\n' > "$TMP/hosts"
  sa "$TMP/hosts" no
  [[ "$output" == *"SSH Security Audit Summary"* ]]
}

@test "ssh-audit: a host it cannot reach does not stop the run" {
  # One unreachable host in a list must not abandon the rest.
  printf 'host-one:alice\nhost-two:bob\n' > "$TMP/hosts"
  run env PATH="$TMP/bin" HOME="$TMP/home" SSH_DEAD=1 \
    "$SA" "$TMP/hosts" no < /dev/null
  [ "$status" -eq 0 ]
  [[ "$output" == *"SSH Security Audit Summary"* ]]
  [ "$(wc -l < "$(audit_dir)/report.csv")" -eq 3 ]
}

@test "ssh-audit: says it cannot connect when ssh fails" {
  printf 'host-one:alice\n' > "$TMP/hosts"
  run env PATH="$TMP/bin" HOME="$TMP/home" SSH_DEAD=1 \
    "$SA" "$TMP/hosts" no < /dev/null
  [[ "$output" == *"Cannot establish SSH connection"* ]]
}

@test "ssh-audit: does not remediate unless it is asked to" {
  # The remediation path edits sshd_config on the remote host and restarts
  # sshd. Answering the prompt with nothing must leave the host alone.
  printf 'host-one:alice\n' > "$TMP/hosts"
  run env PATH="$TMP/bin" HOME="$TMP/home" SSHD_PASSWORD=yes \
    "$SA" "$TMP/hosts" < /dev/null
  run ! grep -q 'sshd_config' "$CALLS"
}

@test "ssh-audit: the second argument skips the prompt" {
  printf 'host-one:alice\n' > "$TMP/hosts"
  sa "$TMP/hosts" no
  [[ "$output" != *"Would you like to automatically remediate"* ]]
}

@test "ssh-audit: connects as the user the host list names" {
  printf 'host-one:alice\n' > "$TMP/hosts"
  sa "$TMP/hosts" no
  grep -q 'alice@host-one' "$CALLS"
}

@test "ssh-audit: uses the key the host list names" {
  # The key is only offered to ssh if it is actually on disk.
  printf 'fake key\n' > "$TMP/special-key"
  printf 'host-one:alice:%s\n' "$TMP/special-key" > "$TMP/hosts"
  sa "$TMP/hosts" no
  grep -q -- "-i $TMP/special-key" "$CALLS"
}

@test "ssh-audit: a named key that is not on disk is not passed to ssh" {
  printf 'host-one:alice:/keys/does-not-exist\n' > "$TMP/hosts"
  sa "$TMP/hosts" no
  run ! grep -q '/keys/does-not-exist' "$CALLS"
}
