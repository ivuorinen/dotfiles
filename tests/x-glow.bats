#!/usr/bin/env bats

# x-glow backs the `glow` alias and is what dfm-docs calls for themed output.
# glow itself is stubbed so the tests assert which arguments x-glow passes,
# not how glow renders — that rendering is what made dfm docs unreliable in
# non-interactive environments.

setup()
{
  X_GLOW="$BATS_TEST_DIRNAME/../local/bin/x-glow"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin" "$TMP/cfg/glow"
  cat > "$TMP/bin/glow" << 'STUB'
#!/usr/bin/env bash
printf 'GLOW_ARGS:%s\n' "$*"
STUB
  chmod +x "$TMP/bin/glow"
  printf '# doc\n' > "$TMP/doc.md"
}

teardown()
{
  rm -rf "$TMP"
}

@test "x-glow: passes the terminal style when the style file exists" {
  printf '{}\n' > "$TMP/cfg/glow/terminal.json"
  run env PATH="$TMP/bin:$PATH" XDG_CONFIG_HOME="$TMP/cfg" "$X_GLOW" "$TMP/doc.md"
  [ "$status" -eq 0 ]
  [[ "$output" == *"-s $TMP/cfg/glow/terminal.json"* ]]
  [[ "$output" == *"$TMP/doc.md"* ]]
}

@test "x-glow: omits the style flag when the style file is absent" {
  run env PATH="$TMP/bin:$PATH" XDG_CONFIG_HOME="$TMP/cfg" "$X_GLOW" "$TMP/doc.md"
  [ "$status" -eq 0 ]
  [[ "$output" != *"-s "* ]]
  [[ "$output" == *"$TMP/doc.md"* ]]
}

@test "x-glow: forwards every argument it is given" {
  run env PATH="$TMP/bin:$PATH" XDG_CONFIG_HOME="$TMP/cfg" "$X_GLOW" --width 40 "$TMP/doc.md"
  [ "$status" -eq 0 ]
  [[ "$output" == *"--width 40"* ]]
}

@test "x-glow: propagates glow's exit code" {
  cat > "$TMP/bin/glow" << 'STUB'
#!/usr/bin/env bash
exit 3
STUB
  chmod +x "$TMP/bin/glow"
  run env PATH="$TMP/bin:$PATH" XDG_CONFIG_HOME="$TMP/cfg" "$X_GLOW" "$TMP/doc.md"
  [ "$status" -eq 3 ]
}
