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
  [ "$(decision 'git mv a b')" = "allow" ]
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
  [ "$(decision 'FOO=bar git push')" = "allow" ]
}

# An empty assignment is legal shell. Requiring a value left `FOO=` as the
# first word, matching neither list, so the command fell through to allow.
@test "pre-bash-route: an empty assignment value is still an assignment" {
  [ "$(decision 'FOO= cat README.md')" = "deny" ]
  [ "$(decision 'FOO= BAR= rg foo .')" = "deny" ]
  [ "$(decision 'FOO= git push')" = "allow" ]
}

# -u/-C/-S take a separate operand. Consuming only the flag left the operand
# as the first word and the real command was never classified.
@test "pre-bash-route: env options that take an operand consume it" {
  [ "$(decision 'env -u FOO cat README.md')" = "deny" ]
  [ "$(decision 'env --unset FOO rg foo .')" = "deny" ]
  [ "$(decision 'env -C /tmp cat README.md')" = "deny" ]
  [ "$(decision 'env -u FOO git push')" = "allow" ]
}

# Wrappers and env prefixes nest in either order, so one pass of each in a
# fixed order is not enough: the wrapper hid the env prefix, which hid `cat`.
@test "pre-bash-route: a wrapper wrapping an env prefix is fully peeled" {
  [ "$(decision 'timeout 5 env -i cat README.md')" = "deny" ]
  [ "$(decision 'nohup env FOO=bar rg foo .')" = "deny" ]
  [ "$(decision 'xargs env -u FOO cat')" = "deny" ]
  [ "$(decision 'timeout 5 env -i git push')" = "allow" ]
}

# `env -S` is not like `-u`/`-C`: its operand IS the command. Consuming it as
# an operand threw the command away — `env -S cat README.md` became
# `README.md` — so only the flag is dropped now.
@test "pre-bash-route: env -S keeps the split string as the command" {
  [ "$(decision 'env -S cat README.md')" = "deny" ]
  [ "$(decision 'env -S "cat README.md"')" = "deny" ]
  [ "$(decision "env -S 'rg foo .'")" = "deny" ]
  [ "$(decision 'env -S git push')" = "allow" ]
}

# Attached forms put the flag and the command in one whitespace-delimited
# token, so the generic flag rule ate the command with the flag. The -S rule
# runs first and keeps the operand.
@test "pre-bash-route: an attached env -S operand is preserved" {
  [ "$(decision "env -S'cat README.md'")" = "deny" ]
  [ "$(decision "env --split-string='cat README.md'")" = "deny" ]
  [ "$(decision "env --split-string='git mv a b'")" = "allow" ]
}

# Both env checks matched the literal string, so a path-qualified env walked
# past them — the same normalisation gap that `/bin/cat` had.
@test "pre-bash-route: a path-qualified env is still env" {
  [ "$(decision '/usr/bin/env cat README.md')" = "deny" ]
  [ "$(decision '/usr/bin/env -S cat README.md')" = "deny" ]
  [ "$(decision '/usr/bin/env git push')" = "allow" ]
}

