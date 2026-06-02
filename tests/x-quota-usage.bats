#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

setup()
{
  STUB_DIR="$(mktemp -d)"

  # quota stub: returns a line with quota field = 0
  cat > "$STUB_DIR/quota" << 'STUB'
#!/usr/bin/env sh
printf '%s\n' "Filesystem  kbytes  quota  limit"
printf '%s\n' "---"
printf '%s\n' "/dev/disk1  1000    0      0"
STUB
  chmod +x "$STUB_DIR/quota"

  export PATH="$STUB_DIR:$PATH"
  export STUB_DIR
}

teardown()
{
  rm -rf "$STUB_DIR"
}

@test "x-quota-usage: skips zero-quota rows without dividing by zero" {
  run local/bin/x-quota-usage
  [ "$status" -eq 0 ]
  [[ "$output" != *"division by zero"* ]]
  # The only row has quota 0, so it is filtered out and no table is rendered.
  [[ "$output" != *"Mount"* ]]
}

@test "x-quota-usage: renders a usage bar for a non-zero quota" {
  cat > "$STUB_DIR/quota" << 'STUB'
#!/usr/bin/env sh
printf '%s\n' "Filesystem  kbytes   quota    limit"
printf '%s\n' "---"
printf '%s\n' "/dev/disk1  500000   1000000  1200000"
STUB
  chmod +x "$STUB_DIR/quota"

  run local/bin/x-quota-usage
  [ "$status" -eq 0 ]
  [[ "$output" == *"Mount"* ]]
  [[ "$output" == *"50.0%"* ]]
}

@test "x-quota-usage: exits 1 when quota output is empty" {
  printf '#!/usr/bin/env sh\n' > "$STUB_DIR/quota"
  chmod +x "$STUB_DIR/quota"

  run local/bin/x-quota-usage
  [ "$status" -eq 1 ]
  [[ "$output" == *"quota was empty"* ]]
}
