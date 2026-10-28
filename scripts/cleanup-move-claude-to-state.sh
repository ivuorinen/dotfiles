#!/usr/bin/env bash
set -euo pipefail
# @description Move Claude Code's state out of the home dir into XDG_STATE_HOME.
#USAGE about "Move ~/.claude and ~/.claude.json into XDG_STATE_HOME"
#
# config/exports and config/fish/exports.fish point CLAUDE_CONFIG_DIR at
# $XDG_STATE_HOME/claude, but only once this has run: while ~/.claude
# exists and $XDG_STATE_HOME/claude does not, they leave it unset, so a
# machine keeps working until it is migrated. Run it once per machine, with
# every Claude Code session closed. It moves
#
#   ~/.claude       -> $XDG_STATE_HOME/claude
#   ~/.claude.json  -> $XDG_STATE_HOME/claude/.claude.json
#
# and rewrites the absolute paths the old location leaves behind:
#
#   plugins/installed_plugins.json   every plugin's installPath
#   plugins/known_marketplaces.json  every marketplace's installLocation
#   .claude.json                     any value pointing into the old dir
#   settings.json                    hook commands and the statusLine
#
# Re-running is safe: every step skips work already done, and a path that
# exists in both places stops the run instead of being merged.

# Ensure DOTFILES is set even when script is invoked directly
if [[ -z "${DOTFILES:-}" ]]; then
  DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  export DOTFILES
fi
# shellcheck source=shared.sh
source "$DOTFILES/config/shared.sh"

dest="${XDG_STATE_HOME:-$HOME/.local/state}/claude"
statusline="${DOTFILES/#"$HOME"/\~}/base/claude/statusline-command.sh"

die()
{
  msgr err "$1"
  exit 1
}

# A running session keeps writing to the old paths. comm is a full path on
# macOS and a bare name on Linux, hence the basename match.
if ps -eo comm= | awk -F/ '$NF == "claude" { found = 1 } END { exit !found }'; then
  die "Claude Code is running: quit every session (terminal, IDE, desktop app) first"
fi

# move <from> <to>: rename one path, never into an existing one.
move()
{
  local from="$1" to="$2"
  if [[ -L "$from" ]]; then
    die "$from is a symlink: move what it points at by hand"
  fi
  if [[ ! -e "$from" ]]; then
    msgr ok "Nothing to move at $from"
    return 0
  fi
  if [[ -e "$to" ]]; then
    die "Both $from and $to exist: merge or remove one by hand, then run this again"
  fi
  mkdir -p "$(dirname "$to")"
  mv "$from" "$to"
  msgr run_done "Moved $from" "→ $to"
}

move "$HOME/.claude" "$dest"
move "$HOME/.claude.json" "$dest/.claude.json"

tmp=$(mktemp)
lib::register_cleanup "$tmp"
lib::trap_cleanup

# rewrite_json <file> <jq program>: run the program over the file and write
# the result back in place (same inode and mode), only when that changes
# something, so a second run leaves the file alone.
rewrite_json()
{
  local file="$1" program="$2"
  [[ -f "$file" ]] || return 0
  # shellcheck disable=SC2016 # expanded by the hook's shell, not this one
  jq --arg old "$HOME/.claude/" --arg new "$dest/" --arg sl "$statusline" \
    --arg hookdir '${CLAUDE_CONFIG_DIR:-$HOME/.claude}/' \
    "$program" "$file" > "$tmp"
  if jq -e --slurpfile out "$tmp" '. == $out[0]' "$file" > /dev/null; then
    return 0
  fi
  cat "$tmp" > "$file"
  msgr run_done "Rewrote old paths in $file"
}

# Absolute paths into the old dir become the same paths under the new one.
relocate='walk(if type == "string" and startswith($old) then $new + .[($old | length):] else . end)'
rewrite_json "$dest/plugins/installed_plugins.json" "$relocate"
rewrite_json "$dest/plugins/known_marketplaces.json" "$relocate"
rewrite_json "$dest/.claude.json" "$relocate"

# The statusLine runs the repo's script, since the dotbot link it used is
# gone. Hook commands find the dir through CLAUDE_CONFIG_DIR when they run,
# which stays right whichever dir Claude Code was started with.
rewrite_json "$dest/settings.json" '
  def swap($from; $to): (. / $from) | join($to);
  (if .statusLine.command then
    .statusLine.command |= (swap("~/.claude/statusline-command.sh"; $sl)
      | swap($old + "statusline-command.sh"; $sl))
  else . end)
  | (if .hooks then
    .hooks |= walk(if type == "string" then
      swap($old; $hookdir) | swap("~/.claude/"; $hookdir) | swap("$HOME/.claude/"; $hookdir)
    else . end)
  else . end)'

# The dotbot link the statusLine used to run, moved along with the dir.
link="$dest/statusline-command.sh"
if [[ -L "$link" && "$(readlink "$link")" == */base/claude/statusline-command.sh ]]; then
  rm "$link"
  msgr run_done "Removed the old statusline link" "$link"
fi

# A plugin that hardcodes ~/.claude recreates it, and deja leaves
# ~/.claude.json.bak behind: report, never delete.
shopt -s nullglob
for left in "$HOME/.claude" "$HOME"/.claude.*; do
  if [[ -e "$left" ]]; then
    msgr warn "Still in \$HOME: $left"
  fi
done
# shellcheck disable=SC2088 # a literal ~ written in the file, not a path
if [[ -f "$dest/settings.json" ]] && grep -qF -e "$HOME/.claude" -e '~/.claude' "$dest/settings.json"; then
  msgr warn "$dest/settings.json still names the old dir: check those lines by hand"
fi

msgr yay "Done. Open a new shell so CLAUDE_CONFIG_DIR is set, then run:"
printf '  %s\n' \
  "claude, then /login  (macOS keys the stored login to the config dir)" \
  "deja doctor          (and 'deja install claude-code' if it flags the Claude wiring)"
