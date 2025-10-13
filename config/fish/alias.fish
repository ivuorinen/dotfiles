# Set aliases for fish shell

alias vim='vim -u "$XDG_CONFIG_HOME/vim/vimrc"'

# eza aliases if eza is installed
if type -q eza >/dev/null
    function eza_git -d "Use eza and its git options if in a git repo"
        if git rev-parse --is-inside-work-tree &>/dev/null
            eza --group-directories-first --icons=always \
                --smart-group --git $argv
        else
            eza --group-directories-first \
                --icons=always \
                --smart-group $argv
        end
    end

    function lsa --wraps='eza_git -al' --description 'eza -al'
        eza_git -al $argv
    end

    function ls --wraps='eza_git' --description eza
        eza_git $argv
    end

    function ll --wraps='eza_git -l' --description 'eza -l'
        eza_git -l $argv
    end

    function l --wraps='eza_git' --description eza
        eza_git $argv
    end
end

# Edit fish alias file
function .a \
    --wraps='nvim ~/.dotfiles/config/fish/alias.fish' \
    --description 'edit alias.fish'
    nvim ~/.dotfiles/config/fish/alias.fish $argv
end

# Go to the directory where my projects are stored
function .c --wraps='cd ~/Code' --description 'cd ~/Code'
    cd ~/Code $argv
end

# Go to the directory where the dotfiles are stored
function .d --wraps='cd ~/.dotfiles' --description 'cd ~/.dotfiles'
    cd ~/.dotfiles $argv
end

# Go to the directory where my work codes are stored
function .s --wraps='cd ~/Code/s' --description 'cd ~/Code/s'
    cd ~/Code/s $argv
end

# Go to the directory where my personal codes are stored
function .p --wraps='cd ~/Code/ivuorinen' --description 'cd ~/Code/ivuorinen'
    cd ~/Code/ivuorinen $argv
end

# shortcut to commit with a message
function commit \
    --wraps='git commit -a -m "chore: automated commit"' \
    --description 'commit shortcut'
    set -l commitMessage $argv
    git add .

    if test -z "$commitMessage"
        if type -q aicommits
            aicommits --type conventional
        else
            git commit -a -m "chore: automated commit"
        end
        return
    end

    git commit -a -m "$commitMessage"
end

function configure_tide \
    --description 'Configure tide with the lean style and my preferences'
    tide configure \
        --auto \
        --style=Lean \
        --prompt_colors='True color' \
        --show_time=No \
        --lean_prompt_height='Two lines' \
        --prompt_connection=Disconnected \
        --prompt_spacing=Sparse \
        --icons='Many icons' \
        --transient=Yes
end

# Random abbreviations
abbr --add stats onefetch --nerd-fonts --true-color never
