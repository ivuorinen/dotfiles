# ╭──────────────────────────────────────────────────────────╮
# │                     fish/config.fish                     │
# ╰──────────────────────────────────────────────────────────╯

test -e "$HOME/.config/fish/alias.fish" &&
    source "$HOME/.config/fish/alias.fish"

test -e "$HOME/.config/fish/exports.fish" &&
    source "$HOME/.config/fish/exports.fish"

test -e "$HOME/.dotfiles/config/fzf/key-bindings.fish" &&
    source "$HOME/.dotfiles/config/fzf/key-bindings.fish"

if status is-interactive
    # Commands to run in interactive shell

    # 1Password plugins if op command is available
    type -q op; and test -e "$HOME/.config/op/plugins.sh" &&
        source "$HOME/.config/op/plugins.sh"

    # version manager initializers
    type -q rbenv; and source (rbenv init -|psub)
    type -q pyenv; and source (pyenv init -|psub)
    type -q pyenv; and source (pyenv virtualenv-init -|psub)
    type -q goenv; and source (goenv init -|psub)
    # type -q fnm; and fnm env --use-on-cd --shell fish | source
    type -q load_nvm; and load_nvm > /dev/stderr

    # Start tmux if not already running and not in SSH
    open-tmux # defined in functions/open-tmux.fish
end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH $HOME/.lmstudio/bin
# End of LM Studio CLI section

# vim: ft=fish ts=4 sw=4 et:

# opencode
fish_add_path /Users/ivuorinen/.opencode/bin

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
