# Daily-driver tools

Practical, setup-specific notes for the tools this dotfiles repo relies
on every day. These are not upstream manuals — they document **how the
tools are wired here** and the handful of commands that matter in
practice. For exhaustive reference, see each tool's own docs.

Everything in `config/mise/config.toml` is installed and pinned by
**mise** (see below), so `which <tool>` will resolve to a mise shim
rather than a Homebrew path.

## Guides

| Tool                               | What it is                           | Doc                                    |
|------------------------------------|--------------------------------------|----------------------------------------|
| mise                               | Unified runtime & CLI-tool manager   | [mise.md](mise.md)                     |
| gopass                             | `pass`-compatible password manager   | [gopass.md](gopass.md)                 |
| git-profile                        | Per-repo Git identity switching      | [git-profile.md](git-profile.md)       |
| sesh                               | Smart tmux session manager           | [sesh.md](sesh.md)                     |
| eza, bat, fd, ripgrep, zoxide, fzf | Modern CLI replacements & navigation | [cli-essentials.md](cli-essentials.md) |

## Related

- `dfm help` — the dotfiles manager (install, brew/apt, checks, docs).
- [../commands.md](../commands.md) — repo lint/format/test workflows.
- [../alias.md](../alias.md) — every shell alias defined in `config/alias`.
- `config/cheat/cheatsheets/` — `cheat <tool>` cheatsheets for many of
  these tools.
