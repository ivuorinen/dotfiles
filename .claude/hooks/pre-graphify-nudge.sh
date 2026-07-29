#!/usr/bin/env bash
# Pre-tool nudge: remind the model to query the knowledge graph before
# reading or grepping raw source. Replaces `graphify hook-guard <mode>`,
# whose reminder is ~400 chars and fires on every Read — several times the
# cost of graphify-first.md, which already carries the full mandate.
#
# The rule is the authority; this is the one-line tip read-routing.md
# describes. Keep it short: it is paid per tool call, not per session.
#
# Hook contract (docs: code.claude.com/docs/en/hooks): exit 0 with only
# hookSpecificOutput JSON on stdout. No permissionDecision — this adds
# context, it never blocks.
#
# Usage: pre-graphify-nudge.sh read|search

mode="${1:-read}"
root="${CLAUDE_PROJECT_DIR:-$PWD}"

# No graph, nothing to suggest — stay silent and cost nothing.
[[ -f "$root/graphify-out/graph.json" ]] || exit 0

case "$mode" in
  search) tip='graphify-out/ exists: prefer `graphify query "<question>"` over raw grep.' ;;
  *) tip='graphify-out/ exists: prefer `graphify query "<question>"` over raw reads.' ;;
esac

jq -cn --arg tip "$tip" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    additionalContext: $tip
  }
}'
