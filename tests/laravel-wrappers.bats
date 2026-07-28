#!/usr/bin/env bats

# art and sail are Laravel wrappers that pick a local binary over the vendored
# one. The choice is the whole contract, so php/bash are stubbed and the tests
# assert which path was invoked and that arguments are forwarded.

setup()
{
  ART="$BATS_TEST_DIRNAME/../local/bin/art"
  SAIL="$BATS_TEST_DIRNAME/../local/bin/sail"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin" "$TMP/proj/vendor/bin"
  cat > "$TMP/bin/php" << 'STUB'
#!/usr/bin/env bash
printf 'PHP:%s\n' "$*"
STUB
  chmod +x "$TMP/bin/php"
  cd "$TMP/proj" || exit 1
}

teardown()
{
  cd / || true
  rm -rf "$TMP"
}

@test "art: prefers a project-root artisan" {
  touch "$TMP/proj/artisan"
  run env PATH="$TMP/bin:$PATH" bash -c "cd '$TMP/proj' && '$ART' migrate"
  [ "$status" -eq 0 ]
  [[ "$output" == "PHP:artisan migrate" ]]
}

@test "art: falls back to vendor/bin/artisan" {
  run env PATH="$TMP/bin:$PATH" bash -c "cd '$TMP/proj' && '$ART' migrate"
  [ "$status" -eq 0 ]
  [[ "$output" == "PHP:vendor/bin/artisan migrate" ]]
}

@test "art: forwards every argument" {
  touch "$TMP/proj/artisan"
  run env PATH="$TMP/bin:$PATH" bash -c "cd '$TMP/proj' && '$ART' make:model User --migration"
  [[ "$output" == *"make:model User --migration"* ]]
}

@test "art: works with no arguments" {
  touch "$TMP/proj/artisan"
  run env PATH="$TMP/bin:$PATH" bash -c "cd '$TMP/proj' && '$ART'"
  [ "$status" -eq 0 ]
  [[ "$output" == "PHP:artisan" ]]
}

@test "sail: prefers a project-root sail script" {
  printf '#!/usr/bin/env bash\nprintf "LOCAL:%%s\\n" "$*"\n' > "$TMP/proj/sail"
  run bash -c "cd '$TMP/proj' && '$SAIL' up"
  [ "$status" -eq 0 ]
  [[ "$output" == "LOCAL:up" ]]
}

@test "sail: falls back to vendor/bin/sail" {
  printf '#!/usr/bin/env bash\nprintf "VENDOR:%%s\\n" "$*"\n' > "$TMP/proj/vendor/bin/sail"
  run bash -c "cd '$TMP/proj' && '$SAIL' up -d"
  [ "$status" -eq 0 ]
  [[ "$output" == "VENDOR:up -d" ]]
}
