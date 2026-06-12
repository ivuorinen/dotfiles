# Completions for x — dynamically discovers x-* sibling commands.
# Not auto-generated. install-completions.sh is patched to skip x
# because subcommands are discovered at runtime, not statically declared.

function __x_list_commands
    set -l x_path (command -v x 2>/dev/null)
    test -n "$x_path" || return

    # Resolve symlinks (BSD-portable, no readlink -f) so completions and the
    # dispatcher agree on which directory contains x-* siblings.
    while test -L "$x_path"
        set -l link (readlink "$x_path")
        if string match -q '/*' -- "$link"
            set x_path "$link"
        else
            set x_path (dirname "$x_path")/"$link"
        end
    end
    set -l x_dir (dirname "$x_path")

    for f in "$x_dir"/x-*
        test -x "$f" || continue
        set -l name (string replace -r '.*/x-' '' -- "$f")
        # Skip files with extensions (e.g. x-foo.py, x-foo.pl)
        if string match -qr '\.' -- "$name"
            continue
        end
        # Prefer #USAGE about, fall back to # @description
        set -l desc (grep -m1 '#USAGE about' "$f" 2>/dev/null \
            | string replace -r '#USAGE about "(.+)"' '$1')
        if test -z "$desc"
            set desc (grep -m1 '# @description' "$f" 2>/dev/null \
                | string replace -r '# @description ' '')
        end
        printf '%s\t%s\n' "$name" "$desc"
    end
end

# Disable default file completions for x
complete -c x -f

# Complete the subcommand name when no subcommand has been given yet
complete -c x -f \
    -n 'not __fish_seen_subcommand_from (__x_list_commands | string replace -r "\t.*" "")' \
    -a '(__x_list_commands)'
