#!/usr/bin/env bash
# PostToolUseFailure logger: append tool failures to a local log file.
# Caps the file at 1000 lines via tail-rotation to keep it bounded.

log_file="$CLAUDE_PROJECT_DIR/.claude/hook-failures.log"
max_lines=1000

entry=$(jq -c '{
  time: (now | strftime("%Y-%m-%dT%H:%M:%SZ")),
  tool: .tool_name,
  error: .error
}')

echo "$entry" >> "$log_file"

# Tail-rotate when the file grows past the cap. Use a temp file +
# rename so a concurrent appender cannot see a half-truncated log.
if [ -f "$log_file" ]; then
  line_count=$(wc -l < "$log_file" 2> /dev/null || echo 0)
  if [ "$line_count" -gt "$max_lines" ]; then
    tmp="${log_file}.tmp.$$"
    tail -n "$max_lines" "$log_file" > "$tmp" && mv -f "$tmp" "$log_file"
  fi
fi

exit 0
