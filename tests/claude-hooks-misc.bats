#!/usr/bin/env bats
#
# Coverage for the remaining .claude/hooks/ scripts — the advisory and
# housekeeping half of the chain, which the four dedicated files
# (pre-bash-route, pre-edit-block, pre-ctx-write-guard,
# post-tool-context-mode-check, post-edit-rules-lint) do not reach.
#
# None of these block a tool call, which is exactly why they need tests: a
# non-blocking hook that stops working fails silently. There is no red gate to
# notice that the formatter stopped formatting or the failure log stopped
# logging.

bats_require_minimum_version 1.5.0

setup()
{
  HOOKS="${BATS_TEST_DIRNAME}/../.claude/hooks"
  WORK="$(mktemp -d)"
  export HOOKS WORK
}

teardown()
{
  rm -rf "$WORK"
}

# Most of these take a PostToolUse payload naming one file.
with_path()
{
  jq -cn --arg fp "$1" '{tool_input: {file_path: $fp}}'
}

# --- post-edit-config-warn.sh -------------------------------------------
# Advisory only: a formatter config change is repo-wide, so it earns a note
# on stderr. It must never block, or editing .editorconfig would be
# impossible.

@test "post-edit-config-warn: warns on a formatter config, without blocking" {
  for f in .editorconfig biome.json .prettierrc.json .shellcheckrc stylua.toml .yamllint.yml; do
    : > "$WORK/$f"
    run -0 bash -c 'with_path() { jq -cn --arg fp "$1" "{tool_input: {file_path: \$fp}}"; }; with_path "$1" | bash "$2"' \
      _ "$WORK/$f" "$HOOKS/post-edit-config-warn.sh"
    [[ "$output" == *"Formatter/linter config changed"* ]]
  done
}

@test "post-edit-config-warn: stays silent for ordinary files" {
  : > "$WORK/notes.md"
  run -0 bash -c 'jq -cn --arg fp "$1" "{tool_input: {file_path: \$fp}}" | bash "$2"' \
    _ "$WORK/notes.md" "$HOOKS/post-edit-config-warn.sh"
  [ -z "$output" ]
}

@test "post-edit-config-warn: a missing file is not an error" {
  run -0 bash -c 'jq -cn --arg fp "$1" "{tool_input: {file_path: \$fp}}" | bash "$2"' \
    _ "$WORK/.editorconfig-that-does-not-exist" "$HOOKS/post-edit-config-warn.sh"
}

# --- post-edit-dotbot-validate.sh ---------------------------------------
# Scoped to install.conf.yaml. This one DOES block (exit 2) — a malformed
# dotbot config breaks ./install, and the failure would otherwise appear far
# from the edit that caused it.

@test "post-edit-dotbot-validate: rejects malformed install.conf.yaml" {
  printf -- '- link:\n    ~/.foo: bar\n  bad indent here: [\n' > "$WORK/install.conf.yaml"
  run -2 bash -c 'jq -cn --arg fp "$1" "{tool_input: {file_path: \$fp}}" | bash "$2"' \
    _ "$WORK/install.conf.yaml" "$HOOKS/post-edit-dotbot-validate.sh"
  [[ "$output" == *"install.conf.yaml"* ]]
}

@test "post-edit-dotbot-validate: accepts a well-formed install.conf.yaml" {
  printf -- '---\n- defaults:\n    link:\n      relink: true\n- link:\n    ~/.bashrc: base/bashrc\n' \
    > "$WORK/install.conf.yaml"
  run -0 bash -c 'jq -cn --arg fp "$1" "{tool_input: {file_path: \$fp}}" | bash "$2"' \
    _ "$WORK/install.conf.yaml" "$HOOKS/post-edit-dotbot-validate.sh"
}

# The repo's real dotbot config must pass its own validator — a check that
# would have caught the link-config split had it gone wrong.
@test "post-edit-dotbot-validate: the repo's own configs validate" {
  for f in install.conf.yaml dotbot-links.yaml; do
    [ -f "${BATS_TEST_DIRNAME}/../$f" ] || continue
  done
  run -0 bash -c 'jq -cn --arg fp "$1" "{tool_input: {file_path: \$fp}}" | bash "$2"' \
    _ "${BATS_TEST_DIRNAME}/../install.conf.yaml" "$HOOKS/post-edit-dotbot-validate.sh"
}

