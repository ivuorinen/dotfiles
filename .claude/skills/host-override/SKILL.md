---
name: host-override
description: >-
  Create or extend host-specific config overlays
  in hosts/<hostname>/ for machine-specific settings.
user-invocable: true
allowed-tools: Bash, Read, Write, Edit
---

When creating host-specific configuration overrides:

## 1. Determine hostname

```bash
hostname -s
```

## 2. Directory structure

Host overrides live in `hosts/<hostname>/` mirroring the
global layout:

```
hosts/<hostname>/
  base/           -> ~/.*
  config/         -> ~/.config/
  install.conf.yaml
```

## 3. Create install.conf.yaml

If it doesn't exist, create `hosts/<hostname>/install.conf.yaml`
following the Dotbot format. Use `include` to layer on top of
the global config:

```yaml
- defaults:
    link:
      create: true
      relink: true
      force: true
```

## 4. Git config overrides

The most common override is `hosts/<hostname>/config/git/overrides/config`.
This is where host-specific git user, signing keys, and credential
helpers go. Always `[include]` the shared config:

```ini
[include]
  path = ~/.dotfiles/config/git/shared
```

## 5. Test

Run `./install` to apply. Dotbot processes
`hosts/<hostname>/install.conf.yaml` after the global config.
