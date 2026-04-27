# ╭──────────────────────────────────────────────────────────╮
# │                     fish/config.fish                     │
# ╰──────────────────────────────────────────────────────────╯

set -g fish_greeting

# Catppuccin theme controls fish syntax/completion colours; the prompt
# itself is rendered by starship (see below). The Catppuccin Mocha theme
# file holds both [light] and [dark] palettes; conf.d/theme-switch.fish
# re-saves it on dark/light flip so syntax colours follow the OS.
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

    # Starship prompt — colours flip via ~/.config/starship.toml symlink swap managed by the theme orchestrator (config/theme/handlers.d/starship).
    # `enable_transience` collapses prior prompts to just the character
    # symbol so scrollback stays clean (matches tide --transient=Yes).
    if type -q starship
        starship init fish | source
        function starship_transient_prompt_func
            starship module character
        end
        enable_transience
    end

    # Initialize other tools if available
    type -q zoxide; and zoxide init fish | source

    # Seed zoxide with project dirs in the background so sesh/gum finds them
    type -q zoxide; and type -q fd; and functions -q zoxide-seed; and zoxide-seed &
    disown 2>/dev/null

    # Start tmux if not already running and not in SSH
    #.t # defined in functions/.t.fish
else
    # Non-interactive shells (IDE subprocesses) use shims for tool discovery
    type -q mise; and mise activate fish --shims | source
end

# Added by LM Studio CLI (lms)
fish_add_path $HOME/.lmstudio/bin
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

# Spawn the theme orchestrator watcher (no-op if one is already running;
# the watcher self-locks). Skip in SSH sessions — the remote OS is the
# wrong oracle; rely on per-session OSC 11 via `apply $(theme-mode)`.
if status is-interactive
    if not set -q SSH_TTY; and not set -q SSH_CONNECTION
        set -l watcher "$DOTFILES/config/theme/watcher"
        if test -x $watcher
            $watcher >/dev/null 2>&1 &
            disown 2>/dev/null
        end
    end
    # Bootstrap mode so the prompt + LS_COLORS are right on first prompt.
    set -l apply "$DOTFILES/config/theme/apply"
    if test -x $apply
        set -l m (theme-mode 2>/dev/null)
        $apply $m >/dev/null 2>&1
    end
end
