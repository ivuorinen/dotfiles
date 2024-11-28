#!/usr/bin/env bash
# Setup antidote for Oh My Zsh
# vim: ft=zsh et sw=2 ts=2

[[ -z "$DOTFILES" ]] && DOTFILES="$HOME/.dotfiles"
[[ -z "$ANTIDOTE_DIR" ]] && ANTIDOTE_DIR="$DOTFILES/tools/antidote"
[[ -z "$ANTIDOTE_HOME" ]] && ANTIDOTE_HOME="$XDG_CACHE_HOME/antidote"
[[ -z "$ANTIDOTE_PLUGINS" ]] && ANTIDOTE_PLUGINS="$XDG_CONFIG_HOME/zsh/antidote_plugins"

[[ ! -d "$ANTIDOTE_DIR" ]] && {
  git submodule add \
    --name antidote \
    --depth=1 \
    -f https://github.com/mattmc3/antidote.git "${ANTIDOTE_DIR}"
  git config -f .gitmodules submodule.antidote.shallow true
}

# Plugin configurations
zstyle ':antidote:bundle' use-friendly-names 'yes'
zstyle ':omz:update' mode reminder
zstyle ':omz:plugins:nvm' autoload yes

# Pure prompt settings
export PURE_PROMPT_SYMBOL='➜'
export PURE_GIT_UNTRACKED_DIRTY=0
zstyle ':prompt:pure:git:stash' show yes
zstyle ':prompt:pure:path' color white
zstyle ':prompt:pure:prompt:success' color green
zstyle ':prompt:pure:prompt:error' color red

# Disable ls colors to avoid issues with eza
export DISABLE_LS_COLORS=true
zstyle ':omz:plugins:eza' 'dirs-first' yes
zstyle ':omz:plugins:eza' 'git-status' yes
zstyle ':omz:plugins:eza' 'icons' yes
zstyle ':omz:plugins:eza' 'ls' yes
zstyle ':omz:plugins:eza' 'prompt' yes

[[ -f "${ANTIDOTE_PLUGINS}.txt" ]] || touch "${ANTIDOTE_PLUGINS}.txt"
FPATH="$ANTIDOTE_DIR/functions:$FPATH"
autoload -Uz antidote
if [[ ! "${ANTIDOTE_PLUGINS}.zsh" -nt "${ANTIDOTE_PLUGINS}.txt" ]]; then
  antidote bundle <"${ANTIDOTE_PLUGINS}.txt" >|"${ANTIDOTE_PLUGINS}.zsh"
fi

# Source your static plugins file.
# shellcheck source=$HOME/.dotfiles/config/zsh/antidote_plugins.zsh
source "${ANTIDOTE_PLUGINS}.zsh"
