#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

# ae encrypts to the SSH public keys published on a GitHub profile; ad
# decrypts with the matching private key. age and curl are stubbed: nothing is
# fetched from github.com and no real key is ever used. The round-trip tests
# at the end run the real age against a throwaway key pair.

setup()
{
  A="$BATS_TEST_DIRNAME/../local/bin/a"
  AE="$BATS_TEST_DIRNAME/../local/bin/ae"
  AD="$BATS_TEST_DIRNAME/../local/bin/ad"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin" "$TMP/work"
  # ae and ad run a, which logs every run; keep that out of the real ~/.cache.
  export AGE_LOGFILE="$TMP/a.log"
  KEYS="$TMP/keys.txt"
  IDENTITY="$TMP/id"
  printf 'PRIVATE KEY\n' > "$IDENTITY"
  CALLS="$TMP/calls"
  : > "$CALLS"
  for tool in bash env mktemp dirname mkdir chmod rm mv cat stat grep date touch find; do
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
[ -n "\$CURL_FAIL" ] && exit 22
# Simulates Ctrl-C mid-download: a partial file, then TERM to the script.
[ -n "\$CURL_KILL" ] && { printf 'ssh-ed' > "\$out"; kill -TERM "\$PPID"; exit 1; }
[ -n "\$CURL_EMPTY" ] && { : > "\$out"; exit 0; }
[ -n "\$CURL_BODY" ] && { printf '%s\n' "\$CURL_BODY" > "\$out"; exit 0; }
[ -n "\$out" ] && printf 'ssh-ed25519 AAAA fake\n' > "\$out"
STUB
  chmod +x "$TMP/bin/age" "$TMP/bin/curl"

  # secret.txt and secret.txt.age are each the other's output name, so
  # tests that expect a write remove the one they would produce.
  printf 'plaintext\n' > "$TMP/work/secret.txt"
  printf 'ENCRYPTED\n' > "$TMP/work/secret.txt.age"
}

# ae's output, for the tests that expect the encrypt to go through.
no_age_output()
{
  rm -f "$TMP/work/secret.txt.age"
}

# ad's output, for the tests that expect the decrypt to go through.
no_plain_output()
{
  rm -f "$TMP/work/secret.txt"
}

# A cached keys file older than the default 7-day bound.
stale_keys()
{
  printf 'ssh-ed25519 AAAA cached\n' > "$KEYS"
  chmod 0400 "$KEYS"
  touch -t 202001010000 "$KEYS"
}

teardown()
{
  chmod -R u+w "$TMP" 2> /dev/null
  rm -rf "$TMP"
}

age_run()
{
  script="$1"
  shift
  run env PATH="$TMP/bin" AGE_KEYSFILE="$KEYS" AGE_IDENTITY="$IDENTITY" \
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
  no_age_output
  age_run "$AE" "$TMP/work/secret.txt"
  [ "$status" -eq 0 ]
  grep -q 'https://example.invalid/keys' "$CALLS"
  [ -f "$KEYS" ]
}

@test "ae: the fetched keys file is read-only" {
  no_age_output
  age_run "$AE" "$TMP/work/secret.txt"
  [ "$(stat -c '%a' "$KEYS" 2> /dev/null || stat -f '%Lp' "$KEYS")" = "400" ]
}

@test "ae: does not refetch keys that are already on disk" {
  no_age_output
  printf 'ssh-ed25519 AAAA existing\n' > "$KEYS"
  age_run "$AE" "$TMP/work/secret.txt"
  [ "$status" -eq 0 ]
  run ! grep -q '^curl ' "$CALLS"
}

@test "ae: refetches keys older than AGE_KEYS_MAX_AGE_DAYS" {
  # A key revoked on GitHub must stop receiving new files.
  no_age_output
  stale_keys
  age_run "$AE" "$TMP/work/secret.txt"
  [ "$status" -eq 0 ]
  grep -q '^curl ' "$CALLS"
  [ "$(cat "$KEYS")" = "ssh-ed25519 AAAA fake" ]
}

@test "ae: a failed refresh warns and keeps using the cached keys" {
  no_age_output
  stale_keys
  run --separate-stderr env PATH="$TMP/bin" CURL_FAIL=1 AGE_KEYSFILE="$KEYS" \
    AGE_KEYSSOURCE="https://example.invalid/keys" "$AE" "$TMP/work/secret.txt"
  [ "$status" -eq 0 ]
  [[ "$stderr" == *"using cached"* ]]
  [ "$(cat "$KEYS")" = "ssh-ed25519 AAAA cached" ]
  grep -q -- "-R $KEYS" "$CALLS"
  [ "$(find "$TMP" -maxdepth 1 -name 'keys.txt.*' | wc -l)" -eq 0 ]
}

