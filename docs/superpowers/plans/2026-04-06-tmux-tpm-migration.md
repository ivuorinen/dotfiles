# Tmux TPM Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace git-submodule-managed tmux plugins with TPM (Tmux Plugin Manager) using `~/.local/share/tmux/plugins/` as the runtime path.

**Architecture:** Remove 7 tmux plugin submodules, rewrite the plugins section of `tmux.conf` to use `set -g @plugin` declarations with auto-bootstrap, enhance `add-submodules.sh` to self-heal stale submodule state, and pre-create the TPM directory via Dotbot.

**Tech Stack:** tmux, TPM, git submodules, Dotbot (YAML), bash

**Spec:** `docs/superpowers/specs/2026-04-06-tmux-tpm-migration-design.md`

---

### Task 1: Remove tmux git submodules

Deinit and remove all 7 tmux plugin submodules from the repo. This must happen first because later edits to `add-submodules.sh` and `tmux.conf` reference paths that would conflict with existing submodule state.

**Files:**
- Modify: `.gitmodules` (7 sections removed by git)
- Remove: `config/tmux/plugins/tmux-continuum/`
- Remove: `config/tmux/plugins/tmux-resurrect/`
- Remove: `config/tmux/plugins/tmux-sessionist/`
- Remove: `config/tmux/plugins/tmux-suspend/`
- Remove: `config/tmux/plugins/tmux-current-pane-hostname/`
- Remove: `config/tmux/plugins/tmux-dark-notify/`
- Remove: `config/tmux/plugins/catppuccin/`

- [ ] **Step 1: Deinit all tmux submodules**

```bash
cd /home/ivuorinen/.dotfiles
git submodule deinit -f config/tmux/plugins/tmux-continuum
git submodule deinit -f config/tmux/plugins/tmux-resurrect
git submodule deinit -f config/tmux/plugins/tmux-sessionist
git submodule deinit -f config/tmux/plugins/tmux-suspend
git submodule deinit -f config/tmux/plugins/tmux-current-pane-hostname
git submodule deinit -f config/tmux/plugins/tmux-dark-notify
git submodule deinit -f config/tmux/plugins/catppuccin
```

Expected: Each prints `Cleared directory 'config/tmux/plugins/<name>'`.

- [ ] **Step 2: Remove submodules from git index and working tree**

```bash
cd /home/ivuorinen/.dotfiles
git rm -f config/tmux/plugins/tmux-continuum
git rm -f config/tmux/plugins/tmux-resurrect
git rm -f config/tmux/plugins/tmux-sessionist
git rm -f config/tmux/plugins/tmux-suspend
git rm -f config/tmux/plugins/tmux-current-pane-hostname
git rm -f config/tmux/plugins/tmux-dark-notify
git rm -f config/tmux/plugins/catppuccin
```

Expected: Each prints `rm 'config/tmux/plugins/<name>'`. The `.gitmodules` file is automatically updated (tmux entries removed).

