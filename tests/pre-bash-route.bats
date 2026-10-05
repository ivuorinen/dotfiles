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
  [ "$(decision 'echo x > config/fish/functions/__bass.py')" = "deny" ]
  [ "$(decision 'cp /tmp/x .claude/skills/graphify/SKILL.md')" = "deny" ]
  [ "$(decision 'rm config/fish/functions/fisher.fish')" = "deny" ]
  [ "$(decision 'git checkout HEAD~5 -- config/fish/functions/bass.fish')" = "deny" ]
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

# A policy deny names no BASH_OK escape; a routing deny does. The policy cases
# below assert the stronger of the two, so a regression to a mere routing deny
# (which BASH_OK overrides) fails.
policy_denied()
{
  printf '{"tool_input":{"command":%s}}' "$(jq -Rn --arg c "$1" '$c')" \
    | bash "$HOOK" \
    | jq -e '.hookSpecificOutput.permissionDecisionReason | contains("BASH_OK does not override")' > /dev/null
}

# eval, sudo, watch and a shell's -c string run their operand as a command, so
# a one-word prefix hid `git add` from the policy tier (agent-loopholes-6bc32964).
@test "pre-bash-route: eval, sudo, watch and shell -c wrappers are unwrapped" {
  policy_denied 'eval git add -A'
  policy_denied 'eval git commit --no-verify -m x'
  policy_denied 'fish -c "git add ."'
  policy_denied "bash -c 'git add .'"
  policy_denied 'sudo git add x'
  policy_denied 'sudo -u root git add x'
  [ "$(decision 'sudo cat README.md')" = "deny" ]
  [ "$(decision 'watch cat README.md')" = "deny" ]
  [ "$(decision 'fish -c "cat README.md"')" = "deny" ]
  [ "$(decision 'fish script.fish')" = "deny" ]
}

# git accepts any unambiguous long-option prefix, global options shift the
# subcommand, and update-index --add stages like add (agent-loopholes-e0092417).
@test "pre-bash-route: abbreviated --no-verify, git globals and update-index --add are denied" {
  policy_denied 'git commit --no-verif -m x'
  policy_denied 'git commit --no-veri -m x'
  policy_denied 'git push --no-verif'
  policy_denied 'git commit --no-gpg -m x'
  policy_denied 'git -c core.HooksPath=/dev/null commit -m x'
  policy_denied 'git -C . add -A'
  policy_denied 'git -C . commit -n -m x'
  policy_denied 'git --git-dir .git -c a=b commit -a -m x'
  policy_denied 'git update-index --add foo'
  policy_denied 'git stage foo'
  policy_denied 'find . -exec git add {} +'
}

@test "pre-bash-route: git global options leave legitimate commands allowed" {
  [ "$(decision 'git -C dir status')" = "allow" ]
  [ "$(decision 'git --no-pager status')" = "allow" ]
  [ "$(decision 'git commit -m x')" = "allow" ]
  [ "$(decision 'git commit --no-verbose -m x')" = "allow" ]
  [ "$(decision 'git update-index --refresh')" = "allow" ]
  [ "$(decision 'git -C dir log')" = "deny" ]
}

# The shell expands globs and folds case (APFS) after the hook has read the
# text, so literal matching alone missed these (agent-loopholes-6cb6e566,
# agent-loopholes-88c3bb49).
@test "pre-bash-route: globbed, case-folded and dotted protected paths are denied" {
  policy_denied 'cp config/fish/secret?.d/github.fish /tmp/x'
  policy_denied 'cp config/secre*.d/* /tmp/'
  policy_denied 'cp config/fish/*/github.fish /tmp/x'
  policy_denied 'cp README.md yarn.l?ck'
  policy_denied 'cp README.md YARN.LOCK'
  policy_denied 'rm tools//dotbot/x'
  policy_denied 'rm tools/./dotbot/x'
  [ "$(decision 'rm build/*')" = "allow" ]
  [ "$(decision 'cp a.txt b.txt')" = "allow" ]
}

@test "pre-bash-route: an empty command yields no decision" {
  [ "$(decision '')" = "allow" ]
}

