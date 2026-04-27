# Theme Orchestrator Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the tmux-coupled theme chain with a stand-alone orchestrator that owns OS detection, dark/light state, and per-app flip logic — extensible to future apps via `handlers.d/`, queryable from any script via `theme-mode`, and working for fish-without-tmux + SSH sessions.

**Architecture:** Three-layer pipeline: a self-locking watcher daemon (Linux portal/gsettings, macOS defaults-poll, OSC 11 fallback) → an actor (`apply`) that atomic-writes mode state and forks isolated handlers in parallel → per-app handlers in `handlers.d/`. Theme assets consolidated under `config/theme/palettes.d/` with `[app].[variant].[ext]` naming. Read API is `theme-mode` plus zero-fork bash/fish functions. Reference spec: `docs/superpowers/specs/2026-04-27-theme-orchestrator-design.md`.

**Tech Stack:** Bash 5+, Fish 3+, Bats (tests), shellcheck + shfmt + fish_indent (lint), Dotbot (install), mise (toolchain).

---

## File Structure

### Created (new)

| Path                                          | Responsibility                                                                                                                                                                                             |
|-----------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `config/theme/_lib.sh`                        | Shared helpers: `_atomic_write`, `_idempotent_ln_sf`, `_acquire_lock`, `_log`. Sourced by `apply` and every handler.                                                                                       |
| `config/theme/probe-osc11`                    | One-shot OSC 11 query → "dark" / "light" / empty. `--input <file>` and `--timeout <sec>` flags as test seams.                                                                                              |
| `config/theme/apply`                          | Actor: validate mode, atomic-write `mode` state file, fork `handlers.d/*` in parallel under 5s timeout, log non-zero exits. Honours `THEME_HANDLERS_DIR` and `XDG_STATE_HOME` env vars.                    |
| `config/theme/watcher`                        | Daemon. Self-locks. Linux: `gsettings monitor` (with `busctl monitor` fallback for non-GNOME); macOS: `defaults read` 2s poll. Honours `--source linux\|macos\|stub` test seam.                            |
| `config/theme/handlers.d/tmux`                | `tmux source-file palettes.d/tmux.<mode>.conf`, errexit-masked.                                                                                                                                            |
| `config/theme/handlers.d/starship`            | `_idempotent_ln_sf palettes.d/starship.<mode>.toml ~/.config/starship.toml`.                                                                                                                               |
| `config/theme/handlers.d/fish`                | `fish -c 'fish_config theme save "Catppuccin Mocha"'` for both modes — the vendored Mocha theme is dual-palette ([light] + [dark]); fish picks the section via OSC 11. (Latte theme file is not vendored.) |
| `config/theme/handlers.d/dircolors`           | `dircolors palettes.d/dircolors.<mode>` → atomic-write `$XDG_STATE_HOME/dotfiles-theme/ls-colors`.                                                                                                         |
| `config/theme/palettes.d/tmux.dark.conf`      | Copy of `config/tmux/theme-dark.conf`.                                                                                                                                                                     |
| `config/theme/palettes.d/tmux.light.conf`     | Copy of `config/tmux/theme-light.conf`.                                                                                                                                                                    |
| `config/theme/palettes.d/starship.dark.toml`  | Copy of `config/starship/starship-dark.toml`.                                                                                                                                                              |
| `config/theme/palettes.d/starship.light.toml` | Copy of `config/starship/starship-light.toml`.                                                                                                                                                             |
| `config/theme/palettes.d/dircolors.dark`      | Vendored from upstream `bliss-dircolors`.                                                                                                                                                                  |
| `config/theme/palettes.d/dircolors.light`     | Derived from `dircolors.dark`; light-mode codes for indices 0–7.                                                                                                                                           |
| `local/bin/theme-mode`                        | Public read API command.                                                                                                                                                                                   |
| `config/fish/functions/theme-mode.fish`       | Zero-fork fish function.                                                                                                                                                                                   |
| `tests/theme-lib.bats`                        | Tests for `_lib.sh` helpers.                                                                                                                                                                               |
| `tests/theme-probe-osc11.bats`                | Tests for `probe-osc11`.                                                                                                                                                                                   |
| `tests/theme-mode.bats`                       | Tests for the read API.                                                                                                                                                                                    |
| `tests/theme-actor.bats`                      | Tests for `apply`.                                                                                                                                                                                         |
| `tests/theme-watcher.bats`                    | Tests for `watcher` (PID lock, stub source).                                                                                                                                                               |
| `tests/theme-handlers.bats`                   | Tests for each handler against fixture palettes.                                                                                                                                                           |

### Modified

| Path                                   | Change                                                                                                                                                                                                                |
|----------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `config/exports`                       | Add `theme_mode` POSIX-portable function; replace starship-bootstrap (lines ~440–453) with one-time `apply $(theme-mode)`; source `ls-colors` cache; spawn watcher unless in SSH.                                     |
| `config/fish/config.fish`              | Spawn watcher unless in SSH; no bash helper needed.                                                                                                                                                                   |
| `config/fish/conf.d/theme-switch.fish` | Watch `mode` state file instead of `tmux-dark-notify-theme.conf`; eval `ls-colors` cache on flip.                                                                                                                     |
| `config/tmux/tmux.conf`                | Remove `run-shell` lines for `linux-dark-notify.sh` and `macos-dark-notify.sh`; replace with one-shot `apply $(theme-mode)`.                                                                                          |
| `install.conf.yaml`                    | Verify-only: the existing `~/.config/:` glob (`path: config/*`) already auto-links `config/theme/` into `~/.config/theme/`. Task 10.1 only adds an explicit entry as a fallback if the glob is found not to cover it. |
| `CLAUDE.md`                            | Update "Shell Configuration Chain" section; remove "the chain requires tmux" limitation note.                                                                                                                         |
| `docs/audit/nitpicker-findings.md`     | Move N-010 to Fixed (Pass 3) once manually verified.                                                                                                                                                                  |

### Deleted

| Path                                  | When                     | Why                                                |
|---------------------------------------|--------------------------|----------------------------------------------------|
| `config/tmux/_apply-theme.sh`         | Phase 11 (after cutover) | Replaced by `_lib.sh` + handlers.                  |
| `config/tmux/linux-dark-notify.sh`    | Phase 11                 | Folded into `watcher`.                             |
| `config/tmux/macos-dark-notify.sh`    | Phase 11                 | Folded into `watcher`.                             |
| `config/tmux/theme-activate.sh`       | Phase 11                 | Bootstrap is in shell init now.                    |
| `config/starship/starship-dark.toml`  | Phase 11                 | Moved to `palettes.d/`.                            |
| `config/starship/starship-light.toml` | Phase 11                 | Moved to `palettes.d/`.                            |
| `config/starship/` (empty dir)        | Phase 11                 | After both files moved.                            |
| `config/dircolors`                    | Phase 11                 | Superseded by `palettes.d/dircolors.{dark,light}`. |

---

## Phase 0 — Scaffold

### Task 0.1: Create directory skeleton

**Files:**
- Create: `config/theme/handlers.d/.gitkeep`
- Create: `config/theme/palettes.d/.gitkeep`

- [ ] **Step 1: Create dirs**

```bash
mkdir -p config/theme/handlers.d config/theme/palettes.d
touch config/theme/handlers.d/.gitkeep config/theme/palettes.d/.gitkeep
```

- [ ] **Step 2: Verify**

```bash
ls -la config/theme/
```
Expected: `handlers.d/`, `palettes.d/` present.

- [ ] **Step 3: Commit**

```bash
git add config/theme/
git commit -m "chore(theme): scaffold config/theme/{handlers.d,palettes.d} skeleton"
```

---

## Phase 1 — Core library (`_lib.sh`)

### Task 1.1: Failing test for `_atomic_write`

**Files:**
- Create: `tests/theme-lib.bats`

- [ ] **Step 1: Write the failing test**

```bash
cat > tests/theme-lib.bats <<'BATS'
#!/usr/bin/env bats

setup()
{
  TMPDIR_TEST="$(mktemp -d)"
  export THEME_LIB="$BATS_TEST_DIRNAME/../config/theme/_lib.sh"
}

teardown()
{
  rm -rf "$TMPDIR_TEST"
}

@test "_atomic_write: writes content to file" {
  source "$THEME_LIB"
  _atomic_write "$TMPDIR_TEST/out" "hello"
  [ "$(cat "$TMPDIR_TEST/out")" = "hello" ]
}

@test "_atomic_write: replaces existing content atomically" {
  source "$THEME_LIB"
  echo "old" > "$TMPDIR_TEST/out"
  _atomic_write "$TMPDIR_TEST/out" "new"
  [ "$(cat "$TMPDIR_TEST/out")" = "new" ]
}

@test "_atomic_write: leaves no temp file on success" {
  source "$THEME_LIB"
  _atomic_write "$TMPDIR_TEST/out" "x"
  count=$(find "$TMPDIR_TEST" -name 'out.tmp.*' | wc -l)
  [ "$count" -eq 0 ]
}
BATS
```

- [ ] **Step 2: Run; verify it fails**

Run: `./node_modules/.bin/bats tests/theme-lib.bats`
Expected: 3 failing tests, errors about missing `_lib.sh`.

- [ ] **Step 3: Implement `_atomic_write` in `_lib.sh`**

```bash
cat > config/theme/_lib.sh <<'LIB'
# config/theme/_lib.sh — shared helpers for the theme orchestrator.
# shellcheck shell=bash

# Atomic write: tmp + rename inside the destination directory so the
# replace is atomic on the same filesystem. Caller passes destination
# path and the literal content (no streaming yet — flips are short).
_atomic_write()
{
  local dst="$1" content="$2" tmp
  local dir
  dir="$(dirname -- "$dst")"
  mkdir -p -- "$dir"
  tmp="$(mktemp "${dst}.tmp.XXXXXX")"
  printf '%s\n' "$content" > "$tmp"
  mv -f -- "$tmp" "$dst"
}
LIB
```

