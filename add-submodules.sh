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

# other repos
git submodule add --name cheat-community \
  -f https://github.com/cheat/cheatsheets.git config/cheat/cheatsheets/community

# tmux plugin manager and plugins
git submodule add --name tmux/tmux-continuum \
  -f https://github.com/tmux-plugins/tmux-continuum config/tmux/plugins/tmux-continuum
git submodule add --name tmux/tmux-resurrect \
  -f https://github.com/tmux-plugins/tmux-resurrect config/tmux/plugins/tmux-resurrect
git submodule add --name tmux/tmux-sensible \
  -f https://github.com/tmux-plugins/tmux-sensible.git config/tmux/plugins/tmux-sensible
git submodule add --name tmux/tmux-sessionist \
  -f https://github.com/tmux-plugins/tmux-sessionist.git config/tmux/plugins/tmux-sessionist
git submodule add --name tmux/tmux-window-name \
  -f https://github.com/ofirgall/tmux-window-name.git config/tmux/plugins/tmux-window-name
git submodule add --name tmux/tmux-yank \
  -f https://github.com/tmux-plugins/tmux-yank.git config/tmux/plugins/tmux-yank

# remove old submodules
[ -d "config/tmux/plugins/tpm" ] && rm -rf config/tmux/plugins/tpm
[ -d "config/tmux/plugins/tmux" ] && rm -rf config/tmux/plugins/tmux
[ -d "config/tmux/plugins/tmux-menus" ] && rm -rf config/tmux/plugins/tmux-menus
[ -d "tools/dotbot-crontab" ] && rm -rf tools/dotbot-crontab
[ -d "tools/dotbot-snap" ] && rm -rf tools/dotbot-snap
