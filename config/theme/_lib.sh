# config/theme/_lib.sh — shared helpers for the theme orchestrator.
# shellcheck shell=bash

# Atomic write: tmp + rename inside the destination directory so the
# replace is atomic on the same filesystem. Caller passes destination
# path and the literal content (no streaming yet — flips are short).
_atomic_write()
{
  local dst="$1" content="$2" tmp dir
  dir="$(dirname -- "$dst")"
  mkdir -p -- "$dir" || return 1
  tmp="$(mktemp "${dst}.tmp.XXXXXX")" || return 1
  # No trap: bash trap is process-level, not function-local, and would
  # clobber callers' EXIT traps. If printf or mv fails, remove the temp
  # by hand so we don't leak orphaned .tmp.XXXXXX siblings of $dst.
  if printf '%s\n' "$content" > "$tmp" && mv -f -- "$tmp" "$dst"; then
    return 0
  fi
  rm -f -- "$tmp"
  return 1
}

# Idempotent symlink: only ln(1)s when target actually changes. Refuses
# to overwrite a regular file at the destination — that's user data,
# not something the orchestrator owns. Carries the N-021 guard from
# the previous _apply-theme.sh.
_idempotent_ln_sf()
{
  local src=$1 dst=$2
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    # Surface the skip so users notice their manual file is shadowing
    # the orchestrator's symlink (e.g. ~/.config/eza/theme.yml left
    # over from before the handler existed). rc=0 — this is intended,
    # not a failure — but silent silence breaks debugging.
    printf 'theme: skipping symlink %s -> %s (destination exists as a regular file)\n' \
      "$dst" "$src" >&2
    return 0
  fi
  if [[ "$(readlink "$dst" 2> /dev/null)" != "$src" ]]; then
    ln -sf "$src" "$dst"
  fi
  return 0
}

# Atomic, race-safe lock. ln(1) is the classic atomic create-if-not-exists
# primitive on POSIX filesystems, and it is the ONLY thing that grants the
# lock here. A loser silently fails the ln and we return 1.
#
# Breaking a stale lock is the hard half, because it is inherently two
# operations (unlink the dead file, link ours) and a pair of syscalls is not
# atomic. The previous version ran them unguarded, so two processes that both
# saw the same dead pid could both succeed: the first won its ln, then the
# second's `rm -f` deleted the *live* pidfile and let it link over the top.
# Both returned 0 and the watcher's singleton guard admitted two daemons.
#
# A read-back after the write does not fix this — each racer reads its own
# write and every one of them concludes it won. The break must instead be
# serialised, so the unlink-then-link pair runs under a second lock that is
# itself taken with ln. A process that cannot take the break lock does not
# break anything; it just returns 1 and lets the winner proceed.
#
# Residual risk, stated rather than hidden: a process SIGKILLed while holding
# the break lock leaves "${pidfile}.break" behind and no later process can
# reclaim a stale lock until it is removed by hand. That window spans one
# cat + kill -0 + rm + ln — orders of magnitude smaller than the whole
# watcher lifetime this guards, and it fails closed (no daemon) rather than
# open (two daemons).
_acquire_lock()
{
  local pidfile=$1 tmp breaklock pid rc
  tmp="$(mktemp "${pidfile}.tmp.XXXXXX")" || return 1
  printf '%s\n' "$$" > "$tmp"

  # Uncontended: nothing holds the lock.
  if ln -- "$tmp" "$pidfile" 2> /dev/null; then
    rm -f -- "$tmp"
    return 0
  fi

  # Contended. Serialise the stale-break so only one process may unlink.
  breaklock="${pidfile}.break"
  if ! ln -- "$tmp" "$breaklock" 2> /dev/null; then
    rm -f -- "$tmp"
    return 1
  fi

  rc=1
  pid=$(cat -- "$pidfile" 2> /dev/null || true)
  if [[ -z "$pid" ]] || ! kill -0 "$pid" 2> /dev/null; then
    # Holder is gone. Safe to replace: we are the only breaker.
    rm -f -- "$pidfile"
    ln -- "$tmp" "$pidfile" 2> /dev/null && rc=0
  fi

  rm -f -- "$breaklock" "$tmp"
  return "$rc"
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
  if ! mkdir -p -- "$dir"; then
    printf 'theme: _log: cannot create log dir %s\n' "$dir" >&2
    return 0
  fi
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
  return 0
}

# Resolve a timeout(1) binary. Macs without coreutils have neither
# `timeout` nor `gtimeout`; Homebrew's `coreutils` ships only `gtimeout`.
# Prints the binary name on success, returns 1 when neither is present.
_resolve_timeout_cmd()
{
  if command -v timeout > /dev/null 2>&1; then
    printf 'timeout\n'
    return 0
  fi
  if command -v gtimeout > /dev/null 2>&1; then
    printf 'gtimeout\n'
    return 0
  fi
  return 1
}