@test "post-edit-dotbot-validate: ignores yaml that is not a dotbot config" {
  printf 'this: [is, broken\n' > "$WORK/other.yaml"
  run -0 bash -c 'jq -cn --arg fp "$1" "{tool_input: {file_path: \$fp}}" | bash "$2"' \
    _ "$WORK/other.yaml" "$HOOKS/post-edit-dotbot-validate.sh"
}

# --- pre-graphify-nudge.sh ----------------------------------------------
# Emits PreToolUse JSON carrying a one-line tip. It is paid per tool call, so
# the contract is: silent and free when there is no graph, one short line when
# there is.

@test "pre-graphify-nudge: silent when no graph exists" {
  run -0 env CLAUDE_PROJECT_DIR="$WORK" bash "$HOOKS/pre-graphify-nudge.sh" read
  [ -z "$output" ]
}

@test "pre-graphify-nudge: emits valid hook JSON when a graph exists" {
  mkdir -p "$WORK/graphify-out"
  : > "$WORK/graphify-out/graph.json"
  run -0 env CLAUDE_PROJECT_DIR="$WORK" bash "$HOOKS/pre-graphify-nudge.sh" read
  # Must be parseable and carry the documented event name, or Claude Code
  # discards it silently.
  [ "$(printf '%s' "$output" | jq -r '.hookSpecificOutput.hookEventName')" = "PreToolUse" ]
  [[ "$(printf '%s' "$output" | jq -r '.hookSpecificOutput.additionalContext')" == *"raw reads"* ]]
}

@test "pre-graphify-nudge: the search mode names grep, not reads" {
  mkdir -p "$WORK/graphify-out"
  : > "$WORK/graphify-out/graph.json"
  run -0 env CLAUDE_PROJECT_DIR="$WORK" bash "$HOOKS/pre-graphify-nudge.sh" search
  [[ "$(printf '%s' "$output" | jq -r '.hookSpecificOutput.additionalContext')" == *"raw grep"* ]]
}

@test "pre-graphify-nudge: never emits a permissionDecision" {
  mkdir -p "$WORK/graphify-out"
  : > "$WORK/graphify-out/graph.json"
  run -0 env CLAUDE_PROJECT_DIR="$WORK" bash "$HOOKS/pre-graphify-nudge.sh" read
  # It adds context; a decision here would silently gate every Read and Bash.
  [ "$(printf '%s' "$output" | jq -r '.hookSpecificOutput.permissionDecision // "none"')" = "none" ]
}

# --- log-failures.sh ----------------------------------------------------

@test "log-failures: appends one JSON line per failure" {
  mkdir -p "$WORK/.claude"
  run -0 bash -c 'printf "%s" "$1" | CLAUDE_PROJECT_DIR="$2" bash "$3"' _ \
    '{"tool_name":"Bash","error":"boom"}' "$WORK" "$HOOKS/log-failures.sh"
  [ -f "$WORK/.claude/hook-failures.log" ]
  [ "$(wc -l < "$WORK/.claude/hook-failures.log")" -eq 1 ]
  [ "$(jq -r '.tool' < "$WORK/.claude/hook-failures.log")" = "Bash" ]
  [ "$(jq -r '.error' < "$WORK/.claude/hook-failures.log")" = "boom" ]
  # The timestamp is what makes the log usable; an entry without one is noise.
  [[ "$(jq -r '.time' < "$WORK/.claude/hook-failures.log")" == 20[0-9][0-9]-* ]]
}

