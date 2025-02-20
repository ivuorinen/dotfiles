# Description: Open tmux session if not already open
# Dependencies: tmux
# Usage: open-tmux
function open-tmux --wraps='tmux attach-session -t main || tmux new-session -s main' --description 'open tmux session'
  if test -z "$SSH_TTY"
    if not set -q TMUX
      tmux attach-session -t main || tmux new-session -s main
    end
  end
end
