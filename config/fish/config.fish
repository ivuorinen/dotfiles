# ╭──────────────────────────────────────────────────────────╮
# │                     fish/config.fish                     │
# ╰──────────────────────────────────────────────────────────╯

test -e "$HOME/.config/fish/alias.fish" &&
    source "$HOME/.config/fish/alias.fish"

test -e "$HOME/.config/fish/exports.fish" &&
    source "$HOME/.config/fish/exports.fish"

if status is-interactive
  # Commands to run in interactive sessions can go here

  # Start tmux if not already running and not in SSH
  open-tmux # defined in functions/open-tmux.fish
end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH $HOME/.lmstudio/bin