@test "ae: a non-numeric AGE_KEYS_MAX_AGE_DAYS is an error" {
  no_age_output
  run env PATH="$TMP/bin" AGE_KEYS_MAX_AGE_DAYS=week AGE_KEYSFILE="$KEYS" \
    "$AE" "$TMP/work/secret.txt"
  [ "$status" -eq 1 ]
  [[ "$output" == *"AGE_KEYS_MAX_AGE_DAYS"* ]]
}

@test "ae: an interrupted keys download leaves no temp file" {
  no_age_output
  run env PATH="$TMP/bin" CURL_KILL=1 AGE_KEYSFILE="$KEYS" \
    AGE_KEYSSOURCE="https://example.invalid/keys" "$AE" "$TMP/work/secret.txt"
  [ "$status" -ne 0 ]
  [ ! -f "$KEYS" ]
  [ "$(find "$TMP" -maxdepth 1 -name 'keys.txt.*' | wc -l)" -eq 0 ]
}

@test "ae: an empty fetch is an error" {
  no_age_output
  run env PATH="$TMP/bin" CURL_EMPTY=1 AGE_KEYSFILE="$KEYS" \
    AGE_KEYSSOURCE="https://example.invalid/keys" "$AE" "$TMP/work/secret.txt"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Failed to fetch keys"* ]]
}

@test "ae: an empty fetch leaves no keys file behind" {
  # Without the cleanup the next run finds a zero-byte keys file, decides it
  # does not need to fetch, and hands age an empty recipients list — a much
  # more confusing failure than the one above. ad already cleaned up here.
  no_age_output
  run env PATH="$TMP/bin" CURL_EMPTY=1 AGE_KEYSFILE="$KEYS" \
    AGE_KEYSSOURCE="https://example.invalid/keys" "$AE" "$TMP/work/secret.txt"
  [ ! -f "$KEYS" ]
}

@test "ae: an HTTP error body is not cached as the keys file" {
  # curl -f fails on a 404, but a 200 page that holds no SSH keys must be
  # rejected too: a cached bad file is never refetched.
  no_age_output
  run env PATH="$TMP/bin" CURL_BODY="Not Found" AGE_KEYSFILE="$KEYS" \
    AGE_KEYSSOURCE="https://example.invalid/keys" "$AE" "$TMP/work/secret.txt"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Failed to fetch keys"* ]]
  [ ! -f "$KEYS" ]
  [ "$(find "$TMP" -maxdepth 1 -name 'keys.txt.*' | wc -l)" -eq 0 ]
}

@test "ae: fetches with curl --fail" {
  no_age_output
  age_run "$AE" "$TMP/work/secret.txt"
  grep -q '^curl -fsSL' "$CALLS"
}

@test "ae: refuses to overwrite an existing .age file" {
  printf 'ssh-ed25519 AAAA existing\n' > "$KEYS"
  age_run "$AE" "$TMP/work/secret.txt"
  [ "$status" -eq 1 ]
  [[ "$output" == *"already exists"* ]]
  [ "$(cat "$TMP/work/secret.txt.age")" = "ENCRYPTED" ]
  run ! grep -q '^age ' "$CALLS"
}

@test "ae: --force overwrites an existing .age file" {
  printf 'ssh-ed25519 AAAA existing\n' > "$KEYS"
  age_run "$AE" --force "$TMP/work/secret.txt"
  [ "$status" -eq 0 ]
  [ "$(cat "$TMP/work/secret.txt.age")" = "CIPHERTEXT" ]
}

@test "ad: never fetches keys" {
  no_plain_output
  age_run "$AD" "$TMP/work/secret.txt.age"
  [ "$status" -eq 0 ]
  run ! grep -q '^curl ' "$CALLS"
  [ ! -f "$KEYS" ]
}

@test "ad: a missing identity is an error" {
  no_plain_output
  run env PATH="$TMP/bin" AGE_IDENTITY="$TMP/no-such-key" \
    "$AD" "$TMP/work/secret.txt.age"
  [ "$status" -eq 1 ]
  [[ "$output" == *"AGE_IDENTITY"* ]]
}

