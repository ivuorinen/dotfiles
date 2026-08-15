#!/usr/bin/env bats
#
# Coverage for .claude/hooks/post-tool-context-mode-check.sh — the PostToolUse
# guard that halts the turn when a context-mode response carries an upgrade
# banner, a native-binding mismatch, or a batch runtime error.
#
# Known and deliberate: the patterns match anywhere in the response, so the
# guard also fires when a response merely QUOTES them — reading the hook's own
# source, .claude/rules/context-mode-issues.md, or a finding body through
# ctx_execute all do it. The trade is stated in the hook: a missed signal
# degrades the routing rules silently for a whole session, a false positive
# costs one /ctx-doctor call. The false-positive case is pinned below so the
# behaviour is a decision on record rather than a surprise.

bats_require_minimum_version 1.5.0

setup()
{
  HOOK="${BATS_TEST_DIRNAME}/../.claude/hooks/post-tool-context-mode-check.sh"
  CTX=mcp__plugin_context-mode_context-mode__ctx_execute
  export HOOK CTX
}

check()
{
  jq -cn --arg tool "$1" --arg resp "$2" \
    '{tool_name: $tool, tool_response: $resp}' | bash "$HOOK"
}

@test "post-tool-context-mode-check: catches the upgrade banner" {
  run -2 check "$CTX" 'context-mode v1.0.111 outdated → v1.0.169 available'
  [[ "$output" == *"context-mode-issues.md"* ]]
}

@test "post-tool-context-mode-check: catches a native binding mismatch" {
  run -2 check "$CTX" 'Error: NODE_MODULE_VERSION 108 does not match 127'
}

@test "post-tool-context-mode-check: catches a batch runtime error" {
  run -2 check "$CTX" 'Batch execution error: worker died'
}

@test "post-tool-context-mode-check: a healthy response passes" {
  run -0 check "$CTX" 'Executed 3 commands (42 lines). Indexed 3 sections.'
}

@test "post-tool-context-mode-check: an empty response passes" {
  run -0 check "$CTX" ''
}

# The remediation tools ARE the fix; their output naturally contains the
# banner, so blocking on them would deadlock the only way out.
@test "post-tool-context-mode-check: exempts the remediation tools" {
  for t in ctx_upgrade ctx_doctor ctx_stats ctx_purge; do
    run -0 check "mcp__plugin_context-mode_context-mode__$t" \
      'v1.0.111 outdated → v1.0.169 available'
  done
}

# Scoped to context-mode tools: a Read or Bash response quoting these strings
# says nothing about the server's health.
@test "post-tool-context-mode-check: ignores non-context-mode tools" {
  run -0 check Read 'v1.0.111 outdated → v1.0.169 available'
  run -0 check Bash 'NODE_MODULE_VERSION mismatch'
  run -0 check Edit 'Batch execution error'
}

# Documented false positive, pinned deliberately rather than left as folklore.
# The guard cannot tell a server reporting a fault from a faithful echo of text
# describing one, so it fails closed: reading this hook's own source, the rule
# file, or a finding body through ctx_execute all trip it.
#
# Pinning the CURRENT behaviour, not the desired message. The agreed change
# (keep detection, reword the block to say "confirm with /ctx-doctor" instead
# of asserting the install is broken) is still unapplied — the classifier
# blocks edits under .claude/hooks/. When it lands, add here:
#   [[ "$output" == *"/ctx-doctor"* ]]
#   [[ "$output" != *"context-mode reported an issue"* ]]
@test "post-tool-context-mode-check: fires on merely quoted signal strings" {
  run -2 check "$CTX" "$(printf '# batch_re=%s\n' "'Batch execution error'")"
  [[ "$output" == *"context-mode-issues.md"* ]]
}
