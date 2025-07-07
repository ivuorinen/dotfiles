# cr.fish — Create and manage code review worktrees for Fish shell
#
# Synopsis:
#   cr [OPTIONS] <source-branch>
#   cr cleanup [OPTIONS]
#
# Description:
#   Create a dedicated worktree for reviewing code based on a ticket ID
#   extracted from a branch name, or clean up existing cr- worktrees.
#
# Constants:
#   CR_DEFAULT_REMOTE      Default Git remote used when none specified
#
# Fish Requirements:
#   Fish shell >= 3.1.0 for argparse builtin
#
# Based on work by ville6000 (https://github.com/ville6000)
#
# Examples:
#   cr feature/1234-add-login
#   cr -r upstream 5678
#   cr cleanup --dry-run

if not set -q CR_DEFAULT_REMOTE
    set -g CR_DEFAULT_REMOTE origin
end

function __cr_show_help
    echo 'Usage: cr [OPTIONS] <source-branch>'
    echo '       cr cleanup [OPTIONS]'
    echo
    echo "  -r, --remote <name>        Git remote (default: $CR_DEFAULT_REMOTE)"
    echo '  -d, --dry-run              Show actions without executing'
    echo '  -f, --force                Skip confirmation prompts'
    echo '  -k, --keep-branch          In cleanup, keep local branches'
    echo '  -b, --branch-only <ticket> Create only the review branch (no worktree)'
    echo '      --cleanup-branches-only In cleanup, delete branches only'
    echo '  -h, --help                 Show this help'
end

function __cr_run_with_spinner --argument-names msg cmd
    set -l tmp (mktemp)
    eval $cmd >$tmp 2>&1 &
    set -l pid $last_pid
    set -l spin_chars '/-\|'
    set -l i 1
    while kill -0 $pid 2>/dev/null
        printf "\r[%c] %s" (string sub -s $i -l 1 $spin_chars) "$msg"
        set i (math (math $i % 4) + 1)
        sleep 0.1
    end
    printf "\r%s\r" (string repeat -n (math (string length "$msg") + 5) " ")
    wait $pid
    set -l output (cat $tmp)
    rm $tmp
    # Remove any leading empty or all-whitespace lines (from spinner clear)
    for line in $output
        if test -n (string trim -- $line)
            echo $line
        end
    end
end

function __cr_cleanup
    argparse dry_run force keep_branch cleanup_branches_only -- $argv
    or return

    set -l dry_run (set -q _flag_dry_run; and echo 1; or echo 0)
    set -l force (set -q _flag_force; and echo 1; or echo 0)
    set -l keep_branch (set -q _flag_keep_branch; and echo 1; or echo 0)
    set -l branches_only (set -q _flag_cleanup_branches_only; and echo 1; or echo 0)

    set -l target_branch
    if test (count $argv) -gt 0
        set target_branch $argv[1]
    end

    git worktree prune

    for wt in (git worktree list --porcelain | awk '/^worktree /{print $2}')
        set -l base (basename $wt)
        if string match -r '^cr-.*' $base
            if test -n "$target_branch" -a "$base" != "$target_branch"
                continue
            end
            if test "$branches_only" = 0
                if test "$dry_run" = 1
                    echo "[DRY-RUN] remove worktree: $wt"
                else if test "$force" = 1
                    git worktree remove --force $wt
                else
                    echo "git worktree remove --force $wt"
                    echo "(!) Use --force to actually remove worktree: $wt."
                end
            end
            if test "$keep_branch" = 0
                if test "$branches_only" = 0
                    if test "$dry_run" = 1
                        echo "[DRY-RUN] delete branch: $base"
                    else if test "$force" = 1
                        git branch -D $base
                    else
                        echo "git branch -D $base"
                        echo "(!) Use --force to actually delete branch: $base."
                    end
                end
            end
        end
    end
end

# --- Main Entrypoint ---