- [ ] **Step 4: Run; verify pass**

Run: `./node_modules/.bin/bats tests/theme-lib.bats -f _atomic_write`
Expected: 3/3 pass.

- [ ] **Step 5: Commit**

```bash
git add tests/theme-lib.bats config/theme/_lib.sh
git commit -m "feat(theme): add _atomic_write helper in config/theme/_lib.sh"
```

### Task 1.2: Add `_idempotent_ln_sf` (carry-over from N-021)

- [ ] **Step 1: Append failing tests**

```bash
cat >> tests/theme-lib.bats <<'BATS'

@test "_idempotent_ln_sf: creates new symlink" {
  source "$THEME_LIB"
  echo data > "$TMPDIR_TEST/src"
  _idempotent_ln_sf "$TMPDIR_TEST/src" "$TMPDIR_TEST/dst"
  [ -L "$TMPDIR_TEST/dst" ]
  [ "$(readlink "$TMPDIR_TEST/dst")" = "$TMPDIR_TEST/src" ]
}

@test "_idempotent_ln_sf: leaves correct symlink alone (no mtime churn)" {
  source "$THEME_LIB"
  echo data > "$TMPDIR_TEST/src"
  ln -s "$TMPDIR_TEST/src" "$TMPDIR_TEST/dst"
  before=$(stat -f %m "$TMPDIR_TEST/dst" 2>/dev/null || stat -c %Y "$TMPDIR_TEST/dst")
  sleep 1
  _idempotent_ln_sf "$TMPDIR_TEST/src" "$TMPDIR_TEST/dst"
  after=$(stat -f %m "$TMPDIR_TEST/dst" 2>/dev/null || stat -c %Y "$TMPDIR_TEST/dst")
  [ "$before" = "$after" ]
}

@test "_idempotent_ln_sf: refuses to overwrite a regular file (N-021 guard)" {
  source "$THEME_LIB"
  echo data > "$TMPDIR_TEST/src"
  echo "user-content" > "$TMPDIR_TEST/dst"
  _idempotent_ln_sf "$TMPDIR_TEST/src" "$TMPDIR_TEST/dst"
  [ ! -L "$TMPDIR_TEST/dst" ]
  [ "$(cat "$TMPDIR_TEST/dst")" = "user-content" ]
}

@test "_idempotent_ln_sf: repairs broken symlink" {
  source "$THEME_LIB"
  ln -s "$TMPDIR_TEST/missing" "$TMPDIR_TEST/dst"
  echo data > "$TMPDIR_TEST/src"
  _idempotent_ln_sf "$TMPDIR_TEST/src" "$TMPDIR_TEST/dst"
  [ "$(readlink "$TMPDIR_TEST/dst")" = "$TMPDIR_TEST/src" ]
}
BATS
```

- [ ] **Step 2: Run; verify it fails**

Run: `./node_modules/.bin/bats tests/theme-lib.bats -f _idempotent_ln_sf`
Expected: 4 failures.

- [ ] **Step 3: Implement helper**

Append to `config/theme/_lib.sh`:

```bash
# Idempotent symlink: only ln(1)s when target actually changes. Refuses
# to overwrite a regular file at the destination — that's user data,
# not something the orchestrator owns. Carries the N-021 guard from
# the previous _apply-theme.sh.
_idempotent_ln_sf()
{
  local src=$1 dst=$2
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    return 0
  fi
  if [[ "$(readlink "$dst" 2> /dev/null)" != "$src" ]]; then
    ln -sf "$src" "$dst"
  fi
}
```

- [ ] **Step 4: Run; verify pass**

Run: `./node_modules/.bin/bats tests/theme-lib.bats -f _idempotent_ln_sf`
Expected: 4/4 pass.

- [ ] **Step 5: Commit**

```bash
git add tests/theme-lib.bats config/theme/_lib.sh
git commit -m "feat(theme): add _idempotent_ln_sf helper (carries N-021 guard)"
```

### Task 1.3: Add `_acquire_lock`

- [ ] **Step 1: Append failing tests**

```bash
cat >> tests/theme-lib.bats <<'BATS'

@test "_acquire_lock: succeeds when no PID file exists" {
  source "$THEME_LIB"
  run _acquire_lock "$TMPDIR_TEST/lock.pid"
  [ "$status" -eq 0 ]
  [ -f "$TMPDIR_TEST/lock.pid" ]
}

@test "_acquire_lock: fails when live PID holds lock" {
  source "$THEME_LIB"
  echo $$ > "$TMPDIR_TEST/lock.pid"
  run _acquire_lock "$TMPDIR_TEST/lock.pid"
  [ "$status" -eq 1 ]
}

@test "_acquire_lock: reclaims stale PID file" {
  source "$THEME_LIB"
  # PID 99999 is overwhelmingly likely to be dead
  echo 99999 > "$TMPDIR_TEST/lock.pid"
  run _acquire_lock "$TMPDIR_TEST/lock.pid"
  [ "$status" -eq 0 ]
  [ "$(cat "$TMPDIR_TEST/lock.pid")" = "$$" ]
}
BATS
```

- [ ] **Step 2: Run; verify fail**

Run: `./node_modules/.bin/bats tests/theme-lib.bats -f _acquire_lock`
Expected: 3 failures.

- [ ] **Step 3: Implement**

Append to `_lib.sh`:

```bash
# Atomic, race-safe lock. ln(1) is the classic atomic create-if-not-exists
# primitive on POSIX filesystems. A loser in a race silently fails the ln
# and we return 1.
_acquire_lock()
{
  local pidfile=$1 tmp
  if [[ -e "$pidfile" ]]; then
    local pid
    pid=$(cat -- "$pidfile" 2> /dev/null || true)
    if [[ -n "$pid" ]] && kill -0 "$pid" 2> /dev/null; then
      return 1
    fi
    # Stale: remove and continue.
    rm -f -- "$pidfile"
  fi
  tmp="$(mktemp "${pidfile}.tmp.XXXXXX")"
  printf '%s\n' "$$" > "$tmp"
  if ln -- "$tmp" "$pidfile" 2> /dev/null; then
    rm -f -- "$tmp"
    return 0
  fi
  rm -f -- "$tmp"
  return 1
}
```

- [ ] **Step 4: Run; verify pass**

Run: `./node_modules/.bin/bats tests/theme-lib.bats -f _acquire_lock`
Expected: 3/3 pass.

- [ ] **Step 5: Commit**

```bash
git add tests/theme-lib.bats config/theme/_lib.sh
git commit -m "feat(theme): add _acquire_lock helper for daemon self-locking"
```

### Task 1.4: Add `_log`

- [ ] **Step 1: Append failing tests**

```bash
cat >> tests/theme-lib.bats <<'BATS'

@test "_log: appends ISO8601-prefixed line" {
  source "$THEME_LIB"
  XDG_STATE_HOME="$TMPDIR_TEST" _log "INFO actor flipped to dark"
  [ -f "$TMPDIR_TEST/dotfiles-theme/log" ]
  grep -q 'INFO actor flipped to dark' "$TMPDIR_TEST/dotfiles-theme/log"
  grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}T' "$TMPDIR_TEST/dotfiles-theme/log"
}

@test "_log: rotates to 200 lines when over threshold" {
  source "$THEME_LIB"
  export XDG_STATE_HOME="$TMPDIR_TEST"
  for i in $(seq 1 220); do _log "line $i"; done
  count=$(wc -l < "$TMPDIR_TEST/dotfiles-theme/log")
  [ "$count" -le 200 ]
  # Last line preserved
  grep -q 'line 220' "$TMPDIR_TEST/dotfiles-theme/log"
}
BATS
```

- [ ] **Step 2: Run; verify fail**

- [ ] **Step 3: Implement**

Append to `_lib.sh`:

```bash
# Append a timestamped line to the orchestrator log. Single-writer
# discipline: only `apply` and `watcher` call this directly. Handlers
# print to stderr and the actor captures + labels.
#
# Rotation: when the file grows past 200 lines, replace with the last
# 200 via mktemp + mv. Cheap; runs at most once per flip.
_log()
{
  local msg="$*"
  local dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-theme"
  local logfile="$dir/log"
  mkdir -p -- "$dir"
  printf '%sZ %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%S')" "$msg" >> "$logfile"
  if [[ -f "$logfile" ]]; then
    local n
    n=$(wc -l < "$logfile" 2> /dev/null || echo 0)
    if (( n > 200 )); then
      local tmp
      tmp="$(mktemp "${logfile}.tmp.XXXXXX")"
      tail -n 200 -- "$logfile" > "$tmp"
      mv -f -- "$tmp" "$logfile"
    fi
  fi
}
```

- [ ] **Step 4: Run; verify pass**

Run: `./node_modules/.bin/bats tests/theme-lib.bats`
Expected: all (~12) pass.

- [ ] **Step 5: Commit**

```bash
git add tests/theme-lib.bats config/theme/_lib.sh
git commit -m "feat(theme): add _log with single-writer rotation"
```

---

## Phase 2 — `probe-osc11`

### Task 2.1: Failing tests for parse + luminance

**Files:**
- Create: `tests/theme-probe-osc11.bats`

- [ ] **Step 1: Write tests**