- [ ] **Step 3: Remove cached submodule repos from .git/modules/**

```bash
cd /home/ivuorinen/.dotfiles
rm -rf .git/modules/tmux
```

The `tmux/` directory under `.git/modules/` contains all 7 cached repos (`tmux/tmux-continuum`, `tmux/catppuccin`, etc.). Removing the parent is cleanest.

- [ ] **Step 4: Remove the now-empty config/tmux/plugins/ directory**

```bash
rm -rf /home/ivuorinen/.dotfiles/config/tmux/plugins
```

- [ ] **Step 5: Verify .gitmodules only contains non-tmux submodules**

```bash
cd /home/ivuorinen/.dotfiles
cat .gitmodules
```

Expected: Only 5 entries remain — `dotbot`, `dotbot-include`, `cheat-community`, `cheat-tldr`, `antidote`. No `tmux/` entries.

---

### Task 2: Enhance add-submodules.sh

Remove the tmux submodule declarations, add them to the old_submodules cleanup array, and enhance `remove_old_submodule` to also clean `.gitmodules` entries.

**Files:**
- Modify: `add-submodules.sh:21-34` (remove tmux block)
- Modify: `add-submodules.sh:57-85` (enhance removal function)
- Modify: `add-submodules.sh:88-105` (add to old_submodules array)

- [ ] **Step 1: Remove the tmux submodule block (lines 21–34)**

Delete the entire "tmux plugin manager and plugins" section. The file should go from the `antidote` submodule add (line 18) directly to the `for MODULE` loop (line 36).

Remove this block:

```bash
# tmux plugin manager and plugins
git submodule add --name tmux/tmux-continuum \
  -f https://github.com/tmux-plugins/tmux-continuum config/tmux/plugins/tmux-continuum
git submodule add --name tmux/tmux-resurrect \
  -f https://github.com/tmux-plugins/tmux-resurrect.git config/tmux/plugins/tmux-resurrect
git submodule add --name tmux/tmux-sessionist \
  -f https://github.com/tmux-plugins/tmux-sessionist.git config/tmux/plugins/tmux-sessionist
git submodule add --name tmux/tmux-suspend \
  -f https://github.com/MunifTanjim/tmux-suspend.git config/tmux/plugins/tmux-suspend
git submodule add --name tmux/tmux-current-pane-hostname \
  -f https://github.com/soyuka/tmux-current-pane-hostname.git config/tmux/plugins/tmux-current-pane-hostname
git submodule add --name tmux/tmux-dark-notify \
  -f https://github.com/ivuorinen/tmux-dark-notify.git config/tmux/plugins/tmux-dark-notify
git submodule add --name tmux/catppuccin \
  -f https://github.com/catppuccin/tmux.git config/tmux/plugins/catppuccin
```

- [ ] **Step 2: Enhance remove_old_submodule to clean .gitmodules**

Add the following block inside `remove_old_submodule()`, after the existing `.git/modules/<name>/` removal block and before the closing `}`:

```bash
  # Remove .gitmodules entry keyed by name
  if [[ -n "$name" ]] && git config -f .gitmodules --get "submodule.$name.path" &>/dev/null; then
    git config -f .gitmodules --remove-section "submodule.$name"
    _log "Removed $name from .gitmodules"
  fi
```

- [ ] **Step 3: Add migrated tmux submodules to old_submodules array**

Add these 7 entries to the `old_submodules` array, after the existing entries:

```bash
  "tmux/tmux-continuum:config/tmux/plugins/tmux-continuum"
  "tmux/tmux-resurrect:config/tmux/plugins/tmux-resurrect"
  "tmux/tmux-sessionist:config/tmux/plugins/tmux-sessionist"
  "tmux/tmux-suspend:config/tmux/plugins/tmux-suspend"
  "tmux/tmux-current-pane-hostname:config/tmux/plugins/tmux-current-pane-hostname"
  "tmux/tmux-dark-notify:config/tmux/plugins/tmux-dark-notify"
  "tmux/catppuccin:config/tmux/plugins/catppuccin"
```

- [ ] **Step 4: Verify the script parses correctly**

```bash
bash -n /home/ivuorinen/.dotfiles/add-submodules.sh && echo "OK"
```

Expected: `OK`

---

### Task 3: Update install.conf.yaml

Add the TPM plugins directory to the `create:` section so Dotbot ensures it exists before tmux launches.

**Files:**
- Modify: `install.conf.yaml:28` (add after `~/.local/state/tmux:`)

- [ ] **Step 1: Add plugins directory to create section**

Add `~/.local/share/tmux/plugins:` to the `create:` block. Place it after the existing `~/.local/share:` entry (line 25) for logical grouping with other share directories:

```yaml
    ~/.local/share/tmux/plugins:
```

- [ ] **Step 2: Validate YAML syntax**

```bash
cd /home/ivuorinen/.dotfiles
python3 -c "import yaml; yaml.safe_load(open('install.conf.yaml'))" && echo "OK"
```

Expected: `OK`

---

### Task 4: Rewrite tmux.conf plugins section

Replace the manual `run-shell` sourcing with TPM `@plugin` declarations, auto-install snippet, and TPM runner.

**Files:**
- Modify: `config/tmux/tmux.conf:98-143`

- [ ] **Step 1: Replace the plugins section**

Replace everything from line 98 (`#  ╭─...Plugins...`) through line 143 (end of file) with:

```tmux
#  ╭──────────────────────────────────────────────────────────╮
#  │ Plugins                                                  │
#  ╰──────────────────────────────────────────────────────────╯

# ── Plugin manager path ──────────────────────────────────────────────
set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.local/share/tmux/plugins"

# ── Plugin configurations ────────────────────────────────────────────

# Plugin that lets you suspend local tmux session,
# so that you can work with nested remote tmux session painlessly.
# https://github.com/MunifTanjim/tmux-suspend
set -g @suspend_key 'F8' # Default is F12
set -g @suspend_suspended_options " \
  status-left-style::bg=brightblack\\,fg=black, \
  status-left:: ⏸ , \
"

# https://github.com/erikw/tmux-dark-notify
set -g @dark-notify-theme-path-light "$HOME/.dotfiles/config/tmux/theme-light.conf"
set -g @dark-notify-theme-path-dark "$HOME/.dotfiles/config/tmux/theme-dark.conf"

# https://github.com/tmux-plugins/tmux-continuum
set -g @continuum-restore 'on'

# ── Plugin declarations (load order matters) ─────────────────────────
# catppuccin must load before dark-notify

set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'MunifTanjim/tmux-suspend'
set -g @plugin 'tmux-plugins/tmux-sessionist'
set -g @plugin 'soyuka/tmux-current-pane-hostname'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'catppuccin/tmux'
set -g @plugin 'ivuorinen/tmux-dark-notify'

# ── Own scripts ──────────────────────────────────────────────────────

# If we started tmux with a session name, rename it.
run-shell "$HOME/.dotfiles/config/tmux/rename-session.sh"

# Load theme based on tmux-dark-notify state.
# This script helps states where dark-notify is not available,
# and we want to have light or dark state constantly available.
run-shell "$HOME/.dotfiles/config/tmux/theme-activate.sh"

# Linux (GNOME/Wayland) equivalent — uses gsettings to monitor color-scheme.
# Exits silently on non-Linux platforms.
run-shell "$HOME/.dotfiles/config/tmux/linux-dark-notify.sh"

# ── TPM bootstrap & runner ───────────────────────────────────────────
# Auto-install TPM on first launch, then run it.

if "test ! -d ~/.local/share/tmux/plugins/tpm" \
   "run 'git clone https://github.com/tmux-plugins/tpm ~/.local/share/tmux/plugins/tpm && ~/.local/share/tmux/plugins/tpm/bin/install_plugins'"

run '~/.local/share/tmux/plugins/tpm/tpm'
```

- [ ] **Step 2: Verify tmux config syntax**

```bash
tmux -f /home/ivuorinen/.dotfiles/config/tmux/tmux.conf start-server \; kill-server 2>&1 || echo "Check output for errors"
```

Expected: No errors (tmux starts and immediately stops). TPM auto-install may trigger if plugins dir is empty — that's fine.

---

### Task 5: Verify and commit

**Files:**
- All modified files from Tasks 1–4

- [ ] **Step 1: Check git status**

```bash
cd /home/ivuorinen/.dotfiles
git status
```

Expected changes:
- Modified: `.gitmodules`
- Modified: `add-submodules.sh`
- Modified: `install.conf.yaml`
- Modified: `config/tmux/tmux.conf`
- Deleted: `config/tmux/plugins/` (7 submodule directories)
- New: `docs/superpowers/specs/2026-04-06-tmux-tpm-migration-design.md`
- New: `docs/superpowers/plans/2026-04-06-tmux-tpm-migration.md`

- [ ] **Step 2: Run linter**

```bash
cd /home/ivuorinen/.dotfiles
yarn lint
```

Expected: Pass (or only pre-existing warnings).

- [ ] **Step 3: Stage and commit all changes**

```bash
cd /home/ivuorinen/.dotfiles
git add .gitmodules add-submodules.sh install.conf.yaml config/tmux/tmux.conf \
  docs/superpowers/specs/2026-04-06-tmux-tpm-migration-design.md \
  docs/superpowers/plans/2026-04-06-tmux-tpm-migration.md
git commit -m "$(cat <<'EOF'
feat(tmux): migrate plugins from git submodules to TPM (#tpm-migration)

Replace 7 git-submodule-managed tmux plugins with TPM declarations.
Plugins now install to ~/.local/share/tmux/plugins/ at runtime via
prefix+I, with automatic TPM bootstrap on first tmux launch.

- Remove tmux submodules from .gitmodules and add-submodules.sh
- Add migrated submodules to old_submodules cleanup array
- Enhance remove_old_submodule to also clean .gitmodules entries
- Pre-create plugins dir via Dotbot install.conf.yaml
- Rewrite tmux.conf plugins section with @plugin declarations
EOF
)"
```

- [ ] **Step 4: Verify commit**

```bash
cd /home/ivuorinen/.dotfiles
git log --oneline -1
git diff HEAD~1 --stat
```

Expected: Single commit with changes to 4 files + 7 submodule deletions + 2 new docs files.
