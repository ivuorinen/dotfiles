# shellcheck shell=bash

autoload -U colors zsh/terminfo
colors

# Defaults
export DOTFILES="$HOME/.dotfiles"

# Explicitly set XDG folders
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_BIN_HOME="$HOME/.local/bin" # this one is custom

# Homebrew configuration
export HOMEBREW="/opt/homebrew"
export HOMEBREW_BIN="$HOMEBREW/bin"
export HOMEBREW_SBIN="$HOMEBREW/sbin"
export HOMEBREW_PKG="$HOMEBREW/opt"
export HOMEBREW_NO_ENV_HINTS=1

export PATH="$XDG_BIN_HOME:$HOMEBREW_BIN:$HOMEBREW_SBIN:/usr/local/sbin:$PATH"

# brew, https://brew.sh
if [ command -v brew &> /dev/null ]; then
    BREW_BIN=$(brew --prefix)/bin
    BREW_SBIN=$(brew --prefix)/sbin

    BREW_PYTHON=$(brew --prefix python@3.8)/bin
    GNUBIN_DIR=$(brew --prefix coreutils)/libexec/gnubin
    BREW_RUBY=$(brew --prefix ruby)/bin
    BREW_GEMS=$(gem environment gemdir)/bin

    export PATH="$BREW_PYTHON:$GNUBIN_DIR:$BREW_GEMS:$BREW_RUBY:$BREW_BIN:$BREW_SBIN:$PATH"
fi

# If we have go packages, include them to the PATH
if command -v go &> /dev/null; then
    export GOPATH=$(go env GOPATH);
    if [ -d "$GOPATH/bin" ]; then
        export PATH="$GOPATH/bin:$PATH"
    fi
fi

if command -v nvim &> /dev/null; then
    export EDITOR="nvim"
fi

# z, https://github.com/rupa/z
export _Z_DATA="$XDG_STATE_HOME/z"

# composer, https://getcomposer.org/
if command -v composer &> /dev/null; then
    export COMPOSER_HOME="$XDG_STATE_HOME/composer"
    export COMPOSER_BIN="$COMPOSER_HOME/vendor/bin"
    export PATH="$COMPOSER_BIN:$PATH"
fi

# gem, rubygems
if command -v gem &>/dev/null; then
    export GEM_HOME="$XDG_STATE_HOME/gem"
    export GEM_PATH="$XDG_STATE_HOME/gem"
fi

# nvm, the node version manager
export NVM_DIR="$XDG_STATE_HOME/nvm"
export NVM_LAZY_LOAD=true
export NVM_COMPLETION=true
export NVM_AUTO_USE=true
[ -s "$HOMEBREW_PKG/nvm/nvm.sh" ] && \. "$HOMEBREW_PKG/nvm/nvm.sh"
[ -s "$HOMEBREW_PKG/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PKG/nvm/etc/bash_completion.d/nvm"

# wakatime, https://github.com/wakatime/wakatime-cli
export WAKATIME_HOME="$XDG_STATE_HOME/wakatime"

# Run x-load-configs in your terminal to reload the files.
function x-load-configs()
{
    # Load the shell dotfiles, and then some:
    for file in $DOTFILES/config/{exports,alias,functions}; do
        [ -r "$file" ] && [ -f "$file" ] && source "$file"
        [ -r "$file-secret" ] && [ -f "$file-secret" ] && source "$file-secret"
        [ -r "$file-$HOSTNAME" ] && [ -f "$file-$HOSTNAME" ] && source "$file-$HOSTNAME"
        [ -r "$file-$HOSTNAME-secret" ] && [ -f "$file-$HOSTNAME-secret" ] && source "$file-$HOSTNAME-secret"
    done
}
x-load-configs

# Import ssh keys in keychain
ssh-add -A 2>/dev/null;

# Antigen configuration
# https://github.com/zsh-users/antigen/wiki/Configuration
export ADOTDIR="$XDG_DATA_HOME/antigen"
export ANTIGEN_SYSTEM_RECEIPT_F=".local/share/antigen/antigen_system_lastupdate"
export ANTIGEN_PLUGIN_RECEIPT_F=".local/share/antigen/antigen_plugin_lastupdate"

# Try to load antigen, if present
[[ -f "$XDG_BIN_HOME/antigen.zsh" ]] && source "$XDG_BIN_HOME/antigen.zsh"

# antigen is present
if command -v antigen &> /dev/null; then
    antigen use oh-my-zsh

    antigen bundle ssh-agent
    antigen bundle colored-man-pages
    antigen bundle jreese/zsh-titles
    antigen bundle zsh-users/zsh-syntax-highlighting
    antigen bundle zsh-users/zsh-completions
    antigen bundle MichaelAquilina/zsh-you-should-use
    antigen bundle unixorn/autoupdate-antigen.zshplugin
    antigen bundle Sparragus/zsh-auto-nvm-use

    hash php 2>/dev/null && antigen bundle php
    hash nvm 2>/dev/null && antigen bundle nvm
    hash docker 2>/dev/null && antigen bundle docker
    # hash ruby 2>/dev/null && antigen bundle ruby
    hash python 2>/dev/null && antigen bundle MichaelAquilina/zsh-autoswitch-virtualenv
    hash jq 2>/dev/null && antigen bundle reegnz/jq-zsh-plugin
    hash docker-compose 2>/dev/null && antigen bundle sroze/docker-compose-zsh-plugin

    # Platform dependant bundles
    if [[ $(uname) == 'Linux' ]]; then
        antigen bundle command-not-found
    elif [[ $(uname) == 'Darwin' ]]; then
        # If we have brew installed
        if command -v brew &> /dev/null; then
            # Only enable brew plugin if brew exists
            antigen bundle brew
            # load Z
            [[ -f "$(brew --prefix z)/etc/profile.d/z.sh" ]] && source "$(brew --prefix z)/etc/profile.d/z.sh"
        fi
    fi

    antigen apply
fi

# op (1Password cli) is present
if hash op 2>/dev/null; then
    eval "$(op completion zsh)"; compdef _op op
fi

# gcloud is present
#if hash gcloud 2>/dev/null; then
#    GCLOUD_LOC=$(gcloud info --format="value(installation.sdk_root)" --quiet)
#    [[ -f "$GCLOUD_LOC/path.zsh.inc" ]] && builtin source "$GCLOUD_LOC/path.zsh.inc"
#    [[ -f "$GCLOUD_LOC/completion.zsh.inc" ]] && builtin source "$GCLOUD_LOC/completion.zsh.inc"
#fi

# Load iterm2 shell integration
# https://iterm2.com/documentation-shell-integration.html
[[ -f "$XDG_BIN_HOME/iterm2_shell_integration.zsh" ]] && source "$XDG_BIN_HOME/iterm2_shell_integration.zsh"

eval "$(starship init zsh)"