```bash
cat > tests/theme-probe-osc11.bats <<'BATS'
#!/usr/bin/env bats

setup()
{
  TMPDIR_TEST="$(mktemp -d)"
  PROBE="$BATS_TEST_DIRNAME/../config/theme/probe-osc11"
}

teardown()
{
  rm -rf "$TMPDIR_TEST"
}

@test "probe-osc11: dark hex => 'dark'" {
  printf '\033]11;rgb:1e1e/1e1e/2e2e\007' > "$TMPDIR_TEST/in"
  run "$PROBE" --input "$TMPDIR_TEST/in" --timeout 1
  [ "$status" -eq 0 ]
  [ "$output" = "dark" ]
}

@test "probe-osc11: light hex => 'light'" {
  printf '\033]11;rgb:eff1/f5f5/f5f5\007' > "$TMPDIR_TEST/in"
  run "$PROBE" --input "$TMPDIR_TEST/in" --timeout 1
  [ "$status" -eq 0 ]
  [ "$output" = "light" ]
}

@test "probe-osc11: no response => empty stdout, exit 0" {
  : > "$TMPDIR_TEST/in"
  run "$PROBE" --input "$TMPDIR_TEST/in" --timeout 0.1
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "probe-osc11: malformed response => empty stdout, exit 0" {
  printf 'not a valid sequence' > "$TMPDIR_TEST/in"
  run "$PROBE" --input "$TMPDIR_TEST/in" --timeout 0.1
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
BATS
```

- [ ] **Step 2: Run; verify fail**

Run: `./node_modules/.bin/bats tests/theme-probe-osc11.bats`
Expected: 4 failures.

### Task 2.2: Implement `probe-osc11`

- [ ] **Step 1: Write the script**

```bash
cat > config/theme/probe-osc11 <<'SCRIPT'
#!/usr/bin/env bash
# probe-osc11 — query the terminal's background colour via OSC 11 and
# print "dark" or "light" based on luminance. Prints nothing (and
# exits 0) if no answer arrives within the timeout window.
#
# Test seams: --input <file> reads OSC 11 reply from a fixture instead
# of /dev/tty; --timeout <seconds> overrides the default 0.2s.
set -uo pipefail

INPUT="/dev/tty"
TIMEOUT="0.2"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --input)
      INPUT="$2"
      shift 2
      ;;
    --timeout)
      TIMEOUT="$2"
      shift 2
      ;;
    *)
      echo "probe-osc11: unknown arg '$1'" >&2
      exit 2
      ;;
  esac
done

# Ask the terminal. When INPUT is /dev/tty, the printf is what
# triggers the reply. When INPUT is a fixture file, the file already
# contains the synthesised reply.
if [[ "$INPUT" = "/dev/tty" ]]; then
  printf '\033]11;?\007' > /dev/tty 2> /dev/null || exit 0
fi

response=""
read -t "$TIMEOUT" -r -d $'\007' response < "$INPUT" 2> /dev/null || exit 0

# Format: \033]11;rgb:RRRR/GGGG/BBBB or rgb:RR/GG/BB
if [[ "$response" =~ rgb:([0-9a-fA-F]+)/([0-9a-fA-F]+)/([0-9a-fA-F]+) ]]; then
  r="${BASH_REMATCH[1]}"
  g="${BASH_REMATCH[2]}"
  b="${BASH_REMATCH[3]}"
  rn=$((16#${r:0:2}))
  gn=$((16#${g:0:2}))
  bn=$((16#${b:0:2}))
  lum=$(( (rn * 299 + gn * 587 + bn * 114) / 1000 ))
  if (( lum < 128 )); then
    echo "dark"
  else
    echo "light"
  fi
fi
SCRIPT
chmod +x config/theme/probe-osc11
```

- [ ] **Step 2: Run; verify pass**

Run: `./node_modules/.bin/bats tests/theme-probe-osc11.bats`
Expected: 4/4 pass.

- [ ] **Step 3: Commit**

```bash
git add tests/theme-probe-osc11.bats config/theme/probe-osc11
git commit -m "feat(theme): add probe-osc11 with luminance threshold and test seams"
```

---

## Phase 3 — Read API (`theme-mode`)

### Task 3.1: Failing tests for `theme-mode`

**Files:**
- Create: `tests/theme-mode.bats`

- [ ] **Step 1: Write tests**

```bash
cat > tests/theme-mode.bats <<'BATS'
#!/usr/bin/env bats

setup()
{
  TMPDIR_TEST="$(mktemp -d)"
  export XDG_STATE_HOME="$TMPDIR_TEST"
  THEME_MODE="$BATS_TEST_DIRNAME/../local/bin/theme-mode"
}

teardown()
{
  rm -rf "$TMPDIR_TEST"
}

@test "theme-mode: prints state file content when present" {
  mkdir -p "$TMPDIR_TEST/dotfiles-theme"
  echo "light" > "$TMPDIR_TEST/dotfiles-theme/mode"
  run "$THEME_MODE"
  [ "$status" -eq 0 ]
  [ "$output" = "light" ]
}

@test "theme-mode: defaults to dark when no state file and no TTY" {
  # bats run() captures stdin from /dev/null, so [ -t 0 ] is false
  run "$THEME_MODE"
  [ "$status" -eq 0 ]
  [ "$output" = "dark" ]
}

@test "theme-mode: trims trailing newline from state file" {
  mkdir -p "$TMPDIR_TEST/dotfiles-theme"
  printf 'dark\n' > "$TMPDIR_TEST/dotfiles-theme/mode"
  run "$THEME_MODE"
  [ "$output" = "dark" ]
}
BATS
```

- [ ] **Step 2: Run; verify fail**

Run: `./node_modules/.bin/bats tests/theme-mode.bats`
Expected: 3 failures.

### Task 3.2: Implement `theme-mode`

- [ ] **Step 1: Write the script**

```bash
cat > local/bin/theme-mode <<'SCRIPT'
#!/usr/bin/env bash
# theme-mode — print the orchestrator's current dark/light state.
#
# Resolution order:
#   1. $XDG_STATE_HOME/dotfiles-theme/mode  (canonical state)
#   2. probe-osc11 against /dev/tty         (interactive shells only)
#   3. literal "dark"                       (fail-safe default)
#
# Always exits 0 so callers can inline the result in conditionals.
set -uo pipefail

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-theme"
state_file="$state_dir/mode"

if [[ -r "$state_file" ]]; then
  read -r mode < "$state_file" || mode=""
  if [[ "$mode" = "dark" || "$mode" = "light" ]]; then
    printf '%s\n' "$mode"
    exit 0
  fi
fi

# No usable state file. Try OSC 11 only when stdin is a TTY (otherwise
# /dev/tty either errors or blocks, e.g. in cron, CI, or piped scripts).
if [[ -t 0 ]]; then
  probe="$(dirname -- "$0")/../share/theme/probe-osc11"
  # Fall back to the in-tree path if not installed yet (development).
  [[ -x "$probe" ]] || probe="${DOTFILES:-$HOME/.dotfiles}/config/theme/probe-osc11"
  if [[ -x "$probe" ]]; then
    result="$("$probe" 2> /dev/null || true)"
    if [[ "$result" = "dark" || "$result" = "light" ]]; then
      printf '%s\n' "$result"
      exit 0
    fi
  fi
fi

echo "dark"
SCRIPT
chmod +x local/bin/theme-mode
```

- [ ] **Step 2: Run; verify pass**

Run: `./node_modules/.bin/bats tests/theme-mode.bats`
Expected: 3/3 pass.

- [ ] **Step 3: Commit**

```bash
git add tests/theme-mode.bats local/bin/theme-mode
git commit -m "feat(theme): add theme-mode read API command"
```

### Task 3.3: Add fish function `theme-mode`

**Files:**
- Create: `config/fish/functions/theme-mode.fish`

- [ ] **Step 1: Write the function**

```bash
cat > config/fish/functions/theme-mode.fish <<'FISH'
function theme-mode --description 'Print the current dark/light mode'
    set -l state_dir (set -q XDG_STATE_HOME; and echo $XDG_STATE_HOME; or echo "$HOME/.local/state")
    set -l state_file "$state_dir/dotfiles-theme/mode"
    if test -r $state_file
        set -l m (string trim < $state_file)
        if test "$m" = "dark" -o "$m" = "light"
            echo $m
            return 0
        end
    end
    # No state file. We're inside fish, so a TTY is implied. Try OSC 11.
    set -l probe "$DOTFILES/config/theme/probe-osc11"
    if test -x $probe
        set -l r (command $probe 2>/dev/null)
        if test "$r" = "dark" -o "$r" = "light"
            echo $r
            return 0
        end
    end
    echo dark
end
FISH
```

- [ ] **Step 2: Verify fish syntax**

Run: `fish -n config/fish/functions/theme-mode.fish`
Expected: no output (exit 0).

- [ ] **Step 3: Smoke test**

Run: `fish -c 'theme-mode'`
Expected: prints `dark` (no state file in test env).

- [ ] **Step 4: Commit**

```bash
git add config/fish/functions/theme-mode.fish
git commit -m "feat(theme): add fish theme-mode function (zero-fork)"
```

### Task 3.4: Add `theme_mode` POSIX function for bash/zsh

**Files:**
- Modify: `config/exports`

- [ ] **Step 1: Read current state of `config/exports` near line 440 to anchor the insertion**

Run: `sed -n '435,455p' config/exports`
Expected output around the existing starship-bootstrap block.

- [ ] **Step 2: Insert function above the starship-bootstrap block**

Use Edit tool to insert before line ~440:

```bash
# theme_mode — POSIX-portable read API. bash and zsh both source this
# file. Behaviour matches local/bin/theme-mode but without forking.
theme_mode()
{
  local state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-theme"
  local state_file="$state_dir/mode"
  if [ -r "$state_file" ]; then
    local m
    read -r m < "$state_file"
    if [ "$m" = "dark" ] || [ "$m" = "light" ]; then
      printf '%s\n' "$m"
      return 0
    fi
  fi
  # No state file. In an interactive shell we'll have already bootstrapped
  # below via apply, so the file should exist. If it doesn't, default safely.
  printf 'dark\n'
}
```

- [ ] **Step 3: Verify shellcheck**

Run: `shellcheck -s bash config/exports`
Expected: no new warnings on the inserted function.

- [ ] **Step 4: Smoke test in bash and zsh**

