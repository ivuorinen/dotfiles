# Set aliases for fish shell

alias vim='vim -u "$XDG_CONFIG_HOME/vim/vimrc"'

# eza aliases if eza is installed
if type -q eza > /dev/null

  function eza_git -d "Use eza and its git options if in a git repo"
      if git rev-parse --is-inside-work-tree &>/dev/null
          eza --group-directories-first --icons=always --smart-group --git $argv
      else
          eza --group-directories-first --icons=always --smart-group $argv
      end
  end

  function lsa --wraps='eza_git -al' --description 'eza -al'
    eza_git -al $argv
  end

  function ls --wraps='eza_git' --description 'eza'
    eza_git $argv
  end

  function ll --wraps='eza_git -l' --description 'eza -l'
    eza_git -l $argv
  end

  function l --wraps='eza_git' --description 'eza'
    eza_git $argv
  end
end
