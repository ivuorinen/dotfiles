#!/usr/bin/env bash
# PostToolUseFailure logger: append tool failures to a local log file.

log_file="$CLAUDE_PROJECT_DIR/.claude/hook-failures.log"

entry=$(jq -c '{
  time: (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
  tool: .tool_name,
  error: .error
}')

echo "$entry" >> "$log_file"

exit 0