@test "log-failures: tail-rotates at the 1000-line cap" {
  mkdir -p "$WORK/.claude"
  # Seed past the cap so the next append triggers rotation.
  for i in $(seq 1 1005); do printf '{"n":%d}\n' "$i"; done > "$WORK/.claude/hook-failures.log"
  run -0 bash -c 'printf "%s" "$1" | CLAUDE_PROJECT_DIR="$2" bash "$3"' _ \
    '{"tool_name":"Edit","error":"x"}' "$WORK" "$HOOKS/log-failures.sh"
  [ "$(wc -l < "$WORK/.claude/hook-failures.log")" -eq 1000 ]
  # Rotation keeps the tail, so the newest entry has to survive it.
  [ "$(tail -1 "$WORK/.claude/hook-failures.log" | jq -r '.tool')" = "Edit" ]
}

# --- session-start-context.sh -------------------------------------------

@test "session-start-context: reports branch, dirty count and last commit" {
  git init -q "$WORK/repo"
  git -C "$WORK/repo" config user.email t@t.t
  git -C "$WORK/repo" config user.name t
  : > "$WORK/repo/a"
  git -C "$WORK/repo" add a
  git -C "$WORK/repo" commit -qm "feat: first"
  : > "$WORK/repo/dirty"

  run -0 env CLAUDE_PROJECT_DIR="$WORK/repo" bash "$HOOKS/session-start-context.sh"
  [[ "$output" == *"Dotfiles session context"* ]]
  [[ "$output" == *"Branch : "* ]]
  [[ "$output" == *"Dirty  : 1 file(s)"* ]]
  [[ "$output" == *"feat: first"* ]]
}

# It runs before anything else in a session, so a non-repo directory must not
# take the session down with it.
@test "session-start-context: survives a directory that is not a repo" {
  run -0 env CLAUDE_PROJECT_DIR="$WORK" bash "$HOOKS/session-start-context.sh"
  [[ "$output" == *"Branch : unknown"* ]]
}

# --- async-bats.sh ------------------------------------------------------
# Runs the matching test file after an edit. Every exit path is 0: it is a
# convenience, and a missing test file or absent bats must not fail the turn.

@test "async-bats: no matching test file is a silent no-op" {
  run -0 env CLAUDE_PROJECT_DIR="$WORK" bash -c \
    'jq -cn --arg fp "$1" "{tool_input: {file_path: \$fp}}" | bash "$2"' \
    _ "$WORK/local/bin/nonexistent-script" "$HOOKS/async-bats.sh"
  [ -z "$output" ]
}

@test "async-bats: runs the test file matching the edited script" {
  mkdir -p "$WORK/tests"
  cat > "$WORK/tests/demo-script.bats" << 'EOF'
#!/usr/bin/env bats
@test "demo: trivially true" { true; }
EOF
  run -0 env CLAUDE_PROJECT_DIR="$WORK" bash -c \
    'jq -cn --arg fp "$1" "{tool_input: {file_path: \$fp}}" | bash "$2"' \
    _ "$WORK/local/bin/demo-script" "$HOOKS/async-bats.sh"
  [[ "$output" == *"demo: trivially true"* ]]
}

@test "async-bats: an empty payload is a no-op" {
  run -0 env CLAUDE_PROJECT_DIR="$WORK" bash -c 'printf "{}" | bash "$1"' _ "$HOOKS/async-bats.sh"
}

# --- post-edit-format.sh ------------------------------------------------
# Dispatches by extension. Each formatter is command -v guarded, so on a host
# missing one the hook must no-op rather than fail.

@test "post-edit-format: formats a shell script in place" {
  command -v shfmt > /dev/null || skip "shfmt not installed"
  printf '#!/usr/bin/env bash\nif true; then\n        echo deep\nfi\n' > "$WORK/s.sh"
  run -0 bash -c 'jq -cn --arg fp "$1" "{tool_input: {file_path: \$fp}}" | bash "$2"' \
    _ "$WORK/s.sh" "$HOOKS/post-edit-format.sh"
  # 8-space indent collapses to the repo's 2.
  grep -q '^  echo deep$' "$WORK/s.sh"
}