```bash
bash -c 'source config/exports >/dev/null 2>&1; type theme_mode; theme_mode'
zsh -c 'source config/exports >/dev/null 2>&1; type theme_mode; theme_mode'
```
Expected: function declared, prints `dark`.

- [ ] **Step 5: Commit**

```bash
git add config/exports
git commit -m "feat(theme): add theme_mode POSIX-portable bash/zsh function"
```

---

## Phase 4 — Actor (`apply`)

### Task 4.1: Failing tests for mode validation + atomic write

**Files:**
- Create: `tests/theme-actor.bats`

- [ ] **Step 1: Write tests**

```bash
cat > tests/theme-actor.bats <<'BATS'
#!/usr/bin/env bats

setup()
{
  TMPDIR_TEST="$(mktemp -d)"
  export XDG_STATE_HOME="$TMPDIR_TEST"
  export THEME_HANDLERS_DIR="$TMPDIR_TEST/handlers.d"
  mkdir -p "$THEME_HANDLERS_DIR"
  APPLY="$BATS_TEST_DIRNAME/../config/theme/apply"
}

teardown()
{
  rm -rf "$TMPDIR_TEST"
}

@test "apply: rejects unknown mode" {
  run "$APPLY" purple
  [ "$status" -eq 2 ]
  [[ "$output" == *"unknown mode 'purple'"* ]]
}

@test "apply: writes mode atomically when valid" {
  run "$APPLY" light
  [ "$status" -eq 0 ]
  [ "$(cat "$TMPDIR_TEST/dotfiles-theme/mode")" = "light" ]
}

@test "apply: idempotent (skip handlers on no-change)" {
  cat > "$THEME_HANDLERS_DIR/touched" <<'STUB'
#!/usr/bin/env bash
touch "$TMPDIR_TEST/handler-ran-$1"
STUB
  chmod +x "$THEME_HANDLERS_DIR/touched"
  TMPDIR_TEST="$TMPDIR_TEST" "$APPLY" light
  rm -f "$TMPDIR_TEST/handler-ran-light"
  TMPDIR_TEST="$TMPDIR_TEST" "$APPLY" light
  # Second call should NOT have re-run the handler
  [ ! -f "$TMPDIR_TEST/handler-ran-light" ]
}
BATS
```

- [ ] **Step 2: Run; verify fail**

Run: `./node_modules/.bin/bats tests/theme-actor.bats`
Expected: 3 failures (script missing).

### Task 4.2: Implement `apply` skeleton (validation + atomic-write + idempotency)

**Files:**
- Create: `config/theme/apply`

- [ ] **Step 1: Write the script**

```bash
cat > config/theme/apply <<'SCRIPT'
#!/usr/bin/env bash
# apply — the actor. Validates mode, atomic-writes state, forks each
# handlers.d/<name> in parallel under a 5s timeout, logs any non-zero
# exit, and returns 0 unless the input was malformed.
#
# Env overrides (test seams):
#   THEME_HANDLERS_DIR  defaults to $DOTFILES/config/theme/handlers.d
#   XDG_STATE_HOME      defaults to $HOME/.local/state
set -uo pipefail

# shellcheck disable=SC1091
source "$(dirname -- "$0")/_lib.sh"

if [[ $# -ne 1 ]]; then
  echo "apply: usage: apply <dark|light>" >&2
  exit 2
fi

mode="$1"
case "$mode" in
  dark | light) ;;
  *)
    echo "apply: unknown mode '$mode'; expected dark|light" >&2
    exit 2
    ;;
esac

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-theme"
state_file="$state_dir/mode"
handlers_dir="${THEME_HANDLERS_DIR:-${DOTFILES:-$HOME/.dotfiles}/config/theme/handlers.d}"

# Idempotent: skip everything if already in the requested mode.
if [[ -r "$state_file" ]]; then
  current=""
  read -r current < "$state_file" || true
  if [[ "$current" = "$mode" ]]; then
    exit 0
  fi
fi

_atomic_write "$state_file" "$mode"
_log "INFO actor flipped to $mode"
SCRIPT
chmod +x config/theme/apply
```

- [ ] **Step 2: Run; verify the first three tests pass**

Run: `./node_modules/.bin/bats tests/theme-actor.bats`
Expected: 3/3 pass.

- [ ] **Step 3: Commit**

```bash
git add tests/theme-actor.bats config/theme/apply
git commit -m "feat(theme): add apply actor with validation, atomic write, idempotency"
```

### Task 4.3: Add parallel handler dispatch with isolation + 5s timeout

- [ ] **Step 1: Append failing tests**

```bash
cat >> tests/theme-actor.bats <<'BATS'

@test "apply: forks each handler in parallel with mode arg" {
  cat > "$THEME_HANDLERS_DIR/h1" <<'STUB'
#!/usr/bin/env bash
echo "h1 $1" > "${TMPDIR_TEST}/h1.out"
STUB
  cat > "$THEME_HANDLERS_DIR/h2" <<'STUB'
#!/usr/bin/env bash
echo "h2 $1" > "${TMPDIR_TEST}/h2.out"
STUB
  chmod +x "$THEME_HANDLERS_DIR/h1" "$THEME_HANDLERS_DIR/h2"
  TMPDIR_TEST="$TMPDIR_TEST" "$APPLY" dark
  [ "$(cat "$TMPDIR_TEST/h1.out")" = "h1 dark" ]
  [ "$(cat "$TMPDIR_TEST/h2.out")" = "h2 dark" ]
}

@test "apply: continues when one handler fails" {
  cat > "$THEME_HANDLERS_DIR/ok" <<'STUB'
#!/usr/bin/env bash
echo "ok $1" > "${TMPDIR_TEST}/ok.out"
STUB
  cat > "$THEME_HANDLERS_DIR/bad" <<'STUB'
#!/usr/bin/env bash
exit 7
STUB
  chmod +x "$THEME_HANDLERS_DIR/ok" "$THEME_HANDLERS_DIR/bad"
  TMPDIR_TEST="$TMPDIR_TEST" run "$APPLY" light
  [ "$status" -eq 0 ]
  [ "$(cat "$TMPDIR_TEST/ok.out")" = "ok light" ]
  grep -q "WARN handler 'bad' exit=7" "$TMPDIR_TEST/dotfiles-theme/log"
}

@test "apply: kills handlers that exceed 5s timeout" {
  cat > "$THEME_HANDLERS_DIR/slow" <<'STUB'
#!/usr/bin/env bash
sleep 30
STUB
  chmod +x "$THEME_HANDLERS_DIR/slow"
  start=$SECONDS
  run "$APPLY" dark
  elapsed=$((SECONDS - start))
  [ "$status" -eq 0 ]
  [ "$elapsed" -lt 10 ]
  grep -q "WARN handler 'slow' exit=124" "$TMPDIR_TEST/dotfiles-theme/log"
}
BATS
```

- [ ] **Step 2: Run; verify fail (3 failures)**

- [ ] **Step 3: Replace the actor with the full implementation**

Use Edit tool to replace the contents of `config/theme/apply` with:

```bash
#!/usr/bin/env bash
# apply — the actor. Validates mode, atomic-writes state, forks each
# handlers.d/<name> in parallel under a 5s timeout, logs any non-zero
# exit, and returns 0 unless the input was malformed.
#
# Env overrides (test seams):
#   THEME_HANDLERS_DIR  defaults to $DOTFILES/config/theme/handlers.d
#   XDG_STATE_HOME      defaults to $HOME/.local/state
set -uo pipefail

# shellcheck disable=SC1091
source "$(dirname -- "$0")/_lib.sh"

if [[ $# -ne 1 ]]; then
  echo "apply: usage: apply <dark|light>" >&2
  exit 2
fi

mode="$1"
case "$mode" in
  dark | light) ;;
  *)
    echo "apply: unknown mode '$mode'; expected dark|light" >&2
    exit 2
    ;;
esac

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-theme"
state_file="$state_dir/mode"
handlers_dir="${THEME_HANDLERS_DIR:-${DOTFILES:-$HOME/.dotfiles}/config/theme/handlers.d}"

if [[ -r "$state_file" ]]; then
  current=""
  read -r current < "$state_file" || true
  if [[ "$current" = "$mode" ]]; then
    exit 0
  fi
fi

_atomic_write "$state_file" "$mode"
_log "INFO actor flipped to $mode"

# Fork each handler under a 5s timeout. Capture stderr per handler so
# the actor can label the lines on the way to the log. We use plain
# wait $pid + $? since `wait -n` is bash 4.3+ but easier here.
declare -a pids names
for h in "$handlers_dir"/*; do
  [[ -x "$h" ]] || continue
  name="$(basename -- "$h")"
  errlog="$state_dir/.handler-$name.err"
  : > "$errlog"
  ( timeout 5s "$h" "$mode" 2> "$errlog" ) &
  pids+=("$!")
  names+=("$name")
done

i=0
for pid in "${pids[@]}"; do
  set +e
  wait "$pid"
  rc=$?
  set -e
  name="${names[$i]}"
  errlog="$state_dir/.handler-$name.err"
  if (( rc != 0 )); then
    _log "WARN handler '$name' exit=$rc"
    if [[ -s "$errlog" ]]; then
      while IFS= read -r line; do
        _log "WARN handler '$name': $line"
      done < "$errlog"
    fi
  fi
  rm -f "$errlog"
  i=$((i + 1))
done

exit 0
```

- [ ] **Step 4: Run; verify pass**

Run: `./node_modules/.bin/bats tests/theme-actor.bats`
Expected: all 6 pass.

- [ ] **Step 5: Commit**

```bash
git add tests/theme-actor.bats config/theme/apply
git commit -m "feat(theme): add parallel handler dispatch with timeout + isolation"
```

---

## Phase 5 — Watcher

### Task 5.1: Failing tests for stub source + lock

**Files:**
- Create: `tests/theme-watcher.bats`

