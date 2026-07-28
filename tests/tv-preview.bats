#!/usr/bin/env bats

# tv-preview is the preview dispatcher for the television cables. It picks a
# renderer from the file extension, so the tests stub both renderers and
# assert which one was chosen and with what arguments.

setup()
{
  PREVIEW="$BATS_TEST_DIRNAME/../local/bin/tv-preview"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin" "$TMP/cfg/glow"
  cat > "$TMP/bin/glow" << 'STUB'
#!/usr/bin/env bash
printf 'GLOW:%s\n' "$*"
STUB
  cat > "$TMP/bin/bat" << 'STUB'
#!/usr/bin/env bash
printf 'BAT:%s\n' "$*"
STUB
  chmod +x "$TMP/bin/glow" "$TMP/bin/bat"
  touch "$TMP/doc.md" "$TMP/DOC.MD" "$TMP/notes.markdown" "$TMP/n.mkd" \
    "$TMP/script.sh" "$TMP/noext"
}

teardown()
{
  rm -rf "$TMP"
}

run_preview()
{
  run env PATH="$TMP/bin:$PATH" XDG_CONFIG_HOME="$TMP/cfg" "$PREVIEW" "$1"
}

@test "tv-preview: renders .md with glow" {
  run_preview "$TMP/doc.md"
  [ "$status" -eq 0 ]
  [[ "$output" == GLOW:* ]]
}

@test "tv-preview: matches uppercase .MD" {
  run_preview "$TMP/DOC.MD"
  [[ "$output" == GLOW:* ]]
}

@test "tv-preview: matches .markdown and .mkd" {
  run_preview "$TMP/notes.markdown"
  [[ "$output" == GLOW:* ]]
  run_preview "$TMP/n.mkd"
  [[ "$output" == GLOW:* ]]
}

@test "tv-preview: uses bat for a non-markdown file" {
  run_preview "$TMP/script.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == BAT:* ]]
  [[ "$output" == *"--color=always"* ]]
}

@test "tv-preview: uses bat for an extensionless file" {
  run_preview "$TMP/noext"
  [[ "$output" == BAT:* ]]
}

@test "tv-preview: passes the terminal style when present" {
  printf '{}\n' > "$TMP/cfg/glow/terminal.json"
  run_preview "$TMP/doc.md"
  [[ "$output" == *"-s $TMP/cfg/glow/terminal.json"* ]]
}

@test "tv-preview: omits the style flag when absent" {
  run_preview "$TMP/doc.md"
  [[ "$output" != *"-s "* ]]
}

@test "tv-preview: falls back to bat for markdown when glow is missing" {
  rm "$TMP/bin/glow"
  run env PATH="$TMP/bin:/usr/bin:/bin" XDG_CONFIG_HOME="$TMP/cfg" "$PREVIEW" "$TMP/doc.md"
  [ "$status" -eq 0 ]
  [[ "$output" == BAT:* ]]
}

@test "tv-preview: separates the filename with -- so a leading dash is safe" {
  touch "$TMP/-dashed.md"
  run_preview "$TMP/-dashed.md"
  [[ "$output" == *"--"* ]]
}
