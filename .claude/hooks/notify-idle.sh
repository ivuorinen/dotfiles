#!/usr/bin/env bash
# Notification hook: alert when Claude goes idle.
# Uses pushover if available, falls back to macOS native notification.

msg=$(jq -r '.message // "Claude is waiting for input"')

if command -v pushover > /dev/null; then
  pushover "Claude Code" "$msg"
elif command -v osascript > /dev/null; then
  osascript -e "display notification \"$msg\" with title \"Claude Code\""
fi

exit 0
