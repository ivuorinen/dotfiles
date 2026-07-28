#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

# x-codeql wraps the codeql CLI: it works out which languages a tree contains,
# builds a database per language and analyses it. codeql is stubbed — a real
# database build takes minutes and downloads query packs — so what is under
# test is the language detection, the option handling and what the script does
# with the SARIF it gets back.

setup()
{
  CQ="$BATS_TEST_DIRNAME/../local/bin/x-codeql"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin" "$TMP/src" "$TMP/out" "$TMP/cache"
  CALLS="$TMP/calls"
  : > "$CALLS"
  for tool in sh bash env date mkdir find awk grep rm cat mktemp head jq; do
    src="$(command -v "$tool")" && ln -sf "$src" "$TMP/bin/$tool"
  done

  cat > "$TMP/bin/codeql" << STUB
#!/usr/bin/env bash
printf 'codeql %s\n' "\$*" >> "$CALLS"

if [ "\$1" = "version" ]; then
  printf '2.20.0\n'
  exit 0
fi

if [ "\$1" = "database" ] && [ "\$2" = "create" ]; then
  mkdir -p "\$3"
  exit 0
fi

if [ "\$1" = "database" ] && [ "\$2" = "analyze" ]; then
  out=""
  for a in "\$@"; do
    case "\$a" in --output=*) out="\${a#--output=}" ;; esac
  done
  for last; do :; done
  case "\$last" in
    *codeql-suites*)
      if [ -n "\$SUITE_FAIL" ]; then
        printf 'the real reason the suite run failed\n' >&2
        exit 1
      fi
      ;;
    *)
      [ -n "\$DEFAULT_FAIL" ] && exit 1
      ;;
  esac
  if [ "\${SARIF_RESULTS:-0}" -eq 0 ]; then
    printf '{"runs":[{"results":[]}]}\n' > "\$out"
  else
    printf '{"runs":[{"results":[{"ruleId":"r1","message":{"text":"first"}},{"ruleId":"r2","message":{"text":"second"}}]}]}\n' > "\$out"
  fi
  exit 0
fi
STUB
  chmod +x "$TMP/bin/codeql"
}

teardown()
{
  rm -rf "$TMP"
}

cq()
{
  cd "$TMP/out" || return 1
  run env PATH="$TMP/bin" XDG_CACHE_HOME="$TMP/cache" "$CQ" "$@"
}

@test "codeql: --help prints usage and exits 0" {
  cq --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"--parallel"* ]]
}

@test "codeql: -v prints the version" {
  cq -v
  [ "$status" -eq 0 ]
  [[ "$output" == *"x-codeql"* ]]
}

@test "codeql: an unknown option is an error" {
  cq --frobnicate
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option: --frobnicate"* ]]
}

@test "codeql: a path that does not exist is an error" {
  cq --path "$TMP/nope"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Path does not exist"* ]]
}

@test "codeql: refuses to run without the codeql binary" {
  printf 'x\n' > "$TMP/src/main.py"
  rm "$TMP/bin/codeql"
  cq --path "$TMP/src"
  [ "$status" -eq 1 ]
  [[ "$output" == *"codeql binary not found"* ]]
}

@test "codeql: a tree with nothing recognisable is an error" {
  printf 'x\n' > "$TMP/src/README"
  cq --path "$TMP/src"
  [ "$status" -eq 1 ]
  [[ "$output" == *"No supported languages detected"* ]]
}

@test "codeql: maps file extensions to languages" {
  printf 'x\n' > "$TMP/src/main.py"
  printf 'x\n' > "$TMP/src/main.go"
  cq --path "$TMP/src"
  [[ "$output" == *"Found languages:"* ]]
  [[ "$output" == *"python"* ]]
  [[ "$output" == *"go"* ]]
}

@test "codeql: counts each language once no matter how many files" {
  printf 'x\n' > "$TMP/src/a.ts"
  printf 'x\n' > "$TMP/src/b.jsx"
  printf 'x\n' > "$TMP/src/c.js"
  cq --path "$TMP/src"
  langs=$(printf '%s\n' "$output" | sed -n 's/.*Found languages: //p')
  [ "$langs" = "javascript" ]
}

