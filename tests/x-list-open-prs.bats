#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

# x-list-open-prs asks GitHub for every open PR across the owner's public
# repos and renders them. Almost all of the script is the jq program that
# classifies and groups those PRs, so the tests feed a fixed fixture through
# the gh path and assert on the rendered report.
#
# gh is stubbed; nothing is fetched. Only the timestamps are computed at run
# time, because "stale" is defined relative to now.

setup()
{
  LOP="$BATS_TEST_DIRNAME/../local/bin/x-list-open-prs"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin"
  FIX="$TMP/prs.json"
  for tool in sh bash env mktemp rm cat jq date; do
    src="$(command -v "$tool")" && ln -sf "$src" "$TMP/bin/$tool"
  done

  iso()
  {
    date -u -d "$1" +%Y-%m-%dT%H:%M:%SZ 2> /dev/null \
      || date -u -v"$2" +%Y-%m-%dT%H:%M:%SZ
  }
  NEW="$(iso '1 hour ago' -1H)"
  OLD="$(iso '5 days ago' -5d)"

  cat > "$FIX" << JSON
[
  {
    "number": 1,
    "title": "Fix a security vulnerability in the parser",
    "createdAt": "$NEW",
    "isDraft": false,
    "url": "https://example.invalid/alpha/1",
    "headRefName": "fix/parser",
    "reviewDecision": "APPROVED",
    "mergeable": "MERGEABLE",
    "mergeStateStatus": "CLEAN",
    "author": { "login": "ivuorinen", "is_bot": false },
    "labels": [],
    "statusCheckRollup": [{ "state": "SUCCESS" }]
  },
  {
    "number": 2,
    "title": "Refactor the parser",
    "createdAt": "$NEW",
    "isDraft": false,
    "url": "https://example.invalid/alpha/2",
    "headRefName": "refactor/parser",
    "reviewDecision": "CHANGES_REQUESTED",
    "mergeable": "CONFLICTING",
    "mergeStateStatus": "DIRTY",
    "author": { "login": "ivuorinen", "is_bot": false },
    "labels": [],
    "statusCheckRollup": [{ "state": "FAILURE" }]
  },
  {
    "number": 3,
    "title": "Add a changelog",
    "createdAt": "$OLD",
    "isDraft": false,
    "url": "https://example.invalid/alpha/3",
    "headRefName": "docs/changelog",
    "reviewDecision": null,
    "mergeable": "MERGEABLE",
    "mergeStateStatus": "BEHIND",
    "author": { "login": "ivuorinen", "is_bot": false },
    "labels": [],
    "statusCheckRollup": []
  },
  {
    "number": 4,
    "title": "Work in progress",
    "createdAt": "$NEW",
    "isDraft": true,
    "url": "https://example.invalid/alpha/4",
    "headRefName": "wip",
    "reviewDecision": null,
    "mergeable": "MERGEABLE",
    "mergeStateStatus": "CLEAN",
    "author": { "login": "ivuorinen", "is_bot": false },
    "labels": [],
    "statusCheckRollup": [{ "status": "IN_PROGRESS" }]
  },
  {
    "number": 5,
    "title": "Update dependency axios to v2",
    "createdAt": "$NEW",
    "isDraft": false,
    "url": "https://example.invalid/alpha/5",
    "headRefName": "renovate/axios-2.x",
    "reviewDecision": null,
    "mergeable": "MERGEABLE",
    "mergeStateStatus": "CLEAN",
    "author": { "login": "renovate[bot]", "is_bot": true },
    "labels": [],
    "statusCheckRollup": [{ "state": "SUCCESS" }]
  },
  {
    "number": 6,
    "title": "Update dependency axios to v3",
    "createdAt": "$NEW",
    "isDraft": false,
    "url": "https://example.invalid/alpha/6",
    "headRefName": "renovate/axios-3.x",
    "reviewDecision": null,
    "mergeable": "MERGEABLE",
    "mergeStateStatus": "CLEAN",
    "author": { "login": "renovate[bot]", "is_bot": true },
    "labels": [],
    "statusCheckRollup": [{ "state": "SUCCESS" }]
  },
  {
    "number": 7,
    "title": "Bump lodash from 1.0.0 to 2.0.0",
    "createdAt": "$NEW",
    "isDraft": false,
    "url": "https://example.invalid/alpha/7",
    "headRefName": "dependabot/npm_and_yarn/lodash-2.0.0",
    "reviewDecision": null,
    "mergeable": "MERGEABLE",
    "mergeStateStatus": "CLEAN",
    "author": { "login": "dependabot[bot]", "is_bot": true },
    "labels": [],
    "statusCheckRollup": [{ "state": "SUCCESS" }]
  },
  {
    "number": 8,
    "title": "Update the react group with 3 updates",
    "createdAt": "$NEW",
    "isDraft": false,
    "url": "https://example.invalid/alpha/8",
    "headRefName": "renovate/react",
    "reviewDecision": null,
    "mergeable": "MERGEABLE",
    "mergeStateStatus": "CLEAN",
    "author": { "login": "renovate[bot]", "is_bot": true },
    "labels": [],
    "statusCheckRollup": [{ "state": "SUCCESS" }]
  }
]
JSON

  cat > "$TMP/bin/gh" << STUB
#!/usr/bin/env bash
case "\$1 \$2" in
  "auth status") [ -n "\$GH_UNAUTH" ] && exit 1; exit 0 ;;
  "repo list")
    [ -n "\$GH_REPOLIST_FAIL" ] && exit 1
    printf 'ivuorinen/alpha\n'
    exit 0
    ;;
  "pr list")
    [ -n "\$GH_NO_PRS" ] && { printf '[]\n'; exit 0; }
    cat "$FIX"
    exit 0
    ;;