@test "ae: errors go to stderr, not stdout" {
  run --separate-stderr env PATH="$TMP/bin" "$AE" "$TMP/work/missing.txt"
  [ "$status" -eq 1 ]
  [ -z "$output" ]
  [[ "$stderr" == *"does not exist"* ]]
}

@test "ad: errors go to stderr, not stdout" {
  run --separate-stderr env PATH="$TMP/bin" "$AD" "$TMP/work/missing.age"
  [ "$status" -eq 1 ]
  [ -z "$output" ]
  [[ "$stderr" == *"does not exist"* ]]
}

@test "ae: a failed encrypt keeps the existing .age file and leaves no temp" {
  printf 'ssh-ed25519 AAAA existing\n' > "$KEYS"
  run env PATH="$TMP/bin" AGE_FAIL=1 AGE_KEYSFILE="$KEYS" "$AE" -f "$TMP/work/secret.txt"
  [ "$status" -eq 1 ]
  grep -q '^age ' "$CALLS"
  [ "$(cat "$TMP/work/secret.txt.age")" = "ENCRYPTED" ]
  [ "$(find "$TMP/work" -name 'tmp.*' | wc -l)" -eq 0 ]
}

@test "ae: encrypts to <file>.age" {
  no_age_output
  printf 'ssh-ed25519 AAAA existing\n' > "$KEYS"
  age_run "$AE" "$TMP/work/secret.txt"
  [ "$status" -eq 0 ]
  [ -f "$TMP/work/secret.txt.age" ]
  [[ "$output" == *"encrypted successfully"* ]]
}

@test "ae: passes the keys file to age as the recipients list" {
  no_age_output
  printf 'ssh-ed25519 AAAA existing\n' > "$KEYS"
  age_run "$AE" "$TMP/work/secret.txt"
  grep -q -- "-R $KEYS" "$CALLS"
}

@test "ad: decrypts by stripping the .age suffix" {
  printf 'ssh-ed25519 AAAA existing\n' > "$KEYS"
  no_plain_output
  age_run "$AD" "$TMP/work/secret.txt.age"
  [ "$status" -eq 0 ]
  [ -f "$TMP/work/secret.txt" ]
  [[ "$output" == *"decrypted successfully"* ]]
}

@test "ad: passes the private key, not the keys file, to age as the identity" {
  no_plain_output
  age_run "$AD" "$TMP/work/secret.txt.age"
  grep -q -- "-d -i $IDENTITY" "$CALLS"
}

@test "ad: refuses to overwrite an existing plaintext" {
  # The plaintext may hold edits newer than the ciphertext.
  printf 'NEWER EDITS\n' > "$TMP/work/secret.txt"
  age_run "$AD" "$TMP/work/secret.txt.age"
  [ "$status" -eq 1 ]
  [[ "$output" == *"already exists"* ]]
  [ "$(cat "$TMP/work/secret.txt")" = "NEWER EDITS" ]
  run ! grep -q '^age ' "$CALLS"
}

@test "ad: --force overwrites an existing plaintext" {
  age_run "$AD" "$TMP/work/secret.txt.age" --force
  [ "$status" -eq 0 ]
  [ "$(cat "$TMP/work/secret.txt")" = "CIPHERTEXT" ]
}

@test "ad: refuses a file without the .age suffix, even with --force" {
  # The output name would equal the input: the ciphertext would be replaced
  # by its own plaintext.
  printf 'ENCRYPTED\n' > "$TMP/work/sealed"
  age_run "$AD" -f "$TMP/work/sealed"
  [ "$status" -eq 1 ]
  [[ "$output" == *"no .age suffix"* ]]
  [ "$(cat "$TMP/work/sealed")" = "ENCRYPTED" ]
}

@test "ad: a failed decrypt does not overwrite the target" {
  # The plaintext is written to a temp file and only moved into place once age
  # succeeds, so a bad key must leave any existing file untouched.
  printf 'ssh-ed25519 AAAA existing\n' > "$KEYS"
  printf 'ORIGINAL\n' > "$TMP/work/secret.txt"
  run env PATH="$TMP/bin" AGE_FAIL=1 AGE_IDENTITY="$IDENTITY" \
    "$AD" --force "$TMP/work/secret.txt.age"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Failed to decrypt"* ]]
  [ "$(cat "$TMP/work/secret.txt")" = "ORIGINAL" ]
}

