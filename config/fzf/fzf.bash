# Setup fzf
# ---------
# Key bindings and completion come from the mise-installed fzf itself
# (`fzf --bash`), so they always match the binary. lib::init_cached
# (config/lib.sh) keeps the generated script in $XDG_CACHE_HOME/shell-init
# and rebuilds it when the mise config changes, so startup does not pay
# for running fzf on every shell.
command -v fzf > /dev/null 2>&1 && lib::init_cached fzf fzf --bash
