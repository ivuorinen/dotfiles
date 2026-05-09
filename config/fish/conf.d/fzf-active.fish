# config/fish/conf.d/fzf-active.fish
#
# Pulls the active fzf palette published by the theme orchestrator
# into the current fish session. The state-dir symlink is rewritten by
# config/theme/handlers.d/fzf on every flip; new shells inherit the
# latest. Live shells stay on their startup palette until restart —
# matches the bash/zsh side and the fish theme-switch behaviour where
# only the fish prompt re-queries OSC 11 in-process.

set -l state_dir (set -q XDG_STATE_HOME; and echo $XDG_STATE_HOME; or echo "$HOME/.local/state")
set -l fzf_active "$state_dir/dotfiles-theme/fzf-active.fish"

if test -r $fzf_active
    source $fzf_active
end