@test "ad: a failed decrypt leaves no temp file behind" {
  no_plain_output
  run env PATH="$TMP/bin" AGE_FAIL=1 AGE_IDENTITY="$IDENTITY" \
    "$AD" "$TMP/work/secret.txt.age"
  [ "$status" -eq 1 ]
  grep -q '^age ' "$CALLS"
  [ "$(find "$TMP/work" -name 'tmp.*' | wc -l)" -eq 0 ]
}

# Real age, throwaway ed25519 key pair: encrypt to the public key (what the
# GitHub keys file holds), decrypt with the private key.
real_keypair()
{
  command -v age > /dev/null || skip "age is not installed"
  command -v ssh-keygen > /dev/null || skip "ssh-keygen is not installed"
  ssh-keygen -q -t ed25519 -N '' -f "$TMP/rt_key"
  cp "$TMP/rt_key.pub" "$KEYS"
  rm -f "$TMP/work/secret.txt.age"
}

@test "ae + ad: round trip with real age and an SSH key pair" {
  real_keypair
  run env AGE_KEYSFILE="$KEYS" "$AE" "$TMP/work/secret.txt"
  [ "$status" -eq 0 ]
  rm "$TMP/work/secret.txt"
  run env AGE_IDENTITY="$TMP/rt_key" "$AD" "$TMP/work/secret.txt.age"
  [ "$status" -eq 0 ]
  [ "$(cat "$TMP/work/secret.txt")" = "plaintext" ]
}

@test "a e + a d: round trip with real age exits 0 both ways" {
  real_keypair
  run env AGE_KEYSFILE="$KEYS" AGE_LOGFILE="$TMP/a.log" "$A" e "$TMP/work/secret.txt"
  [ "$status" -eq 0 ]
  rm "$TMP/work/secret.txt"
  run env AGE_IDENTITY="$TMP/rt_key" AGE_LOGFILE="$TMP/a.log" "$A" d "$TMP/work/secret.txt.age"
  [ "$status" -eq 0 ]
  [ "$(cat "$TMP/work/secret.txt")" = "plaintext" ]
  [ "$(find "$TMP/work" -name 'tmp.*' | wc -l)" -eq 0 ]
}

@test "a: rejects an HTTP error body as the keys file" {
  rm -f "$TMP/work/secret.txt.age"
  run env PATH="$TMP/bin" CURL_BODY="Not Found" AGE_KEYSFILE="$KEYS" \
    AGE_LOGFILE="$TMP/a.log" AGE_KEYSSOURCE="https://example.invalid/keys" \
    "$A" e "$TMP/work/secret.txt"
  [ "$status" -eq 1 ]
  [ ! -f "$KEYS" ]
}

a_run()
{
  run --separate-stderr env PATH="$TMP/bin" AGE_KEYSFILE="$KEYS" \
    AGE_LOGFILE="$TMP/a.log" AGE_KEYSSOURCE="https://example.invalid/keys" \
    "$@" "$A" e "$TMP/work/secret.txt"
}

@test "a: refetches keys older than AGE_KEYS_MAX_AGE_DAYS" {
  no_age_output
  stale_keys
  a_run
  [ "$status" -eq 0 ]
  [ "$(cat "$KEYS")" = "ssh-ed25519 AAAA fake" ]
}

@test "a: keeps fresh keys without fetching" {
  no_age_output
  printf 'ssh-ed25519 AAAA existing\n' > "$KEYS"
  a_run
  [ "$status" -eq 0 ]
  run ! grep -q '^curl ' "$CALLS"
}

@test "a: a failed refresh warns and keeps using the cached keys" {
  no_age_output
  stale_keys
  a_run CURL_FAIL=1
  [ "$status" -eq 0 ]
  [[ "$stderr" == *"using cached"* ]]
  [ "$(cat "$KEYS")" = "ssh-ed25519 AAAA cached" ]
  [ "$(find "$TMP" -maxdepth 1 -name 'keys.txt.*' | wc -l)" -eq 0 ]
}

@test "a: a directory refreshes the keys at most once" {
  # A failing refresh must not be retried (and time out) once per file.
  mkdir "$TMP/work/dir"
  printf 'one\n' > "$TMP/work/dir/one.txt"
  printf 'two\n' > "$TMP/work/dir/two.txt"
  stale_keys
  run env PATH="$TMP/bin" CURL_FAIL=1 AGE_KEYSFILE="$KEYS" AGE_LOGFILE="$TMP/a.log" \
    AGE_KEYSSOURCE="https://example.invalid/keys" "$A" e "$TMP/work/dir"
  [ "$status" -eq 0 ]
  [ "$(grep -c '^curl ' "$CALLS")" -eq 1 ]
  [ -f "$TMP/work/dir/two.txt.age" ]
}

