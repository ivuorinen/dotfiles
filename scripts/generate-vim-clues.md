# generate-vim-clues

Writes the built-in key labels vim's key guide shows on `g`, `z` and `<C-w>`.

## Why

nvim's key guide is mini.clue. Its `gen_clues.g()`, `gen_clues.z()` and
`gen_clues.windows()` ship a description for every built-in command under
those prefixes (about 160 of them). Vim's key guide is vim-which-key, which
has no such list: without one, pressing `g` would show only this config's own
handful of `g` mappings.

Copying the labels by hand drifts the moment mini.nvim changes them. This
script reads them from the installed mini.clue source and writes
`config/vim/autoload/miniclue.vim`, so vim shows the same text nvim does.

## What it reads

Only the literal `return { ... }` table of each generator. Entries built by
Lua expressions outside that table are left out on purpose: the
nvim-version-dependent `gr` clue is one, and the vimrc supplies `gr` from its
own LSP keymaps instead.

| Case                                      | Output                           |
|-------------------------------------------|----------------------------------|
| Plain key (`gg`)                          | `'g': 'Go to line (def: first)'` |
| Key that is also a prefix (`zu`)          | group named `+<its description>` |
| `<Tab>`, `<CR>`, `<BS>`, `<Esc>`, `<Del>` | the name, e.g. `'<Tab>'`         |
| Any other `<C-x>` key                     | `"\<C-x>"`, the raw character    |

vim-which-key looks up only those five special keys by name and every other
control key by its raw character, hence the split.

A generator that is missing, renamed, or yields no entries makes the script
exit 1 rather than write an empty file.

## Usage

```bash
./scripts/generate-vim-clues.py
./scripts/generate-vim-clues.py --source path/to/mini/clue.lua --output FILE
```

The default source is the mini.nvim checkout `vim.pack` installs
(`~/.local/share/nvim/site/pack/core/opt/mini.nvim/lua/mini/clue.lua`). The
generated file records the mini.nvim version it was built from.

Run it after updating mini.nvim, and commit the regenerated file with the
update. `tests/generate-vim-clues.bats` covers the parser.

## License

The description strings are mini.nvim's (MIT, Copyright (c) 2021 Evgeni
Chasnovski). The generated file names its source, and `NOTICE` lists it.
