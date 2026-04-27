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
# The cache file is bash-shaped (`LS_COLORS='val'; export LS_COLORS`)
# because the dircolors handler runs `dircolors -b`. Fish cannot
# `eval` that directly, so extract the value with `string match -rg`
# and assign it via `set -gx`.
if test -r $ls_cache
    set -l ls_value (string match -rg "LS_COLORS='([^']*)'" < $ls_cache | head -1)
    test -n "$ls_value"; and set -gx LS_COLORS $ls_value
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
            set -l ls_value (string match -rg "LS_COLORS='([^']*)'" < $ls_cache | head -1)
            test -n "$ls_value"; and set -gx LS_COLORS $ls_value
        end
    end
end