esac
STUB
  chmod +x "$TMP/bin/gh"
}

teardown()
{
  rm -rf "$TMP"
}

lop()
{
  # The script takes no options; every variation is driven by the stub's
  # environment instead.
  run env PATH="$TMP/bin" "$LOP"
}

@test "list-open-prs: says so when jq is missing" {
  rm "$TMP/bin/jq"
  lop
  [ "$status" -eq 0 ]
  [[ "$output" == "Unable to query GitHub." ]]
}

@test "list-open-prs: says so when the repo listing fails" {
  run env PATH="$TMP/bin" GH_REPOLIST_FAIL=1 "$LOP"
  [ "$status" -eq 0 ]
  [[ "$output" == "Unable to query GitHub." ]]
}

@test "list-open-prs: falls back to the API path without a token" {
  # No gh, no GH_TOKEN and no GITHUB_TOKEN: there is nothing left to try.
  rm "$TMP/bin/gh"
  run env -u GH_TOKEN -u GITHUB_TOKEN PATH="$TMP/bin" "$LOP"
  [ "$status" -eq 0 ]
  [[ "$output" == "Unable to query GitHub." ]]
}

@test "list-open-prs: says when there is nothing open" {
  run env PATH="$TMP/bin" GH_NO_PRS=1 "$LOP"
  [ "$status" -eq 0 ]
  [[ "$output" == "No open PRs." ]]
}

@test "list-open-prs: splits the report into three sections" {
  lop
  [ "$status" -eq 0 ]
  [[ "$output" == *"## Security updates"* ]]
  [[ "$output" == *"## Human PRs"* ]]
  [[ "$output" == *"## Robots"* ]]
}

@test "list-open-prs: a security PR is pulled out of the human section" {
  lop
  sec=$(printf '%s\n' "$output" | sed -n '/## Security updates/,/## Human PRs/p')
  [[ "$sec" == *"alpha#1"* ]]
  hum=$(printf '%s\n' "$output" | sed -n '/## Human PRs/,/## Robots/p')
  [[ "$hum" != *"alpha#1"* ]]
}

