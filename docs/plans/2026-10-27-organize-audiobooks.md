# x-organize-audiobooks.py Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A repeatable command that moves every top-level audiobook file into a folder named after its title, with a
dry run, and never overwrites, copies or loses a book.

**Architecture:** One standard-library Python script. Pure naming (`new_names`) is separate from the safety checks
(`check`, `check_length`) and the move (`move`); `main` walks the files in sorted order and runs the same path for the
dry run and the real run, skipping only the calls that change the disk.

**Tech Stack:** Python 3.12+ (stdlib only), `ffprobe` (only for `[...]` names), bats-core 1.5+ for tests.

**Spec:** `docs/plans/2026-10-27-organize-audiobooks-design.md`

## Global Constraints

- Shebang `#!/usr/bin/env python3`; standard library only; must run on Python 3.12 (`target-version = "py312"`, the
  CI interpreter). No syntax or stdlib API newer than 3.12.
- Lines 2–9 of the script are the `#USAGE` block from Task 1, wrapped in `# fmt: off` / `# fmt: on`. Without the
  wrapper, the `ruff format` hook rewrites `#USAGE` to `# USAGE`, which neither `usage` nor
  `scripts/install-completions.sh` (`grep -qE '^(#USAGE|//USAGE)'`) recognises — verified on 2026-10-27. Never
  remove the wrapper. `mise run lint-usage` skips `.py` files, so run `usage lint` on the script directly.
- `import subprocess  # nosec B404` and the `ffprobe` call line carries `# nosec B603 B607`, as in
  `local/bin/x-git-largest-files.py`.
- 4-space indent, max 120 columns, double quotes (`ruff format`); `.editorconfig` applies to every file touched.
- Output lines are exact: `move  <src> -> <folder>/<file>`, `skip  <src>: <reason>`,
  `fail  <src> -> <folder>/<file>: [Errno N] <strerror>` (stderr). Summary: `moved M, skipped S, failed F`; dry run:
  `dry run: would move M, skip S, fail F`. Two spaces after each verb.
- Exit 0 when no move failed (skips are not failures), 1 when any move failed, 2 for usage errors.
- Tests run only on throwaway folders under `mktemp -d`. Nothing in this plan touches
  `/Volumes/Expansion/library/audiobooks` except the Task 4 dry run; the real run there happens only on the user's
  go-ahead.
- Commits only after the user has explicitly authorised them. When authorised: stage and commit only with `git-hunk`
  (`.claude/rules/git-hunk-commits.md`; `git-hunk list` output goes through context-mode), Conventional Commits
  (`.claude/rules/commit-format.md`), never `--no-verify`, no attribution or session trailers.

## Review Focus

1. A multi-part file with its ID after the part, `Foo, Part 2 [B0PART0002].m4b`, must share the `Foo` folder — Task 1
   naming test.
2. Running with no `DIR` from inside the library must print the same lines as passing the path — Task 1 test.
3. A second run straight after a real run must move nothing and only re-report the copies left behind — Task 2 test.
4. A duplicate whose names differ only in how `ä` is stored (decomposed vs composed) must be skipped, in the dry run
   too — Task 2 test.
5. A name under 255 characters but over 255 bytes (130 × `ä`) must be a skip, not a failed move — Task 3 test.

---

### Task 1: Naming rules, shown by a dry run

**Files:**

- Create: `local/bin/x-organize-audiobooks.py`
- Test: `tests/x-organize-audiobooks.bats`

**Interfaces:**

