---
description: "Node CLIs come from mise; never npm, npx or pnpm."
---

# Node tools

This repo has no `package.json` and no JavaScript package manager. Every
Node CLI it uses (prettier, markdownlint, v8r, …) is pinned in `.mise.toml`
through mise's `npm:` backend, and the lint, fix and test commands are mise
tasks (`mise tasks` lists them).

- Add a Node CLI as `"npm:<package>" = "<version>"` in `.mise.toml` (and in
  `config/mise/config.toml` when a shell outside the repo needs it too).
- Run a one-off with `mise exec -- <tool>`, never `npx <package>`.
- Never `npm install`, `npm run`, `npx`, `pnpm` or `pnpx`.

`pre-bash-route.sh` (Bash) and `pre-ctx-write-guard.sh` (context-mode sandbox
code) deny `npm`, `npx`, `pnpm` and `pnpx` via
`.claude/hooks/lib/bash-policy.sh` (and `BASH_OK` does not override it).
Bypassing either hook is itself forbidden (`.claude/rules/no-hook-bypass.md`).
The ban is by command name: the name as a word of its own anywhere in a
command counts as running it, behind any runner (`mise exec --`,
`doppler run --`, `direnv exec .`), except in a lookup that never executes it
(`command -v npm`, `rg npm docs/`). A config or environment value counts too
(`git -c core.pager=npx`, `EDITOR=npx`).
