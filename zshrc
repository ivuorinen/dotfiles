# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
# shellcheck shell=bash

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

LOCAL_BIN="$HOME/.local/bin"
OPT_FOLDER="/usr/local/opt"
PHP_74=$(brew --prefix php@7.4)/bin
PHP_80=$(brew --prefix php@8.0)/bin
PHP_CUR=$(brew --prefix php)/bin
PYTHON_38="$HOME/Library/Python/3.8/bin"
COMPOSER_DIR="$HOME/.composer/vendor/bin"
BREW_PYTHON=$(brew --prefix python@3.8)/bin
GNUBIN_DIR=$(brew --prefix coreutils)/libexec/gnubin
BREW_RUBY=$(brew --prefix ruby)/bin
BREW_GEMS=$(gem environment gemdir)/bin
USR_SBIN=/usr/local/sbin

export PATH="$LOCAL_BIN:$PYTHON_38:$COMPOSER_DIR:$BREW_PYTHON:$GNUBIN_DIR:$BREW_GEMS:$BREW_RUBY:$USR_SBIN:$PATH"
source "$HOME/.config/antigen.zsh"

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

export NVM_DIR="$HOME/.nvm"
export NVM_LAZY_LOAD=true
export NVM_COMPLETION=true
export NVM_AUTO_USE=true

antigen use oh-my-zsh

antigen bundle php
antigen bundle nvm
# antigen bundle ruby
antigen bundle docker
antigen bundle ssh-agent
# antigen bundle git-auto-fetch

antigen bundle colored-man-pages
antigen bundle jreese/zsh-titles
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-completions

antigen bundle Sparragus/zsh-auto-nvm-use
antigen bundle reegnz/jq-zsh-plugin
antigen bundle MichaelAquilina/zsh-you-should-use
antigen bundle sroze/docker-compose-zsh-plugin
# antigen bundle voronkovich/phpcs.plugin.zsh
antigen bundle unixorn/autoupdate-antigen.zshplugin

antigen theme oskarkrawczyk/honukai-iterm-zsh honukai

# Platform dependant bundles
if [[ $(uname) == 'Linux' ]]
then
    antigen bundle command-not-found
elif [[ $(uname) == 'Darwin' ]]
then
    # Only enable brew plugin if brew exists
    hash brew 2>/dev/null && antigen bundle brew
fi

antigen apply

export HIST_STAMPS="yyyy-mm-dd"

source "$HOME/.alias"

GCLOUD_INSTALL_LOCATION=$(gcloud info --format="value(installation.sdk_root)" --quiet)

source "$GCLOUD_INSTALL_LOCATION/path.zsh.inc"
source "$GCLOUD_INSTALL_LOCATION/completion.zsh.inc"
source "$(brew --prefix z)/etc/profile.d/z.sh"

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
