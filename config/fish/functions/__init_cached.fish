function __init_cached --description 'Source a tool init script from cache, regenerating when the tool changes'
    # `<tool> init fish | source` costs 58-117ms per tool in fish — almost all
    # of it the pipeline, not the parse: sourcing the identical text from a
    # file is 2-4ms. These init scripts are deterministic for a given tool
    # build, so cache the output and source that instead.
    #
    # Usage: __init_cached <binary> <command to generate init script...>
    #   __init_cached zoxide zoxide init fish
    #   __init_cached starship starship init fish --print-full-init

    set -l bin $argv[1]
    set -l gen $argv[2..-1]

    set -l path (command -v $bin)
    test -n "$path"; or return 1

    set -l dir "$XDG_CACHE_HOME/fish/init"
    test -n "$XDG_CACHE_HOME"; or set dir "$HOME/.cache/fish/init"

    set -l cache "$dir/$bin"(string replace -a / _ -- $path)".fish"

    # Freshness stamps. The resolved path alone is NOT enough: these tools
    # resolve through mise shims, which are symlinks to the mise binary
    # created once and never touched again on a tool upgrade (starship's shim
    # predates its current version by months). `test -nt` follows the symlink,
    # so it compares mise's own mtime and would miss every tool bump.
    #
    # Versions here are pinned in the mise configs and changed by editing
    # them, so stamping on those files catches a bump. A `mise up` that moves
    # a floating pin without a config edit will not — `rm -rf
    # $XDG_CACHE_HOME/fish/init` forces a rebuild if a tool ever misbehaves.
    set -l stamps $path
    test -n "$XDG_CONFIG_HOME"; and set -a stamps "$XDG_CONFIG_HOME/mise/config.toml"
    test -n "$DOTFILES"; and set -a stamps "$DOTFILES/.mise.toml"

    set -l stale 0
    test -s "$cache"; or set stale 1
    for stamp in $stamps
        if test -e "$stamp"; and test "$stamp" -nt "$cache"
            set stale 1
        end
    end

    if test $stale -eq 1
        mkdir -p "$dir"
        # Atomic, and PID-suffixed so two shells starting at once cannot
        # read a half-written cache.
        set -l tmp "$cache.$fish_pid.tmp"
        if $gen >"$tmp" 2>/dev/null; and test -s "$tmp"
            mv -f "$tmp" "$cache"
            # Drop caches for older builds of this same tool.
            for stale in "$dir/$bin"*.fish
                test "$stale" = "$cache"; or rm -f "$stale"
            end
        else
            # Generation failed — fall back to the live path so a broken
            # cache never costs the user the tool's integration.
            rm -f "$tmp"
            $gen | source
            return
        end
    end

    source "$cache"
end
