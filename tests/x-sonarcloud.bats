#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

# x-sonarcloud pulls issues from the SonarCloud API and renders them as
# markdown. curl is stubbed — no request is made and no token is needed — and
# the tests run in a fixture directory so the project detection reads planted
# config rather than this repo's.

setup()
{
  SC="$BATS_TEST_DIRNAME/../local/bin/x-sonarcloud"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin" "$TMP/work"
  CALLS="$TMP/calls"
  : > "$CALLS"
  for tool in bash env awk sed grep cut tail head mktemp rm cat jq printf; do
    src="$(command -v "$tool")" && ln -sf "$src" "$TMP/bin/$tool"
  done

  cat > "$TMP/issues.json" << 'JSON'
{
  "total": 3,
  "issues": [
    {
      "key": "AAA",
      "rule": "shell:S1234",
      "severity": "BLOCKER",
      "component": "org_repo:local/bin/thing",
      "message": "Do not do that",
      "type": "VULNERABILITY",
      "status": "OPEN",
      "line": 12,
      "effort": "5min",
      "creationDate": "2026-01-01T00:00:00+0000"
    },
    {
      "key": "BBB",
      "rule": "shell:S5678",
      "severity": "MINOR",
      "component": "org_repo:local/bin/thing",
      "message": "Tidy this up",
      "type": "CODE_SMELL",
      "status": "OPEN",
      "line": 44,
      "effort": "2min",
      "creationDate": "2026-01-02T00:00:00+0000"
    },
    {
      "key": "CCC",
      "rule": "shell:S9012",
      "severity": "CRITICAL",
      "component": "org_repo:scripts/other.sh",
      "message": "Fix this first",
      "type": "BUG",
      "status": "CONFIRMED",
      "line": 7,
      "effort": "10min",
      "creationDate": "2026-01-03T00:00:00+0000"
    }
  ]
}
JSON

  # Emits the body, then the http code on its own line, which is what
  # curl -w "\n%{http_code}" produces.
  cat > "$TMP/bin/curl" << STUB
#!/usr/bin/env bash
for a in "\$@"; do
  case "\$a" in http*) printf 'curl %s\n' "\$a" >> "$CALLS" ;; esac
done
code="\${HTTP_CODE:-200}"
if [ "\$code" != "200" ]; then
  printf '{"errors":[{"msg":"nope"}]}\n%s\n' "\$code"
  exit 0
fi
printf '%s\n%s\n' "\$(cat "$TMP/issues.json")" "200"
STUB
  chmod +x "$TMP/bin/curl"

  cd "$TMP/work" || return 1
}

teardown()
{
  rm -rf "$TMP"
}

props()
{
  cat > "$TMP/work/sonar-project.properties" << 'EOF'
sonar.organization=someorg
sonar.projectKey=someorg_somerepo
EOF
}

sc()
{
  run env PATH="$TMP/bin" SONAR_TOKEN=fake-token "$SC" "$@"
}

@test "sonarcloud: --help prints usage and exits 0" {
  sc --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"x-sonarcloud"* ]]
}

@test "sonarcloud: an unknown argument is rejected" {
  sc --frobnicate
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown argument: --frobnicate"* ]]
}

@test "sonarcloud: a flag with no value is rejected" {
  sc --pr
  [ "$status" -ne 0 ]
  [[ "$output" == *"Missing PR number"* ]]
}

@test "sonarcloud: refuses to run without a token" {
  props
  run env -u SONAR_TOKEN PATH="$TMP/bin" "$SC"
  [ "$status" -eq 1 ]
  [[ "$output" == *"SONAR_TOKEN environment variable is not set"* ]]
}

@test "sonarcloud: refuses to run without curl" {
  rm "$TMP/bin/curl"
  sc
  [ "$status" -eq 1 ]
  [[ "$output" == *"curl is not installed"* ]]
}

@test "sonarcloud: refuses to run without jq" {
  rm "$TMP/bin/jq"
  sc
  [ "$status" -eq 1 ]
  [[ "$output" == *"jq is not installed"* ]]
}

@test "sonarcloud: says what to do when it cannot find a project" {
  sc
  [ "$status" -eq 1 ]
  [[ "$output" == *"Could not auto-detect"* ]]
  [[ "$output" == *"sonar-project.properties"* ]]
  [[ "$output" == *"--org"* ]]
}

@test "sonarcloud: detects the project from sonar-project.properties" {
  props
  sc
  [ "$status" -eq 0 ]
  grep -q 'componentKeys=someorg_somerepo' "$CALLS"
}

@test "sonarcloud: detects the project from the sonarlint config" {
  mkdir -p "$TMP/work/.sonarlint"
  cat > "$TMP/work/.sonarlint/connectedMode.json" << 'EOF'
{ "sonarCloudOrganization": "lintorg", "projectKey": "lintorg_lintrepo" }
EOF
  sc
  [ "$status" -eq 0 ]
  grep -q 'componentKeys=lintorg_lintrepo' "$CALLS"
}

