# Set aliases for fish shell
# @fish-lsp-disable 4004
# - 4004 disabled: interactive aliases have no in-file callers

if type -q nvim
    alias v='nvim'
    alias vim='nvim'
    alias vi='nvim'
end

# Git, taken from ville6000
abbr --add gau git add -u
abbr --add gaa git add -A
abbr --add gcv git commit -v
abbr --add gst git status
abbr --add glg git log
abbr --add gwa git worktree add
abbr --add gwr git worktree remove
abbr --add gwl git worktree list
abbr --add gl 'git log --pretty=format:"%C(yellow)%h%Creset %C(cyan)%an%Creset %Cgreen(%ad)%Creset %s" --date=short'

# .NET, also taken from ville6000
abbr --add dt dotnet test
abbr --add dw dotnet watch

# gopass password manager shortcut (resolves via PATH / mise shim)
if type -q gopass
    alias p='gopass'
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
        git commit -a -m "chore: automated commit"
        return
    end

    git commit -a -m "$commitMessage"
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

# ── Ported from config/alias (bash/zsh parity) ──────────────────────
# `.` (cd $HOME) is intentionally not ported: fish reserves `.` for `source`.

# Prevent common typos
abbr --add cd.. 'cd ..'
alias sl='ls'

# IP addresses
alias x-ip='dig +short myip.opendns.com @resolver1.opendns.com'
alias localip='ipconfig getifaddr en1'
function ips --description 'list IPv4/IPv6 addresses'
    ifconfig -a |
        grep -o 'inet6\? \(\([0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]\+\)\|[a-fA-F0-9:]\+\)' |
        sed -e 's/inet6* //' |
        sort
end

# Show/hide hidden files in Finder
alias show='defaults write com.apple.finder AppleShowAllFiles -bool true; killall Finder'
alias hide='defaults write com.apple.finder AppleShowAllFiles -bool false; killall Finder'

# Pipe public key to clipboard
function pubkey --description 'copy SSH public key to clipboard'
    more ~/.ssh/id_rsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'
end

# Flush Directory Service cache
alias flush='dscacheutil -flushcache'

# Update locatedb
alias updatedb='sudo /usr/libexec/locate.updatedb'

# xdg-ninja for a better experience
alias xdg='xdg-ninja --skip-ok --skip-unsupported'

# watch with: differences, precise, beep and color
alias watchx='watch -dpbc'

# delete .DS_Store files
alias zapds='find . -name ".DS_Store" -print -delete'
# Recursively delete .pyc files
alias zappyc="find . -type f -name '*.pyc' -ls -delete"
# Run all zaps
alias zapall='zapds && zappyc'

# directory usage, total only
alias dn='du -chd1'

# Mirror site with wget
alias mirror_site='wget -m -k -K -E -e robots=off'

# Mirror stdout to stderr (see data going through a pipe)
function peek --description 'tee to stderr'
    tee /dev/stderr $argv
end

# Open dotfiles with $EDITOR
alias zedit='$EDITOR ~/.dotfiles'

# XDG-aware overrides (use `command` to avoid recursing into the function)
function wget --description 'wget with XDG hsts file'
    command wget --hsts-file=$XDG_DATA_HOME/wget-hsts $argv
end
function svn --description 'svn with XDG config dir'
    command svn --config-dir $XDG_CONFIG_HOME/subversion $argv
end
function irssi --description 'irssi with XDG config/home'
    command irssi --config=$XDG_CONFIG_HOME/irssi/config --home=$XDG_CONFIG_HOME/irssi $argv
end

# GitLab code quality scanner
function code_scanner --description 'GitLab code quality scanner'
    set -q CODEQUALITY_VERSION; or set -l CODEQUALITY_VERSION latest
    docker run \
        --env SOURCE_CODE=$PWD \
        --volume $PWD:/code \
        --volume /var/run/docker.sock:/var/run/docker.sock \
        registry.gitlab.com/gitlab-org/ci-cd/codequality:$CODEQUALITY_VERSION \
        /code $argv
end

# Trivy container image scanner
function trivy_scan --description 'Trivy image scanner'
    docker run -v /var/run/docker.sock:/var/run/docker.sock \
        -v $HOME/Library/Caches:/root/.cache/ aquasec/trivy $argv
end

# Laravel artisan shortcut
function art --description 'Laravel artisan'
    if test -f artisan
        php artisan $argv
    else
        php vendor/bin/artisan $argv
    end
end

# Laravel Sail shortcut
function sail --description 'Laravel Sail'
    if test -f sail
        bash sail $argv
    else
        bash vendor/bin/sail $argv
    end
end

# macOS-only helpers
if test (uname) = Darwin
    alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
    function afk --description 'lock the screen'
        osascript -e 'tell application "System Events" to keystroke "q" using {command down,control down}'
    end
    function emptytrash --description 'empty trash on all volumes'
        sudo rm -rfv /Volumes/*/.Trashes
        sudo rm -rfv ~/.Trash
        sudo rm -rfv /private/var/log/asl/*.asl
    end
end
