#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

# tv-gh-repos backs a television channel: it caches the repository list from
# gh and acts on a selected row. gh is stubbed, so nothing is fetched and no
# clone, pull or browser launch reaches the network. XDG_CACHE_HOME and
# GH_REPOS_CODE_ROOT point into the fixture, so neither the real cache nor
# ~/Code is read or written.

setup()
{
  TVR="$BATS_TEST_DIRNAME/../local/bin/tv-gh-repos"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin" "$TMP/cache" "$TMP/code"
  CALLS="$TMP/calls"
  CLIP="$TMP/clipboard"
  : > "$CALLS"
  for tool in bash env jq git date stat sed awk sort cat mktemp mkdir rm mv printf head tr wc dirname basename; do
    src="$(command -v "$tool")" && ln -sf "$src" "$TMP/bin/$tool"
  done

  cat > "$TMP/bin/gh" << STUB
#!/usr/bin/env bash
printf 'gh %s\n' "\$*" >> "$CALLS"

if [ "\$1" = "api" ]; then
  case "\$*" in
    *user/orgs*) printf '[{"login":"acme"}]\n' ;;
    *) printf 'tester\n' ;;
  esac
  exit 0
fi

if [ "\$1" = "repo" ] && [ "\$2" = "list" ]; then
  [ -n "\$GH_LIST_FAIL" ] && { printf 'boom\n' >&2; exit 1; }
  case "\$3" in
    tester)
      cat << 'JSON'
[
  {"nameWithOwner":"tester/alpha","visibility":"PUBLIC","isFork":false,
    "description":"first repo","url":"https://example.invalid/tester/alpha"},
  {"nameWithOwner":"tester/beta","visibility":"PRIVATE","isFork":true,
    "description":"a fork","url":"https://example.invalid/tester/beta"}
]
JSON
      ;;
    acme)
      cat << 'JSON'
[
  {"nameWithOwner":"acme/gamma","visibility":"PUBLIC","isFork":false,
    "description":"org repo","url":"https://example.invalid/acme/gamma"}
]
JSON
      ;;
    *) printf '[]\n' ;;
  esac
  exit 0
fi

if [ "\$1" = "repo" ] && [ "\$2" = "view" ]; then
  case "\$*" in
    *sshUrl*) printf 'git@example.invalid:%s.git\n' "\$3" ;;
    *url*) printf 'https://example.invalid/%s\n' "\$3" ;;
  esac
  exit 0
fi
STUB

  printf '#!/usr/bin/env bash\ncat > "%s"\n' "$CLIP" > "$TMP/bin/xclip"
  chmod +x "$TMP/bin/gh" "$TMP/bin/xclip"
}

teardown()
{
  rm -rf "$TMP"
}

tvr()
{
  run env PATH="$TMP/bin" HOME="$TMP/home" XDG_CACHE_HOME="$TMP/cache" \
    GH_REPOS_CODE_ROOT="$TMP/code" "$TVR" "$@"
}

# A local checkout of one of the fixture repositories.
clone_locally()
{
  local repo="$1"
  mkdir -p "$TMP/code/$(dirname "$repo")"
  git init --quiet -b main "$TMP/code/$repo"
  printf 'x\n' > "$TMP/code/$repo/file"
  git -C "$TMP/code/$repo" add -A
  git -C "$TMP/code/$repo" -c user.email=t@example.com -c user.name=Test \
    commit --quiet -m first
}

@test "tv-gh-repos: no command prints usage" {
  tvr
  [ "$status" -eq 0 ]
  [[ "$output" == *"clone"* ]]
  [[ "$output" == *"preview"* ]]
}

@test "tv-gh-repos: an unknown command exits 1" {
  tvr frobnicate
  [ "$status" -eq 1 ]
}

@test "tv-gh-repos: refuses to run without gh" {
  rm "$TMP/bin/gh"
  tvr list
  [ "$status" -ne 0 ]
  [[ "$output" == *"required command not found: gh"* ]]
}

