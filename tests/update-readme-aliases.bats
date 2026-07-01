#!/usr/bin/env bats
# Tests for scripts/update-readme-aliases.sh — the docs/aliases.md generator.

setup()
{
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  TEST_DOTFILES="$(mktemp -d)"
  mkdir -p "$TEST_DOTFILES/config/fish" "$TEST_DOTFILES/docs"

  # common = identical in both → shared; the rest are shell-specific.
  cat > "$TEST_DOTFILES/config/alias" << 'EOF'
alias common='ls -la'
alias bzonly='echo bz'
EOF
  cat > "$TEST_DOTFILES/config/fish/alias.fish" << 'EOF'
alias common='ls -la'
alias fishonly='echo fish'
EOF
}

teardown()
{
  rm -rf "$TEST_DOTFILES"
}

@test "generates docs/aliases.md and partitions aliases by shell" {
  run env DOTFILES="$TEST_DOTFILES" bash "$REPO_ROOT/scripts/update-readme-aliases.sh"
  [ "$status" -eq 0 ]
  [ -f "$TEST_DOTFILES/docs/aliases.md" ]

  run cat "$TEST_DOTFILES/docs/aliases.md"
  [[ "$output" == *"## Shared (bash, zsh, fish)"* ]]
  [[ "$output" == *"## Bash & Zsh"* ]]
  [[ "$output" == *"## Fish"* ]]
  [[ "$output" == *"common"* ]]
  [[ "$output" == *"bzonly"* ]]
  [[ "$output" == *"fishonly"* ]]
  [[ "$output" == *"Total aliases: 3"* ]]
}

@test "fish abbreviations are folded into the fish alias set" {
  # abbronly exists only as a fish abbr; shareab matches a bash/zsh alias.
  printf "alias shareab='git pull'\n" >> "$TEST_DOTFILES/config/alias"
  printf "abbr --add shareab 'git pull'\nabbr --add abbronly 'echo hi'\n" \
    >> "$TEST_DOTFILES/config/fish/alias.fish"

  run env DOTFILES="$TEST_DOTFILES" bash "$REPO_ROOT/scripts/update-readme-aliases.sh"
  [ "$status" -eq 0 ]

  # An abbr-only entry proves abbr lines are parsed at all.
  run grep -q 'abbronly' "$TEST_DOTFILES/docs/aliases.md"
  [ "$status" -eq 0 ]

  # An alias+abbr with the same command must land in the Shared section.
  shared="$(awk '/^## Shared/{f=1;next} /^## /{f=0} f' "$TEST_DOTFILES/docs/aliases.md")"
  [[ "$shared" == *"shareab"* ]]
}

@test "pipes are escaped exactly once (no double backslash)" {
  # A bare | must become \| so the markdown table survives; a source \|
  # (e.g. a grep BRE alternation) must stay \|, never \\|.
  cat > "$TEST_DOTFILES/config/alias" << 'EOF'
alias piped='foo | bar\|baz'
EOF
  : > "$TEST_DOTFILES/config/fish/alias.fish"

  run env DOTFILES="$TEST_DOTFILES" bash "$REPO_ROOT/scripts/update-readme-aliases.sh"
  [ "$status" -eq 0 ]

  run cat "$TEST_DOTFILES/docs/aliases.md"
  [[ "$output" == *'foo \| bar\|baz'* ]]
  [[ "$output" != *'\\|'* ]]
}

@test "fish functions are collected via --wraps or --description" {
  # A function whose --wraps matches a bash alias is shared; a function with
  # only a --description shows that description; a bare function is skipped.
  printf "alias dotc='cd ~/Code'\n" > "$TEST_DOTFILES/config/alias"
  cat > "$TEST_DOTFILES/config/fish/alias.fish" << 'EOF'
function dotc --wraps='cd ~/Code' --description 'cd ~/Code'
    cd ~/Code $argv
end
function gr --description 'cd to git root'
    cd (git rev-parse --show-toplevel) $argv
end
function complex
    echo nope
end
EOF

  run env DOTFILES="$TEST_DOTFILES" bash "$REPO_ROOT/scripts/update-readme-aliases.sh"
  [ "$status" -eq 0 ]

  run cat "$TEST_DOTFILES/docs/aliases.md"
  # --wraps matches the bash alias command → shared section.
  shared="$(awk '/^## Shared/{f=1;next} /^## /{f=0} f' "$TEST_DOTFILES/docs/aliases.md")"
  [[ "$shared" == *"dotc"* ]]
  # --description-only function appears with its description as the command.
  [[ "$output" == *"cd to git root"* ]]
  # A function with neither --wraps nor --description is skipped.
  [[ "$output" != *"complex"* ]]
}

@test "an eza-guarded alias is listed as its primary (first) definition" {
  # The fish ls/l/ll/lsa are defined twice: an eza form, then a system fallback.
  # First-definition-wins must surface the eza form (the live one), not the
  # fallback that appears later in the file.
  printf "alias ls='eza_git'\n" > "$TEST_DOTFILES/config/alias"
  cat > "$TEST_DOTFILES/config/fish/alias.fish" << 'EOF'
if type -q eza
    function ls --wraps='eza_git' --description eza
        eza_git $argv
    end
else
    function ls --description 'ls (system fallback)'
        command ls $argv
    end
end
EOF

  run env DOTFILES="$TEST_DOTFILES" bash "$REPO_ROOT/scripts/update-readme-aliases.sh"
  [ "$status" -eq 0 ]

  run cat "$TEST_DOTFILES/docs/aliases.md"
  [[ "$output" != *"system fallback"* ]]
  shared="$(awk '/^## Shared/{f=1;next} /^## /{f=0} f' "$TEST_DOTFILES/docs/aliases.md")"
  [[ "$shared" == *"ls"* ]]
}

@test "an alias with differing commands is not treated as shared" {
  printf "alias dup='one'\n" > "$TEST_DOTFILES/config/alias"
  printf "alias dup='two'\n" > "$TEST_DOTFILES/config/fish/alias.fish"

  run env DOTFILES="$TEST_DOTFILES" bash "$REPO_ROOT/scripts/update-readme-aliases.sh"
  [ "$status" -eq 0 ]

  run cat "$TEST_DOTFILES/docs/aliases.md"
  [[ "$output" != *"## Shared"* ]]
  [[ "$output" == *"## Bash & Zsh"* ]]
  [[ "$output" == *"## Fish"* ]]
  [[ "$output" == *"Total aliases: 2"* ]]
}
