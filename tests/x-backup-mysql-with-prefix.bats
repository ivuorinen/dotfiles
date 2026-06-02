#!/usr/bin/env bats

setup()
{
  STUB_DIR="$(mktemp -d)"
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"

  # mysql stub: returns two table names after the header
  cat > "$STUB_DIR/mysql" << 'STUB'
#!/usr/bin/env sh
printf "Tables_in_db (wp_)\n"
printf "wp_options\n"
printf "wp_posts\n"
STUB
  chmod +x "$STUB_DIR/mysql"

  # mysqldump stub: records arg count and each arg on its own line
  cat > "$STUB_DIR/mysqldump" << STUB
#!/usr/bin/env sh
echo "\$#" > "$STUB_DIR/argc.txt"
printf "%s\n" "\$@" > "$STUB_DIR/args.txt"
STUB
  chmod +x "$STUB_DIR/mysqldump"

  export PATH="$STUB_DIR:$PATH"
  export STUB_DIR REPO_ROOT

  # The script writes its <db>_<name>_<timestamp>.sql dump to the current
  # directory. Run from inside STUB_DIR so that artifact lands there and is
  # removed by teardown instead of polluting the repo root.
  cd "$STUB_DIR" || return 1
}

teardown()
{
  rm -rf "$STUB_DIR"
}

@test "x-backup-mysql-with-prefix: passes each table as a separate argument" {
  run bash "$REPO_ROOT/local/bin/x-backup-mysql-with-prefix" wp_ mysite wordpress
  [ "$status" -eq 0 ]
  local argc
  argc=$(cat "$STUB_DIR/argc.txt")
  # database + wp_options + wp_posts = 3 args
  [ "$argc" -eq 3 ]
}

@test "x-backup-mysql-with-prefix: exits 1 without required arguments" {
  run bash "$REPO_ROOT/local/bin/x-backup-mysql-with-prefix"
  [ "$status" -eq 1 ]
}
