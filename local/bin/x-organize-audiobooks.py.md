# x-organize-audiobooks.py

Move each audiobook file in a folder into a folder named after its title.

## Requirements

- Python 3.12 or newer
- [ffprobe](https://ffmpeg.org/ffprobe.html) (part of FFmpeg), only for file names truncated with `[...]`. Without
  it those files are skipped; every other file is handled.

## Usage

```bash
x-organize-audiobooks.py [-n | --dry-run] [DIR]
```

- `DIR` - folder holding the audiobooks (default: current directory)
- `-n`, `--dry-run` - print what would be moved without moving anything

Only `.m4b` and `.mp3` files directly in `DIR` are handled. Hidden files, symlinks, subfolders and other file types
are ignored, so the command can be rerun after every new download.

## Examples

```bash
# See what would happen
x-organize-audiobooks.py -n /Volumes/Expansion/library/audiobooks

# Move the books
x-organize-audiobooks.py /Volumes/Expansion/library/audiobooks

# Run from inside the library
cd /Volumes/Expansion/library/audiobooks && x-organize-audiobooks.py -n
```

## Behavior

Files are handled in sorted name order. Each name goes through these steps:

1. A leading `01 ` or `N-01 ` is removed.
2. Trailing ` [ID]` groups such as ` [B01N17THEO]` stay on the file name and are left out of the folder name.
3. A title ending in `[...]` (cut short when saved) is replaced with the title stored in the file, read by `ffprobe`.
4. Each of `\ / : * ? " < > | ;` becomes `_`.
5. A trailing `, Part N` is left out of the folder name, so the parts of one book share a folder.

| File                                  | New path                                                    |
|---------------------------------------|-------------------------------------------------------------|
| `01 Live.m4b`                         | `Live/Live.m4b`                                             |
| `01 2001; A Space Odyssey.m4b`        | `2001_ A Space Odyssey/2001_ A Space Odyssey.m4b`           |
| `For We Are Many [B01N17THEO].m4b`    | `For We Are Many/For We Are Many [B01N17THEO].m4b`          |
| `1632, Part 1.m4b`                    | `1632/1632, Part 1.m4b`                                     |
| `1-01 Miracle Of Self Discipline.mp3` | `Miracle Of Self Discipline/Miracle Of Self Discipline.mp3` |

Each file prints one line, followed by a summary:

```text
move  01 Live.m4b -> Live/Live.m4b
skip  2001; A Space Odyssey.m4b: 2001_ A Space Odyssey/2001_ A Space Odyssey.m4b already exists
fail  Example.m4b -> Example/Example.m4b: [Errno 13] Permission denied
moved 1, skipped 1, failed 1
```

`fail` lines go to standard error. With `-n` the lines are the same and the summary reads
`dry run: would move M, skip S, fail F`.

A file is skipped, and stays where it is, when:

- its new path already exists, or an earlier file in the same run already takes it. Of two copies of the same book,
  the second stays in place.
- a file, not a folder, already has the folder's name.
- the folder name or file name is longer than the volume allows, or the full path is. Lengths are counted in bytes.
- the title is truncated and no stored title can be read: `ffprobe` is missing, fails, takes over 60 seconds, or the
  stored title is empty.
- no title is left once the prefix is removed.
- the folder name would be empty or start with `.`: the book would stay at the top level, leave the library, or be
  hidden in Finder.

Names that differ only in letter case, or in how a letter such as `ä` is stored, count as the same name, as on APFS.

A move adds the new name with a hard link, then removes the old name. A hard link cannot replace an existing file and
cannot cross volumes, so a book is never overwritten and never copied. If adding the new name fails, the book is
untouched. If removing the old name fails, the book has both names and the `fail` line says so.

Exit status: 0 when no move failed (skips are not failures), 1 when any move failed, 2 for a usage error such as a
`DIR` that is not a folder.