@test "codeql: a workflow directory adds the actions language" {
  mkdir -p "$TMP/src/.github/workflows"
  printf 'on: push\n' > "$TMP/src/.github/workflows/ci.yml"
  printf 'x\n' > "$TMP/src/main.py"
  cq --path "$TMP/src"
  [[ "$output" == *"actions"* ]]
  [[ "$output" == *"python"* ]]
}

@test "codeql: ignores .git and node_modules" {
  # Vendored dependencies would otherwise pull in languages the project does
  # not actually use, and each one costs a full database build.
  mkdir -p "$TMP/src/node_modules/pkg" "$TMP/src/.git"
  printf 'x\n' > "$TMP/src/node_modules/pkg/index.rb"
  printf 'x\n' > "$TMP/src/.git/hook.py"
  printf 'x\n' > "$TMP/src/main.go"
  cq --path "$TMP/src"
  langs=$(printf '%s\n' "$output" | sed -n 's/.*Found languages: //p')
  [ "$langs" = "go" ]
}

@test "codeql: builds the database under the cache directory" {
  printf 'x\n' > "$TMP/src/main.go"
  cq --path "$TMP/src"
  grep -q "database create $TMP/cache/codeql/db-" "$CALLS"
}

@test "codeql: removes the database when it is done" {
  # Databases are large; leaving them behind fills the cache directory.
  printf 'x\n' > "$TMP/src/main.go"
  cq --path "$TMP/src"
  [ -z "$(ls -A "$TMP/cache/codeql")" ]
}

@test "codeql: drops the SARIF file when there are no findings" {
  printf 'x\n' > "$TMP/src/main.go"
  cq --path "$TMP/src"
  [[ "$output" == *"No results found for go"* ]]
  [ ! -f "$TMP/out/codeql-go.sarif" ]
}

@test "codeql: keeps the SARIF file when there are findings" {
  printf 'x\n' > "$TMP/src/main.go"
  cd "$TMP/out" || return 1
  run env PATH="$TMP/bin" XDG_CACHE_HOME="$TMP/cache" SARIF_RESULTS=2 \
    "$CQ" --path "$TMP/src"
  [ "$status" -eq 0 ]
  [ -f "$TMP/out/codeql-go.sarif" ]
  [[ "$output" == *"Found 2 result(s) for go"* ]]
}

@test "codeql: lists the findings it found" {
  printf 'x\n' > "$TMP/src/main.go"
  cd "$TMP/out" || return 1
  run env PATH="$TMP/bin" XDG_CACHE_HOME="$TMP/cache" SARIF_RESULTS=2 \
    "$CQ" --path "$TMP/src"
  [[ "$output" == *"r1: first"* ]]
  [[ "$output" == *"r2: second"* ]]
}

@test "codeql: falls back to the default pack when the suite is missing" {
  printf 'x\n' > "$TMP/src/main.go"
  cd "$TMP/out" || return 1
  run env PATH="$TMP/bin" XDG_CACHE_HOME="$TMP/cache" SUITE_FAIL=1 \
    "$CQ" --path "$TMP/src"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Suite not found, trying default pack"* ]]
  grep -q 'codeql/go-queries$' "$CALLS"
}

@test "codeql: shows the first failure's reason when the fallback also fails" {
  # Without keeping the first attempt's stderr, a genuine analysis failure is
  # reported as nothing more than "suite not found".
  printf 'x\n' > "$TMP/src/main.go"
  cd "$TMP/out" || return 1
  run env PATH="$TMP/bin" XDG_CACHE_HOME="$TMP/cache" SUITE_FAIL=1 DEFAULT_FAIL=1 \
    "$CQ" --path "$TMP/src"
  [ "$status" -eq 1 ]
  [[ "$output" == *"the real reason the suite run failed"* ]]
  [[ "$output" == *"CodeQL analysis failed for go"* ]]
}

@test "codeql: --parallel analyses every language" {
  printf 'x\n' > "$TMP/src/main.go"
  printf 'x\n' > "$TMP/src/main.py"
  cq --path "$TMP/src" --parallel
  [ "$status" -eq 0 ]
  [[ "$output" == *"Running analyses in parallel"* ]]
  grep -q -- '--language=go' "$CALLS"
  grep -q -- '--language=python' "$CALLS"
}

@test "codeql: --path defaults to the current directory" {
  printf 'x\n' > "$TMP/out/main.go"
  cq
  [ "$status" -eq 0 ]
  [[ "$output" == *"Detecting languages in $TMP/out"* ]]
}
