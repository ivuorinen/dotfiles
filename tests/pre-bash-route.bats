#!/usr/bin/env bats
#
# Coverage for .claude/hooks/pre-bash-route.sh — the PreToolUse guard that
# routes output-producing Bash commands to ctx_batch_execute.
#
# The hook was the repo's only untested script for a long time, and it drifted:
# `git status` was denied for months against both .claude/rules/bash-routing.md
# and the hook's own comment, and seven wrapper/path forms bypassed it entirely.
# Every assertion below is a claim bash-routing.md makes in prose.

setup()
{
  HOOK="${BATS_TEST_DIRNAME}/../.claude/hooks/pre-bash-route.sh"
  export HOOK
}

# Feed the hook a PreToolUse payload and echo its decision.
#
# A hook that emits no JSON means "no decision", which lets the call proceed —
# indistinguishable from an explicit allow as far as the model is concerned, so
# both collapse to "allow" here. Asserting on the raw output instead would let
# a silent no-decision masquerade as a pass.
decision()
{
  local out
  out=$(printf '{"tool_input":{"command":%s}}' "$(jq -Rn --arg c "$1" '$c')" | bash "$HOOK")
  # Empty stdout is the no-decision case. It cannot be folded into jq's `//`
  # default: jq given no input produces no output, so the fallback never runs
  # and the caller compares against an empty string instead of "allow".
  if [ -z "$out" ]; then
    printf 'allow'
    return 0
  fi
  printf '%s' "$out" | jq -r '.hookSpecificOutput.permissionDecision // "allow"'
}

@test "pre-bash-route: git status is allowed, with and without -s" {
  [ "$(decision 'git status')" = "allow" ]
  [ "$(decision 'git status -s')" = "allow" ]
}

@test "pre-bash-route: state-mutating git subcommands are allowed" {
  [ "$(decision 'git add .')" = "allow" ]
  [ "$(decision "git commit -m 'x'")" = "allow" ]
  [ "$(decision 'git push')" = "allow" ]
  [ "$(decision 'git rev-parse --git-dir')" = "allow" ]
}

# rebase rewrites history exactly as merge and cherry-pick do, and its
# continuation steps are the same operation. It was omitted while its siblings
# were listed, so every rebase needed a BASH_OK escape.
@test "pre-bash-route: rebase and its continuation steps are allowed" {
  [ "$(decision 'git rebase origin/main')" = "allow" ]
  [ "$(decision 'git rebase --continue')" = "allow" ]
  [ "$(decision 'git rebase --skip')" = "allow" ]
  [ "$(decision 'git rebase --abort')" = "allow" ]
  [ "$(decision 'git rebase -i HEAD~3')" = "allow" ]
}

@test "pre-bash-route: git readers are denied" {
  [ "$(decision 'git log --oneline -5')" = "deny" ]
  [ "$(decision 'git diff')" = "deny" ]
  [ "$(decision 'git show HEAD')" = "deny" ]
  [ "$(decision 'git blame README.md')" = "deny" ]
}

@test "pre-bash-route: output-producing first words are denied" {
  [ "$(decision 'cat README.md')" = "deny" ]
  [ "$(decision 'rg foo .')" = "deny" ]
  [ "$(decision 'find . -name x')" = "deny" ]
  [ "$(decision 'shellcheck local/bin/dfm')" = "deny" ]
}

@test "pre-bash-route: quality gates are denied" {
  [ "$(decision 'yarn lint')" = "deny" ]
  [ "$(decision 'yarn test')" = "deny" ]
  [ "$(decision 'pre-commit run --all-files')" = "deny" ]
  [ "$(decision 'shfmt --diff local/bin/dfm')" = "deny" ]
}

@test "pre-bash-route: package installs and in-place formatters are allowed" {
  [ "$(decision 'yarn install')" = "allow" ]
  [ "$(decision 'mise install')" = "allow" ]
  [ "$(decision 'shfmt -w local/bin/dfm')" = "allow" ]
  [ "$(decision 'fish_indent --write config/fish/config.fish')" = "allow" ]
}

@test "pre-bash-route: a denied command in any pipeline segment is caught" {
  [ "$(decision 'git status | grep modified')" = "deny" ]
  [ "$(decision 'echo $(rg foo src/)')" = "deny" ]
  [ "$(decision 'mkdir -p x && cat README.md')" = "deny" ]
}

# Regression: the deny regexes are anchored, so a path or a backslash escape
# used to match nothing and fall through to allow-by-default.
@test "pre-bash-route: an absolute path cannot hide a denied command" {
  [ "$(decision '/bin/cat README.md')" = "deny" ]
  [ "$(decision '/usr/bin/grep foo README.md')" = "deny" ]
  [ "$(decision '\cat README.md')" = "deny" ]
}

# Regression: the interpreter entries exist to block `bash -c '<denied>'`;
# spelling the interpreter as a path defeated them.
@test "pre-bash-route: an interpreter cannot hide a denied command" {
  [ "$(decision 'bash -c "cat README.md"')" = "deny" ]
  [ "$(decision '/bin/bash -c "cat README.md"')" = "deny" ]
  [ "$(decision 'sh -c "rg foo ."')" = "deny" ]
}

# Regression: only `env` and inline VAR= were peeled, so any other wrapper put
# a harmless token in first position and the denied command went unchecked.
@test "pre-bash-route: a wrapper cannot hide a denied command" {
  [ "$(decision 'command cat README.md')" = "deny" ]
  [ "$(decision 'timeout 5 rg foo .')" = "deny" ]
  [ "$(decision 'nohup grep foo README.md')" = "deny" ]
  [ "$(decision 'git ls-files | xargs cat')" = "deny" ]
  [ "$(decision 'env -i cat README.md')" = "deny" ]
}

# `command -v X` never executes X, so it must survive the wrapper stripping
# that catches `command cat`.
@test "pre-bash-route: command -v stays a probe, not an execution" {
  [ "$(decision 'command -v rg')" = "allow" ]
  [ "$(decision 'command -v cat')" = "allow" ]
}

@test "pre-bash-route: env with a var-list is peeled to the real command" {
  [ "$(decision 'env FOO=bar cat README.md')" = "deny" ]
  [ "$(decision 'FOO=bar cat README.md')" = "deny" ]
  [ "$(decision 'FOO=bar git add .')" = "allow" ]
}

@test "pre-bash-route: BASH_OK passes through and strips the marker" {
  run bash -c 'printf "{\"tool_input\":{\"command\":\"BASH_OK cat README.md\"}}" | bash "$1"' _ "$HOOK"
  [ "$status" -eq 0 ]
  [ "$(printf '%s' "$output" | jq -r '.hookSpecificOutput.permissionDecision')" = "allow" ]
  [ "$(printf '%s' "$output" | jq -r '.hookSpecificOutput.updatedInput.command')" = "cat README.md" ]
}

# The marker only works as the leading token; a command that merely mentions it
# must not bypass.
@test "pre-bash-route: BASH_OK elsewhere in the command does not bypass" {
  [ "$(decision 'cat BASH_OK.md')" = "deny" ]
  [ "$(decision 'echo BASH_OK | cat')" = "deny" ]
}

@test "pre-bash-route: empty and malformed input yield no decision" {
  [ "$(decision '')" = "allow" ]
  run bash -c 'printf "not json" | bash "$1"' _ "$HOOK"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
