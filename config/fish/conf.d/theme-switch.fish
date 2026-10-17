# config/fish/conf.d/theme-switch.fish
#
# Reacts to dark/light flips and family switches published by the theme
# orchestrator. Watches $XDG_STATE_HOME/dotfiles-theme/generation, which
# config/theme/apply rewrites once every handler has finished, and
# reapplies fish syntax colours, LS_COLORS, BAT_THEME and the fzf palette
# in the running session. config/theme/shell-env.sh is the bash/zsh twin.

if not status is-interactive
    return
end

set -l state_dir (set -q XDG_STATE_HOME; and echo $XDG_STATE_HOME; or echo "$HOME/.local/state")
set -l mode_file "$state_dir/dotfiles-theme/mode"
set -l ls_cache "$state_dir/dotfiles-theme/ls-colors"

# Apply once at login so the shell starts in the correct state.
# The cache file is bash-shaped (`LS_COLORS='val'; export LS_COLORS`)
# because the dircolors handler runs `dircolors -b`. Fish cannot
# `eval` that directly, so extract the value with `string match -rg`
# and assign it via `set -gx`.
if test -r $ls_cache
    set -l ls_value (string match -rg "LS_COLORS='([^']*)'" < $ls_cache | head -1)
    test -n "$ls_value"; and set -gx LS_COLORS $ls_value
end

# bat — export the active family's theme name published by the bat
# handler so bat (and bat-driven previews) honour the current mode. The
# state file holds the bare theme name, so a plain `cat` is enough.
set -l bat_theme_file "$state_dir/dotfiles-theme/bat-theme"
test -r $bat_theme_file; and set -gx BAT_THEME (cat $bat_theme_file)

# Seed the generation tracker so the first prompt is a no-op (otherwise
# `__theme_switch_last_generation` is unset and the first fish_prompt
# event always trips the "generation changed" branch and re-saves the theme).
set -l gen_file "$state_dir/dotfiles-theme/generation"
if test -r $gen_file
    read -g __theme_switch_last_generation <$gen_file
end

# Per-prompt cheap watcher: read the stamp (a builtin, no subprocess); only
# do real work when it has changed since the last prompt we saw.
function __theme_switch_check --on-event fish_prompt
    set -l state_dir (set -q XDG_STATE_HOME; and echo $XDG_STATE_HOME; or echo "$HOME/.local/state")
    set -l mode_file "$state_dir/dotfiles-theme/mode"
    set -l gen_file "$state_dir/dotfiles-theme/generation"
    set -l ls_cache "$state_dir/dotfiles-theme/ls-colors"
    test -r $gen_file; or return 0

    read -l gen <$gen_file
    if not set -q __theme_switch_last_generation; or test "$__theme_switch_last_generation" != "$gen"
        set -g __theme_switch_last_generation $gen
        # Re-save the active family's dual-palette theme (<family>-aa,
        # e.g. kanagawa-aa); the name changes only by family, which also
        # rewrites the mode file and lands here. The themes are repo-owned;
        # fisher-managed upstream files would lose their AA [light] edits
        # on `fisher update`. --color-theme names the section from the
        # mode file, as handlers.d/fish does: left to itself fish picks it
        # from the terminal's OSC 11 answer, which WezTerm does not update
        # in panes open across a flip. fish 3.x lacks the option (see the
        # probe in handlers.d/fish). `echo y |` bypasses the interactive
        # overwrite prompt that would otherwise pollute the next prompt line.
        set -l mode
        test -r $mode_file; and set mode (string trim < $mode_file)
        set -l save_opts
        if contains -- "$mode" dark light
            and string match -q '*color-theme=*' -- (functions fish_config)
            set save_opts --color-theme=$mode
        end
        set -l theme (__dotfiles_theme_name)
        and echo y | fish_config theme save $save_opts $theme >/dev/null 2>&1
        # A family without a dircolors palette removes the cache; drop the
        # export too so a previous family's ls colours do not linger.
        if test -r $ls_cache
            set -l ls_value (string match -rg "LS_COLORS='([^']*)'" < $ls_cache | head -1)
            test -n "$ls_value"; and set -gx LS_COLORS $ls_value
        else
            set -e LS_COLORS
        end
        # A family without a bat theme removes the state file; drop the
        # export too so a previous family's theme does not linger.
        set -l bat_theme_file "$state_dir/dotfiles-theme/bat-theme"
        if test -r $bat_theme_file
            set -gx BAT_THEME (cat $bat_theme_file)
        else
            set -e BAT_THEME
        end
        # The fzf palette assigns FZF_DEFAULT_OPTS whole, so sourcing it
        # again replaces the previous family's colours.
        set -l fzf_active "$state_dir/dotfiles-theme/fzf-active.fish"
        test -r $fzf_active; and source $fzf_active
    end
end
