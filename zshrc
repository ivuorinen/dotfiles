# shellcheck shell=bash

OPT_FOLDER="/usr/local/opt"
PHP_74=$(brew --prefix php@7.4)/bin
PHP_CUR=$(brew --prefix php)/bin
export PATH="$HOME/.local/bin:$PHP_74:$PHP_CUR:$HOME/Library/Python/3.8/bin:$HOME/.composer/vendor/bin:$OPT_FOLDER/python@3.8/bin:$OPT_FOLDER/coreutils/libexec/gnubin:$OPT_FOLDER/ruby/bin:/usr/local/sbin:$PATH"
source "$HOME/.config/antigen.zsh"

export NVM_DIR="$HOME/.nvm"
export NVM_LAZY_LOAD=true
export NVM_COMPLETION=true
export NVM_AUTO_USE=true

antigen use oh-my-zsh

antigen bundle php
antigen bundle nvm
antigen bundle ruby
antigen bundle docker
antigen bundle ssh-agent
antigen bundle git-auto-fetch

antigen bundle colored-man-pages
antigen bundle jreese/zsh-titles
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-completions

antigen bundle Sparragus/zsh-auto-nvm-use
antigen bundle reegnz/jq-zsh-plugin
antigen bundle MichaelAquilina/zsh-you-should-use
antigen bundle sroze/docker-compose-zsh-plugin
antigen bundle voronkovich/phpcs.plugin.zsh
antigen bundle unixorn/autoupdate-antigen.zshplugin

antigen theme oskarkrawczyk/honukai-iterm-zsh honukai

# Platform dependant bundles
if [[ $(uname) == 'Linux' ]]
then
    antigen bundle command-not-found
elif [[ $(uname) == 'Darwin' ]]
then
    # Only enable brew plugin if brew exists
    hash brew 2>/dev/null && antigen bundle brew
fi

antigen apply

export HIST_STAMPS="yyyy-mm-dd"

source "$HOME/.alias"

source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
source "/usr/local/etc/profile.d/z.sh"
