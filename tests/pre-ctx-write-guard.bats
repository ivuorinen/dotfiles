#!/usr/bin/env bats
#
# Coverage for .claude/hooks/pre-ctx-write-guard.sh — the PreToolUse guard on
# the context-mode execute tools.
#
# It exists because the sandbox has raw filesystem access while
# pre-edit-block.sh only ever sees Edit/Write/Read calls, so `rm tools/dotbot/x`
# routed through ctx_execute would otherwise reach the disk unchecked
# (finding audit-5f0966e7).
#
# The detection is a documented same-line co-occurrence heuristic: a protected
# path next to a write-shaped token. These tests pin both halves — what it
# catches and what it deliberately lets through — so a future tightening has
# to state which line it is changing.

bats_require_minimum_version 1.5.0

setup()
{
  HOOK="${BATS_TEST_DIRNAME}/../.claude/hooks/pre-ctx-write-guard.sh"
  export HOOK
}

# ctx_execute / ctx_execute_file shape: the code (and optional path) field.
code()
{
  jq -cn --arg c "$1" --arg p "${2:-}" \
    '{tool_input: {code: $c, path: $p}}' | bash "$HOOK"
}

# ctx_batch_execute shape: a commands array. The guard joins every .command
# before scanning, so a denied command hidden at index 3 is still seen.
batch()
{
  jq -cn --args '{tool_input: {commands: ($ARGS.positional | map({command: .}))}}' "$@" \
    | bash "$HOOK"
}

@test "pre-ctx-write-guard: blocks writes aimed at submodule trees" {
  run -2 code 'rm tools/dotbot/src/cli.py'
  [[ "$output" == *"hook-protected path"* ]]
  run -2 code 'mv tools/antidote/foo /tmp/bar'
  run -2 code 'sed -i s/a/b/ tools/dotbot/README.md'
}

@test "pre-ctx-write-guard: blocks writes aimed at lock and vendored files" {
  run -2 code 'echo broken > yarn.lock'
  run -2 code 'truncate -s0 .yarn/install-state.gz'
  run -2 code 'tee config/fzf/key-bindings.bash < /tmp/x'
  run -2 code 'chmod 777 config/fzf/completion.zsh'
}

# pre-edit-block.sh listed these four groups while this guard did not, so the
# same write went through unchecked when routed via ctx_execute rather than
# Edit. The two lists cover the same paths by different doors.
@test "pre-ctx-write-guard: blocks writes to the vendored fish plugin functions" {
  run -2 code 'rm config/fish/functions/fisher.fish'
  run -2 code 'echo x > config/fish/functions/bass.fish'
  run -2 code 'sed -i s/a/b/ config/fish/functions/__bass.py'
  run -2 code 'mv config/fish/functions/__z_add.fish /tmp/x'
  run -2 code 'tee config/fish/functions/__z_clean.fish < /tmp/x'
}

@test "pre-ctx-write-guard: blocks writes to the other vendored trees" {
  run -2 code 'rm .claude/skills/graphify/SKILL.md'
  run -2 code 'echo x > local/bin/iterm2_shell_integration.zsh'
  run -2 code 'rm tools/dotbot-include/plugin.py'
}

# Hand-written fish functions sit in the same directory with no naming signal,
# and must stay writable.
@test "pre-ctx-write-guard: a hand-written fish function is not protected" {
  run -0 code 'rm config/fish/functions/mkcd.fish'
}

@test "pre-ctx-write-guard: blocks node-style writes too, not just shell" {
  run -2 code 'fs.writeFileSync("tools/dotbot/x", data)'
  run -2 code 'await fs.appendFile("yarn.lock", line)'
}

@test "pre-ctx-write-guard: scans every command in a batch, not just the first" {
  run -2 batch 'ls -la' 'git status' 'rm tools/dotbot/x'
  [[ "$output" == *"hook-protected path"* ]]
}

# Reading a protected path is legitimate and must stay cheap — the guard is
# about writes. This is the line most at risk from a careless tightening.
@test "pre-ctx-write-guard: allows reading a protected path" {
  run -0 code 'cat tools/dotbot/README.md'
  run -0 code 'grep -n foo config/fzf/key-bindings.bash'
  run -0 code 'wc -l yarn.lock'
}

# `2> /dev/null` and `2>&1` are redirects, not writes to the named file. The
# guard strips them before matching; without that, every quiet read of a
# protected path would be refused.
@test "pre-ctx-write-guard: a stderr redirect is not a write" {
  run -0 code 'cat tools/dotbot/README.md 2> /dev/null'
  run -0 code 'head -1 yarn.lock 2>&1'
}

@test "pre-ctx-write-guard: writes to unprotected paths are none of its business" {
  run -0 code 'rm /tmp/scratch'
  run -0 code 'echo hi > /tmp/out.txt'
}

# Credentials: for real secrets.d fish files, reading is as forbidden as
# writing, so this branch needs no write-shaped token at all.
@test "pre-ctx-write-guard: blocks any reference to a real secrets.d fish file" {
  run -2 code 'cat config/fish/secrets.d/github.fish'
  [[ "$output" == *"credentials"* ]]
  run -2 code 'ls config/fish/secrets.d/openai.fish'
}

@test "pre-ctx-write-guard: allows the secrets.d example templates" {
  run -0 code 'cat config/fish/secrets.d/github.fish.example'
}

@test "pre-ctx-write-guard: an empty or absent payload is allowed" {
  run -0 code ''
  run -0 bash -c 'printf "{}" | bash "$1"' _ "$HOOK"
}
