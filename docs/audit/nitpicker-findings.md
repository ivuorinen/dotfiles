# Nitpicker Findings

Generated: 2026-04-26
Last validated: 2026-04-26
Scope of latest round: changed-files re-audit after the 5 commits on
feat/unified-prompt-and-theme-chain (96ce5fd...452287b). Surfaced and
fixed two new defects introduced by the branch (N-021, N-022).

## Summary

- Total: 19 | Open: 1 | Fixed: 16 | Invalid: 0 | Advisory: 2

## Open Findings

### Medium

#### [N-010] No verification scenario for fish-without-tmux (wezterm direct)
Category: correctness
Area: `config/fish/conf.d/theme-switch.fish`, `config/exports`
Problem: If fish runs directly under wezterm (no tmux), the symlink at
`$XDG_STATE_HOME/tmux/tmux-dark-notify-theme.conf` may not exist or may be stale
from a prior tmux session. Fish then never updates fish syntax colours on OS
appearance change. The same gap applies to starship: the
`~/.config/starship.toml` symlink is updated by `theme-activate.sh` (one-shot
at tmux start) and by the `{linux,macos}-dark-notify.sh` daemons (continuous
only when tmux is running) — no daemon updates it without tmux.
Status: **DOCUMENTED** as a known limitation in `CLAUDE.md` (the prompt
section now explicitly states the chain requires tmux). A future-work item
would be a no-tmux daemon spawned from the shell rc when `[ -z "$TMUX" ]`,
querying OSC 11 directly. Not implemented this round because the user's
primary workflow is always tmux+fish; the documentation is the appropriate
fix until that workflow changes.
Fix (deferred): standalone OSC 11 polling daemon spawned from `config/exports`
when no tmux session is detected and no other daemon owns the lock. Would
update both `~/.config/starship.toml` and the tmux state symlink so a later
tmux launch finds the right state.

## Fixed

#### [N-021] `_idempotent_ln_sf` clobbered regular files at the destination
Fixed: 2026-04-26
Notes: Added a guard to `_idempotent_ln_sf` in `config/tmux/_apply-theme.sh`:
if the destination is a regular file (not a symlink), the helper returns
early instead of replacing it with `ln -sf`. Reproduced before fix: a
hand-rolled `~/.config/starship.toml` with custom content was silently
destroyed on the next theme flip. Reproduced after fix: the regular file
is preserved across daemon invocations; a working symlink is still
left alone (mtime unchanged); a broken symlink is still repaired.

#### [N-022] Dangling `@` separator when username shows but hostname doesn't
Fixed: 2026-04-26
Notes: Username had `format = "[$user]($style)[@](subtext0)"` which
emitted `user@` even when the hostname module was suppressed (running
as root locally with no SSH). Moved the `@` separator into the hostname
format: `format = "[@](subtext0)[$hostname]($style) "`. Now the `@`
only renders when the hostname does. Username keeps just `[$user]($style)`.
Applied to both starship-dark.toml and starship-light.toml.

#### [N-001] macOS has no continuous appearance watcher
Fixed: 2026-04-26
Notes: Created `config/tmux/macos-dark-notify.sh` polling
`defaults read -g AppleInterfaceStyle` every 2s in a daemon mirroring
`linux-dark-notify.sh`'s lifecycle (per-tmux-socket lock file, nohup
backgrounding, SIGTERM/SIGINT/SIGHUP cleanup). Wired in `tmux.conf` after
`linux-dark-notify.sh`. Both daemons exit silently on non-matching platforms.
Theme-resolution and symlink-update logic extracted into
`config/tmux/_apply-theme.sh` (sourced library) so both daemons share
behaviour with `theme-activate.sh`. Toggling System Settings → Appearance on
macOS now flips wezterm + tmux + starship within ~2s of detection.

#### [N-002] Bash had no light/dark theme reaction
Fixed: 2026-04-26
Notes: Replaced hardcoded ANSI `PS1` in `base/bashrc` with `eval "$(starship init bash)"`.

#### [N-003] Zsh had no light/dark theme reaction
Fixed: 2026-04-26
Notes: Replaced p10k sourcing in `base/zshrc` with starship init. Removed
`romkatv/powerlevel10k` from antidote plugins and deleted `config/zsh/p10k.zsh`.

