# got this from github.com/1000Reasons
function gbl --description 'List branches'
    set -l base (git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | string replace -r '^origin/' '')
    test -n "$base"; or set base main
    set -l color never
    isatty stdout; and set color always
    set -l wip wip
    test $color = always; and set wip (set_color red)wip(set_color normal)
    # Tab-separated tip subject flags gwip commits ("--wip--", same check as gunwip)
    git --no-pager branch --color=$color --sort=-committerdate $argv \
        --format="%(HEAD) %(color:blue)%(align:22)%(committerdate:relative)%(end)%(color:reset) %(color:yellow)%(align:8)%(ahead-behind:$base)%(end)%(color:reset) %(color:green)%(refname:short)%(color:reset)	%(contents:subject)" |
        while read --delimiter \t -l line subject
            if string match -q -- '*--wip--*' $subject
                echo "$line $wip"
            else
                echo $line
            end
        end
end
