#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

# scripts/install-fonts.sh fetches release JSON (gh, else curl), picks the
# asset whose name matches each font's glob, and unpacks the font files into
# the user font directory. gh, curl and unzip are PATH stubs and HOME is a
# scratch dir, so nothing reaches the network or a real font directory.
# gh behaves like an unauthenticated CLI (exit 4) unless GH_OK=1: that is the
# fresh-machine case that used to fail every font instead of using curl.

setup()
{
  SCRIPT="$BATS_TEST_DIRNAME/../scripts/install-fonts.sh"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin" "$TMP/dotfiles/config" "$TMP/home"
  : > "$TMP/dotfiles/config/shared.sh"
  FONT_DIR="$TMP/home/.local/share/fonts"
  CALLS="$TMP/calls"
  : > "$CALLS"

  # One release JSON serves every font: an asset for each registry glob
  # plus a decoy that no glob may select.
  cat > "$TMP/release.json" << 'JSON'
{"assets": [
  {"browser_download_url": "https://example.test/dl/Decoy.tar.xz"},
  {"browser_download_url": "https://example.test/dl/JetBrainsMono.zip"},
  {"browser_download_url": "https://example.test/dl/OpenDyslexic.zip"},
  {"browser_download_url": "https://example.test/dl/monaspace-v1.200.zip"},
  {"browser_download_url": "https://example.test/dl/Fira_Code_v6.2.zip"}
]}
JSON

  cat > "$TMP/bin/gh" << STUB
#!/usr/bin/env bash
printf 'gh %s\n' "\$*" >> "$CALLS"
if [ "\${GH_OK:-0}" = 1 ]; then cat "$TMP/release.json"; exit 0; fi
printf 'To get started with GitHub CLI, please run:  gh auth login\n' >&2
exit 4
STUB

  # curl writes an empty archive for downloads (-o FILE) and serves the
  # release JSON for API requests.
  cat > "$TMP/bin/curl" << STUB
#!/usr/bin/env bash
printf 'curl %s\n' "\$*" >> "$CALLS"
out=""
while [ \$# -gt 0 ]; do
  if [ "\$1" = -o ]; then out="\$2"; shift; fi
  shift
done
if [ -n "\$out" ]; then : > "\$out"; exit 0; fi
cat "$TMP/release.json"
STUB

  # unzip -qo ZIP -d DIR drops one font file in a nested directory, the way
  # release archives nest them.
  cat > "$TMP/bin/unzip" << 'STUB'
#!/usr/bin/env bash
dir="${!#}"
mkdir -p "$dir/nested"
: > "$dir/nested/Font-Regular.ttf"
STUB

  printf '#!/bin/sh\nprintf "Linux\\n"\n' > "$TMP/bin/uname"
  printf '#!/bin/sh\nexit 0\n' > "$TMP/bin/fc-cache"
  printf '#!/bin/sh\nprintf "%%s\\n" "$*"\n' > "$TMP/bin/msgr"
  chmod +x "$TMP/bin/"*
}

teardown()
{
  rm -rf "$TMP"
}

# Run the script against the stubs; extra arguments go to the script.
run_fonts()
{
  run env PATH="$TMP/bin:$PATH" HOME="$TMP/home" DOTFILES="$TMP/dotfiles" \
    GH_OK="${GH_OK:-0}" bash "$SCRIPT" "$@"
}

# Pre-populate the font dir so every registry entry counts as installed.
install_all_fonts()
{
  mkdir -p "$FONT_DIR"
  : > "$FONT_DIR/JetBrainsMonoNL-Regular.ttf"
  : > "$FONT_DIR/OpenDyslexic-Regular.otf"
  : > "$FONT_DIR/MonaspaceNeon-Regular.otf"
  : > "$FONT_DIR/FiraCode-Regular.ttf"
}

@test "install-fonts: an unauthenticated gh falls back to curl" {
  run_fonts
  [ "$status" -eq 0 ]
  grep -q '^gh api repos/ryanoasis/nerd-fonts/releases/latest' "$CALLS"
  grep -q '^curl .*https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest' "$CALLS"
  [ -f "$FONT_DIR/Font-Regular.ttf" ]
}

@test "install-fonts: an authenticated gh needs no curl for release JSON" {
  GH_OK=1
  run_fonts
  [ "$status" -eq 0 ]
  run ! grep -q '^curl .*api.github.com' "$CALLS"
}

@test "install-fonts: each font downloads the asset its glob names" {
  run_fonts
  [ "$status" -eq 0 ]
  grep -q 'https://example.test/dl/JetBrainsMono.zip' "$CALLS"
  grep -q 'https://example.test/dl/OpenDyslexic.zip' "$CALLS"
  grep -q 'https://example.test/dl/monaspace-v1.200.zip' "$CALLS"
  grep -q 'https://example.test/dl/Fira_Code_v6.2.zip' "$CALLS"
  run ! grep -q 'Decoy' "$CALLS"
}

@test "install-fonts: downloads refuse a redirect off https" {
  run_fonts
  [ "$status" -eq 0 ]
  downloads=$(grep -c '^curl .* -o ' "$CALLS")
  [ "$downloads" -eq 4 ]
  [ "$(grep '^curl .* -o ' "$CALLS" | grep -c -- "--proto-redir =https")" -eq 4 ]
}

@test "install-fonts: installed fonts are skipped without a network call" {
  install_all_fonts
  run_fonts
  [ "$status" -eq 0 ]
  [ ! -s "$CALLS" ]
}

@test "install-fonts: --force reinstalls installed fonts" {
  install_all_fonts
  run_fonts --force
  [ "$status" -eq 0 ]
  [ "$(grep -c '^curl .* -o ' "$CALLS")" -eq 4 ]
}

@test "install-fonts: an unknown option exits 1" {
  run_fonts --bogus
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option: --bogus"* ]]
}
