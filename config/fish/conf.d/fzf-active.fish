# config/fish/conf.d/fzf-active.fish
#
# Pulls the active fzf palette published by the theme orchestrator
# into the current fish session. The state-dir symlink is rewritten by
# config/theme/handlers.d/fzf on every flip; new shells inherit the
# latest, and conf.d/theme-switch.fish sources it again in live shells
# once apply bumps the generation stamp (config/theme/shell-env.sh does
# the same for bash and zsh).

set -l state_dir (test -n "$XDG_STATE_HOME"; and echo $XDG_STATE_HOME; or echo "$HOME/.local/state")
set -l fzf_active "$state_dir/dotfiles-theme/fzf-active.fish"

if test -r $fzf_active
    source $fzf_active
end
