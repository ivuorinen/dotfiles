#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

# x-pr-comments turns a PR's review comments into a report for an LLM to work
# from. gh and git are stubbed, so nothing is fetched and the repository the
# suite happens to run in has no influence on the result.

setup()
{
  PRC="$BATS_TEST_DIRNAME/../local/bin/x-pr-comments"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin"
  CALLS="$TMP/calls"
  : > "$CALLS"
  for tool in bash env awk sed cat rm jq; do
    src="$(command -v "$tool")" && ln -sf "$src" "$TMP/bin/$tool"
  done

  cat > "$TMP/bin/git" << 'STUB'
#!/usr/bin/env bash
case "$1 $2" in
  "rev-parse --is-inside-work-tree")
    [ -n "$NOT_A_REPO" ] && exit 1
    printf 'true\n'
    ;;
  "remote get-url")
    [ -n "$NO_REMOTE" ] && exit 1
    printf '%s\n' "${REMOTE_URL:-https://github.com/ivuorinen/dotfiles.git}"
    ;;
esac
STUB

  cat > "$TMP/bin/gh" << STUB
#!/usr/bin/env bash
printf 'gh %s\n' "\$*" >> "$CALLS"

if [ "\$1 \$2" = "auth status" ]; then
  [ -n "\$GH_UNAUTH" ] && exit 1
  exit 0
fi

if [ "\$1 \$2" = "pr view" ]; then
  [ -n "\$PR_MISSING" ] && exit 1
  printf '{"title":"Add a parser","state":"OPEN","url":"https://example.invalid/pr/7"}\n'
  exit 0
fi

if [ "\$1" = "api" ]; then
  for a in "\$@"; do
    case "\$a" in
      */comments) [ -n "\$NO_COMMENTS" ] && { printf '[]\n'; exit 0; }; cat "$TMP/comments.json"; exit 0 ;;
      */reviews) cat "$TMP/reviews.json"; exit 0 ;;
    esac
  done
fi
STUB
  chmod +x "$TMP/bin/git" "$TMP/bin/gh"

  cat > "$TMP/comments.json" << 'JSON'
[
  {
    "id": 11,
    "pull_request_review_id": 100,
    "path": "src/parser.js",
    "commit_id": "abc123",
    "user": { "login": "alice", "type": "User" },
    "line": 42,
    "position": 3,
    "body": "This branch is unreachable."
  },
  {
    "id": 12,
    "pull_request_review_id": 100,
    "path": "src/lexer.js",
    "commit_id": "abc123",
    "user": { "login": "alice", "type": "User" },
    "start_line": 10,
    "line": 14,
    "body": "Extract this into a helper."
  },
  {
    "id": 13,
    "pull_request_review_id": 100,
    "path": "src/old.js",
    "commit_id": "abc123",
    "user": { "login": "coderabbitai[bot]", "type": "Bot" },
    "line": 1,
    "body": "Addressed in commit abc123 — nothing to do."
  },
  {
    "id": 14,
    "pull_request_review_id": 999,
    "path": "src/orphan.js",
    "commit_id": "abc123",
    "user": { "login": "bob", "type": "User" },
    "line": 5,
    "body": "Left over from a review that is gone."
  }
]
JSON

  cat > "$TMP/reviews.json" << 'JSON'
[
  {
    "id": 100,
    "user": { "login": "alice" },
    "submitted_at": "2026-01-01T00:00:00Z",
    "state": "CHANGES_REQUESTED"
  }
]
JSON
}

teardown()
{
  rm -rf "$TMP"
}

prc()
{
  run env PATH="$TMP/bin" "$PRC" "$@"
}

@test "pr-comments: --help prints usage and exits 0" {
  prc --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"x-pr-comments <pr-number>"* ]]
}

@test "pr-comments: no argument is an error" {
  prc
  [ "$status" -eq 1 ]
  [[ "$output" == *"Missing argument"* ]]
}

@test "pr-comments: a non-numeric argument is rejected" {
  prc frobnicate
  [ "$status" -eq 1 ]
  [[ "$output" == *"Invalid argument"* ]]
}

@test "pr-comments: an argument that only starts with a digit is rejected" {
  # The case glob matches on the first character alone, so "12abc" reaches the
  # numeric branch and has to be caught there.
  prc 12abc
  [ "$status" -eq 1 ]
  [[ "$output" == *"Invalid PR number"* ]]
}

@test "pr-comments: a PR url gives the repository and the number" {
  prc https://github.com/someone/theirrepo/pull/7
  [ "$status" -eq 0 ]
  grep -q 'gh pr view 7 --repo someone/theirrepo' "$CALLS"
}