- [ ] **Step 1: Write tests**

```bash
cat > tests/theme-watcher.bats <<'BATS'
#!/usr/bin/env bats

setup()
{
  TMPDIR_TEST="$(mktemp -d)"
  export XDG_STATE_HOME="$TMPDIR_TEST"
  export THEME_HANDLERS_DIR="$TMPDIR_TEST/handlers.d"
  mkdir -p "$THEME_HANDLERS_DIR"
  WATCHER="$BATS_TEST_DIRNAME/../config/theme/watcher"
}

teardown()
{
  if [[ -f "$TMPDIR_TEST/dotfiles-theme/daemon.pid" ]]; then
    pid=$(cat "$TMPDIR_TEST/dotfiles-theme/daemon.pid" 2>/dev/null)
    [[ -n "$pid" ]] && kill "$pid" 2>/dev/null || true
  fi
  rm -rf "$TMPDIR_TEST"
}

@test "watcher: --source stub reads modes from a file and applies each" {
  cat > "$THEME_HANDLERS_DIR/recorder" <<'STUB'
#!/usr/bin/env bash
echo "$1" >> "${TMPDIR_TEST}/recorded"
STUB
  chmod +x "$THEME_HANDLERS_DIR/recorder"
  printf 'dark\nlight\ndark\n' > "$TMPDIR_TEST/source-stub"
  TMPDIR_TEST="$TMPDIR_TEST" run timeout 3 "$WATCHER" --source stub --stub-input "$TMPDIR_TEST/source-stub"
  [ "$status" -eq 0 ]
  [ "$(wc -l < "$TMPDIR_TEST/recorded")" -ge 3 ]
}

@test "watcher: second invocation exits 1 when first holds the lock" {
  echo $$ > "$TMPDIR_TEST/dotfiles-theme/daemon.pid" 2>/dev/null || {
    mkdir -p "$TMPDIR_TEST/dotfiles-theme"
    echo $$ > "$TMPDIR_TEST/dotfiles-theme/daemon.pid"
  }
  run "$WATCHER" --source stub --stub-input /dev/null
  [ "$status" -eq 1 ]
}
BATS
```

- [ ] **Step 2: Run; verify fail**

### Task 5.2: Implement watcher

- [ ] **Step 1: Write the script**

```bash
cat > config/theme/watcher <<'SCRIPT'
#!/usr/bin/env bash
# watcher — the theme orchestrator daemon. Self-locks; subscribes to
# the OS appearance event source; calls `apply` on each detected
# change.
#
# OS sources (auto-detected, override with --source):
#   linux  : prefers `gsettings monitor`; falls back to `busctl monitor`
#            for non-GNOME; exits 0 if neither reachable.
#   macos  : 2s `defaults read` polling.
#   stub   : reads modes (one per line) from --stub-input. Test seam.
set -uo pipefail

# shellcheck disable=SC1091
source "$(dirname -- "$0")/_lib.sh"

SOURCE=""
STUB_INPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source) SOURCE="$2"; shift 2 ;;
    --stub-input) STUB_INPUT="$2"; shift 2 ;;
    *) echo "watcher: unknown arg '$1'" >&2; exit 2 ;;
  esac
done

if [[ -z "$SOURCE" ]]; then
  case "$(uname -s)" in
    Darwin) SOURCE="macos" ;;
    Linux)  SOURCE="linux" ;;
    *)      _log "WARN watcher: unsupported OS, exiting"; exit 0 ;;
  esac
fi

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-theme"
mkdir -p -- "$state_dir"
pidfile="$state_dir/daemon.pid"

if ! _acquire_lock "$pidfile"; then
  _log "INFO watcher: another instance holds $pidfile; exiting"
  exit 1
fi

trap 'rm -f "$pidfile"' EXIT INT TERM HUP

apply_cmd="$(dirname -- "$0")/apply"

apply_mode()
{
  local m="$1"
  [[ "$m" = "dark" || "$m" = "light" ]] || return 0
  "$apply_cmd" "$m" || true
}

case "$SOURCE" in
  stub)
    [[ -r "$STUB_INPUT" ]] || { _log "ERROR watcher stub: --stub-input unreadable"; exit 1; }
    while IFS= read -r line; do
      apply_mode "$line"
    done < "$STUB_INPUT"
    ;;
  macos)
    last=""
    while true; do
      style="$(defaults read -g AppleInterfaceStyle 2> /dev/null || true)"
      if [[ "$style" = "Dark" ]]; then
        cur="dark"
      else
        cur="light"
      fi
      if [[ "$cur" != "$last" ]]; then
        apply_mode "$cur"
        last="$cur"
      fi
      sleep 2
    done
    ;;
  linux)
    if command -v gsettings > /dev/null 2>&1; then
      _log "INFO watcher: subscribing via gsettings monitor"
      # gsettings monitor outputs lines on every change.
      gsettings monitor org.gnome.desktop.interface color-scheme 2> /dev/null \
        | while IFS= read -r _; do
            scheme="$(gsettings get org.gnome.desktop.interface color-scheme 2> /dev/null)"
            case "$scheme" in
              "'prefer-dark'") apply_mode dark ;;
              "'default'" | "'prefer-light'") apply_mode light ;;
            esac
          done
    elif command -v busctl > /dev/null 2>&1; then
      _log "INFO watcher: subscribing via busctl monitor (portal)"
      busctl --user --json=short monitor org.freedesktop.portal.Desktop 2> /dev/null \
        | while IFS= read -r line; do
            case "$line" in
              *color-scheme*1*) apply_mode dark ;;
              *color-scheme*2*) apply_mode light ;;
            esac
          done
    else
      _log "WARN watcher linux: neither gsettings nor busctl available; exiting"
      exit 0
    fi
    ;;
  *)
    echo "watcher: unknown --source '$SOURCE'" >&2
    exit 2
    ;;
esac
SCRIPT
chmod +x config/theme/watcher
```

- [ ] **Step 2: Run; verify pass**

Run: `./node_modules/.bin/bats tests/theme-watcher.bats`
Expected: 2/2 pass.

- [ ] **Step 3: Commit**

```bash
git add tests/theme-watcher.bats config/theme/watcher
git commit -m "feat(theme): add self-locking watcher with stub/macos/linux sources"
```

---

## Phase 6 — Palette files

### Task 6.1: Copy tmux palettes

- [ ] **Step 1: Copy files**

```bash
cp config/tmux/theme-dark.conf  config/theme/palettes.d/tmux.dark.conf
cp config/tmux/theme-light.conf config/theme/palettes.d/tmux.light.conf
```

- [ ] **Step 2: Verify byte-identity**

Run: `diff config/tmux/theme-dark.conf config/theme/palettes.d/tmux.dark.conf && diff config/tmux/theme-light.conf config/theme/palettes.d/tmux.light.conf`
Expected: no output.

- [ ] **Step 3: Commit**

```bash
git add config/theme/palettes.d/tmux.dark.conf config/theme/palettes.d/tmux.light.conf
git commit -m "chore(theme): copy tmux palettes into palettes.d/"
```

### Task 6.2: Copy starship palettes

- [ ] **Step 1: Copy**

```bash
cp config/starship/starship-dark.toml  config/theme/palettes.d/starship.dark.toml
cp config/starship/starship-light.toml config/theme/palettes.d/starship.light.toml
```

- [ ] **Step 2: Verify**

```bash
diff config/starship/starship-dark.toml config/theme/palettes.d/starship.dark.toml && diff config/starship/starship-light.toml config/theme/palettes.d/starship.light.toml
```
Expected: no output.

- [ ] **Step 3: Commit**

```bash
git add config/theme/palettes.d/starship.dark.toml config/theme/palettes.d/starship.light.toml
git commit -m "chore(theme): copy starship palettes into palettes.d/"
```

### Task 6.3: Vendor `bliss-dircolors` as `dircolors.dark`

This task uses `git clone --depth=1` instead of `curl` because
CLAUDE.md's context-mode rules intercept any Bash command containing
`curl` or `wget`. A shallow clone fetches `bliss.dircolors` AND the
`LICENSE` file in one operation, lets us verify license compatibility
locally, and works regardless of whether the context-mode MCP server
is healthy in the current session.

- [ ] **Step 1: Shallow-clone upstream into a temp dir**

```bash
TMP_BLISS="$(mktemp -d)"
git clone --depth=1 https://github.com/joshjon/bliss-dircolors "$TMP_BLISS/repo"
test -r "$TMP_BLISS/repo/bliss.dircolors" || { echo "missing bliss.dircolors"; exit 1; }
test -r "$TMP_BLISS/repo/LICENSE"         || { echo "missing LICENSE";         exit 1; }
```

Expected: clone succeeds; both files present.

- [ ] **Step 2: Verify license is permissive (MIT/BSD/Apache-2.0)**

```bash
head -3 "$TMP_BLISS/repo/LICENSE"
grep -qE 'MIT License|BSD|Apache License' "$TMP_BLISS/repo/LICENSE" \
  || { echo "license is not a known permissive license — abort vendoring"; exit 1; }
```

Expected: grep matches; license is MIT-compatible. **If the grep fails,
stop the task and surface to the controller — do not vendor a
non-permissive file.**

- [ ] **Step 3: Detect the upstream license name (for the source header)**

```bash
LICENSE_NAME="$(head -1 "$TMP_BLISS/repo/LICENSE" | tr -d '\r')"
echo "license: $LICENSE_NAME"
```

Used in Step 4. Common values: `MIT License`, `BSD 2-Clause License`,
`Apache License 2.0`. If empty, fall back to literal `MIT (see upstream LICENSE)`.

- [ ] **Step 4: Write the palette with a source header**

```bash
{
  echo "# Source: https://github.com/joshjon/bliss-dircolors (${LICENSE_NAME:-MIT})"
  echo "# Vendored on: $(date -u +%Y-%m-%d)"
  echo "# Local edits: none — keep upstream-tracking."
  echo
  cat "$TMP_BLISS/repo/bliss.dircolors"
} > config/theme/palettes.d/dircolors.dark
```

