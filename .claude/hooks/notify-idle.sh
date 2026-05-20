#!/usr/bin/env bash
# Notification hook: alert when Claude goes idle.
# Uses pushover if available, falls back to macOS native notification.

msg=$(jq -r '.message // "Claude is waiting for input"')

if command -v pushover > /dev/null; then
  pushover "Claude Code" "$msg"
elif command -v osascript > /dev/null; then
  # Pass $msg as argv so AppleScript never parses it as code.
  osascript \
    -e 'on run argv' \
    -e 'display notification (item 1 of argv) with title "Claude Code"' \
    -e 'end run' \
    -- "$msg"
fi

exit 0
