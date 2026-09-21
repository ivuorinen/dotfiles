#!/usr/bin/env python3
"""Fail when a K.n / K.nl / K.d / K.ld keymap call carries no ``desc``.

``.claude/rules/keymap-descriptions.md`` requires every keymap helper call in
``config/nvim`` to pass an opts table with ``desc`` (which-key shows it). The
rule used to be checked by a grep that required double-quoted keys while every
call site uses single quotes, so it could never fail (agent-loopholes-1324fbe0).

This scanner tokenises just enough Lua to be quote- and comment-proof: it
finds each helper call, splits the argument list at top-level commas, and
checks the opts argument — third for K.n/K.nl ``(key, cmd, opts)``, fourth for
K.d/K.ld ``(key, mode, cmd, opts)``, matching ``lua/utils.lua``. The opts
argument passes when it is a string literal (``handleDesc`` makes that the
description) or a table containing ``desc``.

Ceiling: an opts argument passed as a variable is accepted only if its name
contains ``desc``; the scanner does not follow assignments.

Usage: check-keymap-desc.py [FILE...]   (default: config/nvim/**/*.lua)
"""

from __future__ import annotations

import pathlib
import re
import sys

OPTS_INDEX = {"n": 2, "nl": 2, "d": 3, "ld": 3}
CALL_RE = re.compile(r"\bK\.(n|nl|d|ld)\s*\(")


def skip_string(src: str, i: int) -> int:
    """Return the index just past the Lua string or comment starting at ``i``.

    Returns ``i`` unchanged when no string or comment starts there, so the
    caller can treat the character as code.
    """
    if src.startswith("--", i):
        long = re.match(r"--\[(=*)\[", src[i:])
        if long:
            end = src.find("]" + long.group(1) + "]", i)
            return len(src) if end < 0 else end + len(long.group(1)) + 2
        end = src.find("\n", i)
        return len(src) if end < 0 else end
    long = re.match(r"\[(=*)\[", src[i:])
    if long:
        end = src.find("]" + long.group(1) + "]", i)
        return len(src) if end < 0 else end + len(long.group(1)) + 2
    if src[i] in "'\"":
        q, j = src[i], i + 1
        while j < len(src) and src[j] != q:
            j += 2 if src[j] == "\\" else 1
        return j + 1
    return i


BLOCK_OPEN = {"function", "if", "do", "repeat"}
BLOCK_CLOSE = {"end", "until"}


def call_args(src: str, start: int) -> list[str]:
    """Split the argument list opening at ``start`` (just past ``(``).

    Lua blocks close with keywords, not brackets, so an inline
    ``function() for _, b in … end`` would split at its inner comma if only
    brackets were counted. ``function``/``if``/``do``/``repeat`` open a level
    and ``end``/``until`` close one (``elseif`` is its own word).
    """
    args, depth, i, begin = [], 0, start, start
    while i < len(src):
        j = skip_string(src, i)
        if j != i:
            i = j
            continue
        word = re.match(r"[A-Za-z_]\w*", src[i:]) if (i == 0 or not re.match(r"\w", src[i - 1])) else None
        if word:
            depth += (word.group() in BLOCK_OPEN) - (word.group() in BLOCK_CLOSE)
            i += len(word.group())
            continue
        c = src[i]
        if c in "([{":
            depth += 1
        elif c in ")]}":
            if depth == 0:
                args.append(src[begin:i].strip())
                return args
            depth -= 1
        elif c == "," and depth == 0:
            args.append(src[begin:i].strip())
            begin = i + 1
        i += 1
    return args


def strip_code(src: str) -> str:
    """Blank out strings and comments so CALL_RE only sees real code."""
    out, i = [], 0
    while i < len(src):
        j = skip_string(src, i)
        if j != i:
            out.append(re.sub(r"[^\n]", " ", src[i:j]))
            i = j
        else:
            out.append(src[i])
            i += 1
    return "".join(out)


def check(path: pathlib.Path) -> list[str]:
    """Return one problem line per helper call in ``path`` lacking a desc."""
    src = path.read_text(encoding="utf-8")
    problems = []
    for m in CALL_RE.finditer(strip_code(src)):
        args = call_args(src, m.end())
        idx = OPTS_INDEX[m.group(1)]
        opts = args[idx] if len(args) > idx else ""
        # handleDesc in utils.lua turns a bare string opts into { desc = … }.
        if not (re.match(r"""['"]|\[=*\[""", opts) or re.search(r"\bdesc\b", opts)):
            line = src.count("\n", 0, m.start()) + 1
            problems.append(f"{path}:{line}: K.{m.group(1)} call has no desc in its opts")
    return problems


def main(argv: list[str]) -> int:
    """Check the named files, or every Lua file under config/nvim."""
    files = [pathlib.Path(a) for a in argv] or sorted(pathlib.Path("config/nvim").rglob("*.lua"))
    problems = [p for f in files if f.name != "utils.lua" for p in check(f)]
    if problems:
        print("\n".join(problems))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
