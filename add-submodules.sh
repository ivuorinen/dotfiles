#!/usr/bin/env bash

git submodule sync --recursive

# dotbot and plugins
git submodule add --name dotbot \
  -f https://github.com/anishathalye/dotbot.git tools/dotbot
git submodule add --name dotbot-include \
  -f https://gitlab.com/gnfzdz/dotbot-include.git tools/dotbot-include

# other repos
git submodule add --name cheat-community \
  -f https://github.com/cheat/cheatsheets.git config/cheat/cheatsheets/community
git submodule add --name cheat-tldr \
  -f https://github.com/ivuorinen/cheatsheet-tldr.git config/cheat/cheatsheets/tldr
git submodule add --name antidote \
  --depth 1 \
  -f https://github.com/mattmc3/antidote.git tools/antidote

# Takes submodules and sets them to ignore all changes
for MODULE in $(git config --file .gitmodules --get-regexp path | awk '{ print $2 }'); do
  echo "Ignoring submodule changes for submodule.${MODULE}..."
  git config "submodule.${MODULE}.ignore" "dirty"
done

# Mark certain repositories shallow
git config -f .gitmodules submodule.antidote.shallow true

# Log a message using msgr if available, else echo
_log()
{
  local msg="$1"
  if command -v msgr > /dev/null 2>&1; then
    msgr run_done "$msg"
  else
    echo "  [ok] $msg"
  fi
  return 0
}

# Remove a stale git submodule and clean up references
remove_old_submodule()
{
  local name="$1" path="$2"

  # Remove working tree
  if [[ -d "$path" ]]; then
    rm -rf "$path"
    _log "Removed $path"
  fi

  # Remove stale git index entry
  git rm --cached "$path" 2> /dev/null || true

  # Remove .git/config section keyed by path
  git config --remove-section "submodule.$path" 2> /dev/null || true

  # Skip name-based cleanup if no submodule name provided
  [[ -z "$name" ]] && return 0

  # Remove .git/config section keyed by name
  git config --remove-section "submodule.$name" 2> /dev/null || true

  # Remove .git/modules/<name>/ cached repository
  if [[ -d ".git/modules/$name" ]]; then
    rm -rf ".git/modules/$name"
    _log "Removed .git/modules/$name"
  fi

  # Remove .gitmodules entry keyed by name
  if [[ -n "$name" ]] && git config -f .gitmodules --get "submodule.$name.path" &> /dev/null; then
    git config -f .gitmodules --remove-section "submodule.$name"
    _log "Removed $name from .gitmodules"
  fi
}

# remove old submodules (name:path pairs)
old_submodules=(
  "tmux/tpm:config/tmux/plugins/tpm"
  ":config/tmux/plugins/tmux"
  "tmux/tmux-menus:config/tmux/plugins/tmux-menus"
  "dotbot-crontab:tools/dotbot-crontab"
  "dotbot-snap:tools/dotbot-snap"
  "tmux/tmux-window-name:config/tmux/plugins/tmux-window-name"
  "tmux/tmux-sensible:config/tmux/plugins/tmux-sensible"
  "tmux/tmux-mode-indicator:config/tmux/plugins/tmux-mode-indicator"
  "tmux/tmux-yank:config/tmux/plugins/tmux-yank"
  ":config/tmux/plugins/tmux-fzf-url"
  "nvim-kickstart:config/nvim-kickstart"
  "asdf:local/bin/asdf"
  "asdf:local/asdf"
  "dotbot-asdf:tools/dotbot-asdf"
  "dotbot-pip:tools/dotbot-pip"
  "dotbot-brew:tools/dotbot-brew"
  "tmux/tmux-continuum:config/tmux/plugins/tmux-continuum"
  "tmux/tmux-resurrect:config/tmux/plugins/tmux-resurrect"
  "tmux/tmux-sessionist:config/tmux/plugins/tmux-sessionist"
  "tmux/tmux-suspend:config/tmux/plugins/tmux-suspend"
  "tmux/tmux-current-pane-hostname:config/tmux/plugins/tmux-current-pane-hostname"
  "tmux/tmux-dark-notify:config/tmux/plugins/tmux-dark-notify"
  "tmux/catppuccin:config/tmux/plugins/catppuccin"
)

for entry in "${old_submodules[@]}"; do
  name="${entry%%:*}"
  path="${entry#*:}"
  remove_old_submodule "$name" "$path"
done
