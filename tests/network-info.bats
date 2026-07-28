#!/usr/bin/env bats

# x-ip and x-ips report addresses via external tools. Both are grouped here
# because their real logic is the same shape: refuse clearly when the required
# tool is absent rather than emitting an empty answer a caller would treat as
# "no addresses".

setup()
{
  X_IP="$BATS_TEST_DIRNAME/../local/bin/x-ip"
  X_IPS="$BATS_TEST_DIRNAME/../local/bin/x-ips"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin"
  # A sealed PATH: only these stubs, plus the interpreters the shebang needs.
  # Pointing PATH at /usr/bin would let the real dig/ifconfig leak in and the
  # missing-tool branches would never be reached.
  for tool in bash env sed sort grep cat; do
    ln -sf "$(command -v "$tool")" "$TMP/bin/$tool"
  done
  STUB_PATH="$TMP/bin"
}

teardown()
{
  rm -rf "$TMP"
}

@test "x-ip: reports the address dig returns" {
  cat > "$TMP/bin/dig" << 'STUB'
#!/usr/bin/env bash
echo "203.0.113.7"
STUB
  chmod +x "$TMP/bin/dig"
  run env PATH="$STUB_PATH" "$X_IP"
  [ "$status" -eq 0 ]
  [ "$output" = "203.0.113.7" ]
}

@test "x-ip: queries the OpenDNS resolver" {
  cat > "$TMP/bin/dig" << 'STUB'
#!/usr/bin/env bash
printf 'ARGS:%s\n' "$*"
STUB
  chmod +x "$TMP/bin/dig"
  run env PATH="$STUB_PATH" "$X_IP"
  [[ "$output" == *"myip.opendns.com"* ]]
  [[ "$output" == *"@resolver1.opendns.com"* ]]
}

@test "x-ip: exits 1 with a message when dig is missing" {
  run env PATH="$STUB_PATH" "$X_IP"
  [ "$status" -eq 1 ]
  [[ "$output" == *"dig is required"* ]]
}

@test "x-ip: the missing-tool error goes to stderr" {
  run env PATH="$STUB_PATH" bash -c "'$X_IP' 2>&1 >/dev/null"
  [[ "$output" == *"dig is required"* ]]
}

@test "x-ips: extracts and sorts addresses from ifconfig" {
  cat > "$TMP/bin/ifconfig" << 'STUB'
#!/usr/bin/env bash
cat << 'OUT'
lo0: flags=8049<UP,LOOPBACK>
    inet 127.0.0.1 netmask 0xff000000
    inet6 ::1 prefixlen 128
en0: flags=8863<UP,BROADCAST>
    inet 192.168.1.50 netmask 0xffffff00
OUT
STUB
  chmod +x "$TMP/bin/ifconfig"
  run env PATH="$STUB_PATH" "$X_IPS"
  [ "$status" -eq 0 ]
  [[ "$output" == *"127.0.0.1"* ]]
  [[ "$output" == *"192.168.1.50"* ]]
  [[ "$output" == *"::1"* ]]
}

@test "x-ips: strips the inet prefix from each line" {
  cat > "$TMP/bin/ifconfig" << 'STUB'
#!/usr/bin/env bash
printf '\tinet 10.0.0.1 netmask 0xff000000\n'
STUB
  chmod +x "$TMP/bin/ifconfig"
  run env PATH="$STUB_PATH" "$X_IPS"
  [ "$output" = "10.0.0.1" ]
}

@test "x-ips: exits 1 with a message when ifconfig is missing" {
  run env PATH="$STUB_PATH" "$X_IPS"
  [ "$status" -eq 1 ]
  [[ "$output" == *"ifconfig is required"* ]]
}
