#!/usr/bin/env bash
# PostToolUse on context-mode MCP tools: halt the turn when the
# tool response carries an upgrade prompt or a binding/runtime
# error. context-mode is load-bearing for this repo's routing
# rules; a stale or broken install must surface immediately, not
# be papered over by retrying with degraded behaviour.
#
# Receives the tool invocation JSON on stdin. PostToolUse payloads
# include `tool_response` — we scan its stringified form for known
# signatures.

set -uo pipefail

input=$(cat)

# Only inspect responses from context-mode tools. Any other tool (e.g.
# ctx_execute_file returning a file whose content mentions these patterns)
# would false-positive. The upgrade/doctor/stats/purge tools are also
# excluded — they ARE the remediation and their output naturally contains
# the banner that would otherwise deadlock the check.
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty' 2> /dev/null)
case "$tool" in
  *ctx_upgrade* | *ctx_doctor* | *ctx_stats* | *ctx_purge*)
    exit 0
    ;;
  *context-mode* | *ctx_*) ;;
  *) exit 0 ;;
esac

# Stringify the tool response so we can grep it regardless of
# whether the MCP server returned a JSON object, an array, or a
# plain string.
response=$(printf '%s' "$input" | jq -r '.tool_response // empty' 2> /dev/null)
if [ -z "$response" ]; then
  exit 0
fi

# Patterns that mean "context-mode itself is reporting a problem":
#   1. The upgrade banner — "v1.0.111 outdated → v1.0.146 available"
#   2. Native-binding mismatch — NODE_MODULE_VERSION error from
#      better-sqlite3 after a node upgrade.
#   3. Batch execution error from the runtime layer.
upgrade_re='outdated[^\n]*→[^\n]*available'
binding_re='NODE_MODULE_VERSION'
batch_re='Batch execution error'

hits=""
if printf '%s' "$response" | grep -Eq "$upgrade_re"; then
  hits="${hits}- upgrade available (run /ctx-upgrade)\n"
fi
if printf '%s' "$response" | grep -Eq "$binding_re"; then
  hits="${hits}- native binding mismatch — re-run /ctx-upgrade to rebuild\n"
fi
if printf '%s' "$response" | grep -Eq "$batch_re"; then
  hits="${hits}- batch execution failed inside context-mode runtime\n"
fi

if [ -n "$hits" ]; then
  printf 'BLOCKED: context-mode reported an issue.\n%b' "$hits" >&2
  printf 'Stop and tell the user to run /ctx-upgrade before continuing.\n' >&2
  printf 'See .claude/rules/context-mode-issues.md.\n' >&2
  exit 2
fi

exit 0