- Produces:
  - `class Skip(Exception)` — `str(e)` is the reason printed after `skip  <src>: `.
  - `candidates(root: Path) -> list[str]` — sorted names of regular, non-symlink, non-hidden files in `root` whose
    suffix lower-cased is `.m4b` or `.mp3`.
  - `new_names(path: Path) -> tuple[str, str]` — `(folder, filename)`; raises `Skip("no title left in the name")`.
  - `main(argv: list[str] | None = None) -> int` — argparse: `-n/--dry-run`, positional `dir` (default `.`);
    `parser.error(f"{dir} is not a directory")` when it is not one.
  - Module constants, values copied from the spec:
    `PREFIX = re.compile(r"^(\d+-)?01 ")`,
    `SPLIT = re.compile(r"^(?P<title>.*?)(?P<ids>(?: \[(?!\.\.\.\])[^\]]*\])*)$")`,
    `UNSAFE = re.compile(r'[\\/:*?"<>|;]')`, `PART = re.compile(r", Part \d+$")`.

- [ ] **Step 1: Scaffold the test file and write the failing tests**

Use the repo's `bats-test-scaffold` skill conventions (setup/teardown, `TMPDIR_TEST`), then replace its placeholder
tests with these:

```bash
#!/usr/bin/env bats
# Tests for local/bin/x-organize-audiobooks.py. Every fixture is an empty file
# in a throwaway folder: the script only renames, so no audio is needed.

bats_require_minimum_version 1.5.0

setup()
{
  SCRIPT="$BATS_TEST_DIRNAME/../local/bin/x-organize-audiobooks.py"
  TMPDIR_TEST="$(mktemp -d)"
  export TMPDIR_TEST
  LIB="$TMPDIR_TEST/lib"
  mkdir -p "$LIB"
}

teardown()
{
  chmod -R u+w "$TMPDIR_TEST" 2> /dev/null || true
  rm -rf "$TMPDIR_TEST"
}

book()
{
  local name
  for name in "$@"; do : > "$LIB/$name"; done
}

@test "x-organize-audiobooks: prints usage on --help" {
  run python3 "$SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"usage:"* ]]
}

@test "x-organize-audiobooks: exits 2 when DIR is not a directory" {
  run --separate-stderr python3 "$SCRIPT" -n "$TMPDIR_TEST/missing"
  [ "$status" -eq 2 ]
  [[ "$stderr" == *"is not a directory"* ]]
}

@test "x-organize-audiobooks: dry run applies the naming rules" {
  book "01 Live.m4b" "01 2001; A Space Odyssey.m4b" "For We Are Many [B01N17THEO].m4b" \
    "1632, Part 1.m4b" "Foo, Part 2 [B0PART0002].m4b" "1-01 Miracle Of Self Discipline.mp3" \
    "01 Rework (Unabridged).m4b" "01 Flying Saucer Tour, Vol I.m4b" \
    "A Tale of Two Cities [Tantor] [B002V08IYW].m4b" "01 Upper.M4B" 'Q? A: "B" <C>|D\E.m4b'
  run --separate-stderr python3 "$SCRIPT" -n "$LIB"
  [ "$status" -eq 0 ]
  expected="$(
    cat << 'EOF'
move  01 2001; A Space Odyssey.m4b -> 2001_ A Space Odyssey/2001_ A Space Odyssey.m4b
move  01 Flying Saucer Tour, Vol I.m4b -> Flying Saucer Tour, Vol I/Flying Saucer Tour, Vol I.m4b
move  01 Live.m4b -> Live/Live.m4b
move  01 Rework (Unabridged).m4b -> Rework (Unabridged)/Rework (Unabridged).m4b
move  01 Upper.M4B -> Upper/Upper.M4B
move  1-01 Miracle Of Self Discipline.mp3 -> Miracle Of Self Discipline/Miracle Of Self Discipline.mp3
move  1632, Part 1.m4b -> 1632/1632, Part 1.m4b
move  A Tale of Two Cities [Tantor] [B002V08IYW].m4b -> A Tale of Two Cities/A Tale of Two Cities [Tantor] [B002V08IYW].m4b
move  Foo, Part 2 [B0PART0002].m4b -> Foo/Foo, Part 2 [B0PART0002].m4b
move  For We Are Many [B01N17THEO].m4b -> For We Are Many/For We Are Many [B01N17THEO].m4b
move  Q? A: "B" <C>|D\E.m4b -> Q_ A_ _B_ _C__D_E/Q_ A_ _B_ _C__D_E.m4b
dry run: would move 11, skip 0, fail 0
EOF
  )"
  [ "$output" = "$expected" ]
}

@test "x-organize-audiobooks: skips a name with no title left" {
  book "01 .m4b"
  run --separate-stderr python3 "$SCRIPT" -n "$LIB"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "skip  01 .m4b: no title left in the name" ]
  [ "${lines[1]}" = "dry run: would move 0, skip 1, fail 0" ]
}

@test "x-organize-audiobooks: ignores hidden files, other types, symlinks and subfolders" {
  book "01 Live.m4b" ".hidden.m4b" "notes.txt"
  ln -s "01 Live.m4b" "$LIB/link.m4b"
  mkdir "$LIB/Sub"
  book "Sub/Inside.m4b"
  run --separate-stderr python3 "$SCRIPT" -n "$LIB"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
  [ "${lines[0]}" = "move  01 Live.m4b -> Live/Live.m4b" ]
}

@test "x-organize-audiobooks: DIR defaults to the current folder" {
  book "01 Live.m4b"
  cd "$LIB"
  run --separate-stderr python3 "$SCRIPT" -n
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "move  01 Live.m4b -> Live/Live.m4b" ]
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `bats tests/x-organize-audiobooks.bats`
Expected: every test fails (`python3: can't open file …/x-organize-audiobooks.py`).