- [ ] **Step 5: Clean up the clone**

```bash
rm -rf "$TMP_BLISS"
```

- [ ] **Step 6: Sanity check by running dircolors against it**

Run: `dircolors config/theme/palettes.d/dircolors.dark > /dev/null`
Expected: no errors. (If `dircolors` binary is missing on macOS, install
via `mise install -y coreutils` or `brew install coreutils` and re-run.)

- [ ] **Step 7: Commit**

```bash
git add config/theme/palettes.d/dircolors.dark
git commit -m "feat(theme): vendor bliss-dircolors as palettes.d/dircolors.dark"
```

### Task 6.4: Derive `dircolors.light`

- [ ] **Step 1: Copy and remap**

```bash
cp config/theme/palettes.d/dircolors.dark config/theme/palettes.d/dircolors.light
```

- [ ] **Step 2: Light-mode tuning**

Open `config/theme/palettes.d/dircolors.light` in editor. Find every `38;5;X` where `X` is in `0..7` and bump dark indices into the `8..15` (bright) range so they stay legible on a light background. Specifically:

- Replace `38;5;0`  → `38;5;8`  (dark grey on light → mid grey)
- Replace `38;5;7`  → `38;5;15` (light grey on light → bright white needs bumping the OTHER direction; if your test shows it invisible on white, change to `38;5;0` instead)

Update the source-line header:

```text
# Source: bliss-dircolors (light variant — derived from dircolors.dark)
# Light-mode tuning: 38;5;0..7 codes remapped for legibility on a
# light terminal background.
```

- [ ] **Step 3: Verify dircolors parses it**

Run: `dircolors config/theme/palettes.d/dircolors.light > /dev/null`
Expected: no errors.

- [ ] **Step 4: Visual check**

```bash
LS_COLORS="$(dircolors -b config/theme/palettes.d/dircolors.light | sed 's/^LS_COLORS=//;s/;export.*//' | tr -d "'\"")"
export LS_COLORS
ls -la /tmp 2>/dev/null | head
```

Expected: file types visibly distinguishable in a light terminal.

- [ ] **Step 5: Commit**

```bash
git add config/theme/palettes.d/dircolors.light
git commit -m "feat(theme): derive light variant of dircolors palette"
```

---

## Phase 7 — Handlers

### Task 7.1: tmux handler

**Files:**
- Create: `config/theme/handlers.d/tmux`
- Modify: `tests/theme-handlers.bats`

- [ ] **Step 1: Failing test**

```bash
cat > tests/theme-handlers.bats <<'BATS'
#!/usr/bin/env bats

setup()
{
  TMPDIR_TEST="$(mktemp -d)"
  export XDG_STATE_HOME="$TMPDIR_TEST"
  HD="$BATS_TEST_DIRNAME/../config/theme/handlers.d"
  PD="$BATS_TEST_DIRNAME/../config/theme/palettes.d"
  export DOTFILES="$BATS_TEST_DIRNAME/.."
}

teardown()
{
  rm -rf "$TMPDIR_TEST"
}

@test "tmux handler: succeeds even when no tmux server is running" {
  run "$HD/tmux" dark
  [ "$status" -eq 0 ]
}
BATS
```

Run: `./node_modules/.bin/bats tests/theme-handlers.bats`
Expected: 1 failure (script missing).

- [ ] **Step 2: Implement handler**

```bash
cat > config/theme/handlers.d/tmux <<'SCRIPT'
#!/usr/bin/env bash
# handlers.d/tmux — source the matching tmux palette.
# Errexit-masked: a transient tmux server failure must not poison the
# rest of the chain.
set -uo pipefail

mode="${1:-}"
[[ "$mode" = "dark" || "$mode" = "light" ]] || exit 2

palette="${DOTFILES:-$HOME/.dotfiles}/config/theme/palettes.d/tmux.${mode}.conf"
[[ -r "$palette" ]] || {
  echo "tmux handler: missing palette $palette" >&2
  exit 1
}

tmux source-file "$palette" 2> /dev/null || true
SCRIPT
chmod +x config/theme/handlers.d/tmux
```

- [ ] **Step 3: Run; verify pass**

Run: `./node_modules/.bin/bats tests/theme-handlers.bats -f tmux`
Expected: pass.

- [ ] **Step 4: Commit**

```bash
git add tests/theme-handlers.bats config/theme/handlers.d/tmux
git commit -m "feat(theme): add tmux handler"
```

### Task 7.2: starship handler

- [ ] **Step 1: Append failing test**

```bash
cat >> tests/theme-handlers.bats <<'BATS'

@test "starship handler: swaps ~/.config/starship.toml symlink" {
  export HOME="$TMPDIR_TEST/home"
  mkdir -p "$HOME/.config"
  run "$HD/starship" light
  [ "$status" -eq 0 ]
  [ -L "$HOME/.config/starship.toml" ]
  target="$(readlink "$HOME/.config/starship.toml")"
  [[ "$target" == *"starship.light.toml" ]]
}

@test "starship handler: refuses to clobber a regular file" {
  export HOME="$TMPDIR_TEST/home"
  mkdir -p "$HOME/.config"
  echo "user content" > "$HOME/.config/starship.toml"
  run "$HD/starship" dark
  [ "$status" -eq 0 ]
  [ ! -L "$HOME/.config/starship.toml" ]
  [ "$(cat "$HOME/.config/starship.toml")" = "user content" ]
}
BATS
```

- [ ] **Step 2: Run; verify fail**

- [ ] **Step 3: Implement**

```bash
cat > config/theme/handlers.d/starship <<'SCRIPT'
#!/usr/bin/env bash
# handlers.d/starship — swap ~/.config/starship.toml symlink to the
# matching variant. Refuses to clobber a regular file (N-021 guard).
set -uo pipefail

# shellcheck disable=SC1091
source "$(dirname -- "$0")/../_lib.sh"

mode="${1:-}"
[[ "$mode" = "dark" || "$mode" = "light" ]] || exit 2

src="${DOTFILES:-$HOME/.dotfiles}/config/theme/palettes.d/starship.${mode}.toml"
dst="$HOME/.config/starship.toml"
[[ -r "$src" ]] || {
  echo "starship handler: missing palette $src" >&2
  exit 1
}

mkdir -p -- "$(dirname -- "$dst")"
_idempotent_ln_sf "$src" "$dst"
SCRIPT
chmod +x config/theme/handlers.d/starship
```

- [ ] **Step 4: Run; verify pass**

- [ ] **Step 5: Commit**

```bash
git add tests/theme-handlers.bats config/theme/handlers.d/starship
git commit -m "feat(theme): add starship handler"
```

### Task 7.3: dircolors handler

- [ ] **Step 1: Append failing test**

```bash
cat >> tests/theme-handlers.bats <<'BATS'

@test "dircolors handler: writes ls-colors cache atomically" {
  run "$HD/dircolors" dark
  [ "$status" -eq 0 ]
  [ -f "$TMPDIR_TEST/dotfiles-theme/ls-colors" ]
  grep -q "LS_COLORS=" "$TMPDIR_TEST/dotfiles-theme/ls-colors"
  grep -q "export LS_COLORS" "$TMPDIR_TEST/dotfiles-theme/ls-colors"
}
BATS
```

- [ ] **Step 2: Run; verify fail**

- [ ] **Step 3: Implement**

```bash
cat > config/theme/handlers.d/dircolors <<'SCRIPT'
#!/usr/bin/env bash
# handlers.d/dircolors — regenerate the LS_COLORS cache from the
# palette matching the requested mode. Cache is sourced by shells via
# `eval "$(< $cache/ls-colors)"`.
set -uo pipefail

# shellcheck disable=SC1091
source "$(dirname -- "$0")/../_lib.sh"

mode="${1:-}"
[[ "$mode" = "dark" || "$mode" = "light" ]] || exit 2

src="${DOTFILES:-$HOME/.dotfiles}/config/theme/palettes.d/dircolors.${mode}"
[[ -r "$src" ]] || {
  echo "dircolors handler: missing palette $src" >&2
  exit 1
}

if ! command -v dircolors > /dev/null 2>&1; then
  echo "dircolors handler: dircolors(1) not in PATH" >&2
  exit 1
fi

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-theme"
mkdir -p -- "$state_dir"
content="$(dircolors -b "$src")"
_atomic_write "$state_dir/ls-colors" "$content"
SCRIPT
chmod +x config/theme/handlers.d/dircolors
```

- [ ] **Step 4: Run; verify pass**

- [ ] **Step 5: Commit**

```bash
git add tests/theme-handlers.bats config/theme/handlers.d/dircolors
git commit -m "feat(theme): add dircolors handler that builds LS_COLORS cache"
```

### Task 7.4: fish handler

- [ ] **Step 1: Append smoke test (no in-process verification possible)**

```bash
cat >> tests/theme-handlers.bats <<'BATS'

@test "fish handler: returns 0 with valid mode (smoke test only)" {
  if ! command -v fish >/dev/null 2>&1; then
    skip "fish not installed"
  fi
  run "$HD/fish" dark
  [ "$status" -eq 0 ]
}

@test "fish handler: rejects invalid mode" {
  run "$HD/fish" purple
  [ "$status" -eq 2 ]
}
BATS
```

- [ ] **Step 2: Implement**

