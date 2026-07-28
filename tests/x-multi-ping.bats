#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

# x-multi-ping resolves hostnames with dig and pings every address it finds.
# Both are stubbed: no DNS query and no ICMP packet leaves the machine, so the
# result does not depend on the network the suite runs on.

setup()
{
  MP="$BATS_TEST_DIRNAME/../local/bin/x-multi-ping"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin"
  CALLS="$TMP/calls"
  : > "$CALLS"
  for tool in bash env uname sleep cat; do
    ln -sf "$(command -v "$tool")" "$TMP/bin/$tool"
  done

  # Resolves anything to one v4 and one v6 address, and records the query.
  cat > "$TMP/bin/dig" << STUB
#!/usr/bin/env bash
printf 'dig %s\n' "\$*" >> "$CALLS"
[ -n "\$DIG_EMPTY" ] && exit 0
case "\$*" in
  *AAAA*) printf '2001:db8::1\n' ;;
  *) printf '192.0.2.1\n' ;;
esac
STUB

  cat > "$TMP/bin/ping" << STUB
#!/usr/bin/env bash
printf 'ping %s\n' "\$*" >> "$CALLS"
exit "\${PING_EXIT:-0}"
STUB
  cp "$TMP/bin/ping" "$TMP/bin/ping6"
  chmod +x "$TMP/bin/dig" "$TMP/bin/ping" "$TMP/bin/ping6"
}

teardown()
{
  rm -rf "$TMP"
}

mping()
{
  run env PATH="$TMP/bin" "$MP" "$@"
}

@test "multi-ping: --help exits 0 and shows the options" {
  mping --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"--loop"* ]]
  [[ "$output" == *"--sleep"* ]]
}

@test "multi-ping: no hostname is an error" {
  mping
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage"* ]]
}

@test "multi-ping: an unknown option is rejected" {
  mping --bogus example.com
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option"* ]]
}

@test "multi-ping: --sleep rejects a non-numeric value" {
  mping --sleep abc example.com
  [ "$status" -eq 1 ]
  [[ "$output" == *"numeric"* ]]
}

@test "multi-ping: --sleep=N is validated the same as --sleep N" {
  mping --sleep=abc example.com
  [ "$status" -eq 1 ]
  [[ "$output" == *"numeric"* ]]
}

@test "multi-ping: --sleep with no value at all is an error" {
  mping --sleep
  [ "$status" -eq 1 ]
}

@test "multi-ping: a missing dig aborts and says which tool is missing" {
  rm "$TMP/bin/dig"
  mping example.com
  [ "$status" -eq 1 ]
  [[ "$output" == *"dig"* ]]
  [[ "$output" == *"Aborting"* ]]
}

@test "multi-ping: strips a URI scheme before resolving" {
  mping https://example.com/some/path
  grep -q 'dig +short example.com A' "$CALLS"
  run ! grep -q 'https' "$CALLS"
}

@test "multi-ping: strips a port before resolving" {
  mping example.com:8080
  grep -q 'dig +short example.com A' "$CALLS"
  run ! grep -q '8080' "$CALLS"
}

@test "multi-ping: asks for both A and AAAA records" {
  mping example.com
  grep -q 'dig +short example.com A$' "$CALLS"
  grep -q 'dig +short example.com AAAA$' "$CALLS"
}

@test "multi-ping: reports a reachable address as alive" {
  mping example.com
  [ "$status" -eq 0 ]
  [[ "$output" == *"Host example.com - 192.0.2.1 - alive"* ]]
  [[ "$output" == *"Host example.com - 2001:db8::1 - alive"* ]]
}

@test "multi-ping: reports an unreachable address as FAILED" {
  run env PATH="$TMP/bin" PING_EXIT=1 "$MP" example.com
  [[ "$output" == *"192.0.2.1 - FAILED"* ]]
  [[ "$output" != *"alive"* ]]
}

@test "multi-ping: warns instead of pinging when a name does not resolve" {
  run env PATH="$TMP/bin" DIG_EMPTY=1 "$MP" example.com
  [[ "$output" == *"WARNING: Failed to resolve example.com [A]"* ]]
  [[ "$output" == *"WARNING: Failed to resolve example.com [AAAA]"* ]]
  run ! grep -q '^ping ' "$CALLS"
}

@test "multi-ping: pings every hostname given" {
  mping example.com example.org
  grep -q 'dig +short example.com A' "$CALLS"
  grep -q 'dig +short example.org A' "$CALLS"
}