@test "tv-gh-repos: list builds the cache and prints a row per repository" {
  tvr list
  [ "$status" -eq 0 ]
  [[ "$output" == *"tester/alpha"* ]]
  [[ "$output" == *"tester/beta"* ]]
  [[ "$output" == *"acme/gamma"* ]]
}

@test "tv-gh-repos: the cache files are written" {
  tvr list
  [ -s "$TMP/cache/television/gh-repos/repos.json" ]
  [ -s "$TMP/cache/television/gh-repos/repos.tsv" ]
}

@test "tv-gh-repos: organisations are included as well as the user" {
  tvr list
  grep -q 'gh repo list tester' "$CALLS"
  grep -q 'gh repo list acme' "$CALLS"
}

@test "tv-gh-repos: GH_REPOS_INCLUDE_ORGS=0 asks only for the user" {
  run env PATH="$TMP/bin" HOME="$TMP/home" XDG_CACHE_HOME="$TMP/cache" \
    GH_REPOS_CODE_ROOT="$TMP/code" GH_REPOS_INCLUDE_ORGS=0 "$TVR" list
  grep -q 'gh repo list tester' "$CALLS"
  run ! grep -q 'gh repo list acme' "$CALLS"
}

@test "tv-gh-repos: a second list inside the TTL does not call gh again" {
  tvr list
  : > "$CALLS"
  tvr list
  [ ! -s "$CALLS" ]
}

@test "tv-gh-repos: --refresh rebuilds the cache anyway" {
  tvr list
  : > "$CALLS"
  tvr list --refresh
  grep -q 'gh repo list tester' "$CALLS"
}

@test "tv-gh-repos: an expired cache is rebuilt" {
  tvr list
  : > "$CALLS"
  run env PATH="$TMP/bin" HOME="$TMP/home" XDG_CACHE_HOME="$TMP/cache" \
    GH_REPOS_CODE_ROOT="$TMP/code" GH_REPOS_CACHE_TTL_SECONDS=0 "$TVR" list
  grep -q 'gh repo list tester' "$CALLS"
}

@test "tv-gh-repos: refresh says where the cache is" {
  tvr refresh
  [ "$status" -eq 0 ]
  [[ "$output" == *"Refreshed cache"* ]]
}

@test "tv-gh-repos: one owner failing does not lose the others" {
  # A single inaccessible organisation must not empty the whole list.
  run env PATH="$TMP/bin" HOME="$TMP/home" XDG_CACHE_HOME="$TMP/cache" \
    GH_REPOS_CODE_ROOT="$TMP/code" GH_LIST_FAIL=1 "$TVR" list
  [ "$status" -eq 0 ]
}

@test "tv-gh-repos: an unknown list argument is rejected" {
  tvr list sideways
  [ "$status" -ne 0 ]
  [[ "$output" == *"unknown list argument"* ]]
}

@test "tv-gh-repos: the public filter drops private repositories" {
  tvr list public
  [[ "$output" == *"tester/alpha"* ]]
  [[ "$output" != *"tester/beta"* ]]
}

@test "tv-gh-repos: the private filter keeps only private repositories" {
  tvr list private
  [[ "$output" == *"tester/beta"* ]]
  [[ "$output" != *"tester/alpha"* ]]
}

@test "tv-gh-repos: the forks filter splits forks from the rest" {
  tvr list forks
  [[ "$output" == *"tester/beta"* ]]
  [[ "$output" != *"tester/alpha"* ]]
  tvr list non-forks
  [[ "$output" == *"tester/alpha"* ]]
  [[ "$output" != *"tester/beta"* ]]
}

@test "tv-gh-repos: the user and organizations filters split by owner type" {
  tvr list user
  [[ "$output" == *"tester/alpha"* ]]
  [[ "$output" != *"acme/gamma"* ]]
  tvr list organizations
  [[ "$output" == *"acme/gamma"* ]]
  [[ "$output" != *"tester/alpha"* ]]
}

