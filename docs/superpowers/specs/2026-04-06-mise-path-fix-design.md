# Fix mise config.toml deletion and PATH ordering

**Date:** 2026-04-06
**Status:** Design approved

## Problem

Two issues with mise integration:

1. **config.toml deletion**: Dotbot's `clean: ~/.config: {recursive: true}`
   directive in `install.conf.yaml` can remove the
   `~/.config/mise/config.toml` symlink before the link step recreates
   it. During that gap, mise sees no config.

2. **PATH ordering**: `base/bashrc` and `base/zshrc` append
   `~/.local/share/sonarqube-cli/bin` to PATH on their final lines —
   AFTER `config/exports` runs `mise activate`. This makes
   sonarqube-cli take precedence over mise-managed tools.

## Changes

### 1. Protect mise config from Dotbot clean (`install.conf.yaml`)

Add `exclude:` list to the `~/.config:` clean entry:

```yaml
~/.config:
  recursive: true
  exclude:
    - "mise/config.toml"
```

### 2. Move sonarqube-cli PATH (`base/bashrc`, `base/zshrc`, `config/exports`, `config/fish/exports.fish`)

- Remove `export PATH="$HOME/.local/share/sonarqube-cli/bin:$PATH"`
  from `base/bashrc` and `base/zshrc`
- Add it to `config/exports` BEFORE the `mise activate` block
- Add equivalent `fish_add_path` in `config/fish/exports.fish`

### 3. Remove AWS_DEFAULT_REGION (`config/exports`, `config/fish/exports.fish`)

Already staged in dirty working tree. Include in this change.

### Files

| File                       | Change                                      |
|----------------------------|---------------------------------------------|
| `install.conf.yaml`        | Add exclude for mise/config.toml            |
| `base/bashrc`              | Remove sonarqube-cli PATH line              |
| `base/zshrc`               | Remove sonarqube-cli PATH line              |
| `config/exports`           | Add sonarqube-cli PATH before mise activate |
| `config/fish/exports.fish` | Add sonarqube-cli fish_add_path             |

## Verification

1. `./install` runs without deleting `~/.config/mise/config.toml`
2. `mise doctor` shows no PATH precedence warning
3. `which sonarqube-cli` still resolves correctly
4. `yarn lint` passes

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