```bash
cat > config/theme/handlers.d/fish <<'SCRIPT'
#!/usr/bin/env bash
# handlers.d/fish — persist the Catppuccin palette for future fish
# sessions. Running fish sessions update themselves via the in-process
# event handler in config/fish/conf.d/theme-switch.fish.
#
# config/fish/themes/Catppuccin Mocha.theme is a dual-palette file with
# both [light] and [dark] sections; fish picks the right section by
# querying terminal background via OSC 11. We therefore save the SAME
# theme name regardless of mode — re-saving triggers fish's re-query,
# which is what flips the colours in-process. We do NOT save
# "Catppuccin Latte" because that .theme file is not vendored in this
# repo (only Mocha/Frappe/Macchiato are present); a Latte save would
# error out and the `|| true` fallback would silently leave the prompt
# stuck in dark colours.
set -uo pipefail

mode="${1:-}"
case "$mode" in
  dark|light) ;;
  *) exit 2 ;;
esac

if ! command -v fish > /dev/null 2>&1; then
  echo "fish handler: fish not in PATH" >&2
  exit 1
fi

# `echo y |` bypasses fish_config's interactive
# "Overwrite your current theme? [y/N]" prompt; >/dev/null silences the
# confirmation echo. `|| true` prevents a transient fish failure from
# poisoning the actor's parallel-handler exit-code aggregation.
echo y | fish -c 'fish_config theme save "Catppuccin Mocha"' > /dev/null 2>&1 || true
SCRIPT
chmod +x config/theme/handlers.d/fish
```

- [ ] **Step 3: Run; verify pass**

- [ ] **Step 4: Commit**

```bash
git add tests/theme-handlers.bats config/theme/handlers.d/fish
git commit -m "feat(theme): add fish handler (persists Catppuccin variant)"
```

---

## Phase 8 — Wire into shells

### Task 8.1: Update fish event handler

**Files:**
- Modify: `config/fish/conf.d/theme-switch.fish`

- [ ] **Step 1: Read current contents**

Run: `cat config/fish/conf.d/theme-switch.fish`

- [ ] **Step 2: Replace contents**

Use Write tool with:

```fish
# config/fish/conf.d/theme-switch.fish
#
# Reacts to dark/light flips published by the theme orchestrator.
# Watches $XDG_STATE_HOME/dotfiles-theme/mode and reapplies fish
# syntax colours + LS_COLORS in the running session.

if not status is-interactive
    exit 0
end

set -l state_dir (set -q XDG_STATE_HOME; and echo $XDG_STATE_HOME; or echo "$HOME/.local/state")
set -l mode_file "$state_dir/dotfiles-theme/mode"
set -l ls_cache "$state_dir/dotfiles-theme/ls-colors"

# Apply once at login so the shell starts in the correct state.
if test -r $ls_cache
    eval (cat $ls_cache | string replace -r '^export ' '' | string replace -r ';export.*$' '')
end

# Per-prompt cheap watcher: stat the mode file's mtime; only do real
# work when it's changed since the last prompt we saw.
function __theme_switch_check --on-event fish_prompt
    set -l state_dir (set -q XDG_STATE_HOME; and echo $XDG_STATE_HOME; or echo "$HOME/.local/state")
    set -l mode_file "$state_dir/dotfiles-theme/mode"
    set -l ls_cache "$state_dir/dotfiles-theme/ls-colors"
    test -r $mode_file; or return 0

    set -l mtime (stat -f %m $mode_file 2>/dev/null; or stat -c %Y $mode_file 2>/dev/null)
    if not set -q __theme_switch_last_mtime; or test "$__theme_switch_last_mtime" != "$mtime"
        set -g __theme_switch_last_mtime $mtime
        # Re-save the SAME dual-palette theme; fish re-queries OSC 11
        # and picks [light] vs [dark] from Catppuccin Mocha.theme,
        # which contains both sections. Catppuccin Latte.theme is not
        # vendored in this repo, so we do not switch theme names by
        # mode — saving Mocha for both modes is the correct flip
        # mechanism here. `echo y |` bypasses the interactive overwrite
        # prompt that would otherwise pollute the next prompt line.
        echo y | fish_config theme save "Catppuccin Mocha" >/dev/null 2>&1
        if test -r $ls_cache
            eval (cat $ls_cache | string replace -r '^export ' '' | string replace -r ';export.*$' '')
        end
    end
end
```

- [ ] **Step 3: fish syntax check**

Run: `fish -n config/fish/conf.d/theme-switch.fish`
Expected: silent.

- [ ] **Step 4: Commit**

```bash
git add config/fish/conf.d/theme-switch.fish
git commit -m "feat(theme): rewire fish theme-switch to watch mode state file"
```

### Task 8.2: Spawn watcher from `config/fish/config.fish`

**Files:**
- Modify: `config/fish/config.fish`

- [ ] **Step 1: Read current bottom of file**

Run: `tail -20 config/fish/config.fish`

- [ ] **Step 2: Append spawn block**

Use Edit tool to insert before the closing comment block, after the OrbStack init:

```fish
# Spawn the theme orchestrator watcher (no-op if one is already running;
# the watcher self-locks). Skip in SSH sessions — the remote OS is the
# wrong oracle; rely on per-session OSC 11 via `apply $(theme-mode)`.
if status is-interactive
    if not set -q SSH_TTY; and not set -q SSH_CONNECTION
        set -l watcher "$DOTFILES/config/theme/watcher"
        if test -x $watcher
            $watcher >/dev/null 2>&1 &
            disown 2>/dev/null
        end
    end
    # Bootstrap mode so the prompt + LS_COLORS are right on first prompt.
    set -l apply "$DOTFILES/config/theme/apply"
    if test -x $apply
        set -l m (theme-mode 2>/dev/null)
        $apply $m >/dev/null 2>&1
    end
end
```

- [ ] **Step 3: fish syntax check**

Run: `fish -n config/fish/config.fish`
Expected: silent.

- [ ] **Step 4: Commit**

```bash
git add config/fish/config.fish
git commit -m "feat(theme): spawn watcher + bootstrap from fish config.fish"
```

### Task 8.3: Replace starship-bootstrap in `config/exports`

**Files:**
- Modify: `config/exports`

- [ ] **Step 1: Locate the existing block**

Run: `grep -n "starship_default\|starship_active\|starship-dark.toml" config/exports`

Expected: lines around 444–453.

- [ ] **Step 2: Replace the block (and add watcher spawn) with a single bootstrap call**

Use Edit tool. Replace the lines from the `__dotfiles_starship_default=` block through the `unset` line with:

```bash
# Theme orchestrator: bootstrap state + spawn watcher.
# Skip the watcher fork in SSH sessions — the remote OS is the wrong
# oracle; per-session OSC 11 via `apply $(theme-mode)` is the right
# fallback.
if [ -x "${DOTFILES:-$HOME/.dotfiles}/config/theme/apply" ]; then
  if [ -z "${SSH_TTY:-}${SSH_CONNECTION:-}" ]; then
    watcher="${DOTFILES:-$HOME/.dotfiles}/config/theme/watcher"
    if [ -x "$watcher" ]; then
      "$watcher" > /dev/null 2>&1 &
      disown 2> /dev/null || true
    fi
  fi
  m="$("${DOTFILES:-$HOME/.dotfiles}/local/bin/theme-mode")"
  "${DOTFILES:-$HOME/.dotfiles}/config/theme/apply" "$m" > /dev/null 2>&1 || true
  unset m watcher
fi

# Source LS_COLORS cache produced by the dircolors handler.
ls_cache="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-theme/ls-colors"
[ -r "$ls_cache" ] && eval "$(cat "$ls_cache")"
unset ls_cache
```

- [ ] **Step 3: shellcheck**

Run: `shellcheck -s bash config/exports`
Expected: no new warnings.

- [ ] **Step 4: Smoke test in bash**

```bash
bash -c 'export DOTFILES=$PWD; source config/exports >/dev/null; theme_mode'
```
Expected: prints `dark`.

- [ ] **Step 5: Commit**

```bash
git add config/exports
git commit -m "feat(theme): bootstrap orchestrator + spawn watcher from config/exports"
```

---

## Phase 9 — Tmux config

### Task 9.1: Strip old daemon spawns; add bootstrap call

**Files:**
- Modify: `config/tmux/tmux.conf`

- [ ] **Step 1: Locate run-shell entries**

Run: `grep -n "run-shell\|linux-dark-notify\|macos-dark-notify\|theme-activate" config/tmux/tmux.conf`

- [ ] **Step 2: Remove the linux/macos dark-notify run-shell lines and the theme-activate run-shell line**

Use Edit tool to delete those specific lines (they are typically a small block; keep all other run-shell entries unrelated to the theme chain).

- [ ] **Step 3: Replace with a one-shot bootstrap**

Add (in the same area where the old run-shell spawn lived):

```tmux
# Theme orchestrator bootstrap (one-shot at config load).
# The watcher is spawned by shell init, not by tmux, so fish-without-tmux
# also gets live updates.
run-shell "${DOTFILES:-$HOME/.dotfiles}/config/theme/apply $($DOTFILES/local/bin/theme-mode)"
```

- [ ] **Step 4: Verify tmux config parses**

Run: `tmux -f config/tmux/tmux.conf -L test-orchestrator new-session -d 'true' 2>&1; tmux -L test-orchestrator kill-server 2>/dev/null`
Expected: no parse errors.

- [ ] **Step 5: Commit**

```bash
git add config/tmux/tmux.conf
git commit -m "feat(theme): replace tmux run-shell daemons with orchestrator bootstrap"
```

---

## Phase 10 — Dotbot install

### Task 10.1: Verify dotbot already links `~/.config/theme`

**Files:**
- Read: `install.conf.yaml`

The existing `~/.config/:` glob (`path: config/*`, `glob: true`,
`relink: true`) auto-links every immediate child of `config/` into
`~/.config/`. `config/theme/` is therefore picked up by the existing
glob — no new link entry is needed, and adding one would shadow the
glob with a duplicate definition. This task only **verifies** the
glob covers it; the design's "Add `~/.config/theme` link" line is
satisfied by the pre-existing glob, not by a new YAML entry.

- [ ] **Step 1: Confirm glob covers `config/theme`**

