function theme-reapply --description 'Re-fire theme handlers for the current mode (bypasses apply idempotency guard)'
    set -l mode $argv[1]
    if test -z "$mode"
        set mode (theme-mode)
    end
    if test "$mode" != dark -a "$mode" != light
        echo "theme-reapply: mode must be 'dark' or 'light' (got '$mode')" >&2
        return 2
    end

    set -l dotfiles (set -q DOTFILES; and echo $DOTFILES; or echo "$HOME/.dotfiles")
    set -l handlers_dir "$dotfiles/config/theme/handlers.d"
    if not test -d "$handlers_dir"
        echo "theme-reapply: missing $handlers_dir" >&2
        return 1
    end

    set -l rc 0
    for h in $handlers_dir/*
        if test -x "$h"
            command $h $mode
            or set rc 1
        end
    end

    # Refresh LS_COLORS in this session from the cache the dircolors
    # handler just wrote. Cache is bash-shaped (`LS_COLORS='val'; export
    # LS_COLORS`); fish can't eval that so we extract the value.
    set -l state_dir (set -q XDG_STATE_HOME; and echo $XDG_STATE_HOME; or echo "$HOME/.local/state")
    set -l ls_cache "$state_dir/dotfiles-theme/ls-colors"
    if test -r "$ls_cache"
        set -l ls_value (string match -rg "LS_COLORS='([^']*)'" < $ls_cache | head -1)
        test -n "$ls_value"; and set -gx LS_COLORS $ls_value
    end

    echo "theme-reapply: applied $mode"
    return $rc
end
