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
    if ((n > 200)); then
      local tmp
      tmp="$(mktemp "${logfile}.tmp.XXXXXX")"
      tail -n 200 -- "$logfile" > "$tmp"
      mv -f -- "$tmp" "$logfile"
    fi
  fi
}
