#!/usr/bin/env bats

# x-ssl-expiry-date opens a TLS connection and reads the certificate's
# notAfter date. openssl is stubbed with a fixed expiry, so the test does not
# depend on a reachable host or on whatever a real certificate happens to say
# this week. date is left real — the GNU/BSD parsing fallback is part of what
# is under test.

setup()
{
  SSLX="$BATS_TEST_DIRNAME/../local/bin/x-ssl-expiry-date"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin"
  CALLS="$TMP/calls"
  : > "$CALLS"
  for tool in sh bash env date mktemp rm cat; do
    ln -sf "$(command -v "$tool")" "$TMP/bin/$tool"
  done

  cat > "$TMP/bin/openssl" << STUB
#!/usr/bin/env bash
printf 'openssl %s\n' "\$*" >> "$CALLS"
case "\$1" in
  s_client)
    [ -n "\$SSL_UNREACHABLE" ] && exit 1
    printf 'CERTIFICATE\n'
    ;;
  x509)
    printf 'notAfter=Mar 14 12:00:00 2030 GMT\n'
    ;;
esac
STUB
  chmod +x "$TMP/bin/openssl"
}

teardown()
{
  rm -rf "$TMP"
}

sslx()
{
  run env PATH="$TMP/bin" "$SSLX" "$@"
}

@test "ssl-expiry: no argument prints usage" {
  sslx
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"domain1.org"* ]]
}

@test "ssl-expiry: -h prints usage" {
  sslx -h
  [[ "$output" == *"Usage:"* ]]
}

@test "ssl-expiry: reports the expiry date and remaining days" {
  sslx example.com
  [ "$status" -eq 0 ]
  [[ "$output" == *"example.com"* ]]
  [[ "$output" == *"Expires: Mar 14 12:00:00 2030 GMT"* ]]
  [[ "$output" == *"Days:"* ]]
}

@test "ssl-expiry: the day count is positive for a future certificate" {
  sslx example.com
  days=$(printf '%s\n' "$output" | sed -n 's/.*Days: //p')
  [ "$days" -gt 0 ]
}

@test "ssl-expiry: -d prints just the host and the day count" {
  sslx -d example.com
  [[ "$output" =~ ^example\.com:\ [0-9]+$ ]]
  [[ "$output" != *"Expires"* ]]
}

@test "ssl-expiry: connects to port 443 by default" {
  sslx example.com
  grep -q 'connect example.com:443' "$CALLS"
}

@test "ssl-expiry: -p overrides the port" {
  sslx -p 8443 example.com
  grep -q 'connect example.com:8443' "$CALLS"
}

@test "ssl-expiry: an unreachable host exits 3 and says which URL failed" {
  run env PATH="$TMP/bin" SSL_UNREACHABLE=1 "$SSLX" example.com
  [ "$status" -eq 3 ]
  [[ "$output" == *"Failed to get cert from https://example.com:443/"* ]]
}

@test "ssl-expiry: checks every domain given" {
  sslx example.com example.org
  [[ "$output" == *"example.com"* ]]
  [[ "$output" == *"example.org"* ]]
  grep -q 'connect example.org:443' "$CALLS"
}

@test "ssl-expiry: leaves no temp file behind" {
  # The certificate is downloaded to a temp file that an EXIT trap removes.
  # Pointing TMPDIR at an empty directory makes the leftover check exact.
  mkdir -p "$TMP/tmpdir"
  run env PATH="$TMP/bin" TMPDIR="$TMP/tmpdir" "$SSLX" example.com
  [ "$status" -eq 0 ]
  [ -z "$(ls -A "$TMP/tmpdir")" ]
}
