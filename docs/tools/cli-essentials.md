# CLI essentials

The modern command-line replacements and navigation tools used daily.
All are mise-managed (pinned in `config/mise/config.toml`) and wired into
the shells through `config/alias` (bash/zsh) and `config/fish/`.

## Navigation & search

### zoxide — smarter `cd`

Initialized in fish via `zoxide init fish | source` (`config/fish/config.fish`).

- `z <part-of-path>` — jump to the best-matching directory you have
  visited before.
- `zi <part>` — interactive pick among matches (fzf-style).

### fzf — fuzzy finder

Key bindings sourced from `config/fzf/key-bindings.fish`:

- `Ctrl-T` — paste a fuzzy-selected file path onto the command line.
- `Ctrl-R` — fuzzy-search shell history.
- `Alt-C` — `cd` into a fuzzy-selected directory.

Also used inside helper functions (e.g. branch pickers in
`config/fish/functions/`).

### fd — friendlier `find`

`fd <pattern>` searches the current tree, respecting `.gitignore` by
default. Faster and simpler syntax than `find`.

### ripgrep — fast grep

`rg <pattern>` recursively searches file contents, `.gitignore`-aware.
The default search tool for code; also backs editor and fzf integrations.

## Viewing & listing

### eza — modern `ls`

The `ls` alias points at eza with icons and git status:

```text
ls   → eza -h -s=type --git --icons --group-directories-first
l    → ls -a
ll   → ls -la
lsa  → ls -lah
```

### bat — `cat` with syntax highlighting

`cat` is aliased to `bat` (bash/zsh in `config/alias`, fish in
`config/fish/alias.fish`), giving paging, line numbers, and syntax
highlighting. Use `command cat` for the plain original when piping to
tools that dislike bat's decorations.

## Where to look next

- Versions and backends: `config/mise/config.toml`.
- Cheatsheets: `cheat <tool>` (e.g. `cheat fd`, `cheat rg`), backed by
  `config/cheat/cheatsheets/`.
- All aliases: [../aliases.md](../aliases.md).
