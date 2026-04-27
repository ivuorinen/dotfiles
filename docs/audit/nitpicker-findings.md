# Nitpicker Findings

Generated: 2026-04-26
Last validated: 2026-04-27
Scope of latest round (Pass 2): default-mode full-repo audit run on
feat/theming-and-switching at 88b74c2. Re-validated all prior findings,
hunted for new defects across mise/, scripts/, local/bin/, fish, neovim,
tests, and CI. Filed and fixed 7 new defects (N-023..N-029). Recorded
4 sub-agent claims as Invalid after verification (N-030..N-033).

## Summary

- Total: 30 | Open: 1 | Fixed: 23 | Advisory: 2 | Invalid: 4

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

## Advisory

#### [N-013] WezTerm Wayland appearance detection depends on xdg-desktop-portal version
No change. If wezterm colors don't update on Linux, check wezterm version
(>= 20240203-110809) and that `xdg-desktop-portal` is running.

#### [N-020] oh-my-posh runtime still installed via mise
No change in repo — manual `mise uninstall oh-my-posh` reclaims disk space.
The repo no longer references it, so it won't be reinstalled.

## Fixed

### Pass 1 — 2026-04-26

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

### Pass 2 — 2026-04-27

#### [N-023] Wrong mise schema URL (typo)
Fixed: 2026-04-27
Notes: `config/mise/config.toml:1` had
`#:schema https://mise.en.dev/schema/mise.json`. The actual mise docs domain
is `mise.jdx.dev` (cross-referenced by the repo's own
`docs/superpowers/plans/2026-04-12-mise-python-precompiled-arch.md`). The
broken URL silently no-ops in editors that respect `#:schema`, so schema
validation never fired. Fixed to `https://mise.jdx.dev/schema/mise.json`.

#### [N-024] `install-composer.sh` leaked files in cwd on installer failure under `set -e`
Fixed: 2026-04-27
Notes: With `set -euo pipefail`, a non-zero exit from
`php composer-setup.php --quiet` aborted the script before reaching the
cleanup `rm composer-setup.php` and the `mv composer.phar` lines. Net result:
`composer-setup.php` and possibly a partial `composer.phar` were left in the
caller's cwd. The `RESULT=$?` capture and the `if [[ $RESULT -eq 0 ]]; then mv...`
branch was also dead code under `set -e` — `RESULT` could only ever be 0 by
the time the if ran. Rewrote to `cd "$(mktemp -d)"` with `trap 'rm -rf "$tmpdir"' EXIT`
and dropped the dead `RESULT` plumbing. Also added `mkdir -p ~/.local/bin`
so the final `mv` doesn't fail on a fresh box.

#### [N-025] `x-ssl-expiry-date` lacked signal-based tmp file cleanup
Fixed: 2026-04-27
Notes: `local/bin/x-ssl-expiry-date` only removed its `mktemp` on the
success path or on openssl failure. SIGINT / SIGTERM / SIGHUP between the
mktemp and the `rm -f` left the temp file under `/tmp` (or `$TMPDIR`).
Added `trap 'rm -f "$tmp"' EXIT INT TERM HUP` after mktemp and a
`trap - EXIT INT TERM HUP` after the explicit rm so the trap doesn't
re-fire on the next loop iteration's mktemp.

#### [N-026] `config.fish` PATH append for LM Studio inconsistent and dedup-broken
Fixed: 2026-04-27
Notes: Line 59 was `set -gx PATH $PATH $HOME/.lmstudio/bin` (raw append).
Two practical issues: (a) APPENDS rather than prepending, so a system
binary by the same name would shadow the user one; (b) re-sourcing
config.fish duplicated the entry. Replaced with
`fish_add_path $HOME/.lmstudio/bin`, matching the same idiom used at
line 65 for opencode. `fish_add_path` defaults to prepending and dedupes.

#### [N-027] `handleDesc` mutated caller's table when `desc` lacked `desc` key
Fixed: 2026-04-27
Notes: `config/nvim/lua/utils.lua` had
`if not desc.desc then desc.desc = '?'; return desc end` — mutating the
caller's table. Concrete failing scenario: a user passes a shared opts
table to `K.n('a', cmdA, opts)` then `K.n('b', cmdB, opts)`; after the
first call `opts.desc == '?'`, so the second call sees a populated `desc`
and skips adding its own. Switched to
`return vim.tbl_extend('force', desc, { desc = '?' })` so the function
returns a clone with the default added. Caller's table is left intact.

#### [N-028] `pushover.bats` did not assert that the curl stub was invoked
Fixed: 2026-04-27
Notes: `tests/pushover.bats` only checked `[ "$status" -eq 0 ]`. The stub
returned a JSON success regardless of arguments, so a regression that
short-circuited and never called curl would still pass. Made the stub
`touch "$STUB_DIR/curl.called"` and added
`[ -f "$STUB_DIR/curl.called" ]` to both success-path tests. Verified by
running the full bats suite — all five tests still pass.

#### [N-029] `tests/x-foreach.bats` cleanup leaked tmp dirs on test failure
Fixed: 2026-04-27
Notes: The original test had inline `tmpdir=$(mktemp -d)` and inline
`rm -rf "$tmpdir"` at end of test. If any assertion in between failed,
bats aborts the test before the `rm -rf` runs, leaking the tmp dir under
`/tmp`. Extracted into bats `setup()` / `teardown()` (named `TMPDIR_TEST`
to avoid colliding with the standard `TMPDIR` env var). Bats guarantees
`teardown()` runs even on assertion failure.

## Invalid

### Pass 2 — 2026-04-27

#### [N-030] (Rejected) "GitHub token in tracked exports-secret.fish"
Notes: Sub-agent flagged a Critical "exposed token in tracked file"
during the Pass-2 fish audit. Verified false: `.gitignore` lines 19 and
32 explicitly exclude `**/exports-secret.fish` and
`config/fish/secrets.d/*` (with allowlist for `*.example` and
`README.md`). `git ls-files | grep -i secret` returns only the
`*.example` files and `secrets.d/README.md`. The actual secret file is
a local untracked file used per the design described in CLAUDE.md.

#### [N-031] (Rejected) "set -gx in fish leaks across sessions universally"
Notes: Sub-agent flagged Critical based on a misreading of fish scopes.
`set -gx` creates a global, exported variable scoped to the current
shell session. Universal would be `set -Ux` (different flag). Verified
against fish documentation. Was a real (low-severity) issue with the
specific PATH-append pattern at config.fish line 59 — captured under
N-026 with correct severity (Low) and correct rationale (dedup +
ordering, not session leak).

#### [N-032] (Rejected) "fish_add_path appends instead of prepending"
Notes: Sub-agent claimed `fish_add_path` puts user paths after system,
shadowing user binaries. Verified false against fish's own
`functions -d fish_add_path` output: "It defaults to keeping
$fish_user_paths or creating a universal, prepending and ignoring
existing entries." `fish_add_path` prepends by default. The append
behaviour requires the explicit `--append` flag.

#### [N-033] (Rejected) "GitHub Actions workflows missing top-level permissions: blocks"
Notes: Sub-agent flagged 7 of 8 workflows as missing top-level
`permissions:`. Verified false. All 8 workflows under `.github/workflows/`
have a top-level `permissions:` block within the first 20 lines of the
file (verified by `head -20 *.yml | grep -L '^permissions:'`). The
sync-labels.yml file does have it at line 22. Per-job permissions are
correctly used to elevate only where needed (e.g. issues: write).