- [ ] **Step 3: Implement `candidates`, `new_names` and `main` in `local/bin/x-organize-audiobooks.py`**

Header, lines 1–10 exactly (the `#USAGE` lines have no space after `#`):

```python
#!/usr/bin/env python3
# fmt: off
#USAGE about "Move each audiobook in a folder into a folder named after its title"
#USAGE flag "-n --dry-run" help="Print what would be moved without moving anything"
#USAGE arg "[dir]" help="Folder holding the audiobooks (default: current directory)"
# fmt: on
# ruff format would rewrite "#USAGE" to "# USAGE", which usage and
# scripts/install-completions.sh do not recognise; the fmt markers keep the
# directives byte-for-byte.
"""Move each audiobook in a folder into a folder named after its title."""
```

Confirm `usage generate json --file local/bin/x-organize-audiobooks.py` prints a spec whose `usage` field is
`[-n --dry-run] [dir]`.

`new_names` follows spec steps 1, 2, 4, 5 and 6 in order on `path.stem`, keeping `path.suffix` unchanged; title
truncation (step 3) arrives in Task 3. `main` prints a `move` line per name, a `skip` line for each `Skip`, then the
dry-run summary. Until Task 2, a run without `-n` calls `parser.error("moving is not implemented yet; use -n")`. Then
`chmod +x` the script.

- [ ] **Step 4: Run the tests to verify they pass**

Run: `bats tests/x-organize-audiobooks.bats`
Expected: `6 tests, 0 failures`.

- [ ] **Step 5: Format and lint with the repo's own hooks**

`prek` runs the hooks from `.pre-commit-config.yaml` (ruff, shellcheck, editorconfig, …) on the named files; the
`usage-lint` hook skips `.py`, so it is run directly:

```bash
prek run --files local/bin/x-organize-audiobooks.py tests/x-organize-audiobooks.bats
usage lint local/bin/x-organize-audiobooks.py
```

Expected: every hook `Passed` or `Skipped`; `No issues found.`. If an autofix hook changed a file, rerun until clean.

- [ ] **Step 6: Commit (only if the user has authorised commits)**

`git-hunk commit <hashes of both new files> -m "feat(bin): add x-organize-audiobooks.py naming and dry run"`

### Task 2: Moving, with the overwrite and duplicate checks

**Files:**

- Modify: `local/bin/x-organize-audiobooks.py`
- Test: `tests/x-organize-audiobooks.bats`

**Interfaces:**

