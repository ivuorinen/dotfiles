#!/usr/bin/env bash
# UserPromptSubmit: record the user's latest prompt so pre-bash-route.sh can
# honour a BASH_OK escape only for a command the user actually named
# (bash-routing.md case 4; agent-loopholes-ab4a6d36). Without this record the
# hook could not tell whether the condition held and allowed every escape.
#
# The file is gitignored and written 0600: prompts can carry anything.
# Never blocks — a recording failure leaves BASH_OK denying, which is the safe
# direction.

umask 077
out="${CLAUDE_PROJECT_DIR:-$PWD}/.claude/.last-prompt"
jq -r '.prompt // ""' > "$out" 2> /dev/null || : > "$out"
exit 0
