---
name: fish-validate
description: >-
  Validate fish scripts after editing.
  Apply when writing or modifying any .fish file
  in config/fish/.
user-invocable: false
allowed-tools: Bash, Read, mcp__plugin_context-mode_context-mode__ctx_batch_execute
---

# Validate fish scripts

After editing any `.fish` file in `config/fish/`, validate it. Run the
checks below through `ctx_batch_execute` (`.claude/rules/bash-routing.md`);
`Bash` denies them. Only the in-place `fish_indent --write` runs on `Bash`.

## 1. Syntax check

```bash
fish --no-execute <file>
```

If syntax check fails, fix the issue before proceeding.

## 2. Format check

Run `fish_indent` to verify formatting:

```bash
fish_indent --check <file>
```

If formatting differs, apply it:

```bash
fish_indent --write <file>
```