- Consumes: `Skip`, `candidates`, `new_names`, `main` from Task 1.
- Produces:
  - `check(root: Path, folder: str, filename: str, planned: set[str]) -> None` — raises
    `Skip(f"{folder} exists and is not a folder")` or `Skip(f"{folder}/{filename} already exists")`; otherwise adds
    `unicodedata.normalize("NFC", f"{folder}/{filename}").casefold()` to `planned`. "Exists" uses `os.path.lexists`;
    the planned set is checked before the disk.
  - `move(root: Path, src: str, folder: str, filename: str) -> None` — spec "The move" steps 1–3 with the `rmdir`
    rollback; an `unlink` failure re-raises as `OSError(e.errno, f"{e.strerror}; the book is now under both names")`.

- [ ] **Step 1: Write the failing tests**

```bash
@test "x-organize-audiobooks: moves each book into its folder" {
  book "01 Live.m4b" "1632, Part 1.m4b"
  run --separate-stderr python3 "$SCRIPT" "$LIB"
  [ "$status" -eq 0 ]
  [ -f "$LIB/Live/Live.m4b" ] && [ ! -e "$LIB/01 Live.m4b" ]
  [ -f "$LIB/1632/1632, Part 1.m4b" ] && [ ! -e "$LIB/1632, Part 1.m4b" ]
  [ "${lines[2]}" = "moved 2, skipped 0, failed 0" ]
}

@test "x-organize-audiobooks: dry run changes nothing and prints what the real run does" {
  book "01 Cat's Cradle.m4b" "Cat's Cradle.m4b" "01 Live.m4b"
  before="$(ls -AR "$LIB")"
  run --separate-stderr python3 "$SCRIPT" -n "$LIB"
  [ "$status" -eq 0 ]
  dry=("${lines[@]}")
  [ "$(ls -AR "$LIB")" = "$before" ]
  [ "${dry[3]}" = "dry run: would move 2, skip 1, fail 0" ]
  run --separate-stderr python3 "$SCRIPT" "$LIB"
  [ "$status" -eq 0 ]
  [ "${lines[3]}" = "moved 2, skipped 1, failed 0" ]
  [ "${dry[*]:0:3}" = "${lines[*]:0:3}" ]
}

@test "x-organize-audiobooks: leaves the second copy of a duplicate in place" {
  book "01 Cat's Cradle.m4b" "Cat's Cradle.m4b"
  run --separate-stderr python3 "$SCRIPT" "$LIB"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "move  01 Cat's Cradle.m4b -> Cat's Cradle/Cat's Cradle.m4b" ]
  [ "${lines[1]}" = "skip  Cat's Cradle.m4b: Cat's Cradle/Cat's Cradle.m4b already exists" ]
  [ -f "$LIB/Cat's Cradle.m4b" ]
}

@test "x-organize-audiobooks: treats decomposed and composed ä as the same name" {
  book "01 $(printf 'Ja\314\210niksen vuosi').m4b" "$(printf 'J\303\244niksen vuosi').m4b"
  run --separate-stderr python3 "$SCRIPT" -n "$LIB"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "move  01 "* ]]
  [[ "${lines[1]}" == "skip  "*"already exists" ]]
}

@test "x-organize-audiobooks: reuses an existing book folder" {
  mkdir "$LIB/1632"
  book "1632/1632, Part 1.m4b" "1632, Part 2.m4b"
  run --separate-stderr python3 "$SCRIPT" "$LIB"
  [ "$status" -eq 0 ]
  [ -f "$LIB/1632/1632, Part 1.m4b" ] && [ -f "$LIB/1632/1632, Part 2.m4b" ]
}

@test "x-organize-audiobooks: skips a book whose folder name is taken by a file" {
  book "Live" "01 Live.m4b"
  run --separate-stderr python3 "$SCRIPT" "$LIB"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "skip  01 Live.m4b: Live exists and is not a folder" ]
}

@test "x-organize-audiobooks: reports a failed move on stderr and exits 1" {
  [ "$(id -u)" -ne 0 ] || skip "root ignores folder permissions"
  mkdir "$LIB/Live"
  chmod 555 "$LIB/Live"
  book "01 Live.m4b"
  run --separate-stderr python3 "$SCRIPT" "$LIB"
  [ "$status" -eq 1 ]
  [[ "$stderr" == "fail  01 Live.m4b -> Live/Live.m4b: [Errno "* ]]
  [ -f "$LIB/01 Live.m4b" ]
  [ "${lines[0]}" = "moved 0, skipped 0, failed 1" ]
}

@test "x-organize-audiobooks: a second run only reports the copies left behind" {
  book "01 Cat's Cradle.m4b" "Cat's Cradle.m4b" "01 Live.m4b"
  run --separate-stderr python3 "$SCRIPT" "$LIB"
  run --separate-stderr python3 "$SCRIPT" "$LIB"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
  [ "${lines[0]}" = "skip  Cat's Cradle.m4b: Cat's Cradle/Cat's Cradle.m4b already exists" ]
  [ "${lines[1]}" = "moved 0, skipped 1, failed 0" ]
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `bats tests/x-organize-audiobooks.bats`
Expected: the 8 new tests fail (`moving is not implemented yet`, or the duplicate shown as a second `move`); the 6
Task 1 tests pass.

- [ ] **Step 3: Implement `check` and `move`, and wire them into `main`**

Remove the Task 1 guard. Per file, in this order: `new_names`, `check`, then (unless dry run) `move`; print the
`move` line after a successful move. `OSError` prints the `fail` line to stderr as `[Errno {e.errno}] {e.strerror}`.
Print the real-run summary when not a dry run. Return 1 when any move failed.

- [ ] **Step 4: Run the tests to verify they pass**

Run: `bats tests/x-organize-audiobooks.bats`
Expected: `14 tests, 0 failures`.

- [ ] **Step 5: Format and lint**

Same command as Task 1 Step 5. Expected: clean.

- [ ] **Step 6: Commit (only if the user has authorised commits)**

`git-hunk commit <hashes> -m "feat(bin): move audiobooks into their own folders"`

### Task 3: Stored titles for truncated names, and length limits

**Files:**

- Modify: `local/bin/x-organize-audiobooks.py`
- Test: `tests/x-organize-audiobooks.bats`

**Interfaces:**

- Consumes: `Skip`, `new_names`, `check`, `main` from Tasks 1–2.
- Produces:
  - `FFPROBE_TIMEOUT = 60`
  - `stored_title(path: Path) -> str` — runs
    `["ffprobe", "-v", "error", "-show_entries", "format_tags=title", "-of", "default=nw=1:nk=1", str(path)]` with
    `capture_output=True, encoding="utf-8", timeout=FFPROBE_TIMEOUT, check=False`; returns stripped stdout. Raises
    `Skip("no stored title (ffprobe not found)")` on `FileNotFoundError`, `Skip("no stored title (ffprobe timed out)")`
    on `subprocess.TimeoutExpired`, `Skip(f"no stored title (ffprobe exited {rc})")` on a non-zero exit, and
    `Skip("no stored title (empty)")` for empty output.
  - `check_length(root: Path, folder: str, filename: str) -> None` — compares `len(os.fsencode(...))` of the folder
    name and file name with `os.pathconf(root, "PC_NAME_MAX")`, and of `str(root.resolve() / folder / filename)` with
    `os.pathconf(root, "PC_PATH_MAX")`; raises `Skip(f"folder name too long ({n} > {limit} bytes)")`,
    `Skip(f"file name too long (…)")` or `Skip(f"path too long (…)")`.

- [ ] **Step 1: Write the failing tests**

Add the stub helper after `book()`:

```bash
stub_ffprobe()
{
  mkdir -p "$TMPDIR_TEST/bin"
  cat > "$TMPDIR_TEST/bin/ffprobe" << 'EOF'
#!/bin/sh
printf '%s\n' "$*" >> "$TMPDIR_TEST/ffprobe.calls"
printf '%s\n' "$STUB_TITLE"
exit "${STUB_STATUS:-0}"
EOF
  chmod +x "$TMPDIR_TEST/bin/ffprobe"
  PATH="$TMPDIR_TEST/bin:$PATH"
}
```

Tests:

```bash
@test "x-organize-audiobooks: completes a title cut short without a space before [...]" {
  stub_ffprobe
  export STUB_TITLE="Scrum: A Step-by-Step Guide to Managing Product Development: Lean Six, Book 7"
  src="Scrum_ A Step-by-Step Guide to Managing Product De[...] [B07Q76B9SB].m4b"
  folder="Scrum_ A Step-by-Step Guide to Managing Product Development_ Lean Six, Book 7"
  book "$src"
  run --separate-stderr python3 "$SCRIPT" -n "$LIB"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "move  $src -> $folder/$folder [B07Q76B9SB].m4b" ]
}