# Malformed input and a missing jq used to exit 0 with no decision, skipping
# the policy tier and the secrets guard entirely (agent-loopholes-468c93a6).
# They block now, as pre-edit-block.sh always did.
@test "pre-bash-route: malformed input and a missing jq fail closed" {
  run bash -c 'printf "not json" | bash "$1"' _ "$HOOK"
  [ "$status" -eq 2 ]
  [[ "$output" == *"fails closed"* ]]
  run /bin/bash -c 'printf "{\"tool_input\":{\"command\":\"git add -A\"}}" | PATH=/nonexistent /bin/bash "$1"' _ "$HOOK"
  [ "$status" -eq 2 ]
  [[ "$output" == *"jq is not on PATH"* ]]
}

# The splitter cut on ( ; | with no quote awareness, so every conventional
# commit header moved the flags after it out of the git checks
# (agent-loopholes-8dfa8203).
@test "pre-bash-route: a quoted commit message cannot hide a bypass flag" {
  policy_denied "git commit -m 'fix(x): y' --no-verify"
  policy_denied "git commit -m 'fix(x): y' -n"
  policy_denied "git commit -m 'fix(x): y' -a"
  policy_denied "git commit -m 'a; b' --no-verify"
  policy_denied 'git commit -m "feat(hooks): x | y && z" --no-verif'
  policy_denied "git commit -nm 'fix(x): y'"
}

# Messages are prose: a header with a scope, separators, or a sentence about
# the bypass ban or the secrets tree is not a flag or a path
# (agent-hooks-84fa86e9).
@test "pre-bash-route: conventional commit messages pass" {
  [ "$(decision "git commit -m 'fix(x): y'")" = "allow" ]
  [ "$(decision "git commit -m 'fix(hooks): a; b (c) | d & e'")" = "allow" ]
  [ "$(decision "git commit -m 'docs: explain the --no-verify ban'")" = "allow" ]
  [ "$(decision "git commit --message='docs: -n is --no-verify'")" = "allow" ]
  [ "$(decision "git-hunk commit abc123 def456 -m 'docs(secrets): document secrets.d modes'")" = "allow" ]
  [ "$(decision "git-hunk commit abc -m 'docs(rules): SKIP= and core.hooksPath are banned'")" = "allow" ]
}

# The splitter did not model these shell forms, so the command word was
# something it never checked (agent-loopholes-52d63719).
@test "pre-bash-route: time -p, coproc, trap, process and command substitution are parsed" {
  policy_denied 'time -p git add -A'
  policy_denied 'coproc git add -A'
  policy_denied "trap 'git add -A' EXIT"
  policy_denied 'source <(echo git add -A)'
  policy_denied "\$(printf 'gi%s' t) add -A"
  policy_denied "git commit '--no-verify' -m x"
  policy_denied 'git commit "-n" -m x'
  policy_denied "bash -o pipefail -c 'git add -A'"
  policy_denied "bash <<'EOF'
git add -A
EOF"
}

# Bypasses that carry no flag on the git command line
# (agent-loopholes-63eb3265).
@test "pre-bash-route: environment and hook-file bypasses are denied" {
  policy_denied 'SKIP=commitlint,shellcheck git commit -m x'
  policy_denied 'GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=core.hooksPath GIT_CONFIG_VALUE_0=/dev/null git commit -m x'
  policy_denied 'export SKIP=commitlint; git-hunk commit abc -m x'
  policy_denied 'env PRE_COMMIT_ALLOW_NO_CONFIG=1 git commit -m x'
  policy_denied 'rm .git/hooks/commit-msg'
  policy_denied 'cp /dev/null .git/hooks/pre-commit'
  policy_denied 'echo "[core] hooksPath = /dev/null" >> .git/config'
  # SKIP is an ordinary name away from git and the hook runners.
  [ "$(decision 'SKIP=1 make test')" = "allow" ]
}

