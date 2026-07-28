#!/usr/bin/env bats

# x-welcome-banner is a MOTD: it greets by time of day and prints today's
# date, weather and IP. date and curl are stubbed — the greeting branches are
# only reachable with a fixed clock, and the real script calls wttr.in and
# ipinfo.io, which a test must never do.

setup()
{
  BANNER="$BATS_TEST_DIRNAME/../local/bin/x-welcome-banner"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin"
  CALLS="$TMP/calls"
  : > "$CALLS"
  for tool in bash env cat; do
    ln -sf "$(command -v "$tool")" "$TMP/bin/$tool"
  done

  cat > "$TMP/bin/date" << 'STUB'
#!/usr/bin/env bash
case "$1" in
  +%H) printf '%s\n' "${FAKE_HOUR:-09}" ;;
  *) printf 'FAKE DATE LINE\n' ;;
esac
STUB

  cat > "$TMP/bin/curl" << STUB
#!/usr/bin/env bash
printf 'curl %s\n' "\$*" >> "$CALLS"
printf 'STUBBED\n'
STUB
  chmod +x "$TMP/bin/date" "$TMP/bin/curl"
  # figlet, lolcat, neofetch and ip are absent from this PATH on purpose, so
  # the plain-text fallbacks are what gets exercised.
}

teardown()
{
  rm -rf "$TMP"
}

banner()
{
  run env PATH="$TMP/bin" USER=tester FAKE_HOUR="$1" "$BANNER"
}

@test "welcome-banner: greets the user by name" {
  banner 09
  [ "$status" -eq 0 ]
  [[ "$output" == *"tester"* ]]
}

@test "welcome-banner: says good morning before noon" {
  banner 09
  [[ "$output" == *"Good morning"* ]]
}

@test "welcome-banner: says good afternoon between noon and six" {
  banner 14
  [[ "$output" == *"Good afternoon"* ]]
}

@test "welcome-banner: says good evening between six and ten" {
  banner 19
  [[ "$output" == *"Good evening"* ]]
}

@test "welcome-banner: says good night late" {
  banner 23
  [[ "$output" == *"Good Night"* ]]
}

@test "welcome-banner: says good night in the small hours" {
  # The hour comparison is numeric, so a leading zero must not be read as
  # octal — '03' would be a syntax error under the wrong test operator.
  banner 03
  [[ "$output" == *"Good Night"* ]]
}

@test "welcome-banner: noon is afternoon, not morning" {
  banner 12
  [[ "$output" == *"Good afternoon"* ]]
}

@test "welcome-banner: prints the today section" {
  banner 09
  [[ "$output" == *"Today"* ]]
  [[ "$output" == *"FAKE DATE LINE"* ]]
}

@test "welcome-banner: asks the weather service with a timeout" {
  # No timeout means a MOTD that hangs the login on a dead network.
  banner 09
  grep -q 'wttr.in' "$CALLS"
  grep -q -- '-m 1' "$CALLS"
}

@test "welcome-banner: falls back to plain text without figlet" {
  banner 09
  [ "$status" -eq 0 ]
  [[ "$output" == *"Good morning tester!"* ]]
}
