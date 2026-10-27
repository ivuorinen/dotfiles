#!/usr/bin/env bats
# Tests for the starship blocks in config/fish/config.fish and base/zshrc.
# The init they source calls starship by a versioned install path, so once
# `mise prune` deletes that version from under a running shell the next
# prompt must re-run the init, and while the version is still installed the
# prompt must stay as it is. Sourcing the rc files wholesale pulls in mise,
# antidote and the other tools, so these tests run the real blocks lifted out
# of each file.

setup()
{
  ROOT="$BATS_TEST_DIRNAME/.."
  T="$BATS_TEST_TMPDIR"
  # Two installed versions whose prompt is their own name, and a stand-in for
  # the mise shim whose init names the version in $T/current, the way real
  # starship names the install the shim resolved it to.
  for v in v1 v2; do
    mkdir -p "$T/$v"
    printf '#!/bin/sh\necho %s\n' "$v" > "$T/$v/starship"
    chmod +x "$T/$v/starship"
  done
  mkdir -p "$T/bin"
  cat > "$T/bin/starship" << EOF
#!/bin/sh
sed "s#@BIN@#$T/\$(cat "$T/current")/starship#g" "$T/init.\$2"
EOF
  chmod +x "$T/bin/starship"
  echo v1 > "$T/current"
  cat > "$T/init.fish" << 'EOF'
function fish_prompt
    @BIN@ prompt
end
EOF
  # The prompt line and the zle-keymap-select handling of starship 1.27.0's
  # zsh init, which wraps whatever widget it finds.
  cat > "$T/init.zsh" << 'EOF'
PROMPT='$('@BIN@' prompt)'
starship_zle-keymap-select() {
    zle reset-prompt
}
if [[ -v widgets[zle-keymap-select] ]]; then
    __starship_preserved_zle_keymap_select=${widgets[zle-keymap-select]#user:}
fi
if [[ -z ${__starship_preserved_zle_keymap_select:-} ]]; then
    zle -N zle-keymap-select starship_zle-keymap-select;
else
    starship_zle-keymap-select-wrapped() {
        $__starship_preserved_zle_keymap_select "$@";
        starship_zle-keymap-select "$@";
    }
    zle -N zle-keymap-select starship_zle-keymap-select-wrapped;
fi
EOF
}

# Runs the fish block as config.fish does at startup, bumps the shim to v2
# and backdates the init cache so __init_cached would regenerate it, runs the
# given fish commands, then fires the prompt event and draws the prompt.
fish_prompt_after_bump()
{
  command -v fish > /dev/null || skip "fish not installed"
  local block
  block="$(sed -n '/function __dotfiles_starship_init/,/^        __dotfiles_starship_init$/p' \
    "$ROOT/config/fish/config.fish")"
  run env -u DOTFILES XDG_CACHE_HOME="$T/cache" XDG_CONFIG_HOME="$T/config" \
    PATH="$T/bin:$PATH" fish --no-config -c "
      set -p fish_function_path '$ROOT/config/fish/functions'
      $block
      echo v2 > '$T/current'
      touch -t 200001010000 '$T/cache/fish/init/'*.fish
      $1
      emit fish_prompt
      fish_prompt"
}

# The zsh counterpart: $1 runs before the block, $2 after the bump. Prints
# the drawn prompt, then the zle-keymap-select widget and the one starship
# recorded as wrapped.
zsh_prompt_after_bump()
{
  command -v zsh > /dev/null || skip "zsh not installed"
  local block
  block="$(sed -n '/^  _dotfiles_starship_init()$/,/add-zsh-hook precmd _dotfiles_starship_init/p' \
    "$ROOT/base/zshrc")"
  run env -u DOTFILES XDG_CACHE_HOME="$T/cache" XDG_CONFIG_HOME="$T/config" \
    PATH="$T/bin:$PATH" zsh -fc "
      source '$ROOT/config/lib.sh'
      $1
      $block
      echo v2 > '$T/current'
      touch -t 200001010000 '$T/cache/shell-init/'*.zsh
      $2
      for hook in \$precmd_functions; do \$hook; done
      setopt promptsubst
      print -rP -- \"\$PROMPT\"
      print -r -- \"keymap=\${widgets[zle-keymap-select]} wraps=\${__starship_preserved_zle_keymap_select-}\""
}

@test "fish: a pruned starship version re-runs the prompt init" {
  fish_prompt_after_bump "rm -r '$T/v1'"
  [ "$status" -eq 0 ]
  [ "$output" = "v2" ]
}

@test "fish: an installed starship version keeps the prompt as it is" {
  fish_prompt_after_bump ""
  [ "$status" -eq 0 ]
  [ "$output" = "v1" ]
}

@test "zsh: a pruned starship version re-runs the prompt init" {
  zsh_prompt_after_bump "" "rm -r '$T/v1'"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "v2" ]
}

@test "zsh: an installed starship version keeps the prompt as it is" {
  zsh_prompt_after_bump "" ""
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "v1" ]
}

@test "zsh: a re-init leaves starship's keymap widget unwrapped" {
  zsh_prompt_after_bump "" "rm -r '$T/v1'"
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "keymap=user:starship_zle-keymap-select wraps=" ]
}

@test "zsh: a re-init keeps the keymap widget that predates starship" {
  zsh_prompt_after_bump "own_keymap() { :; }; zle -N zle-keymap-select own_keymap" "rm -r '$T/v1'"
  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "keymap=user:starship_zle-keymap-select-wrapped wraps=own_keymap" ]
}
