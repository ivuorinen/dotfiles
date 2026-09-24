#!/usr/bin/env bats
#
# generate-vim-clues turns mini.clue's gen_clues tables into the label
# dictionaries vim's key guide shows on g, z and <C-w>. Each test writes a
# small fixture clue.lua shaped like mini.clue's, runs the script against it,
# and loads the result in a bare vim so the assertions are on what vim sees,
# not on the generated text.

setup()
{
  GEN="$BATS_TEST_DIRNAME/../scripts/generate-vim-clues.py"
  FIX="$BATS_TEST_TMPDIR"
  mkdir -p "$FIX/rtp/autoload"
  OUT="$FIX/rtp/autoload/miniclue.vim"

  cat > "$FIX/clue.lua" << 'EOF'
MiniClue.gen_clues.g = function()
  local gr_clue = { mode = 'n', keys = 'gr', desc = '+LSP' }
  return {
    { mode = 'n', keys = 'gg',       desc = 'Go to line (def: first)' },
    { mode = 'n', keys = "g'",       desc = "Jump to mark (don't affect jumplist)" },
    { mode = 'n', keys = 'g<Tab>',   desc = 'Go to last accessed tabpage' },
    { mode = 'n', keys = 'g<C-g>',   desc = 'Show information about cursor' },
    { mode = 'x', keys = 'g<C-a>',   desc = 'Increment with compound' },
  }
end

MiniClue.gen_clues.z = function()
  return {
    { mode = 'n', keys = 'zu',  desc = 'Undo spelling commands' },
    { mode = 'n', keys = 'zug', desc = 'Undo `zg`' },
    { mode = 'n', keys = 'zz',  desc = 'Redraw, cursor line at center' },
  }
end

MiniClue.gen_clues.windows = function(opts)
  return {
    { mode = 'n', keys = '<C-w>{',  desc = 'Brace key before the rest' },
    { mode = 'n', keys = '<C-w>}',  desc = 'Show tag in preview' },
    { mode = 'n', keys = '<C-w>w',  desc = 'Focus next', postkeys = nil },
  }
end
EOF
}

# Evaluate a Vim expression against the generated file; prints the result.
vim_eval()
{
  vim -N -X -es -u NONE -i NONE --cmd "set rtp^=$FIX/rtp" \
    -c "redir! > $FIX/out.txt" -c "silent echo $1" -c 'redir END' -c 'qa!' \
    < /dev/null > /dev/null 2>&1
  tr -d '\n' < "$FIX/out.txt"
}

@test "generate-vim-clues: writes a file vim loads" {
  run "$GEN" --source "$FIX/clue.lua" --output "$OUT"
  [ "$status" -eq 0 ]
  [ "$(vim_eval "len(miniclue#get('g', 'n'))")" = "4" ]
}

@test "generate-vim-clues: skips entries outside the return table" {
  "$GEN" --source "$FIX/clue.lua" --output "$OUT"
  [ "$(vim_eval "has_key(miniclue#get('g', 'n'), 'r')")" = "0" ]
}

@test "generate-vim-clues: keeps quotes inside descriptions" {
  "$GEN" --source "$FIX/clue.lua" --output "$OUT"
  [ "$(vim_eval "miniclue#get('g', 'n')[\"'\"]")" = "Jump to mark (don't affect jumplist)" ]
}

@test "generate-vim-clues: names <Tab>, writes other control keys raw" {
  "$GEN" --source "$FIX/clue.lua" --output "$OUT"
  [ "$(vim_eval "miniclue#get('g', 'n')['<Tab>']")" = "Go to last accessed tabpage" ]
  [ "$(vim_eval "miniclue#get('g', 'n')[\"\\<C-g>\"]")" = "Show information about cursor" ]
  [ "$(vim_eval "miniclue#get('g', 'x')[\"\\<C-a>\"]")" = "Increment with compound" ]
}

@test "generate-vim-clues: a key that is also a prefix becomes a named group" {
  "$GEN" --source "$FIX/clue.lua" --output "$OUT"
  [ "$(vim_eval "miniclue#get('z', 'n').u.name")" = "+Undo spelling commands" ]
  [ "$(vim_eval "miniclue#get('z', 'n').u.g")" = 'Undo `zg`' ]
}

@test "generate-vim-clues: braces inside key strings do not end the table" {
  "$GEN" --source "$FIX/clue.lua" --output "$OUT"
  [ "$(vim_eval "len(miniclue#get('windows', 'n'))")" = "3" ]
  [ "$(vim_eval "miniclue#get('windows', 'n').w")" = "Focus next" ]
}

@test "generate-vim-clues: a missing generator fails instead of writing" {
  sed -i.bak '/gen_clues.windows/,$d' "$FIX/clue.lua"
  run "$GEN" --source "$FIX/clue.lua" --output "$OUT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"MiniClue.gen_clues.windows not found"* ]]
  [ ! -e "$OUT" ]
}
