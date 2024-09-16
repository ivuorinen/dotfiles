#!/usr/bin/env bash

# dotbot and plugins
git submodule add --name dotbot \
  -f https://github.com/anishathalye/dotbot.git tools/dotbot
git submodule add --name dotbot-brew \
  -f https://github.com/wren/dotbot-brew.git tools/dotbot-brew
git submodule add --name dotbot-include \
  -f https://gitlab.com/gnfzdz/dotbot-include.git tools/dotbot-include
git submodule add --name dotbot-pip \
  -f https://github.com/sobolevn/dotbot-pip.git tools/dotbot-pip

git submodule add --name nvim-kickstart \
  -f https://github.com/ivuorinen/kickstart.nvim config/nvim-kickstart

# other repos
git submodule add --name cheat-community \
  -f https://github.com/cheat/cheatsheets.git config/cheat/cheatsheets/community
git submodule add --name cheat-tldr \
  -f https://github.com/ivuorinen/cheatsheet-tldr.git config/cheat/cheatsheets/tldr
git submodule add --name asdf \
  -f https://github.com/asdf-vm/asdf.git local/bin/asdf

# tmux plugin manager and plugins
git submodule add --name tmux/tmux-continuum \
  -f https://github.com/tmux-plugins/tmux-continuum config/tmux/plugins/tmux-continuum
git submodule add --name tmux/tmux-mode-indicator \
  -f https://github.com/MunifTanjim/tmux-mode-indicator.git config/tmux/plugins/tmux-mode-indicator
git submodule add --name tmux/tmux-resurrect \
  -f https://github.com/tmux-plugins/tmux-resurrect config/tmux/plugins/tmux-resurrect
git submodule add --name tmux/tmux-sensible \
  -f https://github.com/tmux-plugins/tmux-sensible.git config/tmux/plugins/tmux-sensible
git submodule add --name tmux/tmux-sessionist \
  -f https://github.com/tmux-plugins/tmux-sessionist.git config/tmux/plugins/tmux-sessionist
git submodule add --name tmux/tmux-suspend \
  -f https://github.com/MunifTanjim/tmux-suspend.git config/tmux/plugins/tmux-suspend
git submodule add --name tmux/tmux-window-name \
  -f https://github.com/ivuorinen/tmux-window-name.git config/tmux/plugins/tmux-window-name
git submodule add --name tmux/tmux-yank \
  -f https://github.com/tmux-plugins/tmux-yank.git config/tmux/plugins/tmux-yank
git submodule add --name tmux/tmux-current-pane-hostname \
  -f https://github.com/soyuka/tmux-current-pane-hostname.git config/tmux/plugins/tmux-current-pane-hostname

# Takes submodules and sets them to ignore all changes
for MODULE in $(git config --file .gitmodules --get-regexp path | awk '{ print $2 }'); do
  git config "submodule.${MODULE}.ignore" all
done

# remove old submodules
[ -d "config/tmux/plugins/tpm" ] && rm -rf config/tmux/plugins/tpm
[ -d "config/tmux/plugins/tmux" ] && rm -rf config/tmux/plugins/tmux
[ -d "config/tmux/plugins/tmux-menus" ] && rm -rf config/tmux/plugins/tmux-menus
[ -d "config/tmux/plugins/tmux-dark-notify" ] && rm -rf config/tmux/plugins/tmux-dark-notify
[ -d "tools/dotbot-crontab" ] && rm -rf tools/dotbot-crontab
[ -d "tools/dotbot-snap" ] && rm -rf tools/dotbot-snap