#### [N-004] `set -o errexit` in dark-notify daemon could be killed by transient `tmux source-file` failure
Fixed: 2026-04-26
Notes: `apply_theme` (now in `config/tmux/_apply-theme.sh`) wraps
`tmux source-file "$theme_path" 2>/dev/null || true` so a transient tmux
server failure no longer terminates the daemon. The inner `read` loop in
`linux-dark-notify.sh` and `macos-dark-notify.sh` also wraps the
`apply_theme` call with `|| true`. Removed `set -o errexit` from the daemon
top-levels (the original reason for the wrap is now belt-and-braces).

#### [N-005] oh-my-posh half-wired
Fixed: 2026-04-26
Notes: Removed omp wiring from `config/exports`, `config/mise/config.toml`,
and deleted `config/omp/`.

#### [N-006] Fish handler swallowed first symlink-creation event
Fixed: 2026-04-26
Notes: Removed the `__theme_switch_initialized` guard from
`config/fish/conf.d/theme-switch.fish`. The handler now always re-saves on
the first observed symlink target, eliminating the fish-then-tmux ordering
edge case. Cost is one extra `fish_config theme save` fork per fish session
— negligible.

#### [N-007] `theme-activate.sh` and dark-notify daemons raced on first tmux launch
Fixed: 2026-04-26
Notes: Both `linux-dark-notify.sh` and `macos-dark-notify.sh` now check
`[[ ! -L "$THEME_LINK" ]]` before their initial `apply_theme`. If
`theme-activate.sh` already ran during config load, the symlink exists and
the daemon skips its redundant initial apply.

#### [N-008] `ivuorinen/tmux-dark-notify` plugin declared but not installed
Fixed: 2026-04-26
Notes: Removed `set -g @plugin 'ivuorinen/tmux-dark-notify'` and the
`@dark-notify-theme-path-{light,dark}` options from `config/tmux/tmux.conf`.
Theme paths are hardcoded in the new `_apply-theme.sh` library. Daemon
ownership is now unambiguous: dotfiles own the chain end-to-end via the
two daemons + library.

#### [N-009] `theme-activate.sh` rewrote symlinks unconditionally
Fixed: 2026-04-26
Notes: `_apply-theme.sh` provides `_idempotent_ln_sf` which only calls
`ln(1)` when `readlink` shows the target actually changed. Both the tmux
state symlink and the starship symlink go through this helper. `prefix+r`
no longer churns symlink mtimes.

#### [N-011] `set -Ugq` flag in theme-{light,dark}.conf required tmux ≥ 3.4
Fixed: 2026-04-26
Notes: Added inline comment in both `config/tmux/theme-{light,dark}.conf`
documenting the tmux ≥ 3.4 requirement and what happens on older tmux
(parser silently ignores `-U`, leaving stale colors).

#### [N-012] Misleading "Setting up oh-my-posh configuration" log
Fixed: 2026-04-26
Notes: Subsumed by N-005.

#### [N-014] Starship bootstrap created broken symlinks on fresh installs
Fixed: 2026-04-26
Notes: `config/exports` bootstrap now (a) requires `[ -f "$default" ]` before
linking, so it never creates a brand-new broken symlink; and (b) detects an
existing broken symlink (`[ -L ] && [ ! -e ]`) and repairs it. Verified
end-to-end: missing source → bootstrap skips; source then created → bootstrap
links; source removed → broken symlink → bootstrap repairs on next shell start.

#### [N-016] Dead `autoload -U promptinit; promptinit` in `base/zshrc`
Fixed: 2026-04-26
Notes: Removed line 7. zsh's promptinit framework is unused; starship owns
the prompt entirely.

#### [N-017] Orphan `oh-my-posh.png` in `.github/screenshots/`
Fixed: 2026-04-26
Notes: `git rm .github/screenshots/oh-my-posh.png`. README reference was
already removed in the previous round.

#### [N-018] Starship dark/light TOMLs duplicated module config
Fixed: 2026-04-26
Notes: Strengthened the maintainer-note header in both
`config/starship/starship-{dark,light}.toml` so future editors see the
sync-required convention immediately. A generator script was deferred —
the divergence risk is intentionally cosmetic and the comment is sufficient
for a config-file pair this small.

## Advisory

#### [N-013] WezTerm Wayland appearance detection depends on xdg-desktop-portal version
No change. If wezterm colors don't update on Linux, check wezterm version
(>= 20240203-110809) and that `xdg-desktop-portal` is running.

#### [N-020] oh-my-posh runtime still installed via mise
No change in repo — manual `mise uninstall oh-my-posh` reclaims disk space.
The repo no longer references it, so it won't be reinstalled.

## Invalid

(none)
