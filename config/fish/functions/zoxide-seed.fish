function zoxide-seed --description 'Register project dirs with zoxide so sesh/gum picker finds them'
    set -l roots \
        $HOME/Code \
        $HOME/Code/s \
        $HOME/Code/masf \
        $HOME/Code/ivuorinen

    for root in $roots
        test -d $root; or continue
        fd --type d --max-depth 1 --hidden --exclude .git . $root \
            | while read -l dir
            zoxide add $dir
        end
    end
end
