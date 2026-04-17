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

@test "x-quota-usage: exits 0 with no PHP warnings when quota is zero" {
  run php local/bin/x-quota-usage.php
  [ "$status" -eq 0 ]
  [[ "$output" != *"Division by zero"* ]]
  [[ "$output" != *"Warning"* ]]
}

@test "x-quota-usage: exits non-zero when quota binary is missing" {
  local no_quota
  no_quota="$(mktemp -d)"
  run -127 env PATH="$no_quota" php local/bin/x-quota-usage.php
  rm -rf "$no_quota"
}
