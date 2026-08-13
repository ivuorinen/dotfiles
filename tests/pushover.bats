#!/usr/bin/env bats

setup()
{
  STUB_DIR="$(mktemp -d)"
  cat > "$STUB_DIR/curl" << 'STUB'
#!/usr/bin/env sh
# Mark that the stub was actually invoked so tests can assert on it.
: > "${STUB_DIR}/curl.called"
# Record argv one entry per line. Per-line is what makes the injection tests
# meaningful: it proves a payload arrived as ONE argument rather than being
# split into several by a shell that re-parsed it.
: > "${STUB_DIR}/curl.args"
for a in "$@"; do printf '%s\n' "$a" >> "${STUB_DIR}/curl.args"; done
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

# Regression: the curl invocation used to be assembled into a string and run
# through `eval`, so a command substitution in any value executed instead of
# being transmitted. `pushover 'hello $(id -u) end'` printed the caller's uid.
@test "pushover: command substitution in a message is transmitted, not executed" {
  run sh local/bin/pushover 'hello $(id -u) end'
  [ "$status" -eq 0 ]
  grep -Fqx 'message=hello $(id -u) end' "$STUB_DIR/curl.args"
}

# Same defect, quote-breaking form: a `"` closed the eval'd string and the
# remainder was parsed as further commands.
@test "pushover: a quote in a message cannot start a new command" {
  run sh local/bin/pushover 'a"; echo INJECTED >&2; echo "b'
  [ "$status" -eq 0 ]
  [[ "$output" != *INJECTED* ]]
  grep -Fqx 'message=a"; echo INJECTED >&2; echo "b' "$STUB_DIR/curl.args"
}

# A value with spaces must stay one argv entry. The eval version split it into
# several, silently truncating every multi-word title.
@test "pushover: a multi-word title arrives as a single argument" {
  run sh local/bin/pushover -t "My Long Title" "body"
  [ "$status" -eq 0 ]
  grep -Fqx 'title=My Long Title' "$STUB_DIR/curl.args"
}

@test "pushover: optional flags map to their form fields" {
  run sh local/bin/pushover -d phone -p 1 -s siren "body"
  [ "$status" -eq 0 ]
  grep -Fqx 'device=phone' "$STUB_DIR/curl.args"
  grep -Fqx 'priority=1' "$STUB_DIR/curl.args"
  grep -Fqx 'sound=siren' "$STUB_DIR/curl.args"
  # Unset flags must not be sent at all, not sent empty.
  run grep -Fq 'callback=' "$STUB_DIR/curl.args"
  [ "$status" -ne 0 ]
}

@test "pushover: a missing token fails before any request is made" {
  run env -u PUSHOVER_TOKEN sh local/bin/pushover "body"
  [ "$status" -eq 1 ]
  [[ "$output" == *"no API token"* ]]
  [ ! -f "$STUB_DIR/curl.called" ]
}

@test "pushover: a missing user key fails before any request is made" {
  run env -u PUSHOVER_USER sh local/bin/pushover "body"
  [ "$status" -eq 1 ]
  [[ "$output" == *"no user/group key"* ]]
  [ ! -f "$STUB_DIR/curl.called" ]
}

# The standard USER variable must survive the run: -U used to assign straight
# into it, clobbering it for the rest of the process.
@test "pushover: -U does not overwrite the standard USER variable" {
  run sh -c 'USER=realuser; . /dev/null; sh local/bin/pushover -U key-from-flag "body"; echo "USER=$USER"'
  [ "$status" -eq 0 ]
  [[ "$output" == *"USER=realuser"* ]]
  grep -Fqx 'user=key-from-flag' "$STUB_DIR/curl.args"
}