# `git commit <path>`, -i and -o stage whole files exactly like -a.
@test "pre-bash-route: git commit with a pathspec or -i/-o is denied" {
  policy_denied 'git commit -m msg local/bin/dfm'
  policy_denied 'git commit -i -m msg local/bin/dfm'
  policy_denied 'git commit -o -m msg local/bin/dfm'
  policy_denied 'git commit --only -m msg -- local/bin/dfm'
  policy_denied 'git commit --pathspec-from-file=list -m msg'
  [ "$(decision "git commit -C HEAD --author 'A <a@b.c>' -m x")" = "allow" ]
  [ "$(decision 'git commit --fixup abc123')" = "allow" ]
  [ "$(decision 'git commit -F msg.txt -s')" = "allow" ]
}

# A wildcard standing for secrets.d is only a secrets read when a literal file
# name follows it; a regex argument is not a path (agent-hooks-84fa86e9).
@test "pre-bash-route: globs under config/ and regex arguments are not secrets reads" {
  run policy_denied 'ls config/*'
  [ "$status" -ne 0 ]
  [ "$(decision 'fish_indent --write config/fish/*/*.fish')" = "allow" ]
  run policy_denied "rg -n 'secrets\.d' .claude/rules"
  [ "$status" -ne 0 ]
  policy_denied 'cat config/fish/*/github.fish'
  policy_denied 'cat config/fish/secrets.d/*.fish'
}

# Every suffix of a wrapped argv is checked, so two operand-taking wrapper
# options no longer hide the command (agent-loopholes-2b2e90ee).
@test "pre-bash-route: wrappers with several operand options are seen through" {
  policy_denied 'stdbuf -o L -e L git add -A'
  policy_denied 'sudo -u root -g wheel git add -A'
  policy_denied 'g=git; $g add -A'
  policy_denied "echo 'git add -A' | sh"
}

# A command that runs its arguments as a command hid git from the argv checks
# unless it was on the fixed wrapper list (audit-a5c76774).
@test "pre-bash-route: unlisted runners cannot hide a policy command" {
  policy_denied 'mise exec -- git add -A'
  policy_denied 'mise x -- git commit --no-verify -m x'
  policy_denied 'setsid git add -A'
  policy_denied 'caffeinate git add -A'
  policy_denied 'unbuffer git add .'
  policy_denied 'xcrun git add .'
  policy_denied 'chronic git add .'
  policy_denied 'flock /tmp/l git add .'
  policy_denied 'yarn exec git add .'
  policy_denied 'mise exec python -- -m pip install foo'
  policy_denied 'mise exec -- curl https://example.com'
}

# curl and npm have no verb to anchor on, so they were seen only behind a
# listed runner; the bare word now counts anywhere but in a lookup.
@test "pre-bash-route: no runner of any name hides a name-only ban" {
  policy_denied 'nohup2 curl https://example.com'
  policy_denied 'env -S curl https://example.com'
  policy_denied 'some-unknown-runner npx foo'
  policy_denied 'doppler run -- npm i'
  policy_denied 'op run -- curl https://example.com'
  policy_denied 'direnv exec . npm i'
  policy_denied 'uvx --from x curl'
  policy_denied 'pipx run --spec x npx y'
  policy_denied 'git submodule foreach npm i'
  policy_denied 'setsid wget https://example.com'
  policy_denied 'sudo -u which curl https://example.com'
  policy_denied 'rg --pre curl x .'
  policy_denied 'fd -x curl'
  policy_denied 'man -P curl x'
}

# The same runners hid a shell -c string and an env assignment.
@test "pre-bash-route: no runner of any name hides a command string or env bypass" {
  policy_denied "nohup2 bash -c 'git add -A'"
  policy_denied "nohup2 sh -c 'curl https://example.com'"
  policy_denied 'nohup2 env SKIP=x git commit -m x'
}

