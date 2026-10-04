#!/usr/bin/env bash
# PreToolUse on context-mode execute tools (ctx_execute, ctx_execute_file,
# ctx_batch_execute, ctx_index): the sandbox has raw filesystem access, so code
# that targets hook-protected paths must be denied here — pre-edit-block.sh
# only sees Edit/Write/Read tool calls (finding audit-5f0966e7). The same
# sandbox runs arbitrary shell, so the Bash policy tier (lib/bash-policy.sh)
# runs on its code as well.
#
# Receives tool input JSON on stdin. Blocks with exit 2 and the reason on
# stderr.
set -euo pipefail

# block WHY — refuse the call with WHY as the reason Claude sees.
block()
{
  printf 'BLOCKED: %s\n' "$1" >&2
  exit 2
}

# Fail closed when the payload cannot be read: exiting 0 on a jq failure
# switched off every check below (agent-loopholes-468c93a6).
command -v jq > /dev/null 2>&1 \
  || block "jq is not on PATH, so pre-ctx-write-guard.sh cannot read the payload; it fails closed."

# shellcheck source=lib/bash-policy.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/bash-policy.sh"

input=$(cat)
# `commands` (ctx_batch_execute) are shell. `code` is shell when `language`
# says so or is absent; any other language goes to the string-literal pass.
# `path` (ctx_execute_file, ctx_index) is only read, so it gets the secrets
# check alone.
unreadable="unparseable hook payload; pre-ctx-write-guard.sh fails closed."
# One unit per batch command, newlines carried as \x1e so each stays one line.
# Every batch command runs in a shell of its own, so each is judged on its own:
# joined, a protected path in one (`git submodule status`) and a write-shaped
# token in another (a JavaScript `=>`) read as one write.
shell_units=$(printf '%s' "$input" | jq -r '
  ((.tool_input.commands // [])[] | .command // empty),
  (if (.tool_input.language // "shell") == "shell" then (.tool_input.code // empty) else empty end)
  | gsub("\n"; "\u001e")
' 2> /dev/null) || block "$unreadable"
units=()
while IFS= read -r unit; do
  [[ "$unit" =~ [^[:space:]] ]] && units+=("${unit//$'\x1e'/$'\n'}")
done <<< "$shell_units"
foreign_code=$(printf '%s' "$input" | jq -r '
  if (.tool_input.language // "shell") == "shell" then empty else (.tool_input.code // empty) end
' 2> /dev/null) || block "$unreadable"
path=$(printf '%s' "$input" | jq -r '.tool_input.path // empty' 2> /dev/null) || block "$unreadable"
# Both execute tools take a `cwd`. Inside a secrets or protected tree a bare
# relative name (`cat github.fish`) carries no path text for the predicates to
# see (audit-80f9f36c), so the directory itself is judged.
cwd=$(printf '%s' "$input" | jq -r '.tool_input.cwd // empty' 2> /dev/null) || block "$unreadable"
# A regex test, not ${code//[[:space:]]/}: bash 3.2's pattern substitution is
# quadratic and cost seconds on a long batch.
[[ "$foreign_code" =~ [^[:space:]] ]] || foreign_code=""
[[ ${#units[@]} -gt 0 || -n "$foreign_code" || -n "$path" ]] || exit 0

if [[ -n "$cwd" ]] && secrets_referenced "$cwd"; then
  block "the working directory is inside a secrets.d tree — its files contain credentials. Ask the user instead."
fi

# ponytail: per-unit co-occurrence heuristic — a protected path anywhere in a
# unit (one batch command, or the code) plus a write-shaped token anywhere in
# the same unit. It was per-line until a variable split the two across lines
# (`p=<protected path>` then `writeFileSync(p, …)`, agent-loopholes-408b9560).
# Read-only code that mentions a protected path and writes somewhere else is a
# false positive; Write/Edit is the way round it. The policy tier below checks
# shell redirects and write commands precisely; this stays for the non-shell
# writes it cannot parse.
writeish='>>|>|sed [^|;&]*-i|tee |rm |mv |cp |chmod |truncate |open\(|writeFile|appendFile'

# co_occurs UNIT FOREIGN — refuse UNIT when it names a protected path and
# carries a write-shaped token. For non-shell code (FOREIGN=1) a protected cwd
# counts as the path being named, since every relative write lands inside it;
# shell gets the precise cwd-aware check in the policy tier (BP_CWD below), so
# `echo x > /tmp/y` there still passes.
co_occurs()
{
  local cleaned hit=0
  # Strip stderr/stdout-to-null redirects so `2> /dev/null` does not read as
  # a write.
  cleaned=$(printf '%s' "$1" | sed -E 's/[0-9]*>>?[[:space:]]*(\&[0-9]+|\/dev\/null)//g')
  protected_referenced "$cleaned" && hit=1
  if [[ "$hit" -eq 0 && "$2" -eq 1 && -n "$cwd" ]] && protected_referenced "$cwd/"; then
    hit=1
  fi
  if [[ "$hit" -eq 1 ]] && printf '%s\n' "$cleaned" | grep -qE "$writeish"; then
    echo "BLOCKED: sandbox code combines a hook-protected path (vendor/lock/submodule/git hook) with write-capable operations." >&2
    echo "Protected files follow .claude/rules/vendored-files.md; make legitimate changes with Write/Edit so the edit hooks can vet them." >&2
    exit 2
  fi
  return 0
}

for unit in ${units[@]+"${units[@]}"}; do
  co_occurs "$unit" 0
done
[[ -z "$foreign_code" ]] || co_occurs "$foreign_code" 1

# Real secrets.d files, fish or bash/zsh: reading is as forbidden as writing.
if [[ -n "$path" ]] && secrets_referenced "$path"; then
  block "the path names a secrets.d tree or a real secrets file — these contain credentials. Ask the user instead."
fi

# The Bash policy tier (secrets, hook bypass, git add, npm/pip/uv installs,
# network fetchers) applies to sandbox code too: without it every commit-gate
# rule was one ctx_execute away (agent-loopholes-0e8b508f). Shell that does
# not parse — Python or JavaScript sent without a `language` — falls through
# to the string-literal pass inside bash_policy_check, so `os.system("git add
# -A")` is still read. Each unit is checked alone for the reason the units
# exist: its "code names a policy tool" test would otherwise read one
# command's unparseable shape against another command's tool name.
# BP_CWD lets its write checks resolve relative targets against `cwd`.
# shellcheck disable=SC2034 # read by lib/bash-policy.sh
BP_CWD=$cwd
for unit in ${units[@]+"${units[@]}"}; do
  if bash_policy_check "$unit" shell; then
    block "$BP_REASON"
  fi
done
if [[ -n "$foreign_code" ]] && bash_policy_check "$foreign_code" foreign; then
  block "$BP_REASON"
fi

exit 0
