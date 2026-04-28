# Theme Orchestrator — Design

Date: 2026-04-27
Branch: feat/theming-and-switching → planned follow-up
Status: design approved, awaiting implementation plan

## Context

The dotfiles already flip tmux, starship, and fish syntax colours when
the OS appearance changes. The chain has three problems that this spec
addresses:

1. **It is tmux-coupled.** Both watcher daemons
   (`config/tmux/linux-dark-notify.sh`,
   `config/tmux/macos-dark-notify.sh`) are spawned by tmux's
   `run-shell`. A fish shell running directly under wezterm without
   tmux gets no live updates. Documented as N-010 in
   `docs/audit/nitpicker-findings.md`.
2. **It does not generalise.** Theme-flip logic for tmux and starship
   is hard-coded inside `_apply-theme.sh`. Adding another app means
   editing the library. Concretely, DIRCOLORS / `LS_COLORS` is not
   updated on flip today, so `ls` colours stay frozen at whatever the
   shell sourced at login.
3. **No "what mode is it?" API.** Other scripts cannot ask the system
   for the current dark/light state without re-implementing the
   detection logic.

Goal: a single orchestrator that owns OS detection, the dark/light
state, and the per-app flip logic — extensible to future apps via a
drop-in directory and queryable from any script.

## Architectural decisions

The five clarifying decisions reached during brainstorming:

1. **OS sources stay primary.** Existing event-driven watchers
   (`defaults read AppleInterfaceStyle` on macOS;
   xdg-desktop-portal / gsettings on Linux) keep their role. They
   are instant. OSC 11 against the terminal is a *fallback* used at
   shell startup, in SSH sessions where the local OS is the right
   oracle, and on systems without a portal/gsettings.
2. **V1 scope is minimal.** tmux + starship + fish syntax + DIRCOLORS.
   The architectural risk lives in the actor + handler interface, not
   in the count of handlers. Future apps (alacritty, eza, bat, lazygit,
   delta, gitui) drop in later as new files in `handlers.d/`.
3. **Read API is `theme-mode` plus zero-fork shell functions.**
   `local/bin/theme-mode` for any-shell scripts. `theme-mode` fish
   function and `theme_mode` bash/zsh function for hot paths (prompt,
   tight loops) that should not fork.
4. **Handlers are standalone executables.** Each handler is its own
   `handlers.d/<name>` script, called as `handlers.d/<name> <mode>`.
   The actor forks each one. Isolation is the win: a future handler
   crashing or hanging cannot take down the chain. Fork cost (~4 forks
   on a flip) is negligible at flip frequency.
5. **Daemon is shell-spawned, watcher self-locks.** Interactive shells
   blindly fork+disown `config/theme/watcher`. The **watcher itself**
   takes the PID lock at `$XDG_STATE_HOME/dotfiles-theme/daemon.pid`
   on startup; redundant launches detect a live PID via `kill -0` and
   exit 1 silently. This avoids duplicating lock logic across bash,
   zsh, and fish init paths (fish cannot source bash helpers).
   Stale PIDs (process is gone) are reclaimed. SSH sessions are
   detected via `$SSH_TTY` / `$SSH_CONNECTION` and **do not** fork a
   watcher — they rely on per-session OSC 11 via shell-init `apply
   $(theme-mode)`, because a remote watcher would detect the remote
   OS appearance, which is the wrong oracle for the user's local
   terminal. Daemon lifetime: lives until the host reboots or the
   user explicitly `kill`s it; on macOS launchd reaps at logout, on
   Linux without systemd-logind it orphans to PID 1 (acceptable —
   one cheap watcher per host is fine). Pattern is the same the
   existing tmux daemons use, relocated to shell init so
   fish-without-tmux works (N-010 fix).

## Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│  watcher  (per-OS daemon, shell-spawned, self-locking)               │
│  • Linux: prefers xdg-desktop-portal subscription, falls back to     │
│    `gsettings monitor`; exits if neither is reachable                │
│  • macOS: defaults-read polling at 2s                                │
│  • Self-locks at $XDG_STATE_HOME/dotfiles-theme/daemon.pid; second   │
│    instance exits 1 silently                                         │
│  • Skipped entirely in SSH sessions ($SSH_TTY / $SSH_CONNECTION set) │
│  • Fallback for non-watcher contexts: probe-osc11 via shell-init     │
│    bootstrap — used in SSH and on no-OS-source boxes                 │
│  • On change → calls actor with new mode                             │
└────────────────────────────────┬─────────────────────────────────────┘
                                 │ "dark" | "light"
