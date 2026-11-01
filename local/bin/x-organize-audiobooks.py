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

import argparse
import contextlib
import os
import re
import subprocess  # nosec B404
import sys
import unicodedata
from pathlib import Path

AUDIO_SUFFIXES = (".m4b", ".mp3")
# Seconds to wait for ffprobe; a spun-down disk can take a while to answer.
FFPROBE_TIMEOUT = 60
# Track-number prefix left by some sources: "01 " or "<disc>-01 ".
PREFIX = re.compile(r"^(\d+-)?01 ")
# Title, then the trailing " [ID]" groups. "[...]" marks a truncated title, never an ID.
SPLIT = re.compile(r"^(?P<title>.*?)(?P<ids>(?: \[(?!\.\.\.\])[^\]]*\])*)$")
UNSAFE = re.compile(r'[\\/:*?"<>|;]')
PART = re.compile(r", Part \d+$")


class Skip(Exception):
    """A file left where it is; the message is the reason shown to the user."""


def candidates(root: Path) -> list[str]:
    """Names of the audiobook files directly in root, in sorted order."""
    return sorted(
        entry.name
        for entry in root.iterdir()
        if not entry.name.startswith(".")
        and not entry.is_symlink()
        and entry.is_file()
        and entry.suffix.lower() in AUDIO_SUFFIXES
    )


def stored_title(path: Path) -> str:
    """The title tag stored in the file, read with ffprobe."""
    try:
        result = subprocess.run(  # nosec B603 B607
            ["ffprobe", "-v", "error", "-show_entries", "format_tags=title", "-of", "default=nw=1:nk=1", str(path)],
            capture_output=True,
            encoding="utf-8",
            errors="replace",
            timeout=FFPROBE_TIMEOUT,
            check=False,
        )
    except FileNotFoundError:
        raise Skip("no stored title (ffprobe not found)") from None
    except subprocess.TimeoutExpired:
        raise Skip("no stored title (ffprobe timed out)") from None
    if result.returncode != 0:
        raise Skip(f"no stored title (ffprobe exited {result.returncode})")
    title = result.stdout.strip()
    if not title:
        raise Skip("no stored title (empty)")
    return title


def new_names(path: Path) -> tuple[str, str]:
    """Return (folder, filename) for one audiobook file."""
    parts = SPLIT.match(PREFIX.sub("", path.stem))
    if parts is None:  # SPLIT matches every string; this only narrows the type
        raise Skip("no title left in the name")
    title = parts["title"]
    if title.endswith("[...]"):
        title = stored_title(path)
    title = UNSAFE.sub("_", title).strip()
    ids = UNSAFE.sub("_", parts["ids"])
    if not title:
        raise Skip("no title left in the name")
    folder = PART.sub("", title)
    # "", "." and ".." would keep the book at the top level or move it out of the
    # library; any other leading "." hides the folder in Finder.
    if not folder or folder.startswith("."):
        raise Skip("folder name would be empty or hidden")
    return folder, title + ids + path.suffix


def check_length(root: Path, folder: str, filename: str) -> None:
    """Skip a file whose new names exceed this volume's limits, counted in bytes."""
    name_max = os.pathconf(root, "PC_NAME_MAX")
    # PATH_MAX counts the terminating NUL, so the longest usable path is one byte shorter.
    path_max = os.pathconf(root, "PC_PATH_MAX") - 1
    for kind, name, limit in (
        ("folder name", folder, name_max),
        ("file name", filename, name_max),
        ("path", str(root.resolve() / folder / filename), path_max),
    ):
        size = len(os.fsencode(name))
        if size > limit:
            raise Skip(f"{kind} too long ({size} > {limit} bytes)")


def check(root: Path, folder: str, filename: str, planned: set[str]) -> None:
    """Skip a file whose target is taken; otherwise reserve the target in planned.

    planned holds the targets this run already gave out, so a dry run reports the
    same duplicates as a real run. Keys are NFC and case-folded, matching APFS.
    """
    target = f"{folder}/{filename}"
    key = unicodedata.normalize("NFC", target).casefold()
    if key in planned:
        raise Skip(f"{target} already exists")
    if os.path.lexists(root / folder) and not (root / folder).is_dir():
        raise Skip(f"{folder} exists and is not a folder")
    if os.path.lexists(root / target):
        raise Skip(f"{target} already exists")
    planned.add(key)


def move(root: Path, src: str, folder: str, filename: str) -> None:
    """Give src its new name, then drop the old one.

    os.link fails when the target exists and across volumes, so a move can never
    overwrite a file or fall back to copying it.
    """
    directory = root / folder
    created = not directory.is_dir()
    if created:
        directory.mkdir()
    try:
        os.link(root / src, directory / filename)
    except OSError:
        if created:
            with contextlib.suppress(OSError):
                directory.rmdir()
        raise
    try:
        os.unlink(root / src)
    except OSError as e:
        raise OSError(e.errno, f"{e.strerror}; the book is now under both names") from e


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "-n", "--dry-run", action="store_true", help="print what would be moved without moving anything"
    )
    parser.add_argument(
        "dir", nargs="?", default=".", help="folder holding the audiobooks (default: current directory)"
    )
    args = parser.parse_args(argv)
    root = Path(args.dir)
    if not root.is_dir():
        parser.error(f"{args.dir} is not a directory")

    moved = skipped = failed = 0
    planned: set[str] = set()
    for name in candidates(root):
        try:
            folder, filename = new_names(root / name)
            check_length(root, folder, filename)
            check(root, folder, filename, planned)
        except Skip as reason:
            print(f"skip  {name}: {reason}")
            skipped += 1
            continue
        target = f"{folder}/{filename}"
        if not args.dry_run:
            try:
                move(root, name, folder, filename)
            except OSError as e:
                print(f"fail  {name} -> {target}: [Errno {e.errno}] {e.strerror}", file=sys.stderr)
                failed += 1
                continue
        print(f"move  {name} -> {target}")
        moved += 1

    if args.dry_run:
        print(f"dry run: would move {moved}, skip {skipped}, fail {failed}")
    else:
        print(f"moved {moved}, skipped {skipped}, failed {failed}")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
