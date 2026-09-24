#!/usr/bin/env bash
# PreToolUse on context-mode execute tools (ctx_execute, ctx_execute_file,
# ctx_batch_execute, ctx_index): the sandbox has raw filesystem access, so code
# that targets hook-protected paths must be denied here — pre-edit-block.sh
# only sees Edit/Write/Read tool calls (finding audit-5f0966e7).
#
# Receives tool input JSON on stdin.
set -euo pipefail

# shellcheck source=lib/protected-paths.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/protected-paths.sh"

input=$(cat)
# `code` and `commands` run; `path` (ctx_execute_file, ctx_index) is only
# read. The write check scans what runs, so reading a protected file through
# ctx_execute_file stays allowed; the secrets check scans everything, since
# reading a secret is the harm.
code=$(printf '%s' "$input" | jq -r '
  [
    (.tool_input.code // empty),
    ((.tool_input.commands // []) | map(.command // empty) | join("\n"))
  ] | join("\n")
' 2> /dev/null) || exit 0
path=$(printf '%s' "$input" | jq -r '.tool_input.path // empty' 2> /dev/null) || exit 0
payload=$(printf '%s\n%s' "$code" "$path")
[[ -z "$code$path" ]] && exit 0

# ponytail: whole-payload co-occurrence heuristic — a protected path anywhere
# plus a write-shaped token anywhere. It was per-line until a variable split
# the two across lines (`p=<protected path>` then `writeFileSync(p, …)`,
# agent-loopholes-408b9560). Read-only code that mentions a protected path and
# writes somewhere else is a false positive; Write/Edit is the way round it.
# Upgrade to real argv/AST parsing only if those false positives hurt.
writeish='>>|>|sed [^|;&]*-i|tee |rm |mv |cp |chmod |truncate |open\(|writeFile|appendFile'

# Strip stderr/stdout-to-null redirects so `2> /dev/null` does not read as a
# write.
cleaned=$(printf '%s' "$code" | sed -E 's/[0-9]*>>?[[:space:]]*(\&[0-9]+|\/dev\/null)//g')

if printf '%s\n' "$cleaned" | grep -qE "$PROTECTED_RE" \
  && printf '%s\n' "$cleaned" | grep -qE "$writeish"; then
  echo "BLOCKED: sandbox code combines a hook-protected path (vendor/lock/submodule) with write-capable operations." >&2
  echo "Protected files follow .claude/rules/vendored-files.md; make legitimate changes with Write/Edit so the edit hooks can vet them." >&2
  exit 2
fi

# Real secrets.d files, fish or bash/zsh: reading is as forbidden as writing.
if secrets_referenced "$payload"; then
  echo "BLOCKED: sandbox code references a secrets.d tree or a real secrets file — these contain credentials. Ask the user instead." >&2
  exit 2
fi

exit 0
