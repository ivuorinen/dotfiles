---
name: new-fish-function
description: >-
  Scaffold a new fish function in config/fish/functions/
  with proper conventions and event handling.
user-invocable: true
allowed-tools: Read, Write, Edit, Skill
---

# New fish function

When creating a new fish function in `config/fish/functions/`:

## 1. Create the function file

Create `config/fish/functions/<name>.fish`:

```fish
function <name> --description '<one-line description>'
  # Function logic here
end
```

- One function per file, filename must match function name
- Always include `--description`
- Use `--argument-names` for named parameters

## 2. Conventions

- Use `--wraps` if the function wraps an existing command
- For abbreviation-like functions, prefer fish abbreviations
  in `config/fish/alias.fish` instead

## 3. Validate

Run the `fish-validate` skill on the new file. It owns the check
commands and routes them through `ctx_batch_execute`, which
`.claude/rules/bash-routing.md` requires.
