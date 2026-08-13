---
id: audit-b6c73124
auditor: audit
severity: medium
category: tests
area: tests/
status: open
found: 2026-08-13
---

# The 14-file agent enforcement chain has zero test coverage, while every other script in the repo has a bats file

## Problem

`tests/` holds 79 bats files and 857 assertions covering `local/bin/`, `config/theme/`, `config/lib.sh` and the fish layer. `.claude/hooks/` — 14 scripts, 660 lines — has none. Nothing in `.pre-commit-config.yaml` exercises them either.

This is not a uniformly-thin area; it is the area where a silent defect is least visible. A hook that stops matching still exits 0, prints nothing, and the session continues as if the guard ran. Every other script in this repo fails loudly when it breaks, which is why the untested surface is the enforcement chain rather than, say, `x-hr`.

Two defects in this audit came from the first hook examined — `git status` denied against its own documented allow (`audit-4f747a7d`) and seven bypass forms (`audit-09f208d8`). Both are single-input, single-output cases that a fixture table would have caught on the commit that introduced them. The remaining 13 hooks have not been examined to the same depth and carry the same absence of a safety net.</problem>
<parameter name="evidence">No test references any hook:

```
$ grep -rln "claude/hooks\|pre-bash-route\|pre-edit-block\|stop-lint-gate\|post-edit" tests/
(no output)
```

The untested surface:

```
$ wc -l .claude/hooks/*.sh | tail -1
  660 total
```

```
$ ls .claude/hooks/
async-bats.sh                     post-edit-rules-lint.sh   pre-edit-block.sh
log-failures.sh                   post-tool-context-mode-check.sh  pre-graphify-nudge.sh
notify-idle.sh                    pre-bash-route.sh         session-start-context.sh
post-edit-config-warn.sh          pre-ctx-write-guard.sh    stop-lint-gate.sh
post-edit-dotbot-validate.sh      post-edit-format.sh
```

`.pre-commit-config.yaml` has no entry under `hooks/`, so nothing runs them at commit time either.

The hooks are trivially testable — they are stdin-JSON in, stdout-JSON out:

```
$ printf '{"tool_input":{"command":"git status"}}' | bash .claude/hooks/pre-bash-route.sh \
    | jq -r .hookSpecificOutput.permissionDecision
deny
```

That one line is the whole harness the suite is missing.</evidence>
<parameter name="impact">Every rule in `.claude/rules/` that names a hook as its enforcement — `bash-routing.md`, `read-routing.md`, `vendored-files.md`, `context-mode-issues.md`, `no-hook-bypass.md` — rests on a script that no gate verifies. A regression in any of them degrades silently: the guard stops firing, the rule text still promises it fires, and the divergence surfaces only when someone hand-tests it, as this audit did. The `git status` defect has presumably been live since the allow list was written and produced a wrong denial on every use of the repo's most common git command without anyone noticing.</impact>
<parameter name="fix">Add one bats file per hook, starting with the two that already have known defects. The repo's `.claude/skills/bats-test-scaffold` skill generates the shape; the assertions are a table of input command to expected decision:

```bash
# tests/pre-bash-route.bats
HOOK="${BATS_TEST_DIRNAME}/../.claude/hooks/pre-bash-route.sh"

# Feed the hook a PreToolUse payload and print its decision, or "allow" when
# it emits no JSON at all — a no-decision response lets the call through, so
# the two must be indistinguishable to the assertions.
decision() {
  printf '{"tool_input":{"command":%s}}' "$(jq -Rn --arg c "$1" '$c')" \
    | bash "$HOOK" \
    | jq -r '.hookSpecificOutput.permissionDecision // "allow"'
}

@test "pre-bash-route: allows the documented git readers" {
  [ "$(decision 'git status')" = "allow" ]
  [ "$(decision 'git status -s')" = "allow" ]
}

@test "pre-bash-route: denies output-producing readers" {
  [ "$(decision 'git log --oneline')" = "deny" ]
  [ "$(decision 'cat README.md')" = "deny" ]
  [ "$(decision 'yarn lint')" = "deny" ]
}

@test "pre-bash-route: a wrapper or path cannot hide a denied command" {
  [ "$(decision '/bin/cat README.md')" = "deny" ]
  [ "$(decision 'command cat README.md')" = "deny" ]
  [ "$(decision 'timeout 5 rg foo .')" = "deny" ]
  [ "$(decision 'git ls-files | xargs cat')" = "deny" ]
  [ "$(decision '/bin/bash -c "cat README.md"')" = "deny" ]
}

@test "pre-bash-route: BASH_OK passes through and strips the marker" {
  run bash -c 'printf "{\"tool_input\":{\"command\":\"BASH_OK cat README.md\"}}" | bash "$1"' _ "$HOOK"
  [ "$status" -eq 0 ]
  [[ "$output" == *'"permissionDecision": "allow"'* ]]
  [[ "$output" == *'"command": "cat README.md"'* ]]
}
```

Three of those assertions fail against the current hook — that is the point; land them with the fixes for `audit-4f747a7d` and `audit-09f208d8` so the tests prove the fix rather than describe it.

Then work outward: `pre-edit-block.sh` (one case per blocked path plus one allowed path), `post-tool-context-mode-check.sh` (one case per trigger signal in `context-mode-issues.md`), `stop-lint-gate.sh`. `test-all.sh` picks the files up automatically — it globs `git ls-files '*.bats'` — but `.github/workflows/tests.yml:55` runs `bats tests/` by path, so keep the files under `tests/`.</fix>

## Evidence

## Impact

## Fix
