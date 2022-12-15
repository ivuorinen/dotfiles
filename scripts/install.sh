#!/bin/sh
#
# Usage:
#
#    sh install.sh
#
# Environment variables: VERBOSE, CP, LN, MKDIR, RM, DIRNAME.
#
#    env VERBOSE=1 sh install.sh
#
# DO NOT EDIT THIS FILE
#
# This file is generated by rcm(7) as:
#
#   rcup -B 0 -g
#
# To update it, re-run the above command.
#
: ${VERBOSE:=0}
: ${CP:=/bin/cp}
: ${LN:=/bin/ln}
: ${MKDIR:=/bin/mkdir}
: ${RM:=/bin/rm}
: ${DIRNAME:=/usr/bin/dirname}
verbose()
{
  if [ "$VERBOSE" -gt 0 ]; then
    echo "$@"
  fi
}
handle_file_cp()
{
  if [ -e "$2" ]; then
    printf "%s " "overwrite $2? [yN]"
    read overwrite
    case "$overwrite" in
      y)
        $RM -rf "$2"
        ;;
      *)
        echo "skipping $2"
        return
        ;;
    esac
  fi
  verbose "'$1' -> '$2'"
  $MKDIR -p "$($DIRNAME "$2")"
  $CP -R "$1" "$2"
}
handle_file_ln()
{
  if [ -e "$2" ]; then
    printf "%s " "overwrite $2? [yN]"
    read overwrite
    case "$overwrite" in
      y)
        $RM -rf "$2"
        ;;
      *)
        echo "skipping $2"
        return
        ;;
    esac
  fi
  verbose "'$1' -> '$2'"
  $MKDIR -p "$($DIRNAME "$2")"
  $LN -sf "$1" "$2"
}
handle_file_ln "$HOME/.dotfiles/bash_profile" "$HOME/.bash_profile"
handle_file_ln "$HOME/.dotfiles/bashrc" "$HOME/.bashrc"
handle_file_ln "$HOME/.dotfiles/config/alias" "$HOME/.config/alias"
handle_file_ln "$HOME/.dotfiles/config/exports" "$HOME/.config/exports"
handle_file_ln "$HOME/.dotfiles/config/functions" "$HOME/.config/functions"
handle_file_ln "$HOME/.dotfiles/config/gh/config.yml" "$HOME/.config/gh/config.yml"
handle_file_ln "$HOME/.dotfiles/config/git/config" "$HOME/.config/git/config"
handle_file_ln "$HOME/.dotfiles/config/git/gitignore" "$HOME/.config/git/gitignore"
handle_file_ln "$HOME/.dotfiles/config/wtf/config.yml" "$HOME/.config/wtf/config.yml"
handle_file_ln "$HOME/.dotfiles/git_profiles" "$HOME/.git_profiles"
handle_file_ln "$HOME/.dotfiles/huskyrc" "$HOME/.huskyrc"
handle_file_ln "$HOME/.dotfiles/local/bin/antigen.zsh" "$HOME/.local/bin/antigen.zsh"
handle_file_ln "$HOME/.dotfiles/local/bin/dfm" "$HOME/.local/bin/dfm"
handle_file_ln "$HOME/.dotfiles/local/bin/foreach" "$HOME/.local/bin/foreach"
handle_file_ln "$HOME/.dotfiles/local/bin/x-check-git-attributes" "$HOME/.local/bin/x-check-git-attributes"
handle_file_ln "$HOME/.dotfiles/local/bin/x-open-ports" "$HOME/.local/bin/x-open-ports"
handle_file_ln "$HOME/.dotfiles/rcrc" "$HOME/.rcrc"
handle_file_ln "$HOME/.dotfiles/ssh/allowed_signers" "$HOME/.ssh/allowed_signers"
handle_file_ln "$HOME/.dotfiles/ssh/config" "$HOME/.ssh/config"
handle_file_ln "$HOME/.dotfiles/vuerc" "$HOME/.vuerc"
handle_file_ln "$HOME/.dotfiles/zshrc" "$HOME/.zshrc"
