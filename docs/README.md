# Documentation index

Documentation for this dotfiles repo. Browse it here or with
`dfm docs` — the menu lists every file in this folder and
`dfm docs <name>` renders one (glow → bat → cat, whichever exists).
Generated files are rebuilt with `dfm helpers docs-<name>`; the rest
are hand-written.

## Tool guides

Practical, setup-specific notes for the daily-driver tools. These are
not upstream manuals — they document **how the tools are wired here**
and the handful of commands that matter in practice. Everything in
`config/mise/config.toml` is installed and pinned by **mise**, so
`which <tool>` resolves to a mise shim rather than a Homebrew path.

| Tool                               | What it is                           | Doc                                    |
|------------------------------------|--------------------------------------|----------------------------------------|
| mise                               | Unified runtime & CLI-tool manager   | [mise.md](mise.md)                     |
| gopass                             | `pass`-compatible password manager   | [gopass.md](gopass.md)                 |
| git-profile                        | Per-repo Git identity switching      | [git-profile.md](git-profile.md)       |
| sesh                               | Smart tmux session manager           | [sesh.md](sesh.md)                     |
| eza, bat, fd, ripgrep, zoxide, fzf | Modern CLI replacements & navigation | [cli-essentials.md](cli-essentials.md) |

## Repo reference

- [commands.md](commands.md) — repo lint/format/test workflows.
- [folders.md](folders.md) — interesting folders in this repo.
- [shell.md](shell.md) — shell keybindings.
- [tv.md](tv.md) — television (tv) channels and triggers.

## Generated reference

Regenerate with `dfm helpers docs-all` (or the per-file variant).

- [aliases.md](aliases.md) — every shell alias across bash, zsh, and fish.
- [nvim-keybindings.md](nvim-keybindings.md) — Neovim keybindings.
- [tmux-keybindings.md](tmux-keybindings.md) — tmux keybindings.
- [wezterm-keybindings.md](wezterm-keybindings.md) — wezterm keybindings.

## Related

- `dfm help` — the dotfiles manager (install, brew/apt, checks, docs).
- `config/cheat/cheatsheets/` — `cheat <tool>` cheatsheets for many of
  these tools.
- `audit/` — findings reports written by the audit skills; not part of
  the browsable docs.
