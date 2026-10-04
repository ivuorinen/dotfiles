---
name: yaml-validate
description: >-
  Validate YAML files after editing.
  Apply when writing or modifying any .yml or .yaml file.
user-invocable: false
allowed-tools: Read, mcp__plugin_context-mode_context-mode__ctx_batch_execute
---

After editing any YAML file, validate it. Run every command below through
`ctx_batch_execute` (`.claude/rules/bash-routing.md`); `Bash` denies them.

## 1. Syntax check

Run yamllint on the file:

```bash
yamllint <file>
```

If yamllint is not available, fall back to:

```bash
python3 -c "import yaml; yaml.safe_load(open('<file>'))"
```

## 2. GitHub Actions workflows

If the file is under `.github/workflows/`, also run:

```bash
actionlint <file>
```

If actionlint is not available, report `actionlint not available — <file> not validated`.

## Files to skip

- `config/gh/hosts.yml` — managed by `gh` CLI, not hand-edited
