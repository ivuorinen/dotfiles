# got this from github.com/1000Reasons
function gwl --description 'List worktrees'
    set -l top (git rev-parse --show-toplevel 2>/dev/null); or return
    set -l base (git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | string replace -r '^origin/' '')
    test -n "$base"; or set base main
    set -l blue
    set -l yellow
    set -l green
    set -l red
    set -l normal
    if isatty stdout
        set blue (set_color blue)
        set yellow (set_color yellow)
        set green (set_color green)
        set red (set_color red)
        set normal (set_color normal)
    end
    set -l home_re '^'(string escape --style=regex -- $HOME)
    set -l wt_path
    set -l head
    set -l branch
    # Porcelain records are blank-line separated; the trailing '' flushes the last one
    for line in (git worktree list --porcelain) ''
        switch $line
            case 'worktree *'
                set wt_path (string sub -s 10 -- $line)
            case 'HEAD *'
                set head (string sub -s 6 -- $line)
            case 'branch *'
                set branch (string replace refs/heads/ '' -- (string sub -s 8 -- $line))
            case detached
                set branch '(detached)'
            case ''
                if test -n "$head"
                    set -l mark ' '
                    test "$wt_path" = "$top"; and set mark '*'
                    set -l date (git log -1 --format=%cr $head)
                    set -l ab (git rev-list --left-right --count $head...$base 2>/dev/null | string replace \t ' ')
                    set -l wip
                    git log -1 --format=%s $head | string match -q -- '*--wip--*'; and set wip " $red"wip"$normal"
                    printf '%s %s%-22s%s %s%-8s%s %s%s%s %s%s\n' $mark \
                        "$blue" $date "$normal" "$yellow" "$ab" "$normal" "$green" $branch "$normal" \
                        (string replace -r -- $home_re '~' $wt_path) "$wip"
                end
                set wt_path
                set head
                set branch
        end
    end
end