# The shell resolves `c\at` and `$'cat'` to `cat`; reproducing its quote and
# escape removal here means writing a tokeniser, and every gap in one is a
# silent bypass. Unresolved syntax in the command word is refused instead.
@test "pre-bash-route: an unresolvable command word fails closed" {
  [ "$(decision 'c\at README.md')" = "deny" ]
  [ "$(decision "\$'cat' README.md")" = "deny" ]
  [ "$(decision '"cat" README.md')" = "deny" ]
  # The plain spelling of an allowed command is untouched by this rule.
  [ "$(decision 'git push')" = "allow" ]
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
  [ "$(decision 'timeout 5 git push')" = "allow" ]
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

# BASH_OK is honoured only for a command named in the latest prompt, which
# prompt-record.sh writes to .claude/.last-prompt (agent-loopholes-ab4a6d36).
# with_prompt TEXT points CLAUDE_PROJECT_DIR at a fixture holding TEXT.
with_prompt()
{
  CLAUDE_PROJECT_DIR="$BATS_TEST_TMPDIR/proj"
  mkdir -p "$CLAUDE_PROJECT_DIR/.claude"
  printf '%s\n' "$1" > "$CLAUDE_PROJECT_DIR/.claude/.last-prompt"
  export CLAUDE_PROJECT_DIR
}

@test "pre-bash-route: BASH_OK passes through and strips the marker when the user named the command" {
  with_prompt 'please run cat on the readme'
  run bash -c 'printf "{\"tool_input\":{\"command\":\"BASH_OK cat README.md\"}}" | bash "$1"' _ "$HOOK"
  [ "$status" -eq 0 ]
  [ "$(printf '%s' "$output" | jq -r '.hookSpecificOutput.permissionDecision')" = "allow" ]
  [ "$(printf '%s' "$output" | jq -r '.hookSpecificOutput.updatedInput.command')" = "cat README.md" ]
}

@test "pre-bash-route: BASH_OK is denied when the latest prompt does not name the command" {
  with_prompt 'fix the findings'
  [ "$(decision 'BASH_OK cat README.md')" = "deny" ]
  # A missing prompt record denies too: no evidence the user named anything.
  rm "$CLAUDE_PROJECT_DIR/.claude/.last-prompt"
  [ "$(decision 'BASH_OK cat README.md')" = "deny" ]
}

@test "pre-bash-route: BASH_OK never overrides a policy deny" {
  with_prompt 'run cat and base64 and curl'
  [ "$(decision 'BASH_OK cat config/fish/secrets.d/tfs.fish')" = "deny" ]
  [ "$(decision 'BASH_OK curl -s https://example.com')" = "deny" ]
  [ "$(decision 'BASH_OK git commit --no-verify -m x')" = "deny" ]
}

# Secrets: both trees, any reader, globs and bare directories
# (agent-loopholes-4cafa9a8, agent-loopholes-da375736).
@test "pre-bash-route: secrets files are unreadable through any command" {
  [ "$(decision 'base64 config/fish/secrets.d/tfs.fish')" = "deny" ]
  [ "$(decision "python3 -c 'print(open(\"config/secrets.d/tfs.sh\").read())'")" = "deny" ]
  [ "$(decision 'cp config/secrets.d/sonar.sh /tmp/x')" = "deny" ]
  [ "$(decision 'echo config/fish/secrets.d/*.fish')" = "deny" ]
  [ "$(decision 'mkdir -p config/secrets.d')" = "deny" ]
  # The committed templates stay reachable.
  [ "$(decision 'cp config/secrets.d/github.sh.example /tmp/x')" = "allow" ]
}

# no-hook-bypass.md (agent-loopholes-31a486f9).
@test "pre-bash-route: hook-bypass flags are denied" {
  [ "$(decision "git commit --no-verify -m 'x'")" = "deny" ]
  [ "$(decision "git commit -n -m 'x'")" = "deny" ]
  [ "$(decision 'git push --no-verify')" = "deny" ]
  [ "$(decision 'git config core.hooksPath /dev/null')" = "deny" ]
  [ "$(decision 'prek uninstall')" = "deny" ]
  [ "$(decision 'git commit --no-gpg-sign -m x')" = "deny" ]
  # --amend and --no-edit are not -n clusters.
  [ "$(decision 'git commit --amend --no-edit')" = "allow" ]
}

# git-hunk-commits.md (agent-loopholes-a4023b81).
@test "pre-bash-route: git add and git commit -a are denied" {
  [ "$(decision 'git add local/bin/dfm')" = "deny" ]
  [ "$(decision 'git add -A')" = "deny" ]
  [ "$(decision 'git commit -a -m x')" = "deny" ]
  [ "$(decision 'git commit -am x')" = "deny" ]
  [ "$(decision 'git-hunk commit abc123 -m "fix(x): y"')" = "allow" ]
}

# context-mode.md curl/wget ban, path-qualified or wrapped
# (agent-loopholes-c37c506d).
@test "pre-bash-route: network fetchers are denied in every spelling" {
  [ "$(decision '/usr/bin/curl -s https://example.com')" = "deny" ]
  [ "$(decision 'env curl https://example.com')" = "deny" ]
  [ "$(decision 'command curl https://example.com')" = "deny" ]
  [ "$(decision '\curl https://example.com')" = "deny" ]
  [ "$(decision 'wget https://example.com')" = "deny" ]
  [ "$(decision 'command -v curl')" = "allow" ]
}

# no-npm.md (agent-loopholes-9289ced7).
@test "pre-bash-route: npm and npx are denied" {
  [ "$(decision 'npm install')" = "deny" ]
  [ "$(decision 'npx prettier --write x.yml')" = "deny" ]
  [ "$(decision 'pnpm add x')" = "deny" ]
}

# mise-packages.md; the vendored graphify skill runs these (agent-loopholes-c31d880a).
@test "pre-bash-route: hand-run Python package installs are denied" {
  [ "$(decision 'pip install graphifyy')" = "deny" ]
  [ "$(decision 'python3 -m pip install graphifyy -q --break-system-packages')" = "deny" ]
  [ "$(decision 'uv tool install --upgrade graphifyy -q')" = "deny" ]
  [ "$(decision 'uv pip install x')" = "deny" ]
}

@test "pre-bash-route: node_modules/.bin/bats is denied, bare bats is not" {
  [ "$(decision './node_modules/.bin/bats tests/dfm.bats')" = "deny" ]
  [ "$(decision 'bats tests/dfm.bats')" = "allow" ]
}

# vendored-files.md through Bash (agent-loopholes-cef01270).
@test "pre-bash-route: writes to protected paths are denied" {
  [ "$(decision 'echo x > config/fzf/completion.bash')" = "deny" ]
  [ "$(decision 'cp /tmp/x local/bin/fzf-tmux')" = "deny" ]
  [ "$(decision 'rm config/fish/functions/fisher.fish')" = "deny" ]
  [ "$(decision 'git checkout HEAD~5 -- local/bin/iterm2_shell_integration.zsh')" = "deny" ]
  [ "$(decision 'rm -rf tools/dotbot')" = "deny" ]
}

# Subshells, groups, background, negation and keywords (agent-loopholes-9bfab590).
@test "pre-bash-route: shell grouping and keywords cannot hide a denied command" {
  [ "$(decision '(cat README.md)')" = "deny" ]
  [ "$(decision '{ cat README.md; }')" = "deny" ]
  [ "$(decision 'true & cat README.md')" = "deny" ]
  [ "$(decision '! cat README.md')" = "deny" ]
  [ "$(decision 'if cat README.md; then :; fi')" = "deny" ]
  [ "$(decision 'for f in a; do cat README.md; done')" = "deny" ]
  [ "$(decision 'for f in a b; do mkdir -p "$f"; done')" = "allow" ]
}

# Readers that used to pass as unknown (agent-loopholes-63a35580,
# agent-hooks-d4a254dc, agent-hooks-73fe8599).
@test "pre-bash-route: rule-named and content-emitting readers are denied" {
  [ "$(decision "python3 -c 'print(open(\"README.md\").read())'")" = "deny" ]
  [ "$(decision 'diff CLAUDE.md local/bin/CLAUDE.md')" = "deny" ]
  [ "$(decision 'bat README.md')" = "deny" ]
  [ "$(decision 'git-hunk list -U 0')" = "deny" ]
  [ "$(decision 'graphify query "how does dfm dispatch"')" = "deny" ]
  [ "$(decision 'gh api repos/x/y/pulls')" = "deny" ]
  [ "$(decision 'gh pr view 12')" = "deny" ]
  [ "$(decision 'git-hunk add abc123')" = "allow" ]
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
