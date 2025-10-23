# Description: Open tmux session if not already open
# Dependencies: tmux
# Usage: open-tmux
function open-tmux --wraps='tmux attach-session -t main || tmux new-session -s main' --description 'open tmux session'
    # Check if not in an SSH session and not already in a tmux session
    if test -z "$SSH_TTY"; and not set -q TMUX
        command tmux attach-session -t main || command tmux new-session -s main
    end
end
