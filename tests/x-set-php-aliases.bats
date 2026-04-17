#!/usr/bin/env bats

setup()
{
  STUB_DIR="$(mktemp -d)"
  CACHE_HOME="$(mktemp -d)"

  cat > "$STUB_DIR/brew" << 'STUB'
#!/usr/bin/env sh
case "$1" in
  list) exit 0 ;;
  --prefix) echo "/usr/local" ;;
esac
STUB
  chmod +x "$STUB_DIR/brew"

  export PATH="$STUB_DIR:$PATH"
  export XDG_CACHE_HOME="$CACHE_HOME"
  export STUB_DIR CACHE_HOME
}

teardown()
{
  rm -rf "$STUB_DIR" "$CACHE_HOME"
}

@test "x-set-php-aliases: exits 0 when no PHP formula is installed" {
  run bash local/bin/x-set-php-aliases
  [ "$status" -eq 0 ]
}

@test "x-set-php-aliases: creates brew list cache file even when no PHP found" {
  run bash local/bin/x-set-php-aliases
  [ "$status" -eq 0 ]
  [ -f "$CACHE_HOME/x-set-php-aliases/brew_list.cache" ]
}