@test "x-organize-audiobooks: completes a title cut short with a space before [...]" {
  stub_ffprobe
  export STUB_TITLE="The Conception of Terror: Tales Inspired by M. R. James - Volume 1: An Audible Original Drama"
  src="The Conception of Terror_ Tales Inspired by M. R. [...] [B07MR6RY3T].m4b"
  folder="The Conception of Terror_ Tales Inspired by M. R. James - Volume 1_ An Audible Original Drama"
  book "$src"
  run --separate-stderr python3 "$SCRIPT" -n "$LIB"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "move  $src -> $folder/$folder [B07MR6RY3T].m4b" ]
}

@test "x-organize-audiobooks: reads stored titles only for truncated names" {
  stub_ffprobe
  book "01 Live.m4b" "For We Are Many [B01N17THEO].m4b"
  run --separate-stderr python3 "$SCRIPT" -n "$LIB"
  [ "$status" -eq 0 ]
  [ ! -e "$TMPDIR_TEST/ffprobe.calls" ]
}

@test "x-organize-audiobooks: skips a truncated title when ffprobe is missing" {
  # The empty PATH goes through env so it reaches only the script: bats' own
  # `run --separate-stderr` calls mktemp and needs the normal PATH.
  py="$(python3 -c 'import sys; print(sys.executable)')"
  mkdir "$TMPDIR_TEST/empty"
  book "Cut[...] [B0TEST0001].m4b"
  run --separate-stderr env PATH="$TMPDIR_TEST/empty" "$py" "$SCRIPT" -n "$LIB"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "skip  Cut[...] [B0TEST0001].m4b: no stored title (ffprobe not found)" ]
}

