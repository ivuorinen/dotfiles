#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

# x-gh-get-latest-release-targz reads the GitHub releases API and optionally
# downloads the tarball. curl and tar are stubbed, so no request leaves the
# machine and nothing is extracted into the working directory — the tests
# assert URL extraction, the --get gate, and the failure paths.

setup()
{
  GETREL="$BATS_TEST_DIRNAME/../local/bin/x-gh-get-latest-release-targz"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin"
  CALLS="$TMP/calls"
  : > "$CALLS"
  for tool in bash env sed cat grep; do
    ln -sf "$(command -v "$tool")" "$TMP/bin/$tool"
  done
  # Returns a releases payload for the API URL, records any other fetch.
  cat > "$TMP/bin/curl" << STUB
#!/usr/bin/env bash
printf 'curl %s\n' "\$*" >> "$CALLS"
case "\$*" in
  *api.github.com*)
    cat << 'JSON'
{
  "tag_name": "v1.2.3",
  "tarball_url": "https://api.github.com/repos/owner/repo/tarball/v1.2.3",
  "zipball_url": "https://api.github.com/repos/owner/repo/zipball/v1.2.3"
}
JSON
    ;;
  *) printf 'TARBALLBYTES' ;;
esac
STUB
  cat > "$TMP/bin/tar" << STUB
#!/usr/bin/env bash
printf 'tar %s\n' "\$*" >> "$CALLS"
cat > /dev/null
STUB
  chmod +x "$TMP/bin/curl" "$TMP/bin/tar"
}

teardown()
{
  rm -rf "$TMP"
}

getrel()
{
  run env PATH="$TMP/bin" "$GETREL" "$@"
}

@test "getrel: prints the tarball url for a repo" {
  getrel owner/repo
  [ "$status" -eq 0 ]
  [[ "$output" == *"tarball/v1.2.3"* ]]
}

@test "getrel: picks tarball_url, not zipball_url" {
  getrel owner/repo
  [[ "$output" != *"zipball"* ]]
}

@test "getrel: queries the releases/latest endpoint for that repo" {
  getrel owner/repo
  grep -q 'api.github.com/repos/owner/repo/releases/latest' "$CALLS"
}

@test "getrel: does not download without --get" {
  getrel owner/repo
  run ! grep -q '^tar ' "$CALLS"
}

@test "getrel: --get downloads and extracts" {
  getrel owner/repo --get
  [ "$status" -eq 0 ]
  grep -q '^tar ' "$CALLS"
}

@test "getrel: --get extracts gzip from stdin" {
  getrel owner/repo --get
  grep -q -- '--gzip' "$CALLS"
  grep -q -- '--file=-' "$CALLS"
}

@test "getrel: --get accepts the flag in either position" {
  getrel --get owner/repo
  [ "$status" -eq 0 ]
  grep -q '^tar ' "$CALLS"
}

@test "getrel: an empty api response is an error, and says so" {
  # The message must reach the user. It is emitted inside a function whose
  # stdout main() captures, so on stdout it was swallowed and the failure was
  # completely silent.
  cat > "$TMP/bin/curl" << 'STUB'
#!/usr/bin/env bash
printf '{}\n'
STUB
  chmod +x "$TMP/bin/curl"
  getrel owner/repo
  [ "$status" -eq 1 ]
  run env PATH="$TMP/bin" bash -c "'$GETREL' owner/repo 2>&1 >/dev/null"
  [[ "$output" == *"Failed to fetch"* ]]
}

@test "getrel: no argument prints usage and exits 1" {
  getrel
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "getrel: too many arguments prints usage and exits 1" {
  getrel a b c
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}