@test "sonarcloud: sonar-project.properties wins over the sonarlint config" {
  props
  mkdir -p "$TMP/work/.sonarlint"
  cat > "$TMP/work/.sonarlint/connectedMode.json" << 'EOF'
{ "sonarCloudOrganization": "lintorg", "projectKey": "lintorg_lintrepo" }
EOF
  sc
  grep -q 'componentKeys=someorg_somerepo' "$CALLS"
  run ! grep -q 'lintorg_lintrepo' "$CALLS"
}

@test "sonarcloud: --project-key overrides what was detected" {
  props
  sc --project-key other_key
  grep -q 'componentKeys=other_key' "$CALLS"
}

@test "sonarcloud: --pr scopes the query to a pull request" {
  props
  sc --pr 42
  grep -q 'pullRequest=42' "$CALLS"
}

@test "sonarcloud: --branch scopes the query to a branch" {
  props
  sc --branch feature/x
  grep -q 'branch=feature/x' "$CALLS"
}

@test "sonarcloud: filters are passed through to the API" {
  props
  sc --severities BLOCKER,CRITICAL --types BUG
  grep -q 'severities=BLOCKER,CRITICAL' "$CALLS"
  grep -q 'types=BUG' "$CALLS"
}

@test "sonarcloud: the default query asks only for unresolved issues" {
  props
  sc
  grep -q 'statuses=OPEN,CONFIRMED,REOPENED' "$CALLS"
}

@test "sonarcloud: --resolved drops the status filter entirely" {
  # An empty resolution filter returns both resolved and unresolved issues.
  # resolved=true would return only the resolved ones, which is the opposite
  # of "include resolved".
  props
  sc --resolved
  run ! grep -q 'statuses=' "$CALLS"
  run ! grep -q 'resolved=' "$CALLS"
}

@test "sonarcloud: a bad token is reported as such" {
  props
  run env PATH="$TMP/bin" SONAR_TOKEN=fake HTTP_CODE=401 "$SC"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Authentication failed (HTTP 401)"* ]]
}

@test "sonarcloud: a missing project is reported as such" {
  props
  run env PATH="$TMP/bin" SONAR_TOKEN=fake HTTP_CODE=404 "$SC"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Not found (HTTP 404)"* ]]
}

@test "sonarcloud: rate limiting is reported as such" {
  props
  run env PATH="$TMP/bin" SONAR_TOKEN=fake HTTP_CODE=429 "$SC"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Rate limited (HTTP 429)"* ]]
}

@test "sonarcloud: an unexpected status is still reported" {
  props
  run env PATH="$TMP/bin" SONAR_TOKEN=fake HTTP_CODE=500 "$SC"
  [ "$status" -eq 1 ]
  [[ "$output" == *"HTTP 500"* ]]
}

@test "sonarcloud: stops after one page when the page is not full" {
  props
  sc
  [ "$(grep -c '^curl ' "$CALLS")" -eq 1 ]
}

@test "sonarcloud: lists every issue it fetched" {
  props
  sc
  [[ "$output" == *"Do not do that"* ]]
  [[ "$output" == *"Tidy this up"* ]]
  [[ "$output" == *"Fix this first"* ]]
}

@test "sonarcloud: orders severities worst first" {
  props
  sc
  order=$(printf '%s\n' "$output" | grep '^### Severity:' | head -3)
  [ "$(printf '%s\n' "$order" | head -1)" = "### Severity: BLOCKER" ]
  [ "$(printf '%s\n' "$order" | sed -n 2p)" = "### Severity: CRITICAL" ]
  [ "$(printf '%s\n' "$order" | sed -n 3p)" = "### Severity: MINOR" ]
}

@test "sonarcloud: strips the project prefix from the file path" {
  # SonarCloud components are "<projectKey>:<path>"; the prefix is noise in a
  # report meant to be read next to the source tree.
  props
  sc
  [[ "$output" == *"#### File: local/bin/thing"* ]]
  [[ "$output" != *"#### File: org_repo:"* ]]
}

@test "sonarcloud: each issue carries a link back to SonarCloud" {
  props
  sc
  [[ "$output" == *"https://sonarcloud.io/project/issues?open=AAA"* ]]
}

@test "sonarcloud: the summary counts by severity, type and total" {
  props
  sc
  [[ "$output" == *"- **BLOCKER:** 1"* ]]
  [[ "$output" == *"- **VULNERABILITY:** 1"* ]]
  [[ "$output" == *"- **Total issues:** 3"* ]]
}

@test "sonarcloud: leaves no temp directory behind" {
  props
  mkdir -p "$TMP/tmpdir"
  run env PATH="$TMP/bin" SONAR_TOKEN=fake TMPDIR="$TMP/tmpdir" "$SC"
  [ "$status" -eq 0 ]
  [ -z "$(ls -A "$TMP/tmpdir")" ]
}
