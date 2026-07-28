#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

# php-switcher relinks Homebrew PHP formulas. brew is stubbed and the Cellar
# is a fixture directory, so no formula on the machine running the suite is
# ever unlinked — that would break the user's PHP.
#
# The active version is expressed the way the script reads it: a php symlink
# on PATH pointing into the fixture Cellar, which is what readlink -f resolves.

setup()
{
  PS="$BATS_TEST_DIRNAME/../local/bin/php-switcher"
  # -P: on macOS mktemp hands back a path under /tmp, which is a symlink to
  # /private/tmp. The script compares `readlink -f` of the php on PATH against
  # the Cellar path it built, and only the resolved form matches.
  TMP="$(cd "$(mktemp -d)" && pwd -P)"
  CELLAR="$TMP/cellar"
  CALLS="$TMP/calls"
  mkdir -p "$TMP/bin" "$TMP/work"
  : > "$CALLS"
  for tool in bash env readlink basename dirname find grep sort tail head cut tr rm cat mktemp; do
    src="$(command -v "$tool")" && ln -sf "$src" "$TMP/bin/$tool"
  done

  make_php()
  {
    mkdir -p "$CELLAR/$1/$2/bin"
    printf '#!/usr/bin/env bash\nprintf "PHP %s (cli) (built: today)\\n"\n' "$2" \
      > "$CELLAR/$1/$2/bin/php"
    chmod +x "$CELLAR/$1/$2/bin/php"
  }
  make_php "php@8.1" "8.1.2"
  make_php "php@8.2" "8.2.5"
  make_php "php" "8.4.1"
  # php@8.1 is the linked one.
  ln -sf "$CELLAR/php@8.1/8.1.2/bin/php" "$TMP/bin/php"

  cat > "$TMP/bin/brew" << STUB
#!/usr/bin/env bash
printf 'brew %s\n' "\$*" >> "$CALLS"
case "\$1" in
  --cellar) printf '%s\n' "$CELLAR" ;;
  list) printf 'php\nphp@8.1\nphp@8.2\n' ;;
  info)
    if [ "\$3" = "\${LINKED_FORMULA:-php@8.1}" ]; then
      printf '{"linked_keg":"8.1.2"}\n'
    else
      printf '{"linked_keg":null}\n'
    fi
    ;;
  unlink) exit 0 ;;
  link) [ -n "\$BREW_LINK_FAIL" ] && exit 1; exit 0 ;;
esac
STUB
  chmod +x "$TMP/bin/brew"
}

teardown()
{
  rm -rf "$TMP"
}

ps_run()
{
  cd "$TMP/work" || return 1
  run env PATH="$TMP/bin" "$PS" "$@"
}

@test "php-switcher: refuses to run without Homebrew" {
  rm "$TMP/bin/brew"
  ps_run --current
  [ "$status" -eq 1 ]
  [[ "$output" == *"Homebrew is not installed"* ]]
}

@test "php-switcher: no argument prints usage" {
  ps_run
  [ "$status" -eq 0 ]
  [[ "$output" == *"Brew PHP Switcher"* ]]
  [[ "$output" == *"--auto"* ]]
}

@test "php-switcher: --help prints usage" {
  ps_run --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: php-switcher"* ]]
}

@test "php-switcher: rejects a version that is not x.y" {
  ps_run 8
  [ "$status" -eq 1 ]
  [[ "$output" == *"Invalid PHP version format"* ]]
}

@test "php-switcher: rejects a version that is not a number at all" {
  ps_run eight
  [ "$status" -eq 1 ]
  [[ "$output" == *"Invalid PHP version format"* ]]
}

@test "php-switcher: --installed lists what is in the Cellar" {
  ps_run --installed
  [ "$status" -eq 0 ]
  [[ "$output" == *"Version"* ]]
  [[ "$output" == *"Formula"* ]]
  [[ "$output" == *"php@8.1"* ]]
  [[ "$output" == *"php@8.2"* ]]
}

@test "php-switcher: the unversioned formula is listed by its real version" {
  # The 'php' formula tracks whatever the latest release is, so listing it as
  # "latest" would say nothing about which PHP it actually is.
  ps_run --installed
  [[ "$output" == *"8.4"* ]]
}

@test "php-switcher: marks the linked version as active" {
  ps_run --installed
  printf '%s\n' "$output" | grep 'php@8.1' | grep -q 'Yes'
  printf '%s\n' "$output" | grep 'php@8.2' | grep -q 'No'
}

