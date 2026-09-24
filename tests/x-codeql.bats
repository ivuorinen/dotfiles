#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

# x-codeql wraps the codeql CLI: it works out which languages a tree contains,
# builds a database per language and analyses it. codeql is stubbed — a real
# database build takes minutes and downloads query packs — so what is under
# test is the language detection, the option handling and what the script does
# with the SARIF it gets back.

setup()
{
  # See tests/claude-hooks-misc.bats: the submodule fixture below builds real
  # repos, so it must not inherit the git environment a commit hook carries
  # (GIT_INDEX_FILE and friends).
  unset GIT_INDEX_FILE GIT_DIR GIT_WORK_TREE GIT_OBJECT_DIRECTORY GIT_COMMON_DIR GIT_PREFIX

  CQ="$BATS_TEST_DIRNAME/../local/bin/x-codeql"
  TMP="$(mktemp -d)"
  mkdir -p "$TMP/bin" "$TMP/src" "$TMP/out" "$TMP/cache"
  CALLS="$TMP/calls"
  : > "$CALLS"
  for tool in sh bash env date mkdir find awk grep rm cat mktemp head jq git; do
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
  # PROBE_BUILD_FAIL stands in for a machine where the probe database cannot be
  # compiled at all — verify_engine warns and skips rather than aborting.
  case "\$3" in
    *.probe-db*) [ -n "\$PROBE_BUILD_FAIL" ] && exit 1 ;;
  esac
  mkdir -p "\$3"
  exit 0
fi

if [ "\$1" = "database" ] && [ "\$2" = "analyze" ]; then
  out=""
  for a in "\$@"; do
    case "\$a" in --output=*) out="\${a#--output=}" ;; esac
  done

  # verify_engine compiles a throwaway probe database and aborts the whole run
  # unless a known py/path-injection comes back. A stub that always answers []
  # fails that check, so every python tree would exit 1 before any analysis.
  # Emulate a working dataflow engine for the probe database only; the real
  # tree still goes through the SARIF_RESULTS switch below. PROBE_FAIL makes
  # the probe come back empty, which is what a missing dataflow library pack
  # looks like.
  case "\$3" in
    *.probe-db*)
      if [ -n "\$PROBE_FAIL" ]; then
        printf '{"runs":[{"results":[]}]}\n' > "\$out"
      else
        printf '{"runs":[{"results":[{"ruleId":"py/path-injection","message":{"text":"probe"}}]}]}\n' > "\$out"
      fi
      exit 0
      ;;
  esac

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

@test "codeql: C sources map to the cpp language" {
  # CodeQL has no "c" language; asking for one downloads codeql/c-queries,
  # which does not exist.
  printf 'x\n' > "$TMP/src/main.c"
  printf 'x\n' > "$TMP/src/main.h"
  cq --path "$TMP/src"
  langs=$(printf '%s\n' "$output" | sed -n 's/.*Found languages: //p')
  [ "$langs" = "cpp" ]
}

@test "codeql: in a git repo, submodule and gitignored files do not add languages" {
  git -C "$TMP/src" init -q
  printf 'x\n' > "$TMP/src/main.go"
  printf 'ignored/\n' > "$TMP/src/.gitignore"
  mkdir -p "$TMP/src/ignored" "$TMP/sub"
  printf 'x\n' > "$TMP/src/ignored/app.rb"
  git -C "$TMP/sub" init -q
  printf 'x\n' > "$TMP/sub/lib.h"
  git -C "$TMP/sub" add lib.h
  git -C "$TMP/sub" -c user.name=t -c user.email=t@t -c commit.gpgsign=false \
    commit -qm init
  git -C "$TMP/src" -c protocol.file.allow=always \
    submodule add -q "$TMP/sub" vendor/sub
  [ -f "$TMP/src/vendor/sub/lib.h" ]
  cq --path "$TMP/src"
  langs=$(printf '%s\n' "$output" | sed -n 's/.*Found languages: //p')
  [ "$langs" = "go" ]
}

@test "codeql: builds the database under the cache directory" {
  printf 'x\n' > "$TMP/src/main.go"
  cq --path "$TMP/src"
  grep -q "database create $TMP/cache/codeql/db-" "$CALLS"
}

@test "codeql: passes the tree's code-scanning config to database create" {
  printf 'x\n' > "$TMP/src/main.go"
  mkdir -p "$TMP/src/.github/codeql"
  printf 'paths-ignore:\n  - vendor/**\n' > "$TMP/src/.github/codeql/codeql-config.yml"
  cq --path "$TMP/src"
  [ "$status" -eq 0 ]
  grep -q "database create .*--codescanning-config=$TMP/src/.github/codeql/codeql-config.yml" "$CALLS"
}

@test "codeql: without a code-scanning config the flag is not passed" {
  printf 'x\n' > "$TMP/src/main.go"
  cq --path "$TMP/src"
  [ "$status" -eq 0 ]
  run ! grep -q -- "--codescanning-config" "$CALLS"
}

@test "codeql: the engine probe never gets the tree's config" {
  # The probe's source lives outside the tree; applying the tree's paths-ignore
  # to it is meaningless at best and would hide the known-positive at worst.
  printf 'x\n' > "$TMP/src/app.py"
  mkdir -p "$TMP/src/.github/codeql"
  printf 'paths-ignore:\n  - vendor/**\n' > "$TMP/src/.github/codeql/codeql-config.yml"
  cq --path "$TMP/src"
  [ "$status" -eq 0 ]
  grep "database create .*probe-db" "$CALLS" > "$TMP/probe-calls"
  run ! grep -q -- "--codescanning-config" "$TMP/probe-calls"
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

@test "codeql: the engine self-check actually runs on a python tree" {
  # A self-check that silently never executes is indistinguishable from one
  # that passes, so assert the evidence that it ran, not just a zero exit.
  printf 'x\n' > "$TMP/src/main.py"
  cq --path "$TMP/src"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Engine self-check passed"* ]]
  grep -q -- '--threat-model=all' "$CALLS"
}

@test "codeql: the self-check does not run when no python is present" {
  printf 'x\n' > "$TMP/src/main.go"
  cq --path "$TMP/src"
  [ "$status" -eq 0 ]
  [[ "$output" != *"Engine self-check"* ]]
}

@test "codeql: a probe that detects nothing aborts the run" {
  # The whole point of the check: a zero-result run on the real tree must not
  # be reported as clean when the engine cannot find a known-positive either.
  printf 'x\n' > "$TMP/src/main.py"
  cd "$TMP/out" || return 1
  run env PATH="$TMP/bin" XDG_CACHE_HOME="$TMP/cache" PROBE_FAIL=1 "$CQ" --path "$TMP/src"
  [ "$status" -eq 1 ]
  [[ "$output" == *"engine self-check FAILED"* ]]
  [[ "$output" == *"codeql/python-all"* ]]
}

@test "codeql: a probe that cannot be built warns and continues" {
  printf 'x\n' > "$TMP/src/main.py"
  cd "$TMP/out" || return 1
  run env PATH="$TMP/bin" XDG_CACHE_HOME="$TMP/cache" PROBE_BUILD_FAIL=1 "$CQ" --path "$TMP/src"
  [ "$status" -eq 0 ]
  [[ "$output" == *"could not build its probe database"* ]]
  [[ "$output" != *"Engine self-check passed"* ]]
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
