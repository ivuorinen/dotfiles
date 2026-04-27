#!/usr/bin/env bats

setup()
{
  STUB_DIR="$(mktemp -d)"
  cat > "$STUB_DIR/curl" << 'STUB'
#!/usr/bin/env sh
# Mark that the stub was actually invoked so tests can assert on it.
: > "${STUB_DIR}/curl.called"
echo '{"status":1,"request":"stub-id"}'
STUB
  chmod +x "$STUB_DIR/curl"
  export PATH="$STUB_DIR:$PATH"
  export PUSHOVER_TOKEN="fake-token"
  export PUSHOVER_USER="fake-user"
  export STUB_DIR
}

teardown()
{
  rm -rf "$STUB_DIR"
}

@test "pushover: exits 1 when curl is not available" {
  local no_curl
  no_curl="$(mktemp -d)"
  run env PATH="$no_curl" /bin/sh local/bin/pushover "test message"
  [ "$status" -eq 1 ]
  rm -rf "$no_curl"
}

@test "pushover: exits 0 with message only and no optional flags" {
  run sh local/bin/pushover "hello world"
  [ "$status" -eq 0 ]
  [ -f "$STUB_DIR/curl.called" ]
}

@test "pushover: exits 0 with title flag" {
  run sh local/bin/pushover -t "My Title" "hello"
  [ "$status" -eq 0 ]
  [ -f "$STUB_DIR/curl.called" ]
}
