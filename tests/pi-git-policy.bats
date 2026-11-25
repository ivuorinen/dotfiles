#!/usr/bin/env bats
# Tests for config/pi/agent/extensions/git-policy.ts, omp's tool_call guard for the
# git mandates in config/pi/agent/RULES.md.
#
# Node loads the extension with its built-in TypeScript type stripping, the way omp's
# runtime would, and feeds the handler one tool input per test. The allow cases are
# the false positives a text matcher invites: a banned command named inside a commit
# message, a search pattern or omp's commit helper must pass.

setup()
{
  if [ "$(node -p 'process.features.typescript' 2> /dev/null)" = "undefined" ] \
    || ! command -v node > /dev/null; then
    skip "needs Node with TypeScript type stripping (22.18+); CI installs it through mise"
  fi
  export GP_EXT="$PWD/config/pi/agent/extensions/git-policy.ts"
}

# decide <field> <text>: print blocked or allowed for a tool input with that one field.
# A `commands` text is split on newlines into the ctx_batch array.
decide()
{
  GP_FIELD="$1" GP_TEXT="$2" node --no-warnings --input-type=module -e '
    import { pathToFileURL } from "node:url"
    const { default: register } = await import(pathToFileURL(process.env.GP_EXT).href)
    let handler
    register({ on: (_event, fn) => { handler = fn } })
    const field = process.env.GP_FIELD
    const text = process.env.GP_TEXT
    const value = field === "commands" ? text.split("\n") : text
    const result = await handler({ toolName: "bash", input: { [field]: value } })
    process.stdout.write(result?.block ? "blocked" : "allowed")
  '
}

@test "git-policy: blocks git commit --no-verify" {
  run decide command 'git commit --no-verify -m "x"'
  [ "$output" = "blocked" ]
}

@test "git-policy: blocks git commit -n and a bundled -nm" {
  run decide command 'git commit -n -m "x"'
  [ "$output" = "blocked" ]
  run decide command 'git commit -nm wip'
  [ "$output" = "blocked" ]
}

@test "git-policy: blocks git push --no-verify" {
  run decide command 'git push --no-verify origin main'
  [ "$output" = "blocked" ]
}

@test "git-policy: blocks git add -A, . and --all behind global options" {
  run decide command 'git add -A'
  [ "$output" = "blocked" ]
  run decide command 'git add .'
  [ "$output" = "blocked" ]
  run decide command 'git -C repo add --all'
  [ "$output" = "blocked" ]
}

@test "git-policy: blocks git commit -am" {
  run decide command 'git commit -am "msg"'
  [ "$output" = "blocked" ]
}

@test "git-policy: blocks a banned command chained or in a substitution" {
  run decide command 'git status && git add -A'
  [ "$output" = "blocked" ]
  run decide command 'echo $(git add -A)'
  [ "$output" = "blocked" ]
}

@test "git-policy: blocks a banned command run through sh(), bash -c and a Bun template" {
  run decide code 'await sh("git add -A")'
  [ "$output" = "blocked" ]
  run decide command "bash -c 'git commit --no-verify -m x'"
  [ "$output" = "blocked" ]
  run decide code 'await $`git add -A`'
  [ "$output" = "blocked" ]
}

@test "git-policy: blocks no_verify in omp's commit helper" {
  run decide code 'await d.commit("feat: x", no_verify=True)'
  [ "$output" = "blocked" ]
  run decide code 'await d.commit("feat: x", { noVerify: true })'
  [ "$output" = "blocked" ]
}

@test "git-policy: checks every ctx_batch command" {
  run decide commands $'git log -1\ngit add .'
  [ "$output" = "blocked" ]
}

@test "git-policy: blocks a Claude-Session trailer and a session link" {
  run decide command $'git commit -m "feat: x\n\nClaude-Session: abc"'
  [ "$output" = "blocked" ]
  run decide command 'git commit -m "feat: x" -m "Claude-Session: abc"'
  [ "$output" = "blocked" ]
  run decide code 'await d.commit("feat: x", ["- body", "", "Claude-Session: abc"])'
  [ "$output" = "blocked" ]
  run decide command 'gh pr create --body "see claude.ai/code/session_123"'
  [ "$output" = "blocked" ]
}

@test "git-policy: allows explicit paths, including ./file" {
  run decide command 'git add config/pi/agent/RULES.md'
  [ "$output" = "allowed" ]
  run decide command 'git add ./README.md'
  [ "$output" = "allowed" ]
}

@test "git-policy: allows a commit message that names a banned command" {
  run decide command 'git commit -m "docs: forbid git add -A and --no-verify"'
  [ "$output" = "allowed" ]
  run decide code 'await d.commit("feat: block git commit --no-verify", ["- no_verify=True"])'
  [ "$output" = "allowed" ]
  run decide code 'await d.commit("feat(omp): block Claude-Session: trailers")'
  [ "$output" = "allowed" ]
}

@test "git-policy: allows searches for banned commands" {
  run decide command "rg -n 'git add -A' docs"
  [ "$output" = "allowed" ]
  run decide command "rg -n 'Claude-Session:' docs"
  [ "$output" = "allowed" ]
  run decide command 'grep -rn no_verify=True docs'
  [ "$output" = "allowed" ]
}

@test "git-policy: allows look-alike flags on other subcommands" {
  run decide command 'git commit --amend --no-edit'
  [ "$output" = "allowed" ]
  run decide command 'git commit --allow-empty -m "x"'
  [ "$output" = "allowed" ]
  run decide command 'git log -n 5 --grep commit'
  [ "$output" = "allowed" ]
  run decide command 'git push -n origin main'
  [ "$output" = "allowed" ]
}

@test "git-policy: allows a plain commit through omp's helper" {
  run decide code 'await d.commit("feat: x", ["- body"])'
  [ "$output" = "allowed" ]
}
