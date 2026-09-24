#!/usr/bin/env python3
"""Generate vim-which-key label dictionaries from mini.clue's built-in clues.

nvim shows a key guide on `g`, `z` and `<C-w>` through mini.clue, whose
`gen_clues.g()`, `gen_clues.z()` and `gen_clues.windows()` ship a description
for every built-in command under those prefixes. vim-which-key has no such
list, so vim would show only the handful of user mappings. Hand-copying ~160
labels drifts the moment mini.nvim changes them; this reads them from the
installed mini.clue source instead and writes them as Vim dictionaries.

Only the literal `return { ... }` table of each generator is read. Entries
built by Lua expressions outside it (the nvim-version-dependent `gr` clue)
are left out; the vimrc supplies `gr` from its own LSP keymaps.

A key that is both a command and a prefix of longer keys (`zu`, `<C-w>g`)
becomes a group whose name is the command's own description, prefixed with
"+", because vim-which-key cannot hold a leaf and a group under one key.

Usage:
    scripts/generate-vim-clues.py                    # default source/output
    scripts/generate-vim-clues.py --source PATH/clue.lua --output FILE

The labels are mini.nvim's (MIT, Copyright (c) 2021 Evgeni Chasnovski); the
generated file names its source and the NOTICE entry covers it.
"""

from __future__ import annotations

import argparse
import os
import re
import subprocess  # nosec B404
import sys

DEFAULT_SOURCE = "~/.local/share/nvim/site/pack/core/opt/mini.nvim/lua/mini/clue.lua"
DEFAULT_OUTPUT = "config/vim/autoload/miniclue.vim"

# name in the generated file -> (mini.clue generator, key prefix to strip)
GENERATORS = {
    "g": ("g", "g"),
    "z": ("z", "z"),
    "windows": ("windows", "<C-w>"),
}

STRING = r"'(?:[^'\\]|\\.)*'|\"(?:[^\"\\]|\\.)*\""
ENTRY = re.compile(rf"\{{\s*mode\s*=\s*({STRING}),\s*keys\s*=\s*({STRING}),\s*desc\s*=\s*({STRING})")
# A token is a <...> key name or a single character.
TOKEN = re.compile(r"<[A-Za-z][^<>]*>|.", re.DOTALL)


def lua_string(literal: str) -> str:
    """Decode a quoted Lua string literal (only the escapes mini.clue uses)."""
    body = literal[1:-1]
    return re.sub(r"\\(.)", r"\1", body)


def return_table(source: str, name: str) -> str:
    """Return the text of `return { ... }` inside MiniClue.gen_clues.<name>.

    Raises ValueError when the generator or its table is missing, so a
    renamed upstream function fails loudly instead of emitting empty labels.
    """
    start = source.find(f"MiniClue.gen_clues.{name} = function")
    if start < 0:
        raise ValueError(f"MiniClue.gen_clues.{name} not found")
    table = source.find("return {", start)
    end = source.find("\nend", start)
    if table < 0 or (0 <= end < table):
        raise ValueError(f"no return table in MiniClue.gen_clues.{name}")
    # Count braces outside string literals only: window keys such as
    # '<C-w>}' would otherwise close the table early and drop most entries.
    depth, quote, i = 0, "", table + len("return ")
    while i < len(source):
        ch = source[i]
        if quote:
            if ch == "\\":
                i += 1
            elif ch == quote:
                quote = ""
        elif ch in "'\"":
            quote = ch
        elif ch == "{":
            depth += 1
        elif ch == "}":
            depth -= 1
            if depth == 0:
                return source[table : i + 1]
        i += 1
    raise ValueError(f"unterminated return table in MiniClue.gen_clues.{name}")


