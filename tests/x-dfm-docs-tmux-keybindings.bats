#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

# x-dfm-docs-tmux-keybindings regenerates docs/tmux-keybindings.md from
# `tmux list-keys`. The tests feed it a fixed fixture instead of the running
# tmux server, so the assertions describe the formatting rules rather than
# whatever bindings this machine happens to have.
#
# The script sources "$DOTFILES/config/shared.sh", so DOTFILES points at a
# temporary tree carrying a stub of it. That is what makes the stub PATH hold:
# the real shared.sh pulls in config/exports, which rebuilds PATH from scratch
# and would drop the stub directory — the same reason dfm cannot be isolated
# this way.

setup()
{
  GEN="$BATS_TEST_DIRNAME/../local/bin/x-dfm-docs-tmux-keybindings"
  TMP="$(mktemp -d)"
  DOT="$TMP/dotfiles"
  mkdir -p "$TMP/bin" "$DOT/config" "$DOT/docs"
  OUT="$DOT/docs/tmux-keybindings.md"

  for tool in bash env awk sed sort grep mktemp mv rm cat printf; do
    src="$(command -v "$tool")" && ln -sf "$src" "$TMP/bin/$tool"
  done

  # Minimal stand-in for config/shared.sh: just the three helpers the script
  # uses, and no PATH rebuilding.
  cat > "$DOT/config/shared.sh" << 'SHIM'
msg() { printf '%s\n' "$*"; }
msg_err() { printf '%s\n' "$*" >&2; exit 1; }
x-have() { command -v "$1" > /dev/null 2>&1; }
SHIM

  cat > "$TMP/bin/tmux" << STUB
#!/usr/bin/env bash
notes=0
table=""
shift
while [ \$# -gt 0 ]; do
  case "\$1" in
    -N) notes=1; shift ;;
    -T) table="\$2"; shift 2 ;;
    *) shift ;;
  esac
done

all()
{
  cat << 'KEYS'
bind-key    -T copy-mode    C-Space          send-keys -X begin-selection
bind-key    -T copy-mode    WheelUpPane      send-keys -X scroll-up
bind-key    -T prefix       c                new-window
bind-key    -T prefix       \\"               split-window
bind-key    -T prefix       R                run-shell "__HOME__/.local/share/tmux/plugins/tpm/bindings/install_plugins"
bind-key    -T prefix       S                run-shell "__HOME__/.config/tmux/save.sh"
bind-key    -T root         MouseDown1Pane   select-pane
bind-key    -T zzz-custom   x                kill-pane
KEYS
}

if [ -z "\$table" ]; then
  all | sed "s#__HOME__#\$HOME#"
  exit 0
fi

if [ "\$notes" = "1" ]; then
  case "\$table" in
    prefix)
      printf '    %-20s %s\n' 'c' 'Create a new window'
      printf '    %-20s %s\n' '"' 'Split the window'
      ;;
  esac
  exit 0
fi

all | grep -- "-T \$table " | sed "s#__HOME__#\$HOME#"
STUB
  chmod +x "$TMP/bin/tmux"
}

teardown()
{
  rm -rf "$TMP"
}

gen()
{
  run env PATH="$TMP/bin" HOME="$TMP/home" DOTFILES="$DOT" "$GEN"
}

@test "docs-tmux: refuses to run without tmux" {
  rm "$TMP/bin/tmux"
  gen
  [ "$status" -ne 0 ]
  [[ "$output" == *"tmux not found"* ]]
}

@test "docs-tmux: writes the doc and says where" {
  gen
  [ "$status" -eq 0 ]
  [ -f "$OUT" ]
  [[ "$output" == *"$OUT"* ]]
}

@test "docs-tmux: the doc has a title and the leader key" {
  gen
  [[ "$(head -1 "$OUT")" == "# tmux keybindings" ]]
  grep -q 'Leader: `<ctrl><space>`' "$OUT"
}

@test "docs-tmux: preferred tables come first, the rest follow sorted" {
  gen
  order=$(grep '^## ' "$OUT" | tr -d '#' | tr -d ' ' | tr '\n' ',')
  [ "$order" = "prefix,root,copy-mode,zzz-custom," ]
}

@test "docs-tmux: a table tmux reports but the preferred list omits is still written" {
  # The preferred list is hand-maintained; anything missing from it has to be
  # appended rather than dropped.
  gen
  grep -q '^## zzz-custom' "$OUT"
  grep -q 'kill-pane' "$OUT"
}

@test "docs-tmux: a binding's note wins over its command" {
  gen
  grep -qE '^c +Create a new window$' "$OUT"
  run ! grep -qE '^c +new-window$' "$OUT"
}

@test "docs-tmux: a binding with no note falls back to the command" {
  # The notes stream carries a sentinel so it is never empty. Without it awk's
  # NR == FNR stays true for the second file too and note-less tables — root,
  # copy-mode — render nothing at all.
  gen
  grep -qE '^C-Space +send-keys -X begin-selection$' "$OUT"
}

@test "docs-tmux: the escaped quote key is normalised" {
  gen
  grep -qE '^" +Split the window$' "$OUT"
  run ! grep -q '^\\"' "$OUT"
}

@test "docs-tmux: mouse and wheel events are dropped" {
  gen
  run ! grep -qE 'WheelUpPane|MouseDown1Pane' "$OUT"
}

@test "docs-tmux: the home directory is written back as a literal" {
  # The doc is committed, so an expanded /home/<user> would make it differ on
  # every machine that regenerates it.
  gen
  run ! grep -q "$TMP/home" "$OUT"
  grep -q 'run-shell "\$HOME/\.config/tmux/save\.sh"' "$OUT"
}

@test "docs-tmux: the tmux plugin install path is stripped" {
  gen
  grep -q 'tpm/bindings/install_plugins' "$OUT"
  run ! grep -q '.local/share/tmux/plugins' "$OUT"
}

@test "docs-tmux: leaves no temp file behind" {
  mkdir -p "$TMP/tmpdir"
  run env PATH="$TMP/bin" HOME="$TMP/home" TMPDIR="$TMP/tmpdir" DOTFILES="$DOT" "$GEN"
  [ "$status" -eq 0 ]
  [ -z "$(ls -A "$TMP/tmpdir")" ]
}
