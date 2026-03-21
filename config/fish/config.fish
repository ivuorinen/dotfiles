# ╭──────────────────────────────────────────────────────────╮
# │                     fish/config.fish                     │
# ╰──────────────────────────────────────────────────────────╯

set -g fish_greeting

fish_config theme choose "Catppuccin Mocha"

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

    # mise version manager
    type -q mise; and mise activate fish | source

    # Initialize other tools if available
    type -q zoxide; and zoxide init fish | source

    # Start tmux if not already running and not in SSH
    #.t # defined in functions/.t.fish
else
    # Non-interactive shells (IDE subprocesses) use shims for tool discovery
    type -q mise; and mise activate fish --shims | source
end

# Added by LM Studio CLI (lms)
set -gx PATH $PATH $HOME/.lmstudio/bin
# End of LM Studio CLI section

# vim: ft=fish ts=4 sw=4 et:

# opencode
fish_add_path $HOME/.opencode/bin

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :

# Warn if GITHUB_TOKEN is not set
if status is-interactive; and not set -q GITHUB_TOKEN
    echo "Warning: GITHUB_TOKEN is not set" >&2
end
test -x /opt/homebrew/bin/brew; and eval "$(/opt/homebrew/bin/brew shellenv fish)"
