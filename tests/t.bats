#!/usr/bin/env bats

# t turns a directory or an existing session name into a tmux session. The
# tests pass the selection as an argument, which skips the interactive picker,
# and stub tmux so nothing is created on the real server.

setup()
{
  T="$BATS_TEST_DIRNAME/../local/bin/t"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin" "$TMP/code/my.project"
  CALLS="$TMP/calls"
  : > "$CALLS"
  for tool in bash env basename find sort grep mktemp rm cat; do
    ln -sf "$(command -v "$tool")" "$TMP/bin/$tool"
  done
  # Records every tmux call. display-message prints nothing, so the script
  # never believes it is already on the target session.
  cat > "$TMP/bin/tmux" << STUB
#!/usr/bin/env bash
printf 'tmux %s\n' "\$*" >> "$CALLS"
case "\$1" in
  has-session) exit "\${HAS_SESSION:-1}" ;;
  info) exit 0 ;;
esac
STUB
  printf '#!/usr/bin/env bash\nexit 0\n' > "$TMP/bin/fzf"
  chmod +x "$TMP/bin/tmux" "$TMP/bin/fzf"
}

teardown()
{
  rm -rf "$TMP"
}

t_run()
{
  run env -u TMUX PATH="$TMP/bin" T_ROOT="$TMP/code" "$T" "$@"
}

@test "t: refuses a T_ROOT that does not exist, and names it" {
  run env PATH="$TMP/bin" T_ROOT="$TMP/nope" "$T" "$TMP/code"
  [ "$status" -eq 1 ]
  [[ "$output" == *"$TMP/nope"* ]]
  [[ "$output" == *"does not exist"* ]]
}

@test "t: the T_ROOT error goes to stderr" {
  run env PATH="$TMP/bin" T_ROOT="$TMP/nope" bash -c "'$T' x 2>/dev/null"
  [[ "$output" != *"does not exist"* ]]
}

@test "t: requires tmux" {
  rm "$TMP/bin/tmux"
  t_run "$TMP/code/my.project"
  [ "$status" -eq 1 ]
  [[ "$output" == *"tmux is not installed"* ]]
}

@test "t: requires a picker even when a selection is passed" {
  # check_dependencies runs before the argument is looked at.
  rm "$TMP/bin/fzf"
  t_run "$TMP/code/my.project"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Neither tv nor fzf"* ]]
}

@test "t: rejects a header line as a selection" {
  t_run "# Sessions"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Header selected"* ]]
}

@test "t: rejects an empty selection" {
  t_run ""
  [ "$status" -eq 1 ]
  [[ "$output" == *"No directory or session selected"* ]]
}

@test "t: a header line never reaches tmux" {
  t_run "# Directories"
  run ! grep -q 'new-session' "$CALLS"
}

@test "t: names the session after the directory" {
  t_run "$TMP/code/my.project"
  grep -q 'new-session -A -s myproject' "$CALLS"
}

@test "t: strips dots from the session name" {
  # tmux treats a dot as a pane separator in target specifiers.
  t_run "$TMP/code/my.project"
  run ! grep -q 'my\.project -c' "$CALLS"
}

@test "t: opens the new session in the selected directory" {
  t_run "$TMP/code/my.project"
  grep -q -- "-c $TMP/code/my.project" "$CALLS"
}

@test "t: switches instead of attaching when already inside tmux" {
  run env PATH="$TMP/bin" TMUX="/tmp/fake,1,0" T_ROOT="$TMP/code" \
    "$T" "$TMP/code/my.project"
  grep -q 'new-session -d -s myproject' "$CALLS"
  grep -q 'switch-client -t myproject' "$CALLS"
}

@test "t: does not recreate an existing session from inside tmux" {
  run env PATH="$TMP/bin" TMUX="/tmp/fake,1,0" HAS_SESSION=0 T_ROOT="$TMP/code" \
    "$T" "$TMP/code/my.project"
  run ! grep -q 'new-session' "$CALLS"
  grep -q 'switch-client -t myproject' "$CALLS"
}