@test "php-switcher: --installed says so when the Cellar has no PHP" {
  rm -rf "$CELLAR"
  mkdir -p "$CELLAR"
  ps_run --installed
  [[ "$output" == *"No PHP versions installed through Homebrew"* ]]
}

@test "php-switcher: --current reports the linked version and its formula" {
  ps_run --current
  [ "$status" -eq 0 ]
  [[ "$output" == *"Current PHP version: 8.1.2 (php@8.1)"* ]]
}

@test "php-switcher: --current says so when nothing is linked" {
  rm "$TMP/bin/php"
  ps_run --current
  [[ "$output" == *"No PHP currently linked"* ]]
}

@test "php-switcher: refuses a version that is not installed" {
  ps_run 7.4
  [ "$status" -eq 1 ]
  [[ "$output" == *"PHP version 7.4 is not installed"* ]]
  # The list is printed so the user can see what they can pick instead.
  [[ "$output" == *"php@8.1"* ]]
}

@test "php-switcher: does nothing when the version is already active" {
  ps_run 8.1
  [ "$status" -eq 0 ]
  [[ "$output" == *"PHP version 8.1 is already active"* ]]
  run ! grep -q 'brew link' "$CALLS"
}

@test "php-switcher: unlinks the old version before linking the new one" {
  ps_run 8.2
  [ "$status" -eq 0 ]
  grep -q 'brew unlink php@8.1' "$CALLS"
  grep -q 'brew link --force --overwrite php@8.2' "$CALLS"
}

@test "php-switcher: finds the linked formula wherever it is in the list" {
  # brew list is alphabetical, so the linked formula is usually not first.
  # Scanning has to survive the unlinked entries it passes on the way.
  ln -sf "$CELLAR/php@8.2/8.2.5/bin/php" "$TMP/bin/php"
  run env PATH="$TMP/bin" LINKED_FORMULA=php@8.2 "$PS" 8.1
  [ "$status" -eq 0 ]
  grep -q 'brew unlink php@8.2' "$CALLS"
  grep -q 'brew link --force --overwrite php@8.1' "$CALLS"
}

@test "php-switcher: links the version that was asked for" {
  # The scan for the linked formula used to write to the caller's `formula`
  # variable, so the switch relinked whatever it had just unlinked.
  ps_run 8.2
  run ! grep -q 'brew link --force --overwrite php@8.1' "$CALLS"
}

@test "php-switcher: reports a link failure with the command to run by hand" {
  run env PATH="$TMP/bin" BREW_LINK_FAIL=1 "$PS" 8.2
  [ "$status" -eq 1 ]
  [[ "$output" == *"Failed to link php@8.2"* ]]
  [[ "$output" == *"brew link --force --overwrite php@8.2"* ]]
}

@test "php-switcher: --auto says so when there is no .php-version" {
  ps_run --auto
  [ "$status" -eq 1 ]
  [[ "$output" == *"No .php-version file found"* ]]
}

@test "php-switcher: --auto reads .php-version from the current directory" {
  printf '8.2\n' > "$TMP/work/.php-version"
  ps_run --auto
  [ "$status" -eq 0 ]
  [[ "$output" == *"Requested PHP version: 8.2"* ]]
  grep -q 'brew link --force --overwrite php@8.2' "$CALLS"
}

@test "php-switcher: --auto walks up to a parent directory" {
  printf '8.2\n' > "$TMP/work/.php-version"
  mkdir -p "$TMP/work/src/deep"
  cd "$TMP/work/src/deep" || return 1
  run env PATH="$TMP/bin" "$PS" --auto
  [ "$status" -eq 0 ]
  [[ "$output" == *"Found .php-version file at: $TMP/work/.php-version"* ]]
}

@test "php-switcher: --auto rejects a .php-version it cannot parse" {
  printf 'nonsense\n' > "$TMP/work/.php-version"
  ps_run --auto
  [ "$status" -eq 1 ]
  [[ "$output" == *"Invalid PHP version format"* ]]
}

@test "php-switcher: --auto tolerates trailing whitespace in the file" {
  printf '  8.2  \n' > "$TMP/work/.php-version"
  ps_run --auto
  [ "$status" -eq 0 ]
  [[ "$output" == *"Requested PHP version: 8.2"* ]]
}
