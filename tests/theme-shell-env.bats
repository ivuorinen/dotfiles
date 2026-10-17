#!/usr/bin/env bats
# Tests for config/theme/shell-env.sh: open bash and zsh shells reload the
# colour caches the theme handlers write (ls-colors, bat-theme,
# fzf-active.sh) once apply bumps the generation stamp, and fish does the
# same from conf.d/theme-switch.fish. Each case sources only the file under
# test, never a whole rc file.

setup()
{
  ROOT="$BATS_TEST_DIRNAME/.."
  TMPDIR_TEST="$(mktemp -d)"
  export XDG_STATE_HOME="$TMPDIR_TEST"
  STATE="$TMPDIR_TEST/dotfiles-theme"
  mkdir -p "$STATE"
  export SHELL_ENV="$ROOT/config/theme/shell-env.sh"
}

teardown()
{
  rm -rf "$TMPDIR_TEST"
}

# write_caches <ls> <bat> <fzf> — what the dircolors, bat and fzf handlers
# publish under $XDG_STATE_HOME/dotfiles-theme.
write_caches()
{
  printf "LS_COLORS='%s'; export LS_COLORS\n" "$1" > "$STATE/ls-colors"
  printf '%s\n' "$2" > "$STATE/bat-theme"
  printf 'export FZF_DEFAULT_OPTS="%s"\n' "$3" > "$STATE/fzf-active.sh"
}

bump_generation()
{
  printf '%s\n' "$1" > "$STATE/generation"
}

# in_shell <bash|zsh> <script> — run the script after sourcing shell-env.sh
# alone (zsh -f skips every rc file).
in_shell()
{
  case "$1" in
    zsh) zsh -f -c ". \"\$SHELL_ENV\"; $2" ;;
    *) bash -c ". \"\$SHELL_ENV\"; $2" ;;
  esac
}

# The script each shell runs for the reload checks: load A at generation g1,
# publish B, then fire the prompt hook.
RELOAD='_theme_refresh_env
printf "LS_COLORS='"'"'di=02;35'"'"'; export LS_COLORS\n" > "$XDG_STATE_HOME/dotfiles-theme/ls-colors"
printf "Dracula\n" > "$XDG_STATE_HOME/dotfiles-theme/bat-theme"
printf "export FZF_DEFAULT_OPTS=\"--color=fg:#222222\"\n" > "$XDG_STATE_HOME/dotfiles-theme/fzf-active.sh"'

@test "shell-env: refresh loads LS_COLORS, BAT_THEME and the fzf palette" {
  write_caches 'di=01;34' 'Nord' '--color=fg:#111111'
  bump_generation g1
  run in_shell bash '_theme_refresh_env; echo "$LS_COLORS|$BAT_THEME|$FZF_DEFAULT_OPTS|$_THEME_GENERATION"'
  [ "$status" -eq 0 ]
  [ "$output" = "di=01;34|Nord|--color=fg:#111111|g1" ]
}

@test "shell-env: a removed cache unsets LS_COLORS and BAT_THEME" {
  bump_generation g1
  run in_shell bash 'export LS_COLORS=old BAT_THEME=old; _theme_refresh_env
    echo "${LS_COLORS-unset}|${BAT_THEME-unset}"'
  [ "$status" -eq 0 ]
  [ "$output" = "unset|unset" ]
}

@test "shell-env: without orchestrator state, refresh keeps inherited values" {
  run in_shell bash 'export LS_COLORS=system BAT_THEME=mine; _theme_refresh_env
    echo "$LS_COLORS|$BAT_THEME"'
  [ "$status" -eq 0 ]
  [ "$output" = "system|mine" ]
}

@test "shell-env: the prompt check reloads once the generation changes" {
  write_caches 'di=01;34' 'Nord' '--color=fg:#111111'
  bump_generation g1
  run in_shell bash "$RELOAD"'
    printf "g2\n" > "$XDG_STATE_HOME/dotfiles-theme/generation"
    _theme_prompt_check; echo "$LS_COLORS|$BAT_THEME|$FZF_DEFAULT_OPTS"'
  [ "$status" -eq 0 ]
  [ "$output" = "di=02;35|Dracula|--color=fg:#222222" ]
}

@test "shell-env: an unchanged generation leaves the environment alone" {
  write_caches 'di=01;34' 'Nord' '--color=fg:#111111'
  bump_generation g1
  run in_shell bash "$RELOAD"'
    _theme_prompt_check; echo "$LS_COLORS|$BAT_THEME|$FZF_DEFAULT_OPTS"'
  [ "$status" -eq 0 ]
  [ "$output" = "di=01;34|Nord|--color=fg:#111111" ]
}

@test "shell-env: no generation file is silent and keeps \$?" {
  run in_shell bash 'false; _theme_prompt_check; echo "rc=$?"'
  [ "$status" -eq 0 ]
  [ "$output" = "rc=1" ]
}

@test "shell-env: the prompt hook is registered once in bash" {
  run in_shell bash 'PROMPT_COMMAND=existing
    _theme_prompt_hook_install; _theme_prompt_hook_install; echo "$PROMPT_COMMAND"'
  [ "$status" -eq 0 ]
  [ "$output" = "_theme_prompt_check;existing" ]
}

@test "shell-env: the zsh variant passes the same checks" {
  command -v zsh > /dev/null 2>&1 || skip "zsh not installed"
  write_caches 'di=01;34' 'Nord' '--color=fg:#111111'
  bump_generation g1
  run in_shell zsh "$RELOAD"'
    printf "g2\n" > "$XDG_STATE_HOME/dotfiles-theme/generation"
    _theme_prompt_check; echo "$LS_COLORS|$BAT_THEME|$FZF_DEFAULT_OPTS"'
  [ "$status" -eq 0 ]
  [ "$output" = "di=02;35|Dracula|--color=fg:#222222" ]
  rm -f "$STATE/generation"
  run in_shell zsh 'false; _theme_prompt_check; echo "rc=$?"'
  [ "$output" = "rc=1" ]
  run in_shell zsh '_theme_prompt_hook_install; _theme_prompt_hook_install; print -l $precmd_functions'
  [ "$status" -eq 0 ]
  [ "$output" = "_theme_prompt_check" ]
}

@test "fish: theme-switch reloads the fzf palette on a new generation" {
  command -v fish > /dev/null 2>&1 || skip "fish not installed"
  echo dark > "$STATE/mode"
  echo "set -gx FZF_DEFAULT_OPTS '--color=fg:#111111'" > "$STATE/fzf-active.fish"
  bump_generation g1
  # A stub theme name skips `fish_config theme save`, and XDG_CONFIG_HOME
  # keeps any universal variable away from the developer's own fish config.
  run env XDG_CONFIG_HOME="$TMPDIR_TEST/config" fish --no-config --interactive -c "
    function __dotfiles_theme_name; return 1; end
    source '$ROOT/config/fish/conf.d/theme-switch.fish'
    echo \"set -gx FZF_DEFAULT_OPTS '--color=fg:#222222'\" > '$STATE/fzf-active.fish'
    echo g2 > '$STATE/generation'
    emit fish_prompt
    echo \$FZF_DEFAULT_OPTS"
  [ "$status" -eq 0 ]
  [ "${lines[${#lines[@]} - 1]}" = "--color=fg:#222222" ]
}