┌────────────────────────────────▼─────────────────────────────────────┐
│  actor  (config/theme/apply)                                         │
│  • Atomic write of mode to $XDG_STATE_HOME/dotfiles-theme/mode       │
│  • Forks each handlers.d/<name> with $1=mode, in parallel            │
│  • 5s timeout per handler; non-zero exit logged, never fatal         │
│  • Idempotent: skip if mode unchanged from current state file        │
└────────────────────────────────┬─────────────────────────────────────┘
                                 │ exec handlers.d/<name> dark|light
┌────────────────────────────────▼─────────────────────────────────────┐
│  handlers (one executable per app)                                   │
│  • handlers.d/tmux       — sources tmux palette, swaps state symlink │
│  • handlers.d/starship   — swaps ~/.config/starship.toml             │
│  • handlers.d/fish       — fish_config theme save (persistent state) │
│  • handlers.d/dircolors  — regenerates LS_COLORS cache               │
│  • each script self-contained; sources config/theme/_lib.sh          │
└──────────────────────────────────────────────────────────────────────┘

           │
           │ Read-side (separate concern):
           ▼
┌──────────────────────────────────────────────────────────────────────┐
│  read API                                                            │
│  • theme-mode (local/bin) — any-shell read API                       │
│  • theme_mode (bash function in config/shared.sh) — zero-fork        │
│  • theme-mode (fish function) — zero-fork                            │
└──────────────────────────────────────────────────────────────────────┘
```

### Invariants

- The mode state file is the only canonical source of truth. The
  **actor** writes (atomically); everything else reads. The watcher
  is one of two callers of the actor; shell-init bootstrap is the
  other.
- Handlers are isolated processes; one crashing does not affect the
  chain.
- Tmux becomes just-another-handler; the existing `_apply-theme.sh`
  library is replaced by `_lib.sh` + the four handlers.
- The watcher self-locks at startup; shells fork it blindly. SSH
  sessions skip the watcher fork entirely.
- N-010 is fixed because the watcher spawn is shell-init-based, not
  tmux-init-based.

## Components and layout

```
config/theme/
├── apply                       # actor
├── watcher                     # daemon
├── probe-osc11                 # OSC 11 fallback (one-shot)
├── _lib.sh                     # shared helpers
├── handlers.d/                 # one executable per app
│   ├── tmux
│   ├── starship
│   ├── fish
│   └── dircolors
└── palettes.d/                 # one file per (app, variant) pair
    ├── tmux.dark.conf          # ← was config/tmux/theme-dark.conf
    ├── tmux.light.conf         # ← was config/tmux/theme-light.conf
    ├── starship.dark.toml      # ← was config/starship/starship-dark.toml
    ├── starship.light.toml     # ← was config/starship/starship-light.toml
    ├── dircolors.dark          # new
    └── dircolors.light         # new
