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

    if test $rc -eq 0
        echo "theme-reapply: applied $mode"
    else
        echo "theme-reapply: applied $mode (one or more handlers failed)" >&2
    end
    return $rc
end