@test "a: an interrupted keys download leaves no temp file" {
  no_age_output
  a_run CURL_KILL=1
  [ "$status" -ne 0 ]
  [ ! -f "$KEYS" ]
  [ "$(find "$TMP" -maxdepth 1 -name 'keys.txt.*' | wc -l)" -eq 0 ]
}

# Runs a with fresh cached keys, so nothing is fetched.
a_args()
{
  printf 'ssh-ed25519 AAAA existing\n' > "$KEYS"
  run --separate-stderr env PATH="$TMP/bin" AGE_KEYSFILE="$KEYS" \
    AGE_IDENTITY="$IDENTITY" AGE_KEYSSOURCE="https://example.invalid/keys" \
    "$A" "$@"
}

@test "a: --delete removes the original after encrypting" {
  no_age_output
  a_args --delete e "$TMP/work/secret.txt"
  [ "$status" -eq 0 ]
  [ ! -e "$TMP/work/secret.txt" ]
  [ "$(cat "$TMP/work/secret.txt.age")" = "CIPHERTEXT" ]
}

@test "a: --delete removes the .age file after decrypting" {
  no_plain_output
  a_args --delete d "$TMP/work/secret.txt.age"
  [ "$status" -eq 0 ]
  [ ! -e "$TMP/work/secret.txt.age" ]
  [ -f "$TMP/work/secret.txt" ]
}

@test "a: refuses to overwrite an existing .age file, on stderr" {
  a_args e "$TMP/work/secret.txt"
  [ "$status" -eq 1 ]
  [ -z "$output" ]
  [[ "$stderr" == *"already exists"* ]]
  [ "$(cat "$TMP/work/secret.txt.age")" = "ENCRYPTED" ]
  run ! grep -q '^age ' "$CALLS"
}

@test "a: -f overwrites an existing .age file" {
  a_args -f e "$TMP/work/secret.txt"
  [ "$status" -eq 0 ]
  [ "$(cat "$TMP/work/secret.txt.age")" = "CIPHERTEXT" ]
}

@test "a: --force after the target overwrites too" {
  a_args e "$TMP/work/secret.txt" --force
  [ "$status" -eq 0 ]
  [ "$(cat "$TMP/work/secret.txt.age")" = "CIPHERTEXT" ]
}

@test "a: -v prints progress on stdout" {
  no_age_output
  a_args -v e "$TMP/work/secret.txt"
  [ "$status" -eq 0 ]
  [[ "$output" == *"File encrypted successfully"* ]]
}

@test "a: without -v a success prints nothing" {
  no_age_output
  a_args e "$TMP/work/secret.txt"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
  [ -z "$stderr" ]
}

@test "a: a directory encrypt continues past a failed file" {
  mkdir "$TMP/work/dir"
  printf 'one\n' > "$TMP/work/dir/a1"
  printf 'OLD\n' > "$TMP/work/dir/a1.age"
  printf 'two\n' > "$TMP/work/dir/b2"
  printf 'three\n' > "$TMP/work/dir/c3"
  a_args e "$TMP/work/dir"
  [ "$status" -eq 1 ]
  [ -f "$TMP/work/dir/b2.age" ]
  [ -f "$TMP/work/dir/c3.age" ]
  [ "$(cat "$TMP/work/dir/a1.age")" = "OLD" ]
  [[ "$stderr" == *"1 file(s) failed"* ]]
}

# Only the first target was read, so a glob such as `ae *.txt` encrypted one
# file, exited 0 and left the others in plaintext.
@test "a: every target given is processed" {
  printf 'one\n' > "$TMP/work/m1.txt"
  printf 'two\n' > "$TMP/work/m2.txt"
  a_args e "$TMP/work/m1.txt" "$TMP/work/m2.txt"
  [ "$status" -eq 0 ]
  [ -f "$TMP/work/m1.txt.age" ]
  [ -f "$TMP/work/m2.txt.age" ]
}

@test "a: a bad target among several fails the run but the rest still run" {
  printf 'one\n' > "$TMP/work/m1.txt"
  a_args e "$TMP/work/no-such-file" "$TMP/work/m1.txt"
  [ "$status" -eq 1 ]
  [ -f "$TMP/work/m1.txt.age" ]
  [[ "$stderr" == *"does not exist"* ]]
  [[ "$stderr" == *"1 of the given targets failed"* ]]
}

