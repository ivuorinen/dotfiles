# Design: `x-organize-audiobooks.py` audiobook folder sorter

## Intent

The audiobook library is a flat folder of single-file books from several sources (Libation, Humble Bundle, others).
Each book should live in a folder named after its title, so `./01 Live.m4b` becomes `./Live/Live.m4b`. New downloads
keep arriving from sources whose naming cannot be configured, so this is a repeatable command, not a one-off cleanup.
It runs against a spinning HDD and must never lose or damage a book.

## Goals

- Move every top-level audiobook file into `<title>/<file>` under the folder it is run in.
- Clean the names the sources leave behind: the `01 ` track prefix, truncated `[...]` titles, and characters that
  differ between Finder and the shell.
- Group multi-part books (`1632, Part 1`, `1632, Part 2`) into one folder.
- A dry run that prints exactly what the real run would do.
- Safe to run again after every new download.

## Non-goals

- Editing tags or audio data.
- Deleting duplicates. The second copy of a duplicate stays in place for the user to decide on.
- Recursing into subfolders or renaming folders that already exist.
- Looking titles up online. The only metadata source is the file's own title tag.
- Stripping numeric prefixes other than `01 ` and `N-01 `.

## Anti-goals

- Overwriting any file.
- Copying file data. Every move is a directory-entry change on the same volume.
- Removing a book's last name. The old name is unlinked only after the new name exists.

## Decided

### Which files

Regular files directly in `DIR` whose extension is `.m4b` or `.mp3`, compared case-insensitively. Hidden files
(leading `.`), symlinks, directories and other extensions are ignored. Files are handled in sorted name order, so
`01 X` comes before `X` and `Part 1` before `Part 2`.

### Naming rules

For each file, with `stem` being the name without its extension:

1. **Prefix.** Remove a leading `01 ` or `N-01 ` (regex `^(\d+-)?01 `).
2. **Split.** Split `stem` into a title and trailing ID groups. ID groups are the trailing run of ` [...]` groups whose
   content is not `...`: regex `^(?P<title>.*?)(?P<ids>(?: \[(?!\.\.\.\])[^\]]*\])*)$`.
3. **Truncated title.** If the title ends with `[...]`, replace the title with the file's stored title tag. If the tag
   cannot be read (no `ffprobe`, empty tag, error or 60 s timeout), skip the file.
4. **Characters.** In title and IDs, replace each of `\ / : * ? " < > | ;` with `_`, then trim surrounding whitespace
   from the title. If the title is now empty, skip the file.
5. **New file name.** `title + ids + extension`, the extension kept exactly as it was.
6. **Folder name.** The title with a trailing `, Part N` (regex `, Part \d+$`) removed. If the folder name is empty
   or starts with `.` (`.`, `..`, or a hidden folder), skip the file. Added after the final review.

| Current file                                                               | New path                                                                                                         |
|----------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------|
| `01 Live.m4b`                                                              | `Live/Live.m4b`                                                                                                  |
| `01 2001; A Space Odyssey.m4b`                                             | `2001_ A Space Odyssey/2001_ A Space Odyssey.m4b`                                                                |
| `For We Are Many [B01N17THEO].m4b`                                         | `For We Are Many/For We Are Many [B01N17THEO].m4b`                                                               |
| `1632, Part 1.m4b`                                                         | `1632/1632, Part 1.m4b`                                                                                          |
| `1-01 Miracle Of Self Discipline.mp3`                                      | `Miracle Of Self Discipline/Miracle Of Self Discipline.mp3`                                                      |
| `01 Rework (Unabridged).m4b`                                               | `Rework (Unabridged)/Rework (Unabridged).m4b`                                                                    |
| `01 Flying Saucer Tour, Vol I.m4b`                                         | `Flying Saucer Tour, Vol I/Flying Saucer Tour, Vol I.m4b`                                                        |
| `A Tale of Two Cities [Tantor] [B002V08IYW].m4b`                           | `A Tale of Two Cities/A Tale of Two Cities [Tantor] [B002V08IYW].m4b`                                            |
| `Scrum_ A Step-by-Step Guide to Managing Product De[...] [B07Q76B9SB].m4b` | `Scrum_ … Product Development_ Lean Six, Book 7/Scrum_ … Product Development_ Lean Six, Book 7 [B07Q76B9SB].m4b` |

Parenthesised text is kept: stripping it would merge `The Audiobook of the Year (2018)` with `The Audiobook of the
Year` into one folder.

### Reading the stored title

Only for truncated titles:
`ffprobe -v error -show_entries format_tags=title -of default=nw=1:nk=1 <file>`, found through `PATH` (the call
carries `# nosec B603 B607`, as in `x-git-largest-files.py`). Measured at 100–423 ms per file on the HDD.

### Moving and safety

