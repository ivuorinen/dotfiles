# theme-switch.fish — keep fish syntax/completion colours in sync with tmux
# dark/light state.
#
# Polls the tmux state symlink (managed by linux-dark-notify.sh and
# theme-activate.sh) on every prompt render. When the symlink target changes
# we re-save the active fish theme so fish re-queries the terminal background
# (OSC 11) and picks the matching [light]/[dark] palette section. The shell
# prompt itself is rendered by starship, which reads ~/.config/starship.toml
# fresh on every prompt subprocess invocation — no fish-side reload is
# needed for the prompt.
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

    # Always re-save on first observation. config.fish ran `fish_config theme
    # choose` once at startup, but if tmux created the symlink AFTER fish
    # started (fish-then-tmux ordering) the initial choose ran without a tmux
    # state to consult — re-saving now is the safe action and costs only one
    # fish subprocess fork.
    #
    # `fish_config theme save` reads stdin for an interactive
    # "Overwrite your current theme? [y/N]" confirmation
    # (/usr/share/fish/functions/fish_config.fish line 224). Piping `y`
    # bypasses the prompt; redirecting stdout silences the confirmation
    # echo so it doesn't pollute the prompt line.
    echo y | fish_config theme save "Catppuccin Mocha" >/dev/null 2>&1
end