@test "ae: a glob of several files encrypts each one" {
  printf 'ssh-ed25519 AAAA existing\n' > "$KEYS"
  printf 'one\n' > "$TMP/work/g1.txt"
  printf 'two\n' > "$TMP/work/g2.txt"
  age_run "$AE" "$TMP/work/g1.txt" "$TMP/work/g2.txt"
  [ "$status" -eq 0 ]
  [ -f "$TMP/work/g1.txt.age" ]
  [ -f "$TMP/work/g2.txt.age" ]
}

# The actions run under `action || FAILED=…`, where errexit is off: a failed
# rm logged "deleted" and exited 0 with the plaintext still on disk. The rm
# stub fails only for the source, so the encrypt itself succeeds.
@test "a: a --delete that cannot remove the source fails the file" {
  local real_rm
  real_rm="$(command -v rm)"
  "$real_rm" -f "$TMP/bin/rm" "$TMP/work/secret.txt.age"
  printf '#!/usr/bin/env bash\nfor a in "$@"; do [ "$a" = "%s" ] && exit 1; done\nexec "%s" "$@"\n' \
    "$TMP/work/secret.txt" "$real_rm" > "$TMP/bin/rm"
  chmod +x "$TMP/bin/rm"
  a_args --delete e "$TMP/work/secret.txt"
  [ "$status" -eq 1 ]
  [ -f "$TMP/work/secret.txt.age" ]
  [ -f "$TMP/work/secret.txt" ]
  [[ "$stderr" == *"could not delete"* ]]
}

# A failed install of refreshed keys logged "Keys file fetched" and went on;
# it is now a failed refresh: warn, keep the cached copy, leave no temp file.
@test "a: a refreshed keys file that cannot be installed falls back to the cache" {
  local real_mv
  real_mv="$(command -v mv)"
  stale_keys
  rm -f "$TMP/bin/mv"
  printf '#!/usr/bin/env bash\nfor last; do :; done\n[ "$last" = "%s" ] && exit 1\nexec "%s" "$@"\n' \
    "$KEYS" "$real_mv" > "$TMP/bin/mv"
  chmod +x "$TMP/bin/mv"
  rm -f "$TMP/work/secret.txt.age"
  age_run "$AE" "$TMP/work/secret.txt"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Could not install refreshed keys"* ]]
  [[ "$output" != *"Keys file fetched"* ]]
  [ "$(cat "$KEYS")" = "ssh-ed25519 AAAA cached" ]
  run ls "$TMP"
  [[ "$output" != *"keys.txt."* ]]
}

@test "a: -f never moves the output into a directory of that name" {
  rm "$TMP/work/secret.txt.age"
  mkdir "$TMP/work/secret.txt.age"
  a_args -f e "$TMP/work/secret.txt"
  [ "$status" -eq 1 ]
  [[ "$stderr" == *"is a directory"* ]]
  [ "$(find "$TMP/work/secret.txt.age" -type f | wc -l)" -eq 0 ]
  [ -f "$TMP/work/secret.txt" ]
}

@test "a: -f decrypt never moves the plaintext into a directory" {
  rm "$TMP/work/secret.txt"
  mkdir "$TMP/work/secret.txt"
  a_args -f --delete d "$TMP/work/secret.txt.age"
  [ "$status" -eq 1 ]
  [ "$(find "$TMP/work/secret.txt" -type f | wc -l)" -eq 0 ]
  [ -f "$TMP/work/secret.txt.age" ]
}

@test "a: a directory decrypt recurses like the encrypt" {
  rm "$TMP/work/secret.txt"
  mkdir -p "$TMP/work/sub/deeper"
  printf 'ENCRYPTED\n' > "$TMP/work/sub/deeper/n.txt.age"
  printf 'plain\n' > "$TMP/work/sub/notes.txt"
  a_args d "$TMP/work"
  [ "$status" -eq 0 ]
  [ -f "$TMP/work/secret.txt" ]
  [ -f "$TMP/work/sub/deeper/n.txt" ]
  [ "$(cat "$TMP/work/sub/notes.txt")" = "plain" ]
}

@test "a: a target that does not exist is an error" {
  a_args e "$TMP/work/missing.txt"
  [ "$status" -eq 1 ]
  [[ "$stderr" == *"does not exist"* ]]
}
