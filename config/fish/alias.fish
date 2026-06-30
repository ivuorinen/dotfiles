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
abbr --add gst git status -sbv
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

# cd to git root directory (logic lives in local/bin/x-git-root)
alias cdgr='cd "$(x-git-root)"'

# Colored grep
abbr --add grep 'grep --color'

# Date helpers (datetime/timestamp moved to scripts — run `x datetime` / `x timestamp`)
alias isodate="date +'%Y-%m-%d'"

# Random abbreviations
if type -q onefetch
    abbr --add stats onefetch --nerd-fonts --true-color never
end

# ── Ported from config/alias (bash/zsh parity) ──────────────────────
# `.` (cd $HOME) is intentionally not ported: fish reserves `.` for `source`.

# Prevent common typos
abbr --add cd.. 'cd ..'
alias sl='ls'

# macOS-specific commands live in local/bin/x-* (run `x <name>`):
#   localip -> x-localip                 show/hide -> x-macos-show / x-macos-hide
#   flush   -> x-macos-flush             flushdns  -> x-macos-flushdns
#   updatedb -> x-macos-updatedb

# xdg-ninja for a better experience
alias xdg='xdg-ninja --skip-ok --skip-unsupported'

# watch with: differences, precise, beep and color
alias watchx='watch -dpbc'

# directory usage, total only
alias dn='du -chd1'

# Mirror stdout to stderr (see data going through a pipe)
alias peek='tee /dev/stderr'

# Open dotfiles with $EDITOR
alias zedit='$EDITOR ~/.dotfiles'

# XDG-aware overrides (use `command` to avoid recursing into the function)
function wget --wraps='wget --hsts-file=$XDG_DATA_HOME/wget-hsts' --description 'wget with XDG hsts file'
    command wget --hsts-file=$XDG_DATA_HOME/wget-hsts $argv
end
function irssi --wraps='irssi --config=$XDG_CONFIG_HOME/irssi/config --home=$XDG_CONFIG_HOME/irssi'
    command irssi --config=$XDG_CONFIG_HOME/irssi/config --home=$XDG_CONFIG_HOME/irssi $argv
end
# Render markdown with the terminal-palette style (logic in local/bin/x-glow)
alias glow='x-glow'
