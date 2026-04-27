---
name: fish-validate
description: >-
  Validate fish scripts after editing.
  Apply when writing or modifying any .fish file
  in config/fish/.
user-invocable: false
allowed-tools: Bash, Read
---

# Validate fish scripts

After editing any `.fish` file in `config/fish/`, validate it:

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
fish_indent -w <file>
```