@test "x-organize-audiobooks: skips a truncated title when the stored title is empty" {
  stub_ffprobe
  export STUB_TITLE=""
  book "Cut[...] [B0TEST0001].m4b"
  run --separate-stderr python3 "$SCRIPT" -n "$LIB"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "skip  Cut[...] [B0TEST0001].m4b: no stored title (empty)" ]
}

@test "x-organize-audiobooks: skips a truncated title when ffprobe fails" {
  stub_ffprobe
  export STUB_TITLE="ignored" STUB_STATUS=1
  book "Cut[...] [B0TEST0001].m4b"
  run --separate-stderr python3 "$SCRIPT" -n "$LIB"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "skip  Cut[...] [B0TEST0001].m4b: no stored title (ffprobe exited 1)" ]
}

@test "x-organize-audiobooks: skips a name over the length limit" {
  stub_ffprobe
  STUB_TITLE="$(printf 'A%.0s' {1..300})"
  export STUB_TITLE
  book "Cut[...] [B0TEST0001].m4b"
  run --separate-stderr python3 "$SCRIPT" "$LIB"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "skip  Cut[...] [B0TEST0001].m4b: "*"too long"* ]]
  [ -f "$LIB/Cut[...] [B0TEST0001].m4b" ]
}

@test "x-organize-audiobooks: counts the length limit in bytes, not characters" {
  stub_ffprobe
  # 130 × ä: 130 characters, 260 bytes.
  STUB_TITLE="$(printf '\303\244%.0s' {1..130})"
  export STUB_TITLE
  book "Cut[...] [B0TEST0001].m4b"
  run --separate-stderr python3 "$SCRIPT" "$LIB"
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "skip  Cut[...] [B0TEST0001].m4b: "*"too long"* ]]
  [ -f "$LIB/Cut[...] [B0TEST0001].m4b" ]
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `bats tests/x-organize-audiobooks.bats`
Expected: 7 of the 8 new tests fail. "reads stored titles only for truncated names" already passes, because nothing
calls `ffprobe` yet; it guards Step 3 against calling it for every file. The 14 earlier tests pass.

