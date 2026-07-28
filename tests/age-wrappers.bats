#!/usr/bin/env bats

# ae and ad encrypt and decrypt files with age, using the SSH keys published
# on a GitHub profile. age and curl are stubbed: nothing is fetched from
# github.com and no real key is ever used.

setup()
{
  AE="$BATS_TEST_DIRNAME/../local/bin/ae"
  AD="$BATS_TEST_DIRNAME/../local/bin/ad"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin" "$TMP/work"
  KEYS="$TMP/keys.txt"
  CALLS="$TMP/calls"
  : > "$CALLS"
  for tool in bash env mktemp dirname mkdir chmod rm mv cat stat; do
    ln -sf "$(command -v "$tool")" "$TMP/bin/$tool"
  done

  cat > "$TMP/bin/age" << STUB
#!/usr/bin/env bash
printf 'age %s\n' "\$*" >> "$CALLS"
[ -n "\$AGE_FAIL" ] && exit 1
printf 'CIPHERTEXT\n'
STUB

  # Writes to whatever -o names, so the script's fetch path can be exercised.
  cat > "$TMP/bin/curl" << STUB
#!/usr/bin/env bash
printf 'curl %s\n' "\$*" >> "$CALLS"
out=""
while [ \$# -gt 0 ]; do
  [ "\$1" = "-o" ] && out="\$2"
  shift
done
[ -n "\$CURL_EMPTY" ] && { : > "\$out"; exit 0; }
[ -n "\$out" ] && printf 'ssh-ed25519 AAAA fake\n' > "\$out"
STUB
  chmod +x "$TMP/bin/age" "$TMP/bin/curl"

  printf 'plaintext\n' > "$TMP/work/secret.txt"
  printf 'ENCRYPTED\n' > "$TMP/work/secret.txt.age"
}

teardown()
{
  rm -rf "$TMP"
}

age_run()
{
  script="$1"
  shift
  run env PATH="$TMP/bin" AGE_KEYSFILE="$KEYS" \
    AGE_KEYSSOURCE="https://example.invalid/keys" "$script" "$@"
}

@test "ae: refuses to run without age installed" {
  rm "$TMP/bin/age"
  age_run "$AE" "$TMP/work/secret.txt"
  [ "$status" -eq 1 ]
  [[ "$output" == *"age is not installed"* ]]
}

@test "ad: refuses to run without age installed" {
  rm "$TMP/bin/age"
  age_run "$AD" "$TMP/work/secret.txt.age"
  [ "$status" -eq 1 ]
  [[ "$output" == *"age is not installed"* ]]
}

@test "ae: refuses to run without curl installed" {
  rm "$TMP/bin/curl"
  age_run "$AE" "$TMP/work/secret.txt"
  [ "$status" -eq 1 ]
  [[ "$output" == *"curl is not installed"* ]]
}

@test "ae: no argument prints usage" {
  age_run "$AE"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "ad: no argument prints usage" {
  age_run "$AD"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "ae: rejects a file that does not exist" {
  age_run "$AE" "$TMP/work/missing.txt"
  [ "$status" -eq 1 ]
  [[ "$output" == *"does not exist"* ]]
}

@test "ad: rejects a file that does not exist" {
  age_run "$AD" "$TMP/work/missing.age"
  [ "$status" -eq 1 ]
  [[ "$output" == *"does not exist"* ]]
}

@test "ae: fetches the keys file when it is missing" {
  age_run "$AE" "$TMP/work/secret.txt"
  [ "$status" -eq 0 ]
  grep -q 'https://example.invalid/keys' "$CALLS"
  [ -f "$KEYS" ]
}

@test "ae: the fetched keys file is read-only" {
  age_run "$AE" "$TMP/work/secret.txt"
  [ "$(stat -c '%a' "$KEYS" 2> /dev/null || stat -f '%Lp' "$KEYS")" = "400" ]
}

@test "ae: does not refetch keys that are already on disk" {
  printf 'ssh-ed25519 AAAA existing\n' > "$KEYS"
  age_run "$AE" "$TMP/work/secret.txt"
  run ! grep -q '^curl ' "$CALLS"
}

@test "ae: an empty fetch is an error" {
  run env PATH="$TMP/bin" CURL_EMPTY=1 AGE_KEYSFILE="$KEYS" \
    AGE_KEYSSOURCE="https://example.invalid/keys" "$AE" "$TMP/work/secret.txt"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Failed to fetch keys"* ]]
}

@test "ae: an empty fetch leaves no keys file behind" {
  # Without the cleanup the next run finds a zero-byte keys file, decides it
  # does not need to fetch, and hands age an empty recipients list — a much
  # more confusing failure than the one above. ad already cleaned up here.
  run env PATH="$TMP/bin" CURL_EMPTY=1 AGE_KEYSFILE="$KEYS" \
    AGE_KEYSSOURCE="https://example.invalid/keys" "$AE" "$TMP/work/secret.txt"
  [ ! -f "$KEYS" ]
}

@test "ad: an empty fetch leaves no keys file behind" {
  run env PATH="$TMP/bin" CURL_EMPTY=1 AGE_KEYSFILE="$KEYS" \
    AGE_KEYSSOURCE="https://example.invalid/keys" "$AD" "$TMP/work/secret.txt.age"
  [ ! -f "$KEYS" ]
}

@test "ae: encrypts to <file>.age" {
  printf 'ssh-ed25519 AAAA existing\n' > "$KEYS"
  age_run "$AE" "$TMP/work/secret.txt"
  [ "$status" -eq 0 ]
  [ -f "$TMP/work/secret.txt.age" ]
  [[ "$output" == *"encrypted successfully"* ]]
}

@test "ae: passes the keys file to age as the recipients list" {
  printf 'ssh-ed25519 AAAA existing\n' > "$KEYS"
  age_run "$AE" "$TMP/work/secret.txt"
  grep -q -- "-R $KEYS" "$CALLS"
}

@test "ad: decrypts by stripping the .age suffix" {
  printf 'ssh-ed25519 AAAA existing\n' > "$KEYS"
  rm -f "$TMP/work/secret.txt"
  age_run "$AD" "$TMP/work/secret.txt.age"
  [ "$status" -eq 0 ]
  [ -f "$TMP/work/secret.txt" ]
  [[ "$output" == *"decrypted successfully"* ]]
}

@test "ad: passes the keys file to age as the identity" {
  printf 'ssh-ed25519 AAAA existing\n' > "$KEYS"
  age_run "$AD" "$TMP/work/secret.txt.age"
  grep -q -- "-d -i $KEYS" "$CALLS"
}

@test "ad: a failed decrypt does not overwrite the target" {
  # The plaintext is written to a temp file and only moved into place once age
  # succeeds, so a bad key must leave any existing file untouched.
  printf 'ssh-ed25519 AAAA existing\n' > "$KEYS"
  printf 'ORIGINAL\n' > "$TMP/work/secret.txt"
  run env PATH="$TMP/bin" AGE_FAIL=1 AGE_KEYSFILE="$KEYS" \
    AGE_KEYSSOURCE="https://example.invalid/keys" "$AD" "$TMP/work/secret.txt.age"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Failed to decrypt"* ]]
  [ "$(cat "$TMP/work/secret.txt")" = "ORIGINAL" ]
}

@test "ad: a failed decrypt leaves no temp file behind" {
  printf 'ssh-ed25519 AAAA existing\n' > "$KEYS"
  run env PATH="$TMP/bin" AGE_FAIL=1 AGE_KEYSFILE="$KEYS" \
    AGE_KEYSSOURCE="https://example.invalid/keys" "$AD" "$TMP/work/secret.txt.age"
  [ "$(find "$TMP/work" -name 'tmp.*' | wc -l)" -eq 0 ]
}