# Pagers, editors and ssh/diff/browser commands run a config or environment
# value as a command, so a value is held to the same checks as argv.
@test "pre-bash-route: a banned tool in a config or environment value is denied" {
  policy_denied 'git -c core.pager=npx log'
  policy_denied "git -c core.editor='curl x' commit"
  policy_denied "git -c sequence.editor='npm exec x' rebase -i HEAD~2"
  policy_denied 'VAR=npx git --config-env=core.pager=VAR log'
  policy_denied 'MANPAGER=curl man x'
  policy_denied 'PAGER=npx less x'
  policy_denied 'GIT_PAGER=npx git log'
  policy_denied 'GIT_EDITOR="curl x" git commit'
  policy_denied 'EDITOR=npx foo'
  policy_denied 'VISUAL=wget x'
  policy_denied "GIT_SSH_COMMAND='curl x' git fetch"
  policy_denied 'GIT_EXTERNAL_DIFF=npx git diff'
  policy_denied 'BROWSER=curl gh pr view --web'
  policy_denied 'env GIT_PAGER=npx git log'
  policy_denied "git -c core.editor='git add -A' commit"
  policy_denied 'git config core.pager npx'
}

@test "pre-bash-route: ordinary config and environment values pass the policy tier" {
  local c
  for c in 'LC_ALL=C rg curl' 'git -c color.ui=always log -S curl' \
    'GIT_PAGER=cat git log' 'PATH=$HOME/bin:$PATH git status' \
    'git -c core.pager=less log' 'git config --get core.pager' \
    "rg 'x=curl' docs/" 'echo FOO=npm'; do
    run policy_denied "$c"
    [ "$status" -ne 0 ] || {
      echo "denied: $c"
      return 1
    }
  done
  [ "$(decision 'EDITOR=vim git commit -m x')" = "allow" ]
}

# Lookups and searches never execute the name they are given.
@test "pre-bash-route: lookups and searches naming curl or npm pass the policy tier" {
  local c
  for c in 'which curl' 'command -v npm' 'type curl' 'man curl' \
    'rg -n curl local/bin/' 'rg npm docs/' "grep -rn 'npx' .claude/" \
    'fd curl' 'git log -S curl' 'git log -S curl -- docs/' 'git grep npm docs/' \
    "git commit -m 'fix: drop curl'" 'echo "use curl"' 'mise which npm' \
    'rg -P curl x' 'which bash git'; do
    run policy_denied "$c"
    [ "$status" -ne 0 ] || {
      echo "denied: $c"
      return 1
    }
  done
  [ "$(decision 'which curl')" = "allow" ]
  [ "$(decision 'command -v npm')" = "allow" ]
}

@test "pre-bash-route: a mere mention of a policy tool is not a command" {
  [ "$(decision 'which curl npm git')" = "allow" ]
  [ "$(decision 'mise exec -- shfmt -w local/bin/a')" = "allow" ]
  [ "$(decision "git commit -m 'git add is banned'")" = "allow" ]
  run policy_denied 'rg -n git local/bin'
  [ "$status" -ne 0 ]
}

# A config file named by environment or include can carry core.hooksPath with
# no key in argv for the bypass scan to see (audit-c36f6a78).
@test "pre-bash-route: config files that can set core.hooksPath are denied" {
  policy_denied 'GIT_CONFIG_GLOBAL=/tmp/c git commit -m x'
  policy_denied 'GIT_CONFIG_SYSTEM=/tmp/c git commit -m x'
  policy_denied 'export GIT_CONFIG=/tmp/c; git commit -m x'
  policy_denied 'git -c include.path=/tmp/c commit -m x'
  policy_denied 'git -c includeIf.gitdir:~/.path=/tmp/c commit -m x'
  policy_denied 'git config include.path /tmp/c'
  policy_denied 'git config --global includeIf.gitdir:/x/.path /tmp/c'
}

# Reading the hook state is what commit-format.md asks for; only a write is a
# bypass (audit-b668407e).
@test "pre-bash-route: reading core.hooksPath or an alias is allowed" {
  [ "$(decision 'git config --get core.hooksPath')" = "allow" ]
  [ "$(decision 'git config --local --get core.hooksPath')" = "allow" ]
  [ "$(decision 'git config --get-regexp alias')" = "allow" ]
  policy_denied 'git config core.hooksPath /dev/null'
  policy_denied 'git config --unset core.hooksPath'
}

