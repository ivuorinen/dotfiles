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
  # -n: replace an existing link to a directory instead of following it
  # and creating the new link inside the old target (BSD and GNU ln both
  # accept it). A failed ln is returned so the handler exits non-zero.
  if [[ "$(readlink "$dst" 2> /dev/null)" != "$src" ]]; then
    ln -sfn -- "$src" "$dst" || {
      printf 'theme: failed to link %s -> %s\n' "$dst" "$src" >&2
      return 1
    }
  fi
  return 0
}

# The user's saved family choice, written by local/bin/theme. Per machine
# and outside the repo, so switching never leaves a tracked change.
_theme_choice_file()
{
  printf '%s\n' "${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-theme/choice"
}

# True when $1 is a usable family: the name feeds a filesystem path, so
# accept only a plain slug that names an existing palettes.d/<family>/ dir.
_theme_valid_family()
{
  [[ "${1-}" =~ ^[a-z0-9][a-z0-9-]*$ && -d "${DOTFILES:-$HOME/.dotfiles}/config/theme/palettes.d/$1" ]]
}

# Active theme family, first match wins:
#   1. $DOTFILES_THEME_FAMILY (test seam); an invalid value fails closed.
#   2. The saved choice (_theme_choice_file); a missing, empty or invalid
#      one is skipped, so a removed family never leaves things unthemed.
#   3. The tracked default, config/theme/family.
# Prints the family; returns 1 (with a stderr note) otherwise.
_theme_family()
{
  local root="${DOTFILES:-$HOME/.dotfiles}/config/theme" family="" choice
  if [[ -n "${DOTFILES_THEME_FAMILY:-}" ]]; then
    family="$DOTFILES_THEME_FAMILY"
  else
    choice="$(_theme_choice_file)"
    # read -r trims surrounding whitespace, so "  kanagawa " still counts.
    [[ -r "$choice" ]] && {
      read -r family < "$choice" || true
    }
    if ! _theme_valid_family "$family"; then
      family=""
      [[ -r "$root/family" ]] && {
        read -r family < "$root/family" || true
      }
    fi
  fi
  if ! _theme_valid_family "$family"; then
    printf 'theme: invalid or unknown theme family %q\n' "$family" >&2
    return 1
  fi
  printf '%s\n' "$family"
}

# Resolve palettes.d/<family>/<mode>/<file> for the active family.
# Prints the path and returns 0 when it exists; returns 1 when the family
# is invalid or does not ship the file.
_palette()
{
  local mode=$1 file=$2 family path
  family="$(_theme_family)" || return 1
  path="${DOTFILES:-$HOME/.dotfiles}/config/theme/palettes.d/$family/$mode/$file"
  [[ -e "$path" ]] || return 1
  printf '%s\n' "$path"
}

# Link a palette into place, or — when the active family ships none
# (empty src) — remove a stale link left by another family so palettes
# never mix. Only a symlink is ever removed; a regular file is user data
# and stays (same guard as _idempotent_ln_sf). -L, not -e: a link left
# dangling by a moved palette must still be cleaned up.
_link_palette()
{
  local src=$1 dst=$2
  if [[ -n "$src" ]]; then
    _idempotent_ln_sf "$src" "$dst"
    return
  fi
  if [[ -L "$dst" ]]; then
    rm -f -- "$dst"
    printf 'theme: active family ships no palette for %s; removed stale link\n' "$dst" >&2
  fi
  return 0
}

# Non-blocking exclusive lock on $1, held on fd 9 of the calling shell until
# that process exits. It is a kernel flock(2) lock, taken with flock(1)
# (util-linux on Linux) or else lockf(1) (macOS base system), so the kernel
# drops it however the holder dies, SIGKILL included. The file's content is
# never consulted: the holder's pid is written there for diagnostics only.
#
# This replaced a pidfile lock whose stale-break ran under a second lock
# file. A process killed inside that window left the second lock behind,
# and no later process could reclaim the first. In practice that happened:
# shells spawned at login are killed mid-acquire, and the watcher stayed
# down for good.
#
# Never unlink a lock file. A process that opened the old inode would lock
# it while the next one locks a new file at the same path, and both hold
# "the" lock.
_acquire_lock()
{
  local lockfile=$1
  exec 9>> "$lockfile" || return 1
  if command -v flock > /dev/null 2>&1; then
    flock -n 9 || {
      exec 9>&-
      return 1
    }
  elif command -v lockf > /dev/null 2>&1; then
    lockf -s -t 0 9 || {
      exec 9>&-
      return 1
    }
  else
    exec 9>&-
    _log "ERROR lock: neither flock nor lockf is installed; cannot lock $lockfile"
    return 1
  fi
  printf '%s\n' "$$" > "$lockfile"
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