def parse(source: str, name: str, prefix: str) -> dict[str, dict]:
    """Parse one generator into {mode: tree}; leaves are str, groups dict."""
    trees: dict[str, dict] = {}
    for mode_lit, keys_lit, desc_lit in ENTRY.findall(return_table(source, name)):
        mode, keys, desc = (lua_string(x) for x in (mode_lit, keys_lit, desc_lit))
        if not keys.startswith(prefix) or keys == prefix:
            continue
        tokens = TOKEN.findall(keys[len(prefix) :])
        node = trees.setdefault(mode, {})
        for tok in tokens[:-1]:
            child = node.get(tok)
            if isinstance(child, str):
                child = {"name": "+" + child.lstrip("+")}
            node[tok] = child or {"name": "+" + tok}
            node = node[tok]
        last = tokens[-1]
        if isinstance(node.get(last), dict):
            node[last]["name"] = "+" + desc.lstrip("+")
        else:
            node[last] = desc
    if not trees:
        raise ValueError(f"MiniClue.gen_clues.{name} yielded no entries")
    return trees


def vim_key(tok: str) -> str:
    """Render a dictionary key the way vim-which-key looks it up.

    vim-which-key names only <Tab>, <CR>, <BS>, <Esc> and <Del>; every other
    control key reaches its dictionary as the raw character, so those keys are
    written as a double-quoted "\\<C-x>" that Vim expands when it reads them.
    """
    if tok in ("<Tab>", "<CR>", "<BS>", "<Esc>", "<Del>"):
        return f"'{tok}'"
    if len(tok) > 1 and tok.startswith("<"):
        return '"\\' + tok + '"'
    return "'" + tok.replace("'", "''") + "'"


def vim_value(value: str | dict, indent: int) -> str:
    """Render a label (str) or a group (dict) as a Vim literal."""
    if isinstance(value, str):
        return "'" + value.replace("'", "''") + "'"
    pad = "      \\ " + "  " * indent
    items = sorted(value.items(), key=lambda kv: (kv[0] != "name", kv[0].lower(), kv[0]))
    body = "".join(f"\n{pad}  {vim_key(k)}: {vim_value(v, indent + 1)}," for k, v in items)
    return "{" + body + f"\n{pad}}}"


def mini_version(source_path: str) -> str:
    """Best-effort `git describe` of the mini.nvim checkout, else 'unknown'."""
    repo = os.path.dirname(os.path.dirname(os.path.dirname(source_path)))
    try:
        out = subprocess.run(  # nosec B603 B607
            ["git", "-C", repo, "describe", "--tags", "--always"],
            capture_output=True,
            text=True,
            check=True,
        )
        return out.stdout.strip() or "unknown"
    except OSError, subprocess.CalledProcessError:
        return "unknown"


def render(source: str, version: str) -> str:
    """Build the whole autoload file."""
    lines = [
        '" GENERATED by scripts/generate-vim-clues.py -- do not edit; rerun the script.',
        '"',
        "\" Built-in key labels for vim-which-key, read from mini.nvim's",
        f'" lua/mini/clue.lua (MiniClue.gen_clues.g/z/windows), mini.nvim {version}.',
        '" Labels: mini.nvim, MIT License, Copyright (c) 2021 Evgeni Chasnovski.',
        '" See NOTICE.',
        "",
        '" miniclue#get({name}, {mode}): name is g, z or windows; mode is n or x.',
        '" Returns a fresh copy, so callers can extend it without touching this data.',
        "function! miniclue#get(name, mode) abort",
        "  return deepcopy(get(get(s:clues, a:name, {}), a:mode, {}))",
        "endfunction",
        "",
    ]
    data = {name: parse(source, gen, prefix) for name, (gen, prefix) in GENERATORS.items()}
    lines.append("let s:clues = " + vim_value(data, 0))
    return "\n".join(lines) + "\n"


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Generate vim-which-key label dictionaries from mini.clue's built-in clues."
    )
    parser.add_argument("--source", default=DEFAULT_SOURCE, help="path to mini.clue's clue.lua")
    parser.add_argument("--output", default=DEFAULT_OUTPUT, help="Vim autoload file to write")
    args = parser.parse_args(argv)

    source_path = os.path.expanduser(args.source)
    try:
        with open(source_path, encoding="utf-8") as fh:
            source = fh.read()
        text = render(source, mini_version(source_path))
    except (OSError, ValueError) as err:
        print(f"generate-vim-clues: {err}", file=sys.stderr)
        return 1

    with open(args.output, "w", encoding="utf-8") as fh:
        fh.write(text)
    print(f"wrote {args.output}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
