#!/usr/bin/env bash
# PreToolUse on context-mode execute tools (ctx_execute, ctx_execute_file,
# ctx_batch_execute): the sandbox has raw filesystem access, so code that
# targets hook-protected paths must be denied here — pre-edit-block.sh only
# sees Edit/Write/Read tool calls (finding audit-5f0966e7).
#
# Receives tool input JSON on stdin.
set -euo pipefail

input=$(cat)
payload=$(printf '%s' "$input" | jq -r '
  [
    (.tool_input.code // empty),
    (.tool_input.path // empty),
    ((.tool_input.commands // []) | map(.command // empty) | join("\n"))
  ] | join("\n")
' 2> /dev/null) || exit 0
[[ -z "$payload" ]] && exit 0

# Must stay in step with the case list in pre-edit-block.sh: that guard covers
# Edit/Write, this one covers the same paths reached through the sandbox. Four
# groups were listed there but missing here — the five fish plugin functions,
# the graphify skill, the iTerm2 integration, and tools/dotbot-include (which
# the tools/dotbot prefix does happen to cover) — so a `rm` on any of them went
# through ctx_execute unchecked.
protected='fzf-tmux|yarn\.lock|\.yarn/|tools/dotbot|tools/antidote|config/fzf/(completion|key-bindings)\.|cheat/cheatsheets/(community|tldr)|config/fish/functions/(fisher|bass|__bass|__z_add|__z_clean)\.|\.claude/skills/graphify/|iterm2_shell_integration\.zsh'
# ponytail: same-line co-occurrence heuristic — write-shaped tokens next to a
# protected path. Upgrade to real argv parsing only if false positives hurt.
writeish='>>|>|sed [^|;&]*-i|tee |rm |mv |cp |chmod |truncate |open\(|writeFile|appendFile'

# Strip stderr/stdout-to-null redirects so `2> /dev/null` does not read as a
# write, then check line by line.
cleaned=$(printf '%s' "$payload" | sed -E 's/[0-9]*>>?[[:space:]]*(\&[0-9]+|\/dev\/null)//g')

if printf '%s\n' "$cleaned" | grep -E "$protected" | grep -qE "$writeish"; then
  echo "BLOCKED: sandbox code combines a hook-protected path (vendor/lock/submodule) with write-capable operations." >&2
  echo "Protected files follow .claude/rules/vendored-files.md; make legitimate changes with Write/Edit so the edit hooks can vet them." >&2
  exit 2
fi

# Real secrets.d fish files: reading is as forbidden as writing (credentials).
if printf '%s\n' "$payload" | grep -E 'secrets\.d/[[:alnum:]._-]+\.fish' | grep -qv '\.fish\.example'; then
  echo "BLOCKED: sandbox code references a real secrets.d fish file — these contain credentials. Ask the user instead." >&2
  exit 2
fi

exit 0
