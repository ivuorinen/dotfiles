#!/usr/bin/env bats
# Every theme family under config/theme/palettes.d/<family>/<mode>/ ships
# the full set of files the handlers resolve, in both modes, and every
# structured file parses. A family missing one would make its handler
# unlink that app's palette at runtime; this catches it in CI instead.

setup()
{
  ROOT="$BATS_TEST_DIRNAME/.."
  PD="$ROOT/config/theme/palettes.d"
  # tmux.thm.conf is optional: only families that override @thm_* ship it.
  REQUIRED=(starship.toml eza.yml gitui.ron yazi.toml fzf.sh fzf.fish
    gh-dash.theme.yml television.toml dircolors tmux.conf bat.theme)
}

families()
{
  local d
  for d in "$PD"/*/; do
    basename -- "$d"
  done
}

check_complete()
{
  local pd=$1 fam mode f missing=()
  for fam in $(PD="$pd" families); do
    for mode in dark light; do
      for f in "${REQUIRED[@]}"; do
        [[ -e "$pd/$fam/$mode/$f" ]] || missing+=("$fam/$mode/$f")
      done
    done
  done
  if ((${#missing[@]})); then
    printf 'missing: %s\n' "${missing[@]}"
    return 1
  fi
}

@test "palettes: at least catppuccin, kanagawa and oasis exist" {
  [ -d "$PD/catppuccin" ]
  [ -d "$PD/kanagawa" ]
  [ -d "$PD/oasis" ]
}

@test "palettes: every family ships every handler file in both modes" {
  check_complete "$PD"
}

@test "palettes: the completeness check fails when a file is missing" {
  cp -R "$PD" "$BATS_TEST_TMPDIR/pd"
  rm "$BATS_TEST_TMPDIR/pd/kanagawa/light/gitui.ron"
  run check_complete "$BATS_TEST_TMPDIR/pd"
  [ "$status" -eq 1 ]
  [[ "$output" == *"kanagawa/light/gitui.ron"* ]]
}

@test "palettes: the tracked family file names an existing family" {
  run cat "$ROOT/config/theme/family"
  [ "$status" -eq 0 ]
  [ -d "$PD/$output" ]
}

@test "palettes: every TOML palette parses" {
  command -v python3 > /dev/null 2>&1 || skip "python3 not installed"
  run python3 - "$PD" << 'PY'
import pathlib, sys, tomllib
bad = []
for p in sorted(pathlib.Path(sys.argv[1]).rglob("*.toml")):
    try:
        tomllib.loads(p.read_text())
    except Exception as e:  # noqa: BLE001 - report every parse failure
        bad.append(f"{p}: {e}")
print("\n".join(bad))
sys.exit(1 if bad else 0)
PY
  [ "$status" -eq 0 ]
}

@test "palettes: every YAML palette parses" {
  command -v yamllint > /dev/null 2>&1 || skip "yamllint not installed"
  run yamllint -d '{extends: relaxed, rules: {line-length: disable}}' "$PD"
  [ "$status" -eq 0 ]
}

# Private tmux socket dir under /tmp, not BATS_TEST_TMPDIR: the socket
# path must fit macOS's 104-byte sun_path, and a deep TMPDIR overflows it.
private_tmux()
{
  # shellcheck disable=SC2030,SC2031
  TMUX_TMPDIR="$(mktemp -d /tmp/tmx.XXXXXX)"
  export TMUX_TMPDIR
  unset TMUX
}

teardown()
{
  if [[ -n "${TMUX_TMPDIR:-}" && "$TMUX_TMPDIR" == /tmp/tmx.* ]]; then
    tmux kill-server 2> /dev/null || true
    rm -rf -- "$TMUX_TMPDIR"
  fi
}

@test "palettes: every tmux palette parses" {
  command -v tmux > /dev/null 2>&1 || skip "tmux not installed"
  private_tmux
  # `sleep`, not a shell: a shell pane would run shell init, which spawns
  # the theme watcher with this test's environment.
  tmux -f /dev/null new-session -d -s parse 'sleep 300'
  local f rc=0
  for f in "$PD"/*/*/tmux*.conf; do
    tmux source-file -n "$f" || {
      echo "parse error: $f"
      rc=1
    }
  done
  tmux kill-server
  [ "$rc" -eq 0 ]
}

@test "tmux.conf: server options stay idempotent across the flip-time reload" {
  command -v tmux > /dev/null 2>&1 || skip "tmux not installed"
  private_tmux
  tmux -f /dev/null new-session -d -s idem 'sleep 300'
  # handlers.d/tmux re-sources tmux.conf on every flip, so any appending
  # `set -as`/`-ag` on an array option would grow it without bound.
  grep -E '^set +-s +terminal-features' "$ROOT/config/tmux/tmux.conf" > "$BATS_TEST_TMPDIR/tf.conf"
  [ -s "$BATS_TEST_TMPDIR/tf.conf" ]
  tmux source-file "$BATS_TEST_TMPDIR/tf.conf"
  local once
  once="$(tmux show -s terminal-features | wc -l)"
  tmux source-file "$BATS_TEST_TMPDIR/tf.conf"
  tmux source-file "$BATS_TEST_TMPDIR/tf.conf"
  local thrice
  thrice="$(tmux show -s terminal-features | wc -l)"
  tmux kill-server
  [ "$once" -eq "$thrice" ]
  run grep -nE '^set(-option)? +-[a-z]*a[a-z]* +terminal-features' "$ROOT/config/tmux/tmux.conf"
  [ "$status" -eq 1 ]
}

@test "palettes: every bat.theme names a vendored tmTheme" {
  local f name
  for f in "$PD"/*/*/bat.theme; do
    read -r name < "$f"
    [ -f "$ROOT/config/bat/themes/$name.tmTheme" ] || {
      echo "$f names missing tmTheme: $name"
      return 1
    }
  done
}
