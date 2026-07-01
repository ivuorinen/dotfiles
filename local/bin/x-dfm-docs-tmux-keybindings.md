# x-dfm-docs-tmux-keybindings

Regenerate `docs/tmux-keybindings.md` from `tmux list-keys`.

The doc lists **every** registered binding in **every** key table
(`prefix`, `root`, `copy-mode`, `copy-mode-vi`, and any others tmux
reports), including the built-in defaults — not just the keys that carry
a note.

## Usage

```bash
x-dfm-docs-tmux-keybindings
```

Usually invoked as `dfm helpers docs-tmux`. No parameters are needed. The script
writes the file under `docs/` and overwrites any existing version.

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
