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
  # prek is the runner actually installed; denying only the old name left the
  # real command unrouted.
  [ "$(decision 'prek run --all-files')" = "deny" ]
  [ "$(decision 'prek run')" = "deny" ]
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

# An empty assignment is legal shell. Requiring a value left `FOO=` as the
# first word, matching neither list, so the command fell through to allow.
@test "pre-bash-route: an empty assignment value is still an assignment" {
  [ "$(decision 'FOO= cat README.md')" = "deny" ]
  [ "$(decision 'FOO= BAR= rg foo .')" = "deny" ]
  [ "$(decision 'FOO= git add .')" = "allow" ]
}

# -u/-C/-S take a separate operand. Consuming only the flag left the operand
# as the first word and the real command was never classified.
@test "pre-bash-route: env options that take an operand consume it" {
  [ "$(decision 'env -u FOO cat README.md')" = "deny" ]
  [ "$(decision 'env --unset FOO rg foo .')" = "deny" ]
  [ "$(decision 'env -C /tmp cat README.md')" = "deny" ]
  [ "$(decision 'env -u FOO git add .')" = "allow" ]
}

# Wrappers and env prefixes nest in either order, so one pass of each in a
# fixed order is not enough: the wrapper hid the env prefix, which hid `cat`.
@test "pre-bash-route: a wrapper wrapping an env prefix is fully peeled" {
  [ "$(decision 'timeout 5 env -i cat README.md')" = "deny" ]
  [ "$(decision 'nohup env FOO=bar rg foo .')" = "deny" ]
  [ "$(decision 'xargs env -u FOO cat')" = "deny" ]
  [ "$(decision 'timeout 5 env -i git add .')" = "allow" ]
}

# `env -S` is not like `-u`/`-C`: its operand IS the command. Consuming it as
# an operand threw the command away — `env -S cat README.md` became
# `README.md` — so only the flag is dropped now.
@test "pre-bash-route: env -S keeps the split string as the command" {
  [ "$(decision 'env -S cat README.md')" = "deny" ]
  [ "$(decision 'env -S "cat README.md"')" = "deny" ]
  [ "$(decision "env -S 'rg foo .'")" = "deny" ]
  [ "$(decision 'env -S git add .')" = "allow" ]
}

# Attached forms put the flag and the command in one whitespace-delimited
# token, so the generic flag rule ate the command with the flag. The -S rule
# runs first and keeps the operand.
@test "pre-bash-route: an attached env -S operand is preserved" {
  [ "$(decision "env -S'cat README.md'")" = "deny" ]
  [ "$(decision "env --split-string='cat README.md'")" = "deny" ]
  [ "$(decision "env --split-string='git add .'")" = "allow" ]
}

# Both env checks matched the literal string, so a path-qualified env walked
# past them — the same normalisation gap that `/bin/cat` had.
@test "pre-bash-route: a path-qualified env is still env" {
  [ "$(decision '/usr/bin/env cat README.md')" = "deny" ]
  [ "$(decision '/usr/bin/env -S cat README.md')" = "deny" ]
  [ "$(decision '/usr/bin/env git add .')" = "allow" ]
}

# The shell resolves `c\at` and `$'cat'` to `cat`; reproducing its quote and
# escape removal here means writing a tokeniser, and every gap in one is a
# silent bypass. Unresolved syntax in the command word is refused instead.
@test "pre-bash-route: an unresolvable command word fails closed" {
  [ "$(decision 'c\at README.md')" = "deny" ]
  [ "$(decision "\$'cat' README.md")" = "deny" ]
  [ "$(decision '"cat" README.md')" = "deny" ]
  # The plain spelling of an allowed command is untouched by this rule.
  [ "$(decision 'git add .')" = "allow" ]
}

# A split string can nest quotes, so one strip left `"cat` and matched no
# anchored entry. normalise_cmd now strips to a fixed point, both ends.
@test "pre-bash-route: nested quoting still resolves to the command" {
  [ "$(decision 'env -S '"'"'"cat" README.md'"'"'')" = "deny" ]
  [ "$(decision "env -S '\"rg\" foo .'")" = "deny" ]
}

# Wrapper options with operands are open-ended (`stdbuf -o L`, `xargs -E EOF`,
# `timeout --signal KILL`), and every one missed leaves the operand as the
# first word. Rather than enumerate them, an unrecognised post-wrapper token
# fails closed.
@test "pre-bash-route: an unnormalisable wrapper form fails closed" {
  [ "$(decision 'stdbuf -o L cat README.md')" = "deny" ]
  [ "$(decision 'xargs -E EOF cat')" = "deny" ]
  [ "$(decision 'timeout --signal KILL rg foo .')" = "deny" ]
}

# Fail-closed must not swallow the ordinary wrapped-allow case.
@test "pre-bash-route: a wrapped allowed command is still allowed" {
  [ "$(decision 'timeout 5 git add .')" = "allow" ]
  [ "$(decision 'nohup git push')" = "allow" ]
  [ "$(decision 'nice mkdir -p x')" = "allow" ]
}

# Regression: a bare wrapper has no trailing token for the substitutions to
# consume, so the stripping loop never converged and the hook hung forever —
# blocking every Bash call in the session, not just this one.
@test "pre-bash-route: a bare wrapper terminates instead of looping" {
  for c in xargs timeout command nohup exec time stdbuf nice ionice builtin; do
    run timeout 5 bash -c 'printf "{\"tool_input\":{\"command\":\"$1\"}}" | bash "$2"' _ "$c" "$HOOK"
    [ "$status" -ne 124 ]
  done
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
