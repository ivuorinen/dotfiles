function __dotfiles_theme_name --description 'Print the fish theme name for the active dotfiles theme family'
    # The family resolves as in config/theme/_lib.sh: DOTFILES_THEME_FAMILY,
    # then the saved choice in $XDG_STATE_HOME/dotfiles-theme/choice (skipped
    # unless it names a palettes.d family), then config/theme/family. Its
    # fish theme is the repo-owned dual-palette
    # config/fish/themes/<family>-aa.theme. Prints nothing and returns 1 when
    # either is missing, so callers leave the current theme alone instead of
    # mixing families.
    set -l dotfiles (test -n "$DOTFILES"; and echo $DOTFILES; or echo "$HOME/.dotfiles")
    set -l state (test -n "$XDG_STATE_HOME"; and echo $XDG_STATE_HOME; or echo "$HOME/.local/state")
    set -l family $DOTFILES_THEME_FAMILY
    if test -z "$family"
        for file in "$state/dotfiles-theme/choice" "$dotfiles/config/theme/family"
            test -r $file; or continue
            read -l line <$file
            set line (string trim -- "$line")
            if string match -qr '^[a-z0-9][a-z0-9-]*$' -- "$line"
                and test -d "$dotfiles/config/theme/palettes.d/$line"
                set family $line
                break
            end
        end
    end
    string match -qr '^[a-z0-9][a-z0-9-]*$' -- "$family"; or return 1
    test -r "$dotfiles/config/fish/themes/$family-aa.theme"; or return 1
    echo "$family-aa"
end
