#!/usr/bin/env bats
#
# Coverage for scripts/check-keymap-desc.py, which replaced a grep that could
# never fail (it required double quotes; every call site uses single quotes —
# agent-loopholes-1324fbe0).

bats_require_minimum_version 1.5.0

setup()
{
  SCRIPT="${BATS_TEST_DIRNAME}/../scripts/check-keymap-desc.py"
  F="$BATS_TEST_TMPDIR/keys.lua"
}

@test "check-keymap-desc: a call without a description fails" {
  printf "K.nl('zz', ':echo<cr>')\n" > "$F"
  run -1 python3 "$SCRIPT" "$F"
  [[ "$output" == *"keys.lua:1"* ]]
}

@test "check-keymap-desc: string and table descriptions pass, in every helper" {
  cat > "$F" << 'EOF'
K.n('a', 'b', { desc = 'x' })
K.nl('b', 'c', 'Label')
K.d('<', { 'n', 'v' }, '<gv', 'Indent')
K.ld('cf', 'n', function()
  for _, b in ipairs(x) do
    if b then f(b, { force = false }) end
  end
end, 'Format')
-- K.n('c', 'd')
EOF
  run -0 python3 "$SCRIPT" "$F"
}

@test "check-keymap-desc: the committed nvim config passes" {
  cd "${BATS_TEST_DIRNAME}/.."
  run -0 python3 "$SCRIPT"
}
