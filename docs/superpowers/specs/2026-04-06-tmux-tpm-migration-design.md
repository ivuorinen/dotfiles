# Tmux TPM Migration Design

**Date:** 2026-04-06
**Branch:** chore/tmux-tpm-migration
**Status:** Approved

## Summary

Migrate tmux plugin management from git submodules to TPM (Tmux Plugin
Manager). Plugins move from `config/tmux/plugins/` (symlinked into
`~/.config/tmux/plugins/`) to `~/.local/share/tmux/plugins/` managed
by TPM at runtime.

## Motivation

Git submodules for tmux plugins add friction:

- Submodule updates require commits in the dotfiles repo
- New machine setup needs `git submodule update --init --recursive`
- Plugin versions are pinned to commit hashes in the dotfiles repo

TPM provides `prefix + I` to install and `prefix + U` to update,
with automatic bootstrap on first tmux launch.

## Decisions

| Decision               | Choice                           | Rationale                                            |
|------------------------|----------------------------------|------------------------------------------------------|
| Plugin manager path    | `~/.local/share/tmux/plugins/`   | XDG-compliant, separates managed plugins from config |
| Migration approach     | Full TPM (`set -g @plugin`)      | Idiomatic, clean, TPM handles sourcing               |
| All 7 plugins          | Migrate all to TPM               | No reason to keep any as submodules                  |
| Directory pre-creation | `install.conf.yaml` creates path | Ensures dir exists before tmux runs                  |

## Plugins (declaration order)

Load order matters — catppuccin must load before dark-notify.

| # | Plugin                     | Source                              |
|---|----------------------------|-------------------------------------|
| 1 | tpm                        | `tmux-plugins/tpm`                  |
| 2 | tmux-suspend               | `MunifTanjim/tmux-suspend`          |
| 3 | tmux-sessionist            | `tmux-plugins/tmux-sessionist`      |
| 4 | tmux-current-pane-hostname | `soyuka/tmux-current-pane-hostname` |
| 5 | tmux-resurrect             | `tmux-plugins/tmux-resurrect`       |
| 6 | tmux-continuum             | `tmux-plugins/tmux-continuum`       |
| 7 | catppuccin                 | `catppuccin/tmux`                   |
| 8 | tmux-dark-notify           | `ivuorinen/tmux-dark-notify`        |

## Changes

### 1. config/tmux/tmux.conf

**Set plugin manager path** at the top of the plugins section:

```tmux
set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.local/share/tmux/plugins"
```

**Plugin config options** (suspend key, dark-notify paths,
continuum-restore) remain unchanged.

**Replace manual `run-shell` sourcing** (lines 131–138) with
`@plugin` declarations in the load order above.

**Add auto-install snippet** before the TPM runner:

```tmux
if "test ! -d ~/.local/share/tmux/plugins/tpm" \
   "run 'git clone https://github.com/tmux-plugins/tpm ~/.local/share/tmux/plugins/tpm && ~/.local/share/tmux/plugins/tpm/bin/install_plugins'"
```

**TPM runner** as the final line:

```tmux
run '~/.local/share/tmux/plugins/tpm/tpm'
```

**Own scripts** (rename-session.sh, theme-activate.sh,
linux-dark-notify.sh) remain as `run-shell` — they are not plugins.

### 2. Submodule removal

Remove 7 tmux submodules:

- `tmux/tmux-continuum` → `config/tmux/plugins/tmux-continuum`
- `tmux/tmux-resurrect` → `config/tmux/plugins/tmux-resurrect`
- `tmux/tmux-sessionist` → `config/tmux/plugins/tmux-sessionist`
- `tmux/tmux-suspend` → `config/tmux/plugins/tmux-suspend`
- `tmux/tmux-current-pane-hostname` → `config/tmux/plugins/tmux-current-pane-hostname`
- `tmux/tmux-dark-notify` → `config/tmux/plugins/tmux-dark-notify`
- `tmux/catppuccin` → `config/tmux/plugins/catppuccin`

Non-tmux submodules remain: dotbot, dotbot-include, cheat-community,
cheat-tldr, antidote.

### 3. add-submodules.sh

**Remove** the "tmux plugin manager and plugins" block (lines 21–34).

**Add** the 7 submodules to the `old_submodules` array:

```bash
"tmux/tmux-continuum:config/tmux/plugins/tmux-continuum"
"tmux/tmux-resurrect:config/tmux/plugins/tmux-resurrect"
"tmux/tmux-sessionist:config/tmux/plugins/tmux-sessionist"
"tmux/tmux-suspend:config/tmux/plugins/tmux-suspend"
"tmux/tmux-current-pane-hostname:config/tmux/plugins/tmux-current-pane-hostname"
"tmux/tmux-dark-notify:config/tmux/plugins/tmux-dark-notify"
"tmux/catppuccin:config/tmux/plugins/catppuccin"
```

**Enhance `remove_old_submodule`** to also clean `.gitmodules`:

```bash
# Remove .gitmodules entry keyed by name
if [[ -n "$name" ]] && git config -f .gitmodules --get "submodule.$name.path" &>/dev/null; then
  git config -f .gitmodules --remove-section "submodule.$name"
  _log "Removed $name from .gitmodules"
fi
```

### 4. install.conf.yaml

Add to `create:` section:

```yaml
~/.local/share/tmux/plugins:
```

### 5. Cleanup

- Remove `config/tmux/plugins/` directory entirely (empty after
  submodule removal)
- No GitHub Actions changes needed (operates on `.gitmodules` contents)
- No CLAUDE.md hook changes needed

## Files modified

| File                    | Action                                                             |
|-------------------------|--------------------------------------------------------------------|
| `config/tmux/tmux.conf` | Rewrite plugins section                                            |
| `add-submodules.sh`     | Remove tmux block, add to old_submodules, enhance removal function |
| `install.conf.yaml`     | Add plugins dir to create section                                  |
| `.gitmodules`           | Remove 7 tmux entries (via git rm)                                 |
| `config/tmux/plugins/`  | Remove directory                                                   |
