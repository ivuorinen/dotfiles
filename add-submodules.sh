#!/usr/bin/env bash

git submodule add --name dotbot -f https://github.com/anishathalye/dotbot.git tools/dotbot
git submodule add --name dotbot-brew -f https://github.com/wren/dotbot-brew.git tools/dotbot-brew
git submodule add --name dotbot-include -f https://gitlab.com/gnfzdz/dotbot-include.git tools/dotbot-include
git submodule add --name cheat-community -f https://github.com/cheat/cheatsheets.git config/cheat/cheatsheets/community

# tmux plugin manager and plugins
git submodule add --name tmux/tpm \
  -f https://github.com/tmux-plugins/tpm.git config/tmux/plugins/tpm
git submodule add --name tmux/catppuccin \
  -f https://github.com/catppuccin/tmux.git config/tmux/plugins/tmux
git submodule add --name tmux/tmux-continuum \
  -f https://github.com/tmux-plugins/tmux-continuum config/tmux/plugins/tmux-continuum
git submodule add --name tmux/tmux-menus \
  -f https://github.com/jaclu/tmux-menus.git config/tmux/plugins/tmux-menus
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
