---
name: lua-format
description: >-
  Format Lua files after editing.
  Apply when writing or modifying any .lua file.
user-invocable: false
allowed-tools: Bash
---

After editing any `.lua` file, format it with stylua:

```bash
stylua <file>
```

Project settings are in `stylua.toml` (90-char line length).

If stylua is not available, skip formatting silently.

## Files to never format

- Files inside `config/nvim/` managed by plugins (lazy.nvim lockfile)