# An alias renames the subcommand past every check keyed on add/commit
# (audit-8559f9b1).
@test "pre-bash-route: git aliases cannot rename a denied subcommand" {
  policy_denied 'git -c alias.st=add st -A'
  policy_denied "git -c alias.c='commit --no-verify' c -m x"
  policy_denied 'git --config-env=alias.st=X st -A'
  policy_denied 'git config alias.st add'
  policy_denied 'git config --global alias.c "!git add -A"'
}

@test "pre-bash-route: persistent aliases are resolved before the checks" {
  local repo="$BATS_TEST_TMPDIR/repo"
  git init -q "$repo"
  git -C "$repo" config alias.st add
  git -C "$repo" config alias.sneak '!git commit --no-verify -m x'
  git -C "$repo" config alias.undo 'reset --soft'
  policy_denied "git -C $repo st -A"
  cd "$repo"
  policy_denied 'git st -A'
  policy_denied 'git sneak'
  run policy_denied 'git undo HEAD~1'
  [ "$status" -ne 0 ]
}

# update-index records worktree content for each path operand, which is `git
# add` by another name (audit-4bd3f195).
@test "pre-bash-route: update-index with path operands is staging" {
  policy_denied 'git update-index config/alias'
  policy_denied 'git update-index --again'
  policy_denied 'git update-index --cacheinfo 100644,abc,f'
  policy_denied 'git update-index --chmod=+x local/bin/a'
  policy_denied 'git update-index --ad config/alias'
  [ "$(decision 'git update-index --refresh')" = "allow" ]
  [ "$(decision 'git update-index -q --really-refresh')" = "allow" ]
  [ "$(decision 'git update-index --assume-unchanged config/alias')" = "allow" ]
  [ "$(decision 'git update-index --no-skip-worktree config/alias')" = "allow" ]
}

# In-place editors outside the copy/move/sed list rewrote vendored files and
# yarn.lock unvetted (audit-5a6f71da).
@test "pre-bash-route: in-place editors writing protected paths are denied" {
  policy_denied 'perl -pi -e s/a/b/ config/fish/functions/fisher.fish'
  policy_denied 'perl -i.bak -pe s/a/b/ yarn.lock'
  policy_denied 'ruby -pi -e x yarn.lock'
  policy_denied 'vim -c wq yarn.lock'
  policy_denied 'ed yarn.lock'
  policy_denied 'patch yarn.lock fix.diff'
  policy_denied "awk '{print > \"yarn.lock\"}' /dev/null"
  policy_denied 'gawk -i inplace 1 yarn.lock'
  run policy_denied 'rg -n patch yarn.lock'
  [ "$status" -ne 0 ]
  run policy_denied "perl -ne 'print if /x/' yarn.lock"
  [ "$status" -ne 0 ]
}

# BASH_OK covered the whole line once its first command was named, so an
# unbounded reader rode along (audit-7b087cc6).
@test "pre-bash-route: BASH_OK requires every command in the line to be named" {
  with_prompt 'please run yarn build for me'
  [ "$(decision 'BASH_OK yarn build; cat README.md')" = "deny" ]
  [ "$(decision 'BASH_OK yarn build && git log -p')" = "deny" ]
  with_prompt 'run cat and wc on the readme'
  [ "$(decision 'BASH_OK cat README.md | wc -l')" = "allow" ]
}

# mise installs versioned binaries, and python takes `-mpip` as one word
# (audit-8f8345da).
@test "pre-bash-route: versioned pip and python spellings are denied" {
  policy_denied 'python3.12 -m pip install foo'
  policy_denied 'pip3.12 install foo'
  policy_denied 'python3 -mpip install foo'
  run policy_denied 'python3.12 -m pip list'
  [ "$status" -ne 0 ]
}

# The bats rule matched any text naming the path, so a search for it was
# refused (audit-b668407e).
@test "pre-bash-route: node_modules/.bin/bats is denied as a command only" {
  policy_denied 'node_modules/.bin/bats tests'
  run policy_denied "rg -c -e 'node_modules/.bin/bats' tests"
  [ "$status" -ne 0 ]
}