Checks before a move; each failure skips the file, leaves it in place, and reports why:

1. **Too long.** The folder name or file name exceeds `os.pathconf(DIR, "PC_NAME_MAX")` bytes, or the absolute target
   path exceeds `PC_PATH_MAX` bytes. Lengths are counted as encoded bytes, not characters.
2. **Target exists.** The target path exists on disk, or an earlier file in this run already planned it. Planned
   targets are compared after NFC normalisation and case folding, matching APFS. This is what makes the dry run report
   the same skips as the real run.
3. **Folder name taken.** A non-directory already exists at the folder path.

The move:

1. `os.mkdir(folder)` when it does not exist; an existing folder is used as it is.
2. `os.link(src, dst)`. It fails if `dst` exists (no overwrite) and across volumes (no copy).
3. `os.unlink(src)`.

If step 2 fails, the original is untouched and a folder created in step 1 is removed with `os.rmdir`. If step 3 fails,
the book has both names and the failure is reported. Ctrl-C leaves at most one file with both names; a rerun reports
it as "target exists".

The dry run follows the same code path and skips only the `mkdir`, `link`, `unlink` and `rmdir` calls.

### Command and output

```text
x-organize-audiobooks.py [-n | --dry-run] [DIR]
```

`DIR` defaults to the current directory; argparse handles options and `-h`. A `DIR` that is not a directory is a usage
error (exit 2). One line per file, paths relative to `DIR`:

```text
move  01 Live.m4b -> Live/Live.m4b
skip  2001; A Space Odyssey.m4b: 2001_ A Space Odyssey/2001_ A Space Odyssey.m4b already exists
skip  Example [...] [B0XXXXXXXX].m4b: no stored title (ffprobe not found)
fail  Example.m4b -> Example/Example.m4b: [Errno 1] Operation not permitted
moved 133, skipped 7, failed 0
```

`move` and `skip` lines and the summary go to stdout, `fail` lines to stderr. A dry run prints the same lines, with the
summary `dry run: would move 133, skip 7, fail 0`. Exit status is 0 when nothing failed and 1 when any move failed;
skips do not count as failures.

### Location and conventions

| Part   | Path                                                  |
|--------|-------------------------------------------------------|
| Script | `local/bin/x-organize-audiobooks.py`                  |
| Docs   | `local/bin/x-organize-audiobooks.py.md`               |
| Tests  | `tests/x-organize-audiobooks.bats`                    |
| Design | `docs/plans/2026-10-27-organize-audiobooks-design.md` |

- Follows `.claude/rules/local-bin-scripts.md`: `x-` prefix, a `#USAGE about "…"` line, a bats test.
- `#!/usr/bin/env python3`, standard library only, runs on Python 3.12 (`target-version = "py312"`, the CI
  interpreter).
- Reaches `PATH` through the existing `local/bin/*` → `~/.local/bin` dotbot link.

### Tests

`tests/x-organize-audiobooks.bats`, written before the script. Fixtures are empty files with real-looking names in a
temp dir; a stub `ffprobe` early on `PATH` returns a fixed title, so CI needs neither ffprobe nor audio. Cases:

- every row of the naming table;
- a duplicate pair (`01 X` and `X`): the first moves, the second stays and is reported;
- a dry run changes nothing on disk and prints the same lines as the real run;
- an existing book folder is reused;
- a name over the length limit (stub returns a 300-character title) is skipped;
- `ffprobe` missing, and `ffprobe` returning an empty title, are skipped;
- a file occupying the folder's name is skipped;
- hidden files, other extensions, symlinks and subfolders are ignored;
- exit status 0 with skips, 2 for a missing `DIR`.

No test relies on the filesystem's case sensitivity, so they pass on APFS and on CI's ext4.

### Verification

1. `mise run test` and `mise run lint` pass with zero warnings.
2. Dry run on `/Volumes/Expansion/library/audiobooks`; the output is shown to the user. Expected: 133 moves, 7 skips.
3. The real run only on the user's go-ahead.

## Measured on the library (2026-10-27)

- 140 audio files (138 `.m4b`, 2 `.mp3`), no subfolders, APFS. `NAME_MAX` 255 bytes, `PATH_MAX` 1024 bytes.
- Longest planned names: file 110 bytes, folder 94 bytes, absolute path 242 bytes.
- 7 duplicate pairs, each pair the same byte size: 2001, A Canticle for Leibowitz, A Scanner Darkly, An Appetite for
  Wonder, Baskervillen Koira, Cat's Cradle, The Andromeda Strain.
- Title-tag scan of all 140 files (25.6 s): 124 match the name, 2 differ only in punctuation, 11 are the title before
  `:`, 1 has an extra `[Tantor]`, and 2 are truncated with `[...]`. Every file has a title tag.