@test "pr-comments: a github url that is not a PR is rejected" {
  prc https://github.com/someone/theirrepo/issues/7
  [ "$status" -eq 1 ]
  [[ "$output" == *"Invalid GitHub PR URL format"* ]]
}

@test "pr-comments: a bare number uses the origin remote" {
  prc 7
  [ "$status" -eq 0 ]
  grep -q 'gh pr view 7 --repo ivuorinen/dotfiles' "$CALLS"
}

@test "pr-comments: an ssh remote is parsed too" {
  run env PATH="$TMP/bin" REMOTE_URL="git@github.com:someone/theirrepo.git" "$PRC" 7
  grep -q 'gh pr view 7 --repo someone/theirrepo' "$CALLS"
}

@test "pr-comments: a bare number outside a repository is an error" {
  run env PATH="$TMP/bin" NOT_A_REPO=1 "$PRC" 7
  [ "$status" -eq 1 ]
  [[ "$output" == *"Not inside a git repository"* ]]
}

@test "pr-comments: a repository with no origin is an error" {
  run env PATH="$TMP/bin" NO_REMOTE=1 "$PRC" 7
  [ "$status" -eq 1 ]
  [[ "$output" == *"No origin remote found"* ]]
}

@test "pr-comments: a non-GitHub remote is an error" {
  run env PATH="$TMP/bin" REMOTE_URL="https://gitlab.com/someone/theirrepo.git" "$PRC" 7
  [ "$status" -eq 1 ]
  [[ "$output" == *"not a GitHub repository"* ]]
}

@test "pr-comments: refuses to run without gh" {
  rm "$TMP/bin/gh"
  prc 7
  [ "$status" -eq 1 ]
  [[ "$output" == *"GitHub CLI (gh) is not installed"* ]]
}

@test "pr-comments: refuses to run when gh is not authenticated" {
  run env PATH="$TMP/bin" GH_UNAUTH=1 "$PRC" 7
  [ "$status" -eq 1 ]
  [[ "$output" == *"not authenticated"* ]]
}

@test "pr-comments: a PR that cannot be fetched is an error" {
  run env PATH="$TMP/bin" PR_MISSING=1 "$PRC" 7
  [ "$status" -eq 1 ]
  [[ "$output" == *"Failed to fetch PR #7"* ]]
}

@test "pr-comments: the report carries the PR's own details" {
  prc 7
  [[ "$output" == *"# GitHub PR Comments Analysis Report"* ]]
  [[ "$output" == *"**Title:** Add a parser"* ]]
  [[ "$output" == *"**State:** OPEN"* ]]
  [[ "$output" == *"**URL:** https://example.invalid/pr/7"* ]]
}

@test "pr-comments: comments are grouped under their review" {
  prc 7
  [[ "$output" == *"### Review by alice (2026-01-01T00:00:00Z) [CHANGES_REQUESTED]"* ]]
  [[ "$output" == *"Review ID: 100"* ]]
}

@test "pr-comments: each comment names its file and body" {
  prc 7
  [[ "$output" == *"**File:** src/parser.js"* ]]
  [[ "$output" == *"This branch is unreachable."* ]]
  [[ "$output" == *"**File:** src/lexer.js"* ]]
  [[ "$output" == *"Extract this into a helper."* ]]
}

@test "pr-comments: a multi-line comment shows the line range" {
  prc 7
  [[ "$output" == *"**Lines:** 10-14"* ]]
  [[ "$output" == *"**Lines:** 42"* ]]
}

@test "pr-comments: an already-addressed CodeRabbit comment is dropped" {
  # These are noise — the bot is reporting that the work is done.
  prc 7
  [[ "$output" != *"src/old.js"* ]]
  [[ "$output" != *"nothing to do"* ]]
}

@test "pr-comments: a comment whose review is gone is still shown" {
  # Selecting the review without a fallback would silently drop the whole
  # group, losing real feedback.
  prc 7
  [[ "$output" == *"src/orphan.js"* ]]
  [[ "$output" == *"Left over from a review that is gone."* ]]
  [[ "$output" == *"### Review by unknown"* ]]
}

@test "pr-comments: says so when there are no file comments" {
  run env PATH="$TMP/bin" NO_COMMENTS=1 "$PRC" 7
  [ "$status" -eq 0 ]
  [[ "$output" == *"No file-specific comments found."* ]]
}

@test "pr-comments: the report ends with the analysis instructions" {
  prc 7
  [[ "$output" == *"## Next Steps for LLM Analysis"* ]]
}
