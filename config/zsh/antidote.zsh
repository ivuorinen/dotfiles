#!/usr/bin/env bash
# Setup antidote for Oh My Zsh
# vim: ft=zsh et sw=2 ts=2

[[ -z "$DOTFILES" ]] && DOTFILES="$HOME/.dotfiles"
[[ -z "$ANTIDOTE_DIR" ]] && ANTIDOTE_DIR="$DOTFILES/tools/antidote"
[[ -z "$ANTIDOTE_HOME" ]] && ANTIDOTE_HOME="$XDG_CACHE_HOME/antidote"
[[ -z "$ANTIDOTE_PLUGINS" ]] && ANTIDOTE_PLUGINS="$XDG_CONFIG_HOME/zsh/antidote_plugins"

# antidote is a submodule already declared in .gitmodules. An rc file must not
# mutate the repo (a `git submodule add` here ran in whatever directory the
# shell started in), so a missing checkout only warns and skips plugins.
# Test the file that gets loaded, not the directory: a clone without
# --recursive leaves tools/antidote as an existing empty directory.
if [[ ! -r "$ANTIDOTE_DIR/functions/antidote" ]]; then
  echo "antidote missing: run 'git -C $DOTFILES submodule update --init tools/antidote'" >&2
  return 0
fi

# Plugin configurations
zstyle ':antidote:bundle' use-friendly-names 'yes'
zstyle ':omz:update' mode reminder

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
# Build into a temp file and move it into place only on success: a failed
# bundle written straight to the .zsh left a 0-byte file newer than the .txt,
# which the -nt check then never rebuilt. A 0-byte bundle counts as stale.
if [[ ! -s "${ANTIDOTE_PLUGINS}.zsh" || ! "${ANTIDOTE_PLUGINS}.zsh" -nt "${ANTIDOTE_PLUGINS}.txt" ]]; then
  if antidote bundle < "${ANTIDOTE_PLUGINS}.txt" >| "${ANTIDOTE_PLUGINS}.zsh.tmp"; then
    mv -f "${ANTIDOTE_PLUGINS}.zsh.tmp" "${ANTIDOTE_PLUGINS}.zsh"
  else
    rm -f "${ANTIDOTE_PLUGINS}.zsh.tmp"
  fi
fi

# Where friendly-names antidote keeps OMZ. getantidote/use-omz returns early
# when $ZSH is an existing dir; unset, it runs `antidote path ohmyzsh/ohmyzsh`
# in a subshell on every start (~0.3s).
export ZSH="$ANTIDOTE_HOME/ohmyzsh/ohmyzsh"

# Source your static plugins file.
# shellcheck source=$HOME/.dotfiles/config/zsh/antidote_plugins.zsh
[[ -r "${ANTIDOTE_PLUGINS}.zsh" ]] && source "${ANTIDOTE_PLUGINS}.zsh"
