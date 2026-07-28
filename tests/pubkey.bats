#!/usr/bin/env bats

# pubkey copies a public key to the clipboard. The guard matters more than the
# copy: without it the script pipes a missing file into pbcopy and reports
# success, leaving the user with a stale clipboard.

setup()
{
  PUBKEY="$BATS_TEST_DIRNAME/../local/bin/pubkey"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin" "$TMP/home/.ssh"
  CLIP="$TMP/clipboard"
  cat > "$TMP/bin/pbcopy" << STUB
#!/usr/bin/env bash
cat > "$CLIP"
STUB
  chmod +x "$TMP/bin/pbcopy"
  printf 'ssh-rsa AAAADEFAULT user@host\n' > "$TMP/home/.ssh/id_rsa.pub"
}

teardown()
{
  rm -rf "$TMP"
}

@test "pubkey: copies the default key when no argument is given" {
  run env PATH="$TMP/bin:$PATH" HOME="$TMP/home" "$PUBKEY"
  [ "$status" -eq 0 ]
  grep -q 'AAAADEFAULT' "$CLIP"
}

@test "pubkey: confirms the copy on stdout" {
  run env PATH="$TMP/bin:$PATH" HOME="$TMP/home" "$PUBKEY"
  [[ "$output" == *"copied"* ]]
}

@test "pubkey: copies an explicitly named key" {
  printf 'ssh-ed25519 AAAAOTHER user@host\n' > "$TMP/other.pub"
  run env PATH="$TMP/bin:$PATH" HOME="$TMP/home" "$PUBKEY" "$TMP/other.pub"
  [ "$status" -eq 0 ]
  grep -q 'AAAAOTHER' "$CLIP"
}

@test "pubkey: a missing key file exits 1 and copies nothing" {
  run env PATH="$TMP/bin:$PATH" HOME="$TMP/home" "$PUBKEY" "$TMP/no-such.pub"
  [ "$status" -eq 1 ]
  [ ! -f "$CLIP" ]
}

@test "pubkey: the missing-key error goes to stderr" {
  run env PATH="$TMP/bin:$PATH" HOME="$TMP/home" bash -c "'$PUBKEY' '$TMP/no-such.pub' 2>&1 >/dev/null"
  [[ "$output" == *"no such key file"* ]]
}

@test "pubkey: a missing default key is reported, not silently copied" {
  rm "$TMP/home/.ssh/id_rsa.pub"
  run env PATH="$TMP/bin:$PATH" HOME="$TMP/home" "$PUBKEY"
  [ "$status" -eq 1 ]
  [ ! -f "$CLIP" ]
}
