# got this from github.com/1000Reasons
function gbd --description 'List local branches merged into remote base; delete with --delete'
    argparse d/delete -- $argv; or return
    git fetch --prune; or return
    set -l base (git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | string replace -r '^origin/' '')
    test -n "$base"; or set base main
    # Skip base, current (*) and worktree-checked-out (+) branches
    set -l branches (git branch --merged origin/$base | string match -rv '^[*+]|^\s*'$base'$' | string trim)
    if test (count $branches) -eq 0
        echo 'No merged branches'
        return
    end
    if not set -q _flag_delete
        printf '%s\n' $branches
        echo 'Dry run; rerun with --delete to delete'
        return
    end
    git branch -d $branches
end
