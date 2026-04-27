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
