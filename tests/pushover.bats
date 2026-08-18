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
# Record USER as the child process sees it. A parent-shell check cannot prove
# anything: the script runs in its own process and could set USER freely
# without the caller ever observing it.
printf '%s\n' "${USER-}" > "${STUB_DIR}/curl.user"
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
#
# Asserted inside the curl stub, not in the calling shell. A child process
# cannot modify its parent's variables, so echoing $USER after the script
# returns proves nothing — that check passed even against the broken version.
@test "pushover: -U does not overwrite the standard USER variable" {
  run env USER=realuser sh local/bin/pushover -U key-from-flag "body"
  [ "$status" -eq 0 ]
  grep -Fqx 'realuser' "$STUB_DIR/curl.user"
  grep -Fqx 'user=key-from-flag' "$STUB_DIR/curl.args"
}

# With -F, curl reads a local file when a value starts with `@` (or `<`), so a
# message could exfiltrate a file to the API. --form-string takes it literally.
@test "pushover: a message starting with @ is text, not a file reference" {
  run sh local/bin/pushover '@/etc/passwd'
  [ "$status" -eq 0 ]
  grep -Fqx 'message=@/etc/passwd' "$STUB_DIR/curl.args"
  # The literal-value flag must be what carries it.
  grep -Fqx -- '--form-string' "$STUB_DIR/curl.args"
  run grep -Fqx -- '-F' "$STUB_DIR/curl.args"
  [ "$status" -ne 0 ]
}

@test "pushover: a title starting with < is text, not a file reference" {
  run sh local/bin/pushover -t '<config' 'body'
  [ "$status" -eq 0 ]
  grep -Fqx 'title=<config' "$STUB_DIR/curl.args"
}
