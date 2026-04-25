# theme-switch.fish — keep fish/tide colors in sync with tmux dark/light state.
#
# Polls the tmux state symlink (managed by linux-dark-notify.sh and
# theme-activate.sh) on every prompt render. When the symlink target changes
# we re-save the active fish theme so fish re-queries the terminal background
# (OSC 11) and picks the matching [light]/[dark] palette section, then asks
# tide to invalidate its cached prompt strings.
#
# Polling on `fish_prompt` is intentional: signal-based IPC (SIGUSR1, etc.)
# is unsafe because the default disposition is Terminate, so any fish that
# hasn't loaded this file yet would die on signal receipt — including a
# login fish driving the desktop session.

function __theme_switch_check --on-event fish_prompt --description 'Refresh theme if tmux state symlink changed'
    status is-interactive; or return 0

    set -l state_dir $XDG_STATE_HOME
    test -n "$state_dir"; or set state_dir "$HOME/.local/state"
    set -l link "$state_dir/tmux/tmux-dark-notify-theme.conf"

    test -L "$link"; or return 0
    set -l target (readlink "$link" 2>/dev/null)
    test -n "$target"; or return 0

    if test "$target" = "$__theme_switch_last_target"
        return 0
    end

    set -g __theme_switch_last_target "$target"

    # First observation in this fish session — config.fish already applied
    # the theme via `fish_config theme choose`, so don't re-do it.
    if not set -q __theme_switch_initialized
        set -g __theme_switch_initialized 1
        return 0
    end

    fish_config theme save "Catppuccin Mocha" 2>/dev/null
    functions -q tide; and tide reload 2>/dev/null
end