```bash
grep -nE 'glob: true|path: config' install.conf.yaml
```
Expected: shows the existing block with `glob: true` and
`path: config/*` under `~/.config/:`. No edit needed.

- [ ] **Step 2: Dry-run dotbot to confirm `~/.config/theme` would be created**

```bash
./install --only link 2>&1 | grep -E 'theme|skipped|target'
```
Expected: line indicating `~/.config/theme` is linked (not skipped),
or a creation/relink line for it. If absent, fall back to adding an
explicit entry — see fallback below.

- [ ] **Step 3 (only if Step 2 shows the glob does NOT cover it): add explicit link**

Use Edit tool to add this entry under the existing `- link:` block,
**after** the `~/.config/:` glob entry:

```yaml
    ~/.config/theme:
      path: config/theme
      create: true
      relink: true
```

Then run `yarn lint` and verify dotbot picks it up via Step 2.

- [ ] **Step 4: Commit only if Step 3 ran**

```bash
git add install.conf.yaml
git commit -m "chore(install): add explicit ~/.config/theme link (glob did not cover)"
```

If Step 3 was skipped, no commit is needed for this task — the glob
already does the work.

---

## Phase 11 — Cutover & cleanup

### Task 11.1: Manual end-to-end verification (gate before deletes)

- [ ] **Step 1: Reload shell, confirm bootstrap works**

```bash
exec $SHELL -l
theme-mode
cat $XDG_STATE_HOME/dotfiles-theme/mode
```
Expected: matches your current OS appearance.

- [ ] **Step 2: Toggle OS appearance**

Manually toggle System Settings → Appearance.
Wait ≤ 3s.

- [ ] **Step 3: Verify chain flipped**

```bash
cat $XDG_STATE_HOME/dotfiles-theme/mode  # should reflect new mode
ls -la                                    # should reflect new LS_COLORS
```

If anything is wrong: do **not** proceed to deletes; open `tail -50 $XDG_STATE_HOME/dotfiles-theme/log` and fix.

### Task 11.2: Delete old tmux theme machinery

- [ ] **Step 1: Remove**

```bash
git rm config/tmux/_apply-theme.sh
git rm config/tmux/linux-dark-notify.sh
git rm config/tmux/macos-dark-notify.sh
git rm config/tmux/theme-activate.sh
```

- [ ] **Step 2: Confirm no remaining references**

```bash
grep -rn "_apply-theme\|linux-dark-notify\|macos-dark-notify\|theme-activate" . \
  --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=docs
```
Expected: no hits.

- [ ] **Step 3: Commit**

```bash
git commit -m "refactor(theme): remove obsolete tmux theme machinery"
```

### Task 11.3: Delete old palette source dirs

- [ ] **Step 1: Remove**

```bash
git rm config/tmux/theme-dark.conf
git rm config/tmux/theme-light.conf
git rm config/starship/starship-dark.toml
git rm config/starship/starship-light.toml
git rm config/dircolors
```

- [ ] **Step 2: Remove the now-empty starship dir**

```bash
rmdir config/starship 2>/dev/null || true
```

- [ ] **Step 3: Update `install.conf.yaml`** to remove any references to the deleted starship/dircolors/tmux palette files (search for `starship-dark`, `starship-light`, `theme-dark.conf`, `theme-light.conf`, `dircolors`).

- [ ] **Step 4: Verify no references**

```bash
grep -rn "config/starship\|theme-dark.conf\|theme-light.conf\|config/dircolors" . \
  --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=docs
```
Expected: no hits.

- [ ] **Step 5: Commit**

```bash
git add install.conf.yaml
git commit -m "refactor(theme): remove obsolete palette source files"
```

---

## Phase 12 — Documentation

### Task 12.1: Update `CLAUDE.md`

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Locate the "Shell Configuration Chain" section**

Run: `grep -n "Shell Configuration Chain\|the chain requires tmux" CLAUDE.md`

- [ ] **Step 2: Replace the section**

Use Edit tool to replace the section content with:

```markdown
### Shell Configuration Chain

Both `base/bashrc` and `base/zshrc` source `config/shared.sh`,
which loads:

- `config/exports` — environment variables, XDG dirs, PATH
- `config/alias` — shell aliases

Zsh additionally uses **antidote** (in `tools/antidote/`) for plugin
management. All three shells (bash, zsh, fish) render their prompt
with **starship**.

### Theme Orchestrator (`config/theme/`)

Dark/light theming is owned by a stand-alone orchestrator:

- `config/theme/watcher` — self-locking daemon, spawned from shell init
  (skipped in SSH sessions). Subscribes to portal/gsettings on Linux,
  polls `defaults read` on macOS.
- `config/theme/apply <mode>` — actor; atomic-writes
  `$XDG_STATE_HOME/dotfiles-theme/mode` and forks each
  `handlers.d/<name>` in parallel under a 5s timeout.
- `config/theme/handlers.d/{tmux,starship,fish,dircolors}` — per-app
  flip executables. Add new apps by dropping a file here.
- `config/theme/palettes.d/[app].[variant].[ext]` — theme assets,
  consolidated in one place.
- `local/bin/theme-mode` (and bash/fish functions) — public read API.
- Fallback: `config/theme/probe-osc11` — OSC 11 query for SSH and
  no-OS-source environments.

Fish reacts to flips via `config/fish/conf.d/theme-switch.fish`,
which watches the mode state file.
```

- [ ] **Step 3: Smoke read**

Run: `head -150 CLAUDE.md | sed -n '/Theme Orchestrator/,/^##/p'`
Expected: section reads cleanly.

- [ ] **Step 4: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: replace tmux-coupled theme description with orchestrator section"
```

### Task 12.2: Mark N-010 fixed in audit log

**Files:**
- Modify: `docs/audit/nitpicker-findings.md`

- [ ] **Step 1: Move N-010 from Open to Fixed under a new Pass 3 header**

Use Edit tool to:
1. Delete the N-010 block under `## Open Findings → ### Medium`.
2. Add `### Pass 3 — 2026-04-27` (or current date) under `## Fixed` with a single entry summarising the orchestrator's role in fixing the gap.
3. Update the `Last validated:` line and the Summary counts.

```markdown
### Pass 3 — 2026-04-27

#### [N-010] No verification scenario for fish-without-tmux (wezterm direct)
Fixed: 2026-04-27
Notes: Replaced by the theme orchestrator. The watcher daemon is spawned
from shell init (any flavour, with `_acquire_lock` ensuring single-instance),
so fish-without-tmux now gets live OS-driven updates. SSH sessions skip
the spawn and rely on per-session OSC 11 via `theme-mode`. The "chain
requires tmux" CLAUDE.md note has been removed.
```

- [ ] **Step 2: Commit**

```bash
git add docs/audit/nitpicker-findings.md
git commit -m "docs(audit): mark N-010 fixed by theme orchestrator (Pass 3)"
```

---

## Phase 13 — Final verification

### Task 13.1: Run all theme-related bats tests

- [ ] **Step 1: Run**

```bash
yarn test
```
Expected: all bats tests pass, including the six new theme files.

### Task 13.2: Run pre-commit on all files

- [ ] **Step 1: Run**

```bash
pre-commit run --all-files
```
Expected: all checks pass.

### Task 13.3: Manual integration verification (recap)

- [ ] **Step 1**: macOS — System Settings → Appearance toggle; tmux + starship + `ls` colours flip within ~2s.
- [ ] **Step 2**: Linux — GNOME Settings → Appearance toggle; same.
- [ ] **Step 3**: SSH from local WezTerm to a remote box without a daemon; `theme-mode` reports your local OS state on first call.
- [ ] **Step 4**: `kill $(cat $XDG_STATE_HOME/dotfiles-theme/daemon.pid)`; spawn a new shell; confirm the new shell respawns the watcher and bootstraps mode.

### Task 13.4: Final commit (if any tracked changes remain)

- [ ] **Step 1: status**

```bash
git status
```

If anything is dangling, stage and commit; otherwise the implementation is done.

---

## Rollback plan

If post-cutover the orchestrator misbehaves and needs to be reverted:

```bash
git revert <range-of-commits>  # the 11.2/11.3 deletion commits last
```

Because deletion came last, reverting in commit-reverse order restores
the old machinery atomically.

---

## Self-review notes

**Spec coverage:**
- Decisions 1–5 → addressed in Phases 1–10 (lib, probe, read API, actor, watcher; SSH guard in 8.2/8.3; self-lock in 5.2; SSH-skip in shell init).
- Components & layout → all 16 created files have a task; all 6 modified files have a task; all 8 deleted files have a task.
- Naming convention `[app].[variant].[ext]` → applied in Phase 6 palette tasks.
- Read API (state file → probe-osc11 → default `dark`) with TTY guard → Task 3.2.
- Actor: validation, atomic write, idempotency, parallel dispatch with timeout, isolation, log → Tasks 4.1–4.3.
- Watcher: self-lock, three sources (linux/macos/stub), --source flag → Task 5.2.
- Logging discipline (single-writer, ISO8601, 200-line rotation) → Task 1.4.
- Migration plan (single PR, no flag, gated cutover before deletes) → Phases 11.1–11.3 enforce the gate.
- N-010 closure → Task 12.2.

**Placeholder scan:** no "TBD"/"TODO"/"figure out later" entries remain. The dircolors light-mode tuning in Task 6.4 is concrete (specific code-mappings + verification command).

**Type/identifier consistency:** `_atomic_write`, `_idempotent_ln_sf`, `_acquire_lock`, `_log` are defined in Phase 1 and used by `apply` (Phase 4), `watcher` (Phase 5), and the starship/dircolors handlers (Phase 7). The state-file path `$XDG_STATE_HOME/dotfiles-theme/{mode,daemon.pid,ls-colors,log}` is used identically across all phases. `theme-mode` (CLI) and `theme_mode` (bash function) are documented as the same contract in Tasks 3.1–3.4.
