#!/usr/bin/env bats

# x-open-ports formats listening sockets as a Markdown table or JSON. Both
# lsof and ss are stubbed with fixed output, so the tests assert the parsing
# and formatting rather than whatever happens to be listening on the host —
# which would make the suite depend on the machine running it.

setup()
{
  PORTS="$BATS_TEST_DIRNAME/../local/bin/x-open-ports"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin"
  # The JSON path additionally uses cut; a missing entry here surfaces as a
  # bare exit 127 rather than a useful failure.
  for tool in bash env awk sort uniq cat grep sed cut tr head; do
    ln -sf "$(command -v "$tool")" "$TMP/bin/$tool"
  done
  cat > "$TMP/bin/lsof" << 'STUB'
#!/usr/bin/env bash
cat << 'OUT'
COMMAND PID USER FD TYPE DEVICE SIZE/OFF NODE NAME
sshd 1234 root 3u IPv4 12345 0t0 TCP *:22 (LISTEN)
nginx 5678 www-data 6u IPv4 23456 0t0 TCP 127.0.0.1:8080 (LISTEN)
OUT
STUB
  chmod +x "$TMP/bin/lsof"
}

teardown()
{
  rm -rf "$TMP"
}

ports()
{
  run env PATH="$TMP/bin" "$PORTS" "$@"
}

@test "x-open-ports: --help exits 0 and documents both formats" {
  ports --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"--json"* ]]
  [[ "$output" == *"Usage:"* ]]
}

@test "x-open-ports: prints a markdown table by default" {
  ports
  [ "$status" -eq 0 ]
  [[ "$output" == *"| User"* ]]
  [[ "$output" == *"|---"* ]]
}

@test "x-open-ports: extracts the port from the address column" {
  ports
  [[ "$output" == *"22"* ]]
  [[ "$output" == *"8080"* ]]
}

@test "x-open-ports: reports the listening command" {
  ports
  [[ "$output" == *"sshd"* ]]
  [[ "$output" == *"nginx"* ]]
}

@test "x-open-ports: reports the owning user" {
  ports
  [[ "$output" == *"root"* ]]
  [[ "$output" == *"www-data"* ]]
}

@test "x-open-ports: does not emit the lsof header row as data" {
  ports
  [[ "$output" != *"SIZE/OFF"* ]]
  [[ "$output" != *"COMMAND PID USER"* ]]
}

@test "x-open-ports: --json produces parseable JSON" {
  ports --json
  [ "$status" -eq 0 ]
  printf '%s' "$output" | python3 -c 'import json,sys; json.load(sys.stdin)'
}

@test "x-open-ports: --json carries the same ports as the table" {
  ports --json
  [[ "$output" == *"22"* ]]
  [[ "$output" == *"8080"* ]]
}

@test "x-open-ports: an unknown option is rejected" {
  ports --definitely-not-an-option
  [ "$status" -ne 0 ]
}
