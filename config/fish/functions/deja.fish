function deja --wraps deja --description 'Run deja, refusing install and update'
    # Both rewrite the Copilot and pi configs this repo manages.
    # `command deja install ...` still runs them.
    set -l cmd $argv[1]
    test "$cmd" = --framed; and set cmd $argv[2]
    switch "$cmd"
        case install update
            echo "deja: '$cmd' rewrites configs the dotfiles manage; run 'command deja $cmd' to do it anyway" >&2
            return 1
    end
    command deja $argv
end
