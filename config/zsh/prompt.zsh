#!/usr/bin/env bash
# Setup prompt
# vim: ft=zsh:

setopt PROMPT_SUBST

# Setup vcs_info
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' max-exports 2
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' check-for-staged-changes true
zstyle ':vcs_info:*' use-simple true
zstyle ':vcs_info:*' unstagedstr '%F{red}*'   # display this when there are unstaged changes
zstyle ':vcs_info:*' stagedstr '%F{yellow}+'  # display this when there are staged changes

zstyle ':vcs_info:*' formats '%F{5}%F{2}%b%c%u%F{5}%f '
zstyle ':vcs_info:*' actionformats '%F{5}%F{2}%b%F{3}|%F{1}%a%c%u%F{5}%f '

theme_precmd () {
  vcs_info
}

export NL=$'\n'

# Set defaults for display.
# We want the host always, but only the user if we are in an SSH session or root.
P_HOST="%F{green}%m%f"
P_USER=''

# If we are in an SSH session, we want to show the username
[[ "$SSH_CONNECTION" != '' ]] && P_USER="%{${fg}[magenta]%}%n%f"

# If we are root, color the user name differently
[[ $UID -eq 0 ]] && P_USER="%{${fg}[red]%}%n%f"

# If P_USER is set, suffix user with @ giving us user@host
[[ -n "$P_USER" ]] && P_USER="$P_USER@"

# Combine the prompt parts. Could be just the host, or user@host.
P_PREFIX="$P_USER$P_HOST"

# Set the color of the current directory
P_DIR="%F{blue}%~%f"

# Change the color of the prompt if the last command failed
P_SHELL="%(?.%F{green}.%F{red})➜%f"

# Any extras we want to display
P_EXTRA=""

# Set the prompt
# user@host /path/to/current/dir (branch) ➜
export PROMPT="${P_PREFIX} ${P_DIR} %{$reset_color%}${vcs_info_msg_0_}%{$reset_color%}%{${P_EXTRA}%}${NL}${P_SHELL} "

autoload -U add-zsh-hook
add-zsh-hook precmd theme_precmd
