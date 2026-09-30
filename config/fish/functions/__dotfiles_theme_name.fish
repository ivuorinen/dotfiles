function __dotfiles_theme_name --description 'Print the fish theme name for the active dotfiles theme family'
    # The family comes from config/theme/family (DOTFILES_THEME_FAMILY
    # overrides it, as in config/theme/_lib.sh). Its fish theme is the
    # repo-owned dual-palette config/fish/themes/<family>-aa.theme. Prints
    # nothing and returns 1 when either is missing, so callers leave the
    # current theme alone instead of mixing families.
    set -l dotfiles (set -q DOTFILES; and echo $DOTFILES; or echo "$HOME/.dotfiles")
    set -l family $DOTFILES_THEME_FAMILY
    if test -z "$family"; and test -r "$dotfiles/config/theme/family"
        read -l family_line <"$dotfiles/config/theme/family"
        set family $family_line
    end
    string match -qr '^[a-z0-9][a-z0-9-]*$' -- "$family"; or return 1
    test -r "$dotfiles/config/fish/themes/$family-aa.theme"; or return 1
    echo "$family-aa"
end