@test "list-open-prs: marks a PR with failing checks" {
  lop
  [[ "$output" == *"alpha#2"* ]]
  printf '%s\n' "$output" | grep -A1 'alpha#2' | grep -q 'FAILING'
}

@test "list-open-prs: marks a PR that has been open too long" {
  lop
  printf '%s\n' "$output" | grep -A1 'alpha#3' | grep -q 'STALE'
}

@test "list-open-prs: marks a draft" {
  lop
  printf '%s\n' "$output" | grep -A1 'alpha#4' | grep -q 'DRAFT'
}

@test "list-open-prs: reports the review decision" {
  lop
  printf '%s\n' "$output" | grep -A6 'alpha#1' | grep -q 'review: approved'
  printf '%s\n' "$output" | grep -A6 'alpha#2' | grep -q 'review: changes requested'
  printf '%s\n' "$output" | grep -A6 'alpha#3' | grep -q 'review: awaiting review'
}

@test "list-open-prs: reports the branch state" {
  lop
  printf '%s\n' "$output" | grep -A8 'alpha#2' | grep -q 'branch: conflict'
  printf '%s\n' "$output" | grep -A8 'alpha#3' | grep -q 'branch: behind'
  printf '%s\n' "$output" | grep -A8 'alpha#1' | grep -q 'branch: up to date'
}

@test "list-open-prs: an unfinished check counts as pending, not passing" {
  lop
  printf '%s\n' "$output" | grep -A7 'alpha#4' | grep -q 'ci:     pending'
}

@test "list-open-prs: a PR with no checks at all counts as passing" {
  lop
  printf '%s\n' "$output" | grep -A7 'alpha#3' | grep -q 'ci:     passing'
}

@test "list-open-prs: groups robot PRs by the dependency they bump" {
  lop
  [[ "$output" == *"### axios"* ]]
  [[ "$output" == *"### lodash"* ]]
}

@test "list-open-prs: two PRs for one dependency land in the same group" {
  lop
  grp=$(printf '%s\n' "$output" | sed -n '/### axios/,/### /p')
  [[ "$grp" == *"alpha#5"* ]]
  [[ "$grp" == *"alpha#6"* ]]
}

@test "list-open-prs: a grouped update is not filed under one dependency" {
  lop
  [[ "$output" == *"### Multiple dependencies"* ]]
  printf '%s\n' "$output" | grep -A3 '### Multiple dependencies' | grep -q 'alpha#8'
}

@test "list-open-prs: robot PRs stay out of the human section" {
  lop
  hum=$(printf '%s\n' "$output" | sed -n '/## Human PRs/,/## Robots/p')
  for n in 5 6 7 8; do
    [[ "$hum" != *"alpha#$n"* ]] || {
      echo "robot PR #$n was listed as a human PR"
      return 1
    }
  done
}

@test "list-open-prs: failing PRs sort above the rest" {
  lop
  hum=$(printf '%s\n' "$output" | sed -n '/## Human PRs/,/## Robots/p')
  first=$(printf '%s\n' "$hum" | grep -oE 'alpha#[0-9]+' | head -1)
  [ "$first" = "alpha#2" ]
}

@test "list-open-prs: every entry carries its url and author" {
  lop
  printf '%s\n' "$output" | grep -A3 'alpha#1' | grep -q 'https://example.invalid/alpha/1'
  printf '%s\n' "$output" | grep -A4 'alpha#1' | grep -q 'author: ivuorinen'
}

@test "list-open-prs: leaves no temp file behind" {
  mkdir -p "$TMP/tmpdir"
  run env PATH="$TMP/bin" TMPDIR="$TMP/tmpdir" "$LOP"
  [ "$status" -eq 0 ]
  [ -z "$(ls -A "$TMP/tmpdir")" ]
}