```

### Naming convention for `palettes.d/`

- `[app].[variant].[ext]` — variant is `dark` or `light` for V1.
- Files with no native extension (dircolors) drop the `.ext` →
  `dircolors.dark`.
- Future apps with their own pre-existing names get renamed for
  consistency: alacritty's `theme-day.toml` / `theme-night.toml`
  become `alacritty.light.toml` / `alacritty.dark.toml` when that
  handler is added.
- Two handler shapes coexist: **file-swap handlers** (tmux,
  starship, dircolors) read from `palettes.d/`; **stateful-command
  handlers** (fish_config) do not. The convention is "if the handler
  reads a file, the file lives in `palettes.d/`."

### New files

| Path                                                                                                                                                               | Role                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `config/theme/apply`                                                                                                                                               | The actor. Validates mode, atomic-writes state file, forks each `handlers.d/*` in parallel under a 5s timeout, logs failures, never aborts. Honours `THEME_HANDLERS_DIR` and `XDG_STATE_HOME` env vars (test seam).                                                                                                                                                                                                                                                                                                                                                                  |
| `config/theme/watcher`                                                                                                                                             | OS-aware daemon. **Linux**: prefers xdg-desktop-portal `org.freedesktop.appearance color-scheme` subscription; falls back to `gsettings monitor org.gnome.desktop.interface color-scheme` if portal is unavailable; logs and exits 0 if neither is reachable. **macOS**: polls `defaults read -g AppleInterfaceStyle` at 2s. **Self-locks** at startup via `_acquire_lock` against `$XDG_STATE_HOME/dotfiles-theme/daemon.pid`; if another live instance holds the lock, exits 1 silently. Calls `apply` on each detected change. Honours `--source linux\|macos\|stub` (test seam). |
| `config/theme/probe-osc11`                                                                                                                                         | One-shot OSC 11 query against `/dev/tty`. Prints `dark` / `light` / empty. Used at shell startup as bootstrap and in SSH where OS sources do not apply. Honours `--input <path>` and `--timeout <seconds>` (test seams).                                                                                                                                                                                                                                                                                                                                                             |
| `config/theme/_lib.sh`                                                                                                                                             | Shared helpers: `_idempotent_ln_sf`, `_atomic_write`, `_acquire_lock`, `_log`. Carries over `_idempotent_ln_sf` from the existing `_apply-theme.sh` (incl. the N-021 file-vs-symlink guard).                                                                                                                                                                                                                                                                                                                                                                                         |
| `config/theme/handlers.d/tmux`                                                                                                                                     | `tmux source-file palettes.d/tmux.<mode>.conf` (errexit-masked) plus state-symlink swap for the fish handler chain.                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `config/theme/handlers.d/starship`                                                                                                                                 | Swap `~/.config/starship.toml` → `palettes.d/starship.<mode>.toml` via `_idempotent_ln_sf`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| `config/theme/handlers.d/fish`                                                                                                                                     | `fish -c 'fish_config theme save "Catppuccin Mocha\|Latte"'` to persist colours for future fish sessions. Running fish sessions re-trigger via in-process event handler.                                                                                                                                                                                                                                                                                                                                                                                                             |
| `config/theme/handlers.d/dircolors`                                                                                                                                | `dircolors palettes.d/dircolors.<mode>` → atomic-write to `$XDG_STATE_HOME/dotfiles-theme/ls-colors`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
| `config/theme/palettes.d/dircolors.dark`                                                                                                                           | New. Vendored from `bliss-dircolors` upstream: <https://raw.githubusercontent.com/joshjon/bliss-dircolors/refs/heads/master/bliss.dircolors>. Implementation plan fetches and commits the file as-is, keeping a `# Source:` header for upstream traceability. License: check upstream LICENSE before vendoring (likely MIT).                                                                                                                                                                                                                                                         |
| `config/theme/palettes.d/dircolors.light`                                                                                                                          | New. Derived from `dircolors.dark` by remapping the dark-on-dark entries (codes mapping 38;5;0..7) to lighter equivalents that stay legible on a light background. Concrete tuning is an implementation-plan step (test against a side-by-side `ls -la` before/after on a light terminal).                                                                                                                                                                                                                                                                                           |
| `local/bin/theme-mode`                                                                                                                                             | Public read API. Reads the state file; if missing **and stdin is a TTY**, calls `probe-osc11`; if missing **and no TTY** (cron, CI, non-interactive script), skips OSC 11 and prints `dark` directly. Always exits 0.                                                                                                                                                                                                                                                                                                                                                                |
| `config/fish/functions/theme-mode.fish`                                                                                                                            | Zero-fork fish function with the same contract.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
| `tests/theme-actor.bats`, `tests/theme-mode.bats`, `tests/theme-probe-osc11.bats`, `tests/theme-handlers.bats`, `tests/theme-lib.bats`, `tests/theme-watcher.bats` | Coverage (see Testing).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |

### Modified files

| Path                                   | Change                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
|----------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `config/exports`                       | Add `theme_mode` bash function (POSIX-portable so zsh's `source` of exports also picks it up; bash and zsh both source this file). Replace the starship-bootstrap block (current ~lines 440–453) with a one-time `apply $(theme-mode)` call. Add `eval "$(< $XDG_STATE_HOME/dotfiles-theme/ls-colors 2>/dev/null)"` so `LS_COLORS` is sourced at shell start. **Spawn the watcher unconditionally** (`config/theme/watcher &`, then `disown`); the watcher self-locks. Skip the spawn if `${SSH_TTY-}${SSH_CONNECTION-}` is non-empty (SSH session). |
| `config/fish/conf.d/theme-switch.fish` | Watch `$XDG_STATE_HOME/dotfiles-theme/mode` instead of `tmux-dark-notify-theme.conf`. Logic otherwise unchanged. Source `…/ls-colors` for fish's own `LS_COLORS` reload.                                                                                                                                                                                                                                                                                                                                                                             |
| `config/fish/config.fish`              | Spawn watcher unconditionally (`config/theme/watcher &; disown`); the watcher self-locks. Skip the spawn if `$SSH_TTY` or `$SSH_CONNECTION` is set. No bash helper needed — fish only forks the executable.                                                                                                                                                                                                                                                                                                                                          |
| `config/tmux/tmux.conf`                | Remove `run-shell` lines that spawn `linux-dark-notify.sh` / `macos-dark-notify.sh`. Tmux config-load now just calls `apply $(theme-mode)` once.                                                                                                                                                                                                                                                                                                                                                                                                     |
| `install.conf.yaml`                    | New link: `~/.config/theme` → `config/theme`. Handlers + actor live under a stable XDG path so the watcher can find them by absolute path independent of `$DOTFILES`.                                                                                                                                                                                                                                                                                                                                                                                |

### Replaced (deleted)

- `config/tmux/_apply-theme.sh` → split into `config/theme/_lib.sh` plus the four handlers.
- `config/tmux/linux-dark-notify.sh` → folded into `config/theme/watcher`.
- `config/tmux/macos-dark-notify.sh` → folded into `config/theme/watcher`.
- `config/tmux/theme-activate.sh` → no longer needed (shell init does the bootstrap).
- `config/starship/` directory — empty after palette move; deleted.
- `config/dircolors` — superseded by `palettes.d/dircolors.{dark,light}`.

### State files (under `$XDG_STATE_HOME/dotfiles-theme/`)

- `mode` — `dark` or `light` plus a trailing newline. Atomically written by `apply`.
- `daemon.pid` — PID of the live watcher; staleness detected via `kill -0`.
- `ls-colors` — output of `dircolors palettes.d/dircolors.<mode>`. Sourced by shells.
- `log` — append-only audit log; tail-rotated to last 200 lines.

## Data flow

### A. Cold start (first interactive shell, no daemon yet)

```
shell rc (bash/zsh exports OR fish config.fish)
  ├─ if not in SSH session ($SSH_TTY/$SSH_CONNECTION unset):
  │    fork+disown config/theme/watcher  (watcher self-locks at startup;
  │                                       redundant launches exit 1 silently)
  ├─ apply "$(theme-mode)"
  │    theme-mode: read state file → empty → probe-osc11 → "dark"
  │    apply: atomic-write mode file, fork handlers.d/* in parallel
  │        ├─ tmux:      tmux source-file palettes.d/tmux.dark.conf || true
  │        ├─ starship:  swap ~/.config/starship.toml → palettes.d/starship.dark.toml
  │        ├─ fish:      fish -c 'fish_config theme save "Catppuccin Mocha"'
  │        └─ dircolors: dircolors palettes.d/dircolors.dark > $cache/ls-colors
  └─ eval "$(< $cache/ls-colors)"  # shell picks up colours for itself
```

### B. OS appearance toggle (the live happy path)

```
User flips System Settings → Dark Mode
  ├─ watcher (already running)
  │     Linux:  portal subscription fires (gsettings monitor if portal absent)
  │     macOS:  next 2s defaults-read tick detects "Light"
  ├─ watcher calls: config/theme/apply light
  │     atomic-write mode, fork handlers in parallel (~250ms total)
  ├─ each running fish: conf.d/theme-switch.fish event handler fires
  │     on mode-file change:
  │       - fish_config theme save "Catppuccin Latte"  (in-process recolour)
  │       - eval "$(< $cache/ls-colors)"               (LS_COLORS reload)
  └─ each running bash/zsh: PROMPT_COMMAND polls mode-mtime once per
        prompt; on change, eval the ls-colors cache. Cheap (one stat
        + one file-read on flip-detect, otherwise just one stat).
```

### C. SSH session boots remote shell

```
ssh remote
  ├─ remote shell rc loads
  │    detects $SSH_TTY / $SSH_CONNECTION → skips watcher fork entirely
  │    (a remote watcher would detect REMOTE OS appearance, which is
  │    the wrong oracle — your local terminal is the truth here).
  └─ apply "$(theme-mode)"
       theme-mode: read state file → empty (fresh box) → probe-osc11
                   probe-osc11 queries the SSH-tunnelled terminal — your
                   local WezTerm answers via the same channel → correct mode.
       handlers run; remote session colour-matches your *local* OS.
       No live updates: when you flip mode locally, you'll need to
       re-prompt or re-run apply on the remote (the next OSC 11 query
       sees the new state). Acceptable trade-off; SSH sessions are
       transient.
```

### D. Handler crashes mid-apply

```
apply light
  ├─ fork handlers.d/* in parallel under timeout 5s; collect PIDs
  ├─ wait on each; collect exit codes
  ├─ for any non-zero or 124 (timeout): _log handler-name + exit code
  └─ apply itself returns 0; one bad handler does not roll back the
     mode file, does not skip the other handlers, does not crash the
     watcher.
```

## Error handling

### Atomic / race-safe primitives in `_lib.sh`

| Helper                       | Behaviour                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
|------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `_atomic_write FILE CONTENT` | `mktemp` in same dir → write → `mv` (atomic on same filesystem). Used for `mode` and `ls-colors`.                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `_idempotent_ln_sf SRC DST`  | Carry-over from N-021. Refuses to overwrite a regular file at DST; only re-`ln(1)`s when the target actually differs.                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| `_acquire_lock PIDFILE`      | Check `kill -0` against any existing PID; if alive → return 1; if dead → unlink stale PID; then `ln(1)` a temp file to PIDFILE (atomic create-if-not-exists; fails if a sibling shell raced and won).                                                                                                                                                                                                                                                                                                                                                              |
| `_log MSG`                   | Append to `$XDG_STATE_HOME/dotfiles-theme/log`. **Single-writer discipline**: only `apply` and `watcher` call `_log` directly; handlers print to stderr and `apply` captures and labels each line before writing. This avoids the read-modify-write race that a tail-based rotation would have under concurrent writers. **Rotation**: when log size exceeds 200 lines (checked at the start of `_log`), atomically replace with `tail -n 200` via mktemp + mv. Concurrent `_log` calls cannot race because both originate from the same `apply` process serially. |

### Failure-mode catalogue

| #  | Scenario                                                  | Behaviour                                                                                                                                                                                                                                                    |
|----|-----------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1  | Watcher dies (crash, OOM, kill)                           | PID file orphans. Next interactive shell start sees stale PID (`kill -0` fails), unlinks it, respawns. Lost in-between flips are caught by the next-shell bootstrap (`apply $(theme-mode)`).                                                                 |
| 2  | Two shells race the lock                                  | `_acquire_lock` is `ln(1)`-based; only one creates the PID file. The loser silently skips the spawn.                                                                                                                                                         |
| 3  | A handler exits non-zero                                  | Logged with handler name + exit code. Other handlers run unaffected. The mode file is **not** rolled back — partial flip is better than no flip.                                                                                                             |
| 4  | A handler hangs                                           | `apply` runs each as `timeout 5s handlers.d/<name> $mode`. Exit 124 → logged as "stuck", killed.                                                                                                                                                             |
| 5  | Linux without portal *and* without gsettings              | watcher logs the gap, exits 0. Theme defaults to whatever `probe-osc11` returns at shell init; no live updates. Documented degradation, not a crash.                                                                                                         |
| 5b | Inside SSH session (any OS)                               | Shell init detects `$SSH_TTY` / `$SSH_CONNECTION`, skips watcher spawn entirely. Mode is established once via `apply $(theme-mode)` → `probe-osc11` against the local terminal. No live updates from the remote OS (which would be the wrong oracle anyway). |
| 6  | OSC 11 times out                                          | `probe-osc11` runs with `read -t 0.2` by default (tunable via `--timeout`; slow/remote terminals may need higher). On timeout, prints nothing and exits 0. `theme-mode` falls through to last-known state file → if also empty → defaults to `dark`.         |
| 6b | `theme-mode` called without a TTY                         | If state file is missing AND stdin is not a terminal (`[ -t 0 ]` is false), skip `probe-osc11` and print `dark` immediately. Cron jobs, CI scripts, and non-interactive subshells get a deterministic answer instead of blocking on `/dev/tty`.              |
| 7  | `apply` called with invalid mode                          | Rejected with `"apply: unknown mode 'X'; expected dark\|light"` to stderr; exit 2; mode file untouched.                                                                                                                                                      |
| 8  | Palette file missing for the requested mode               | Per-handler concern. Each handler `[ -r "$palette" ] \|\| { _log "missing $palette"; exit 1; }`. The actor logs and continues with other handlers.                                                                                                           |
| 9  | `dircolors` binary missing on a stripped Linux            | Handler logs and exits 1. The cache file keeps its last good content. Shells using `eval "$(< $cache/ls-colors)"` keep their previous colours.                                                                                                               |
| 10 | tmux server not running when tmux handler runs            | `tmux source-file ... 2>/dev/null \|\| true` — the file is still good for the next tmux launch.                                                                                                                                                              |
| 11 | Concurrent `apply` (shell bootstrap + watcher first tick) | Last `_atomic_write` wins for the mode file. Handlers are idempotent. Harmless redundancy.                                                                                                                                                                   |
| 12 | fish event handler fires in non-interactive fish          | Existing guard `status is-interactive; or return` — already in the codebase, kept.                                                                                                                                                                           |

### Out of scope for V1

- **Restoring previous state on partial flip failure.** Would require remembering which handlers succeeded mid-apply, doubling moving parts. The user can just re-toggle.
- **Liveness probe / `theme-doctor` command.** Diagnose via `cat $XDG_STATE_HOME/dotfiles-theme/log`; add a doctor command later once we have field reports.

### Logging discipline

- Single file: `$XDG_STATE_HOME/dotfiles-theme/log`.
- Format: `ISO8601 LEVEL component message`.
- Rotation: trim to last 200 lines after each write.
- Levels: INFO for mode transitions, WARN for handler non-zero, ERROR for actor itself failing. No DEBUG.

## Testing

### Harness

bats, same as the existing `tests/` suite. New files:

| File                           | Covers                                                                                                                    |
|--------------------------------|---------------------------------------------------------------------------------------------------------------------------|
| `tests/theme-actor.bats`       | `apply` mode validation, atomic mode write, parallel handler dispatch, isolation on handler crash, 5s timeout enforcement |
| `tests/theme-mode.bats`        | read API (state file present → probe-osc11 fallback → default `dark`)                                                     |
| `tests/theme-probe-osc11.bats` | OSC 11 timeout, hex luminance threshold (e.g., `#1e1e2e` → dark, `#eff1f5` → light)                                       |
| `tests/theme-handlers.bats`    | per-handler smoke tests against fixture palette files                                                                     |
| `tests/theme-lib.bats`         | `_atomic_write`, `_idempotent_ln_sf` (carries the N-021 file-vs-symlink scenario), `_acquire_lock` race                   |
| `tests/theme-watcher.bats`     | PID-lock honoured, SIGTERM cleanup, debounce                                                                              |

### Mocking strategy

- **OS sources.** Stub `defaults`, `gsettings`, `busctl` via `PATH` prefix to a `mktemp -d`, return canned outputs. Same trick `tests/pushover.bats` already uses for the curl stub.
- **OSC 11.** `probe-osc11` accepts `--input <file>`; production path reads `/dev/tty`, tests pass a fixture file containing a synthesised terminal reply (`\033]11;rgb:1e/1e/2e\007`).
- **State paths.** Every test sets `XDG_STATE_HOME=$(mktemp -d)` in `setup()` and removes it in `teardown()` (per the N-029 fix, never inline cleanup).
- **Handler dir override.** `apply` reads `THEME_HANDLERS_DIR`, defaulting to `$DOTFILES/config/theme/handlers.d`. Tests point it at a fixture dir with three handlers: `pass-fast`, `fail-on-purpose`, `hang-forever`.

### Test seams in production code

These exist purely so tests don't need root, a desktop, or a terminal. Documented in each script's header so they don't look like accidental escape hatches.

- `apply` honours `THEME_HANDLERS_DIR` and `XDG_STATE_HOME`.
- `probe-osc11` honours `--input <path>` and `--timeout <seconds>`.
- `watcher` honours `--source linux|macos|stub` (the `stub` source reads detected modes from a file the test writes to, simulating an event stream).

### CI integration

- `yarn test` already invokes `bats tests/*.bats`. New files are picked up automatically.
- Pre-commit hooks (shellcheck, shfmt, fish_syntax, fish_indent) cover style and obvious shell errors.
- No new GitHub Actions workflow needed.

### Manual / out-of-scope verifications

These can't reasonably go in CI; documented as a one-time verification ritual:

1. Flip macOS System Settings → Appearance, confirm tmux + starship + dircolors-derived `ls` colours flip within ~2s of detection.
2. Same on Linux with the GNOME Settings → Appearance toggle.
3. SSH from local WezTerm to a remote box without a running daemon, open a fish shell, confirm prompt colours match the local OS. Tests OSC 11 fallback path end-to-end.
4. Kill the watcher (`kill $(cat $XDG_STATE_HOME/dotfiles-theme/daemon.pid)`); spawn a new shell; confirm the new shell respawns the watcher and bootstraps mode correctly.

### Explicit non-coverage

- WezTerm's actual OSC 11 response (would require a real terminal). Stubbed.
- Visual correctness of the dark vs light palettes. Subjective; a future light-mode review pass against actual usage.
- Behaviour on terminals that don't speak OSC 11 (rxvt, plain `xterm` without colour). Documented as "if `probe-osc11` returns nothing, you get the last cached mode or `dark`."

## Migration / rollout

This branch will:

1. Land the new `config/theme/` tree with all components and handlers.
2. Move palette files into `config/theme/palettes.d/` with the new naming.
3. Rip out the old `_apply-theme.sh`, `linux-dark-notify.sh`, `macos-dark-notify.sh`, `theme-activate.sh`, and tmux's `run-shell` daemon spawns.
4. Update `config/exports`, `config/fish/config.fish`,
   `config/fish/conf.d/theme-switch.fish`, `config/tmux/tmux.conf`,
   and `install.conf.yaml`.
5. Update `CLAUDE.md`'s "Shell Configuration Chain" section to describe the new orchestrator and remove the "the chain requires tmux" limitation.
6. Update `docs/audit/nitpicker-findings.md` to mark N-010 as Fixed (Pass 3) once verified manually on macOS + Linux + SSH.

A single PR. No feature flag — the theme chain is internal-only and the rollout is atomic to the user's machines.

## Open questions deferred to implementation plan

- Exact `dircolors.light` palette tuning. Start from the vendored `bliss.dircolors`; remap the dark-on-dark entries (codes targeting indices 0..7 on a dark background) to lighter equivalents legible on a light terminal. Verify with side-by-side `ls -la` against representative file types before committing.
- License-compatibility check against bliss-dircolors upstream before vendoring (likely MIT; confirm in plan).
- Whether to ship a tiny `theme-doctor` command in V1 or wait for field reports (currently leaning wait).
- Whether `dotbot` should also link `config/theme/handlers.d/` and `config/theme/palettes.d/` individually, or just link the parent `config/theme/` once. Linking once is simpler; revisit if it causes issues with host-specific overrides under `hosts/<hostname>/config/theme/`.

## Appendix — relationship to existing nitpicker findings

- **N-010 (Open, Medium)**: fixed by this design. The watcher is no longer tmux-coupled; fish-without-tmux gets live updates via the shell-spawned daemon.
- **N-021 (Fixed)**: the file-vs-symlink guard in `_idempotent_ln_sf` is preserved verbatim in the new `_lib.sh`.
- **N-009 (Fixed)**: the idempotent symlink helper is preserved.
- **N-007 (Fixed)**: the prior daemon-vs-`theme-activate` race no longer applies. There are still two callers of `apply` (shell-init bootstrap and watcher detection), but both go through the same atomic-write + idempotent-handlers path; the prior race relied on two diverging code paths racing to apply state, which is removed.