# The shebang anchor exists so zsh scripts under */bin/* are not shfmt'd —
# shfmt has no zsh support and mangles (( )) and glob qualifiers.
@test "post-edit-format: leaves a zsh script under bin/ alone" {
  command -v shfmt > /dev/null || skip "shfmt not installed"
  mkdir -p "$WORK/bin"
  printf '#!/usr/bin/env zsh\nif true; then\n        echo deep\nfi\n' > "$WORK/bin/z"
  before="$(cat "$WORK/bin/z")"
  run -0 bash -c 'jq -cn --arg fp "$1" "{tool_input: {file_path: \$fp}}" | bash "$2"' \
    _ "$WORK/bin/z" "$HOOKS/post-edit-format.sh"
  [ "$(cat "$WORK/bin/z")" = "$before" ]
}

@test "post-edit-format: ignores extensions it has no formatter for" {
  printf 'unchanged   content\n' > "$WORK/f.txt"
  run -0 bash -c 'jq -cn --arg fp "$1" "{tool_input: {file_path: \$fp}}" | bash "$2"' \
    _ "$WORK/f.txt" "$HOOKS/post-edit-format.sh"
  [ "$(cat "$WORK/f.txt")" = 'unchanged   content' ]
}

@test "post-edit-format: a missing file is a no-op" {
  run -0 bash -c 'jq -cn --arg fp "$1" "{tool_input: {file_path: \$fp}}" | bash "$2"' \
    _ "$WORK/gone.sh" "$HOOKS/post-edit-format.sh"
}

# --- notify-idle.sh -----------------------------------------------------
# Forwards hook-supplied text to pushover, falling back to osascript. That
# text is untrusted input reaching a command line, which is how the pushover
# eval defect was reachable from a hook in the first place — so the argv
# handling is the thing worth pinning here.

# Stub pushover so the hook's chosen branch is observable, recording argv one
# entry per line: per-line is what proves a payload arrived as ONE argument
# rather than being split by a shell that re-parsed it.
stub_pushover()
{
  mkdir -p "$WORK/bin"
  cat > "$WORK/bin/pushover" << 'EOF'
#!/usr/bin/env sh
for a in "$@"; do printf '%s\n' "$a" >> "$STUB_ARGS"; done
EOF
  chmod +x "$WORK/bin/pushover"
}

@test "notify-idle: forwards the message to pushover with a title" {
  stub_pushover
  run -0 env PATH="$WORK/bin:$PATH" STUB_ARGS="$WORK/args" bash -c \
    'printf "%s" "$1" | bash "$2"' _ '{"message":"build finished"}' "$HOOKS/notify-idle.sh"
  grep -Fqx 'Claude Code' "$WORK/args"
  grep -Fqx 'build finished' "$WORK/args"
}

@test "notify-idle: falls back to a default message" {
  stub_pushover
  run -0 env PATH="$WORK/bin:$PATH" STUB_ARGS="$WORK/args" bash -c \
    'printf "%s" "$1" | bash "$2"' _ '{}' "$HOOKS/notify-idle.sh"
  grep -Fqx 'Claude is waiting for input' "$WORK/args"
}

# A notification body is untrusted text. It must reach pushover as a single
# argument with its metacharacters intact, never expanded en route.
@test "notify-idle: shell metacharacters survive as one literal argument" {
  stub_pushover
  run -0 env PATH="$WORK/bin:$PATH" STUB_ARGS="$WORK/args" bash -c \
    'printf "%s" "$1" | bash "$2"' _ \
    '{"message":"done $(id -u) \"quoted\" & more"}' "$HOOKS/notify-idle.sh"
  grep -Fqx 'done $(id -u) "quoted" & more' "$WORK/args"
  # The substitution must not have run: the caller's uid must not appear.
  run ! grep -q "done $(id -u) " "$WORK/args"
}

@test "notify-idle: exits cleanly when no notifier is installed" {
  # /usr/bin:/bin only — enough for bash and jq, but it holds neither
  # pushover (which lives in ~/.local/bin) nor osascript (macOS-only), so
  # both branches miss and the hook must still exit 0 rather than erroring.
  run -0 env PATH="/usr/bin:/bin" bash -c \
    'printf "%s" "$1" | bash "$2"' _ '{"message":"x"}' "$HOOKS/notify-idle.sh"
  [ -z "$output" ]
}
