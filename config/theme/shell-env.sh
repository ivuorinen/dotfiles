# shellcheck shell=bash
# config/theme/shell-env.sh — bash/zsh side of the theme orchestrator.
#
# The theme handlers publish colour caches under
# $XDG_STATE_HOME/dotfiles-theme (ls-colors, bat-theme), and
# config/theme/apply rewrites `generation` once every handler has finished.
# A shell loads the caches at startup and, through the prompt hook, again
# whenever the stamp moves — so a theme switch reaches shells that are
# already open. config/fish/conf.d/theme-switch.fish is the fish twin.
#
# Sourced by config/exports. Defines functions only; nothing runs on source.

# Load the colour caches into this shell and remember the stamp they belong
# to. A missing cache unsets its variable only while the orchestrator runs
# on this host (a generation stamp exists): elsewhere the inherited value
# (a system LS_COLORS, a hand-set BAT_THEME) stays. fzf needs nothing here:
# it reads its colours from FZF_DEFAULT_OPTS_FILE at every start.
_theme_refresh_env()
{
  local dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-theme" gen=""
  [[ -r "$dir/generation" ]] && read -r gen < "$dir/generation"
  if [[ -r "$dir/ls-colors" ]]; then
    # shellcheck source=/dev/null
    . "$dir/ls-colors"
  elif [[ -n "$gen" ]]; then
    unset LS_COLORS
  fi
  if [[ -r "$dir/bat-theme" ]]; then
    read -r BAT_THEME < "$dir/bat-theme" && export BAT_THEME
  elif [[ -n "$gen" ]]; then
    unset BAT_THEME
  fi
  _THEME_GENERATION="$gen"
  return 0
}

# Prompt hook: reload the caches once the stamp has moved. Runs before
# every prompt, so the unchanged case is builtins only (no subprocess), and
# it hands back the $? it was called with for the prompt to show.
_theme_prompt_check()
{
  local rc=$? gen=""
  local file="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-theme/generation"
  [[ -r "$file" ]] && read -r gen < "$file"
  if [[ -n "$gen" && "$gen" != "${_THEME_GENERATION-}" ]]; then
    _theme_refresh_env
  fi
  return "$rc"
}

# Run _theme_prompt_check before each prompt: PROMPT_COMMAND in bash, a
# precmd hook in zsh. Calling it again (a re-sourced rc file) adds nothing.
_theme_prompt_hook_install()
{
  if [[ -n "${ZSH_VERSION-}" ]]; then
    autoload -Uz add-zsh-hook && add-zsh-hook precmd _theme_prompt_check
    return
  fi
  # An array PROMPT_COMMAND (bash 5.1+) is safe: this rewrites element 0.
  # starship's init moves the existing PROMPT_COMMAND into
  # STARSHIP_PROMPT_COMMAND and runs it from starship_precmd, so a re-sourced
  # rc file must look there too or the hook would run twice per prompt.
  case ";${PROMPT_COMMAND:-};${STARSHIP_PROMPT_COMMAND:-};" in
    *";_theme_prompt_check;"*) ;;
    *) PROMPT_COMMAND="_theme_prompt_check${PROMPT_COMMAND:+;$PROMPT_COMMAND}" ;;
  esac
}
