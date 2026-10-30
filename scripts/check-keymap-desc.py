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

A raw ``vim.keymap.set(mode, lhs, rhs, opts)`` is held to the same rule when
its lhs is a ``<leader>`` literal: those are the maps mini.clue labels, and a
leader map written without the helpers otherwise commits unlabelled
(audit-1ca7cb00). Non-leader raw maps (buffer-local UI keys such as ``q``) are
not checked.

Ceiling: an opts argument passed as a variable is accepted only if its name
contains ``desc``; the scanner does not follow assignments. A ``vim.keymap.set``
reached through a local alias is not seen.

Usage: check-keymap-desc.py [FILE...]   (default: config/nvim/**/*.lua)
"""

from __future__ import annotations

import pathlib
import re
import sys

OPTS_INDEX = {"K.n": 2, "K.nl": 2, "K.d": 3, "K.ld": 3, "vim.keymap.set": 3}
CALL_RE = re.compile(r"\b(K\.(?:n|nl|d|ld)|vim\.keymap\.set)\s*\(")
LEADER_RE = re.compile(r"""['"]<[Ll]eader>""")


def long_bracket_end(src: str, i: int, offset: int) -> int | None:
    """Return the index past a ``[=*[ … ]=*]`` opening at ``i + offset``, else None."""
    long = re.match(r"\[(=*)\[", src[i + offset :])
    if not long:
        return None
    end = src.find("]" + long.group(1) + "]", i)
    return len(src) if end < 0 else end + len(long.group(1)) + 2


def quoted_end(src: str, i: int) -> int:
    """Return the index just past the quoted string opening at ``i``."""
    q, j = src[i], i + 1
    while j < len(src) and src[j] != q:
        j += 2 if src[j] == "\\" else 1
    return j + 1


def skip_string(src: str, i: int) -> int:
    """Return the index just past the Lua string or comment starting at ``i``.

    Returns ``i`` unchanged when no string or comment starts there, so the
    caller can treat the character as code.
    """
    if src.startswith("--", i):
        end = long_bracket_end(src, i, 2)
        if end is not None:
            return end
        end = src.find("\n", i)
        return len(src) if end < 0 else end
    end = long_bracket_end(src, i, 0)
    if end is not None:
        return end
    if src[i] in "'\"":
        return quoted_end(src, i)
    return i


BLOCK_OPEN = {"function", "if", "do", "repeat"}
BLOCK_CLOSE = {"end", "until"}


def word_at(src: str, i: int) -> re.Match[str] | None:
    """Match an identifier starting at ``i``, unless ``i`` is mid-word."""
    if i > 0 and re.match(r"\w", src[i - 1]):
        return None
    return re.match(r"[A-Za-z_]\w*", src[i:])


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
        word = word_at(src, i)
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
    """Return one problem line per helper or leader ``vim.keymap.set`` lacking a desc."""
    src = path.read_text(encoding="utf-8")
    problems = []
    for m in CALL_RE.finditer(strip_code(src)):
        name = m.group(1)
        args = call_args(src, m.end())
        if name == "vim.keymap.set" and not (len(args) > 1 and LEADER_RE.match(args[1])):
            continue
        idx = OPTS_INDEX[name]
        opts = args[idx] if len(args) > idx else ""
        # handleDesc in utils.lua turns a bare string opts into { desc = … }.
        if not (re.match(r"""['"]|\[=*\[""", opts) or re.search(r"\bdesc\b", opts)):
            line = src.count("\n", 0, m.start()) + 1
            problems.append(f"{path}:{line}: {name} call has no desc in its opts")
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
