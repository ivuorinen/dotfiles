# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
# shellcheck shell=bash

autoload -U colors zsh/terminfo
colors

export HOMEBREW="/opt/homebrew"
export DOTFILES="$HOME/.dotfiles"
export PATH="$HOMEBREW/opt/ruby/bin:$HOMEBREW/bin:$HOMEBREW/sbin:/usr/local/sbin:$PATH"
export HOMEBREW_NO_ENV_HINTS=1

# Explicitely set XDG folders
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"

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

LOCAL_BIN="$HOME/.local/bin"
COMPOSER_DIR="$HOME/.composer/vendor/bin"
export PATH="$LOCAL_BIN:$COMPOSER_DIR:$PATH"

export NVM_DIR="$HOME/.nvm"
export NVM_LAZY_LOAD=true
export NVM_COMPLETION=true
export NVM_AUTO_USE=true
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# Run x-load-configs in your terminal to reload the files.
function x-load-configs()
{
    # Load the shell dotfiles, and then some:
    for file in ~/.dotfiles/config/{exports,alias,functions}; do
        [ -r "$file" ] && [ -f "$file" ] && source "$file"
        [ -r "$file-secret" ] && [ -f "$file-secret" ] && source "$file-secret"
        [ -r "$file-$HOSTNAME" ] && [ -f "$file-$HOSTNAME" ] && source "$file-$HOSTNAME"
        [ -r "$file-$HOSTNAME-secret" ] && [ -f "$file-$HOSTNAME-secret" ] && source "$file-$HOSTNAME-secret"
    done
}
x-load-configs

# Import ssh keys in keychain
ssh-add -A 2>/dev/null;

# Try to load antigen, if present
[[ -f "$HOME/.local/bin/antigen.zsh" ]] && source "$HOME/.local/bin/antigen.zsh"

# antigen is present
if command -v antigen &> /dev/null; then
    antigen use oh-my-zsh

    # antigen theme oskarkrawczyk/honukai-iterm-zsh honukai

    antigen bundle ssh-agent
    antigen bundle colored-man-pages
    antigen bundle jreese/zsh-titles
    antigen bundle zsh-users/zsh-syntax-highlighting
    antigen bundle zsh-users/zsh-completions
    antigen bundle MichaelAquilina/zsh-you-should-use
    antigen bundle unixorn/autoupdate-antigen.zshplugin
    antigen bundle Sparragus/zsh-auto-nvm-use
    # antigen bundle git-auto-fetch

    hash php 2>/dev/null && antigen bundle php
    hash nvm 2>/dev/null && antigen bundle nvm
    hash docker 2>/dev/null && antigen bundle docker
    # hash ruby 2>/dev/null && antigen bundle ruby
    # hash python 2>/dev/null && antigen bundle MichaelAquilina/zsh-autoswitch-virtualenv
    hash jq 2>/dev/null && antigen bundle reegnz/jq-zsh-plugin
    hash docker-compose 2>/dev/null && antigen bundle sroze/docker-compose-zsh-plugin
    # antigen bundle voronkovich/phpcs.plugin.zsh

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

eval "$(starship init zsh)"

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
