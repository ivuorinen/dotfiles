---
name: new-fish-function
description: >-
  Scaffold a new fish function in config/fish/functions/
  with proper conventions and event handling.
user-invocable: true
allowed-tools: Bash, Read, Write, Edit
---

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

- Do NOT use `_tide_` prefix (reserved for tide prompt plugin)
- Use `--wraps` if the function wraps an existing command
- For abbreviation-like functions, prefer fish abbreviations
  in `config/fish/alias.fish` instead

## 3. Validate

Run the fish-validate skill checks:

```bash
fish --no-execute config/fish/functions/<name>.fish
fish_indent --check config/fish/functions/<name>.fish
```
