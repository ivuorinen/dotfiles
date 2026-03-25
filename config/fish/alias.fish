# Set aliases for fish shell

if type -q nvim
    alias vim='nvim'
    alias vi='nvim'
end

if type -q bat
    alias cat='bat'
end

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
else
    function ls --description 'ls (system fallback)'
        command ls $argv
    end
    function ll --description 'ls -lh (system fallback)'
        command ls -lh $argv
    end
    function l --description 'ls (system fallback)'
        command ls $argv
    end
    function lsa --description 'ls -lah (system fallback)'
        command ls -lah $argv
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

# Navigation aliases
abbr --add .. 'cd ..'
abbr --add ... 'cd ../..'
abbr --add .... 'cd ../../..'

# Interesting folders
function .b --wraps='cd $XDG_BIN_HOME' --description 'cd $XDG_BIN_HOME'
    cd $XDG_BIN_HOME $argv
end

function .l --wraps='cd ~/.local' --description 'cd ~/.local'
    cd ~/.local $argv
end

function .o --wraps='cd ~/Code/ivuorinen/obsidian/' --description 'cd ~/Code/ivuorinen/obsidian/'
    cd ~/Code/ivuorinen/obsidian/ $argv
end

# cd to git root directory
function cdgr --description 'cd to git root'
    if git rev-parse --is-inside-work-tree &>/dev/null
        cd (git rev-parse --show-toplevel); or return $status
    else
        echo >&2 "Not in a git repository"
        return 1
    end
end

# Colored grep
abbr --add grep 'grep --color'

# Date helpers
alias isodate="date +'%Y-%m-%d'"
alias x-datetime="date +'%Y-%m-%d %H:%M:%S'"
alias x-timestamp="date +'%s'"

# Random abbreviations
if type -q onefetch
    abbr --add stats onefetch --nerd-fonts --true-color never
end