@test "tv-gh-repos: the cloned filter reflects what is on disk" {
  clone_locally "tester/alpha"
  tvr list cloned
  [[ "$output" == *"tester/alpha"* ]]
  [[ "$output" != *"acme/gamma"* ]]
}

@test "tv-gh-repos: the uncloned filter is the complement" {
  clone_locally "tester/alpha"
  tvr list uncloned
  [[ "$output" != *"tester/alpha"* ]]
  [[ "$output" == *"acme/gamma"* ]]
}

@test "tv-gh-repos: --json emits parseable JSON with the same repositories" {
  tvr list --json
  [ "$status" -eq 0 ]
  printf '%s' "$output" | jq -e 'type == "array"' > /dev/null
  printf '%s' "$output" | jq -e 'map(.nameWithOwner) | index("tester/alpha")' > /dev/null
}

@test "tv-gh-repos: a command that needs a repository says so" {
  for cmd in clone open pull edit copy-url; do
    tvr "$cmd"
    [ "$status" -ne 0 ] || {
      echo "$cmd accepted no argument"
      return 1
    }
    [[ "$output" == *"requires OWNER/REPO"* ]] || {
      echo "$cmd did not explain what it needs"
      return 1
    }
  done
}

@test "tv-gh-repos: a repository name that is not owner/repo is rejected" {
  # The name reaches git and gh command lines, so it is validated first.
  tvr clone 'evil; rm -rf /'
  [ "$status" -ne 0 ]
  [[ "$output" == *"invalid repository name"* ]]
  run ! grep -q 'repo view' "$CALLS"
}

@test "tv-gh-repos: cloning something already cloned does nothing" {
  clone_locally "tester/alpha"
  tvr clone tester/alpha
  [ "$status" -eq 0 ]
  [[ "$output" == *"Already cloned"* ]]
  run ! grep -q 'repo view' "$CALLS"
}

@test "tv-gh-repos: a target that exists but is not a repository is an error" {
  mkdir -p "$TMP/code/tester/alpha"
  tvr clone tester/alpha
  [ "$status" -ne 0 ]
  [[ "$output" == *"not a Git repository"* ]]
}

@test "tv-gh-repos: pulling something that is not cloned is an error" {
  tvr pull tester/alpha
  [ "$status" -ne 0 ]
  [[ "$output" == *"not cloned"* ]]
}

@test "tv-gh-repos: pulling refuses to touch a dirty worktree" {
  # --ff-only would fail anyway, but the point is to say why before running
  # anything and to show what is dirty.
  clone_locally "tester/alpha"
  printf 'uncommitted\n' >> "$TMP/code/tester/alpha/file"
  tvr pull tester/alpha
  [ "$status" -ne 0 ]
  [[ "$output" == *"worktree is dirty"* ]]
}

@test "tv-gh-repos: editing something that is not cloned is an error" {
  tvr edit tester/alpha
  [ "$status" -ne 0 ]
  [[ "$output" == *"not cloned"* ]]
}

@test "tv-gh-repos: copy-url puts the url on the clipboard" {
  tvr copy-url tester/alpha
  [ "$status" -eq 0 ]
  [[ "$output" == *"Copied: https://example.invalid/tester/alpha"* ]]
  grep -q 'https://example.invalid/tester/alpha' "$CLIP"
}

@test "tv-gh-repos: copy-url says so when there is no clipboard command" {
  rm "$TMP/bin/xclip"
  tvr copy-url tester/alpha
  [ "$status" -ne 0 ]
  [[ "$output" == *"no supported clipboard command"* ]]
}

@test "tv-gh-repos: open asks gh to open the page" {
  tvr open tester/alpha
  [ "$status" -eq 0 ]
  grep -q 'repo view tester/alpha --web' "$CALLS"
}
