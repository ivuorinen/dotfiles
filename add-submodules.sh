#!/usr/bin/env bash

git submodule add --name dotbot-brew -f https://github.com/wren/dotbot-brew.git dotbot-brew
git submodule add --name dotbot-include -f https://gitlab.com/gnfzdz/dotbot-include.git dotbot-include
git submodule add --name cheat-community -f https://github.com/cheat/cheatsheets.git config/cheat/cheatsheets/community
git submodule add --name tmux/tpm -f https://github.com/tmux-plugins/tpm.git config/tmux/plugins/tpm

