#!/usr/bin/env bats

# x-when-up and x-when-down wait on ping, then run a command. ping and sleep
# are stubbed so the tests are instant and deterministic, and so the retry
# behaviour is observable through a counter rather than by waiting.
#
# The ssh shortcut is the subtle part: `x-when-up ssh host` must treat host as
# the target and still run the full `ssh host` command, while
# `x-when-up host cmd` shifts the host off first.

setup()
{
  WHEN_UP="$BATS_TEST_DIRNAME/../local/bin/x-when-up"
  WHEN_DOWN="$BATS_TEST_DIRNAME/../local/bin/x-when-down"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin"
  PINGS="$TMP/pings"
  RAN="$TMP/ran"
  : > "$PINGS"
  : > "$RAN"
  cat > "$TMP/bin/sleep" << 'STUB'
#!/usr/bin/env bash
exit 0
STUB
  chmod +x "$TMP/bin/sleep"
  # Records the command it was asked to run, so tests can assert argv.
  cat > "$TMP/bin/record" << STUB
#!/usr/bin/env bash
printf '%s\n' "\$*" >> "$RAN"
STUB
  chmod +x "$TMP/bin/record"
  cat > "$TMP/bin/ssh" << STUB
#!/usr/bin/env bash
printf 'ssh %s\n' "\$*" >> "$RAN"
STUB
  chmod +x "$TMP/bin/ssh"
}

teardown()
{
  rm -rf "$TMP"
}

# $1 = number of failed pings before success (0 = up immediately)
stub_ping()
{
  cat > "$TMP/bin/ping" << STUB
#!/usr/bin/env bash
n=\$(cat "$PINGS" 2>/dev/null || echo 0)
n=\$((n + 1)); printf '%s' "\$n" > "$PINGS"
[ "\$n" -gt $1 ]
STUB
  chmod +x "$TMP/bin/ping"
}

# Inverted: succeeds while the host is "up", fails after $1 attempts.
stub_ping_going_down()
{
  cat > "$TMP/bin/ping" << STUB
#!/usr/bin/env bash
n=\$(cat "$PINGS" 2>/dev/null || echo 0)
n=\$((n + 1)); printf '%s' "\$n" > "$PINGS"
[ "\$n" -le $1 ]
STUB
  chmod +x "$TMP/bin/ping"
}

@test "x-when-up: runs the command once the host answers" {
  stub_ping 0
  run env PATH="$TMP/bin:$PATH" "$WHEN_UP" myhost record hello
  [ "$status" -eq 0 ]
  grep -q 'hello' "$RAN"
}

@test "x-when-up: keeps pinging until the host answers" {
  stub_ping 3
  run env PATH="$TMP/bin:$PATH" "$WHEN_UP" myhost record hello
  [ "$status" -eq 0 ]
  [ "$(cat "$PINGS")" -eq 4 ]
  grep -q 'hello' "$RAN"
}

@test "x-when-up: shifts the host off the command" {
  stub_ping 0
  run env PATH="$TMP/bin:$PATH" "$WHEN_UP" myhost record one two
  [ "$status" -eq 0 ]
  grep -q '^one two$' "$RAN"
}

@test "x-when-up: the ssh shortcut keeps the host in the command" {
  stub_ping 0
  run env PATH="$TMP/bin:$PATH" "$WHEN_UP" ssh myhost
  [ "$status" -eq 0 ]
  grep -q '^ssh myhost$' "$RAN"
}

@test "x-when-up: announces what it is waiting for" {
  stub_ping 0
  run env PATH="$TMP/bin:$PATH" "$WHEN_UP" myhost record hello
  [[ "$output" == *"myhost"* ]]
}

@test "x-when-up: too few arguments exits 1" {
  run env PATH="$TMP/bin:$PATH" "$WHEN_UP" onlyhost
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "x-when-up: no arguments exits 1 and runs nothing" {
  run env PATH="$TMP/bin:$PATH" "$WHEN_UP"
  [ "$status" -eq 1 ]
  [ ! -s "$RAN" ]
}

@test "x-when-down: runs the command once the host stops answering" {
  stub_ping_going_down 2
  run env PATH="$TMP/bin:$PATH" "$WHEN_DOWN" myhost record bye
  [ "$status" -eq 0 ]
  [ "$(cat "$PINGS")" -eq 3 ]
  grep -q 'bye' "$RAN"
}

@test "x-when-down: too few arguments exits 1" {
  run env PATH="$TMP/bin:$PATH" "$WHEN_DOWN" onlyhost
  [ "$status" -eq 1 ]
}
