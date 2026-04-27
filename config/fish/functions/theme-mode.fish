function theme-mode --description 'Print the current dark/light mode'
    set -l state_dir (set -q XDG_STATE_HOME; and echo $XDG_STATE_HOME; or echo "$HOME/.local/state")
    set -l state_file "$state_dir/dotfiles-theme/mode"
    if test -r $state_file
        set -l m (string trim < $state_file)
        if test "$m" = dark -o "$m" = light
            echo $m
            return 0
        end
    end
    # No state file. We're inside fish, so a TTY is implied. Try OSC 11.
    set -l probe "$DOTFILES/config/theme/probe-osc11"
    if test -x $probe
        set -l r (command $probe 2>/dev/null)
        if test "$r" = dark -o "$r" = light
            echo $r
            return 0
        end
    end
    echo dark
end