function cr --description 'Create or cleanup code-review worktrees'
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "Not inside a git repository." >&2
        return 1
    end

    set -l remotes (git remote)
    if test (count $remotes) -eq 0
        echo "No git remotes found. Please add a remote before using cr." >&2
        return 1
    end

    if not type -q argparse
        echo 'cr.fish requires the argparse builtin' >&2
        return 1
    end

    argparse \
        r/remote= \
        h/help \
        d/dry-run \
        f/force \
        y/yes \
        k/keep-branch \
        b/branch-only= \
        cleanup-branches-only \
        -- $argv
    or return

    if set -q _flag_h; or set -q _flag_help
        __cr_show_help
        return 0
    end

    set -l remote (set -q _flag_remote; and echo $_flag_remote[-1]; or echo $CR_DEFAULT_REMOTE)
    if set -q _flag_yes
        set -g _flag_force 1
    end

    if not contains $remote $remotes
        echo "Remote '$remote' does not exist. Available remotes: $remotes" >&2
        return 1
    end

    if test (count $argv) -gt 0 -a "$argv[1]" = cleanup
        __cr_cleanup \
            (set -q _flag_dry_run; and echo --dry_run) \
            (set -q _flag_force; and echo --force) \
            (set -q _flag_keep_branch; and echo --keep_branch) \
            (set -q _flag_cleanup_branches_only; and echo --cleanup_branches_only)
        return 0
    end

    set -l source_branch ""
    if test (count $argv) -gt 0
        set source_branch $argv[1]
    else if type -q fzf
        set -l branches (__cr_run_with_spinner "Fetching branches..." \
            "git ls-remote --heads $remote | sed 's|.*refs/heads/||'")
        printf "\n"
        if test (count $branches) -eq 0
            echo "No branches found on remote '$remote'." >&2
            return 1
        end
        set -l exclude_branches main master develop dev trunk
        set -l filtered_branches
        for b in $branches
            set b (string trim -- $b)
            if not contains -- $b $exclude_branches
                set filtered_branches $filtered_branches $b
            end
        end
        set source_branch (printf '%s\n' $filtered_branches | fzf --prompt='Select branch: ')
        echo "Selected branch: $source_branch"
        if test $status -ne 0
            echo 'Selection aborted' >&2
            return 1
        end
        if test -z "$source_branch"
            echo 'No branch selected' >&2
            return 1
        end
    else
        __cr_show_help >&2
        return 1
    end

    # Extract ticket ID from branch name, or use slug if not found
    set -l branch_tail (string split "/" $source_branch)[-1]
    set -l ticket_id (printf '%s\n' $branch_tail | grep -o '[0-9]\+' | tail -n1)
    set -l review_suffix ""
    if test -z "$ticket_id"
        # No numeric ticket, use slug of branch name as suffix
        set review_suffix (string replace -ra '[^a-zA-Z0-9]+' '-' -- $source_branch)
    else
        set review_suffix $ticket_id
    end
    if set -q _flag_b; or set -q _flag_branch_only
        set review_suffix $_flag_branch_only[-1]
    end
    set -l review_branch cr-$review_suffix
    set -l folder ../$review_branch

    # Branch-only mode
    if set -q _flag_b; or set -q _flag_branch_only
        if set -q _flag_dry_run
            echo "[DRY-RUN] Create branch $review_branch from $remote/$source_branch"
            return 0
        end
        __cr_run_with_spinner "Fetching from $remote..." \
            "git fetch $remote $source_branch"
        git branch $review_branch $remote/$source_branch
        echo "Created branch $review_branch"
        return 0
    end

    __cr_run_with_spinner "Checking remote branch..." \
        "git ls-remote --exit-code --heads $remote $source_branch >/dev/null 2>&1"
    if test $status -ne 0
        echo "No remote branch $remote/$source_branch" >&2
        return 1
    end
    if git show-ref --quiet refs/heads/$review_branch
        echo "Local branch $review_branch exists" >&2
        return 1
    end
    if test -d $folder
        echo "Directory $folder exists" >&2
        return 1
    end

    if set -q _flag_dry_run
        echo "[DRY-RUN] Add worktree $folder -b $review_branch $remote/$source_branch"
        return 0
    end

    __cr_run_with_spinner "Fetching from $remote..." \
        "git fetch $remote $source_branch"
    git worktree add $folder -b $review_branch $remote/$source_branch
end

# --- Completion Functions ---

complete -c cr -l help -s h -f -d 'Show help'
complete -c cr -l remote -s r -f -d 'Git remote' -a '(git remote)'
complete -c cr -l dry-run -s d -f -d 'Dry run'
complete -c cr -l force -s f -f -d 'Skip confirmations'
complete -c cr -l keep-branch -s k -f -d 'Keep branches in cleanup'
complete -c cr -l branch-only -s b -f -d 'Branch-only mode' \
    -a '(__fish_cr_ticket_ids)'
complete -c cr -l cleanup-branches-only -f -d 'Branches-only cleanup'
complete -c cr -f -a cleanup -d 'Cleanup mode' \
    -n 'not __fish_seen_subcommand_from cleanup'
complete -c cr -n '__fish_seen_subcommand_from cleanup' -f \
    -a '(__fish_cr_cleanup_branches)' -d 'cr-* branch'
complete -c cr -n '__fish_seen_subcommand_from cleanup' -f
complete -c cr -n 'not __fish_seen_subcommand_from cleanup' -f \
    -a '(__fish_cr_branches)' -d 'Source branch'

function __fish_cr_cleanup_branches
    git worktree list --porcelain | awk '/^worktree /{print $2}' | while read -l wt
        set base (basename $wt)
        if string match -r '^cr-.*' $base
            echo $base
        end
    end
end

function __fish_cr_branches --description 'List remote branches'
    set -l exclude_branches main master develop dev trunk
    set -l branches (git ls-remote --heads $CR_DEFAULT_REMOTE | \
        sed 's|.*refs/heads/||')
    for b in $branches
        set b (string trim -- $b)
        if not contains -- $b $exclude_branches
            echo $b
        end
    end
end

function __fish_cr_ticket_ids --description 'List ticket IDs from remote branches'
    for b in (git ls-remote --heads $CR_DEFAULT_REMOTE | \
        sed 's|.*refs/heads/||')
        set b (string trim -- $b)
        set -l id (string match -r '[0-9]+' -- $b)
        if test -n "$id"
            echo $id
        end
    end
end
