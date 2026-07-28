#!/usr/bin/env bats

# x-record drives a desktop screen-recording stack (giph, eww, slop,
# notify-send.sh). Starting a recording needs a compositor and interactive
# selection, so the tests cover the dependency gate that runs first — the part
# that decides whether the script can work at all.

setup()
{
  RECORD="$BATS_TEST_DIRNAME/../local/bin/x-record"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin"
  for tool in bash env cat grep; do
    ln -sf "$(command -v "$tool")" "$TMP/bin/$tool"
  done
  # Every dependency the script checks for, all inert.
  for tool in ffmpeg notify-send.sh pkill eww giph slop pgrep; do
    printf '#!/usr/bin/env bash\nexit 0\n' > "$TMP/bin/$tool"
    chmod +x "$TMP/bin/$tool"
  done
}

teardown()
{
  rm -rf "$TMP"
}

@test "x-record: names the dependency that is missing" {
  rm "$TMP/bin/giph"
  run env PATH="$TMP/bin" "$RECORD"
  [ "$status" -eq 1 ]
  [[ "$output" == *"giph"* ]]
  [[ "$output" == *"not found"* ]]
}

@test "x-record: checks every tool it needs, not just the first" {
  for missing in ffmpeg eww slop notify-send.sh; do
    rm -f "$TMP/bin/$missing"
    run env PATH="$TMP/bin" "$RECORD"
    [ "$status" -eq 1 ] || {
      echo "a missing $missing was not caught"
      return 1
    }
    [[ "$output" == *"$missing"* ]] || {
      echo "the message did not name $missing"
      return 1
    }
    printf '#!/usr/bin/env bash\nexit 0\n' > "$TMP/bin/$missing"
    chmod +x "$TMP/bin/$missing"
  done
}

@test "x-record: the dependency check runs before anything else" {
  # With no dependencies at all it must fail cleanly, not with a shell error
  # about an unset variable or a missing command mid-script.
  rm -f "$TMP/bin/ffmpeg" "$TMP/bin/giph" "$TMP/bin/eww" "$TMP/bin/slop"
  run env PATH="$TMP/bin" "$RECORD"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Please install it"* ]]
}
