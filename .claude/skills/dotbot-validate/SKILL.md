---
name: dotbot-validate
description: >-
  Validate Dotbot install.conf.yaml files after editing.
  Apply when writing or modifying any install.conf.yaml.
user-invocable: false
allowed-tools: Bash, Read
---

After editing any `install.conf.yaml` file, validate it:

## 1. YAML syntax

```bash
yamllint -d relaxed <file>
```

If yamllint is not available, fall back to:

```bash
python3 -c "import yaml; yaml.safe_load(open('<file>'))"
```

## 2. Link target verification

For each `link` entry, verify the source path exists relative
to the repo root. Report any missing source files.

## 3. Host-specific configs

Files in `hosts/<hostname>/install.conf.yaml` overlay the
global config. Verify that any `include` directives reference
existing files.

## Key locations

- `install.conf.yaml` — global config
- `hosts/*/install.conf.yaml` — per-host overlays
