#!/usr/bin/env bash
# SessionStart context: print branch, dirty file count, and last commit.

cd "$CLAUDE_PROJECT_DIR" || exit 0

branch=$(git branch --show-current 2> /dev/null)
dirty=$(git status --short 2> /dev/null | wc -l | tr -d ' ')
last=$(git log -1 --oneline 2> /dev/null)

echo "=== Dotfiles session context ==="
echo "Branch : ${branch:-unknown}"
echo "Dirty  : ${dirty} file(s)"
echo "Last   : ${last}"

exit 0