# PATH=/nonexistent stops at the jq check, so the parser-missing branch was
# never reached (audit-0576cb89). This PATH keeps jq and the system tools.
@test "pre-bash-route: a missing shfmt fails closed" {
  local bin="$BATS_TEST_TMPDIR/bin"
  mkdir -p "$bin"
  ln -s "$(command -v jq)" "$bin/jq"
  if PATH="$bin:/usr/bin:/bin" command -v shfmt > /dev/null; then
    skip "shfmt is installed in a system directory"
  fi
  run /bin/bash -c 'printf "{\"tool_input\":{\"command\":\"git add -A\"}}" | PATH="$2:/usr/bin:/bin" /bin/bash "$1"' _ "$HOOK" "$bin"
  [ "$status" -eq 0 ]
  [ "$(printf '%s' "$output" | jq -r '.hookSpecificOutput.permissionDecision')" = "deny" ]
  [[ "$output" == *"shfmt is not on PATH"* ]]
}

# shfmt before 3.14.0 encodes operators as enum numbers, not strings, so no
# redirect matched the write operators and every protected redirect passed.
# The stub rewrites the real parser's operators to numbers the way an old
# shfmt emits them.
@test "pre-bash-route: numeric redirect operators from an older shfmt still deny protected writes" {
  local bin="$BATS_TEST_TMPDIR/oldshfmt" real
  real="$(command -v shfmt)"
  mkdir -p "$bin"
  printf '#!/usr/bin/env bash\n"%s" "$@" | jq -c '\''walk(if type == "object" and (.Op | type) == "string" then .Op = 54 else . end)'\''\n' "$real" > "$bin/shfmt"
  chmod +x "$bin/shfmt"
  PATH="$bin:$PATH"
  [ "$(decision 'echo x > config/fish/functions/__bass.py')" = "deny" ]
  [ "$(decision 'echo x >> yarn.lock')" = "deny" ]
  [ "$(decision 'echo x > /tmp/out.txt')" = "allow" ]
  [ "$(decision 'git status 2>&1')" = "allow" ]
}

# The git write alternative anchored the subcommand right after `git`, so a
# global option in between let it rewrite a protected path.
@test "pre-bash-route: git global options do not hide a protected-path write" {
  [ "$(decision 'git -C . checkout -- yarn.lock')" = "deny" ]
  [ "$(decision 'git --no-pager restore yarn.lock')" = "deny" ]
  [ "$(decision 'git -c core.quotepath=off rm tools/dotbot/setup.py')" = "deny" ]
  [ "$(decision 'git -C . status')" = "allow" ]
}

# The install checks compared only the word right after pip / -m pip / uv's
# subcommand, so an option in between hid `install`.
@test "pre-bash-route: options before install do not hide a hand-run install" {
  [ "$(decision 'pip -q install requests')" = "deny" ]
  [ "$(decision 'pip3 --disable-pip-version-check install x')" = "deny" ]
  [ "$(decision 'pip --index-url https://example.com/simple install y')" = "deny" ]
  [ "$(decision 'python3 -m pip -q install x')" = "deny" ]
  [ "$(decision 'python3 -mpip -q install x')" = "deny" ]
  [ "$(decision 'uv --quiet pip install x')" = "deny" ]
  [ "$(decision 'uv --quiet tool install ruff')" = "deny" ]
  [ "$(decision 'pip --version')" = "allow" ]
  [ "$(decision 'uv tool list')" = "allow" ]
}

# A bare get/list anywhere marked git config as a read, so the legacy set form
# with that word as the value skipped the hooksPath and alias checks.
@test "pre-bash-route: a get or list value does not make a git config write a read" {
  [ "$(decision 'git config core.hooksPath get')" = "deny" ]
  [ "$(decision 'git config alias.st list')" = "deny" ]
  [ "$(decision 'git config get core.hooksPath')" = "allow" ]
  [ "$(decision 'git config --file .git/config get core.hooksPath')" = "allow" ]
  [ "$(decision 'git config list')" = "allow" ]
  [ "$(decision 'git config --get core.hooksPath')" = "allow" ]
}
