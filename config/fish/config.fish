# ╭──────────────────────────────────────────────────────────╮
# │                     fish/config.fish                     │
# ╰──────────────────────────────────────────────────────────╯

# ASDF configuration code
source $HOME/.local/asdf/asdf.fish

fish_add_path $HOME/.local/bin
fish_add_path $HOME/.local/share/nvim/mason/bin
fish_add_path $HOME/.local/state/composer/vendor/bin

if status is-interactive
  # Commands to run in interactive sessions can go here
end
