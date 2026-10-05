---
name: lua-format
description: >-
  Format Lua files after editing.
  Apply when writing or modifying any .lua file.
user-invocable: false
allowed-tools: mcp__plugin_context-mode_context-mode__ctx_batch_execute
---

Every `Edit`/`Write` of a `.lua` file is already formatted in place:
`.claude/hooks/post-edit-format.sh` runs `stylua <file>` after the edit.
To confirm, run the check through `ctx_batch_execute`
(`.claude/rules/bash-routing.md`; `Bash` denies `stylua`):

```bash
stylua --check <file>
```

Project settings are in `stylua.toml` (90-char line length).

If stylua is not available, say so in the response: `stylua not available — <file> not formatted`.

## Files to never format

- Files inside `config/nvim/` managed by plugins (lazy.nvim lockfile)
