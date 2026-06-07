#!/usr/bin/env bats
# Tests for local/bin/x-gh-get-latest-version.
# Argument-parsing tests need no stubs (parse_arguments exits before any curl call).
# API-behaviour tests use a sequenced curl stub: each call reads its body from
# $STUB_DIR/res_N.json and its HTTP code from $STUB_DIR/code_N (0-indexed counter).

setup()
{
  STUB_DIR="$(mktemp -d)"
  export STUB_DIR
  export PATH="$STUB_DIR:$PATH"
  export _RATE_OK='{"resources":{"core":{"remaining":5000,"reset":9999999999}}}'
}

teardown()
{
  rm -rf "$STUB_DIR"
}

# Install the sequenced curl stub into STUB_DIR.
# When called with -o FILE (api_request pattern): body → FILE, code → stdout.
# When called without -o (check_rate_limits pattern): body → stdout.
_install_curl_stub()
{
  cat > "$STUB_DIR/curl" << 'STUB'
#!/usr/bin/env bash
n=$(cat "$STUB_DIR/call_count" 2>/dev/null || echo 0)
echo $((n + 1)) > "$STUB_DIR/call_count"
body=$(cat "$STUB_DIR/res_${n}.json" 2>/dev/null || echo '{}')
code=$(cat "$STUB_DIR/code_${n}" 2>/dev/null || echo 200)
output_file=""
for ((i = 1; i <= $#; i++)); do
  if [[ "${!i}" == "-o" ]]; then
    j=$((i + 1))
    output_file="${!j}"
    break
  fi
done
if [[ -n "$output_file" ]]; then
  printf '%s' "$body" > "$output_file"
  printf '%s' "$code"
else
  printf '%s' "$body"
fi
STUB
  chmod +x "$STUB_DIR/curl"
  echo 0 > "$STUB_DIR/call_count"
}

# Set the body and HTTP code for call N (0-indexed).
_set_curl_response()
{
  local n="$1" body="$2" code="${3:-200}"
  printf '%s' "$body" > "$STUB_DIR/res_${n}.json"
  printf '%s' "$code" > "$STUB_DIR/code_${n}"
}

# ── Argument parsing — exits before any curl call ────────────────────────────

@test "no args: shows usage, exits 0" {
  run bash local/bin/x-gh-get-latest-version
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: x-gh-get-latest-version"* ]]
}

@test "--help: shows usage, exits 0" {
  run bash local/bin/x-gh-get-latest-version --help
  [ "$status" -eq 0 ]
  [[ "$output" == "Usage: x-gh-get-latest-version"* ]]
}

@test "unknown flag: exits non-zero, prints 'Unknown option'" {
  run bash local/bin/x-gh-get-latest-version owner/repo --bogus-flag
  [ "$status" -ne 0 ]
  [[ "$output" == *"Unknown option"* ]]
}

@test "--branch without value: exits 1, mentions --branch in error" {
  run bash local/bin/x-gh-get-latest-version owner/repo --branch
  [ "$status" -eq 1 ]
  [[ "$output" == *"--branch"* ]]
}

@test "two positional args: exits non-zero, prints 'Unexpected argument'" {
  run bash local/bin/x-gh-get-latest-version owner/repo extra-arg
  [ "$status" -ne 0 ]
  [[ "$output" == *"Unexpected argument"* ]]
}

# ── API error handling — curl stub required ───────────────────────────────────

@test "404 from API: exits 2" {
  _install_curl_stub
  # Call 0: check_rate_limits (no -o)
  _set_curl_response 0 "$_RATE_OK" 200
  # Call 1: check_repository via api_request (-o FILE)
  _set_curl_response 1 '{"message":"Not Found"}' 404
  run bash local/bin/x-gh-get-latest-version owner/nonexistent
  [ "$status" -eq 2 ]
  [[ "$output" == *"not found"* || "$output" == *"Not Found"* || "$output" == *"Repository"* ]]
}

@test "403 rate-limit exceeded: exits 3" {
  _install_curl_stub
  # Call 0: check_rate_limits (no -o)
  _set_curl_response 0 "$_RATE_OK" 200
  # Call 1: check_repository (-o FILE) — triggers 403 rate-limit path
  _set_curl_response 1 \
    '{"message":"API rate limit exceeded","rate":{"reset":9999999999}}' 403
  run bash local/bin/x-gh-get-latest-version owner/repo
  [ "$status" -eq 3 ]
  [[ "$output" == *"rate limit"* ]]
}

@test "successful release fetch: exits 0, prints release tag" {
  _install_curl_stub
  # Call 0: check_rate_limits (no -o)
  _set_curl_response 0 "$_RATE_OK" 200
  # Call 1: check_repository (-o FILE)
  _set_curl_response 1 \
    '{"full_name":"owner/repo","default_branch":"main"}' 200
  # Call 2: get_release_version → /releases (-o FILE)
  _set_curl_response 2 \
    '[{"tag_name":"v1.2.3","prerelease":false,"created_at":"2024-01-01T00:00:00Z"}]' 200
  run bash local/bin/x-gh-get-latest-version owner/repo
  [ "$status" -eq 0 ]
  [[ "$output" == *"v1.2.3"* ]]
}
