---
description: "Halt and notify the user when context-mode reports an upgrade or runtime error — never paper over it."
alwaysApply: true
---

# context-mode issue handling

context-mode is load-bearing for this repo's routing rules
(`.claude/rules/context-mode.md`, `.claude/rules/bash-routing.md`).
A stale or broken install silently degrades the rule chain — falling
back to direct `Bash` instead of `ctx_batch_execute`, or losing FTS5
indexing entirely.

If a context-mode MCP tool response carries any of the following
signals, stop the turn and notify the user. Do not retry the call,
do not silently switch to Bash, and do not attempt the upgrade
yourself.

## Trigger signals

- An upgrade banner: `vX.Y.Z outdated → vA.B.C available`.
- A native-binding mismatch: `NODE_MODULE_VERSION` mentioned in the
  error text (better-sqlite3 ABI drift after a Node upgrade).
- A runtime error from the batch layer: `Batch execution error:`.
- Any context-mode tool that exits non-zero with a message naming
  itself in the error (e.g. `context-mode v...` in the error body).

## Required response

1. Stop work on the current task.
2. Tell the user, in one sentence, that context-mode needs upgrading
    and that they must run `/ctx-upgrade`.
3. Wait for the user to run the upgrade and restart the session
    before continuing. The new MCP tool schemas only load after a
    session restart.

The PostToolUse hook
`.claude/hooks/post-tool-context-mode-check.sh` enforces this
automatically: it exits 2 with a blocking message whenever the
signals above appear in a context-mode tool response. The rule
exists so the behaviour is also documented in prose, and so an
agent without the hook active still follows the same path.