- [ ] **Step 3: Implement `stored_title` and `check_length`, and wire them in**

`new_names` replaces the title with `stored_title(path)` when the title ends with `[...]` (spec step 3), before the
character step. `main` calls `check_length` before `check`.

- [ ] **Step 4: Run the tests to verify they pass**

Run: `bats tests/x-organize-audiobooks.bats`
Expected: `22 tests, 0 failures`.

- [ ] **Step 5: Format and lint, including bandit**

Task 1 Step 5 commands, then `mise run lint-bandit`. Expected: clean; bandit reports no issues for the script.

- [ ] **Step 6: Commit (only if the user has authorised commits)**

`git-hunk commit <hashes> -m "feat(bin): complete truncated audiobook titles from tags"`

### Task 4: Documentation, full verification, dry run on the library

**Files:**

- Create: `local/bin/x-organize-audiobooks.py.md`
- Already present: `docs/plans/2026-10-27-organize-audiobooks-design.md`, this plan

**Interfaces:**

- Consumes: the finished script and its exact output lines.

- [ ] **Step 1: Write `local/bin/x-organize-audiobooks.py.md`**

Sections as in `local/bin/a.md`: one-line description, `## Requirements` (Python 3.12+, `ffprobe` only for `[...]`
names), `## Usage` (the command line and `-n`), `## Examples` (dry run, real run, run from inside the library),
`## Behavior` (the naming rules table from the spec, skip reasons, exit statuses, "never overwrites or copies").

- [ ] **Step 2: Lint the docs**

```bash
prek run --files local/bin/x-organize-audiobooks.py.md docs/plans/2026-10-27-organize-audiobooks-design.md \
  docs/plans/2026-10-27-organize-audiobooks.md
```

Expected: every hook `Passed` or `Skipped`.

- [ ] **Step 3: Full repo gates**

Run: `mise run lint` then `mise run test` (about 5 minutes, ~1300 tests).
Expected: both exit 0, `0 failures`, no warnings.

- [ ] **Step 4: Put the command on PATH**

Run: `ln -s "$HOME/.dotfiles/local/bin/x-organize-audiobooks.py" "$HOME/.local/bin/x-organize-audiobooks.py"` (the
link dotbot's `local/bin/*` rule creates on the next `./install`).
Expected: `command -v x-organize-audiobooks.py` prints `~/.local/bin/x-organize-audiobooks.py`.

- [ ] **Step 5: Dry run on the real library and show the user**

Run: `x-organize-audiobooks.py -n /Volumes/Expansion/library/audiobooks`
Expected: exit 0; 133 `move` lines and 7 `skip` lines (the unprefixed copies of 2001, A Canticle for Leibowitz, A
Scanner Darkly, An Appetite for Wonder, Baskervillen Koira, Cat's Cradle, The Andromeda Strain); the two `[...]` files
completed as in the spec table; last line `dry run: would move 133, skip 7, fail 0`. Show the full output to the user.
Stop here: the real run happens only when the user says so.

- [ ] **Step 6: Commit (only if the user has authorised commits)**

`git-hunk commit <hashes> -m "docs(bin): document x-organize-audiobooks.py"`, then
`git-hunk commit <hashes> -m "docs(plans): add audiobook organizer design and plan"`.
