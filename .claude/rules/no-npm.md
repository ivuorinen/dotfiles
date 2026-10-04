---
description: "Package manager constraint: yarn v4+ only, never npm."
---

# Package manager

Use `yarn` (v4+), never `npm`.

The repo uses Yarn Berry. Running `npm install` corrupts the
lockfile and bypasses the workspace resolver. `pre-bash-route.sh`
(Bash) and `pre-ctx-write-guard.sh` (context-mode sandbox code) deny
`npm`, `npx`, `pnpm` and `pnpx` via `.claude/hooks/lib/bash-policy.sh`
(and `BASH_OK` does not override it); `pre-edit-block.sh` blocks edits to `yarn.lock` and
`.yarn/`. Bypassing either hook is itself forbidden
(`.claude/rules/no-hook-bypass.md`). The ban is by command name: the name
as a word of its own anywhere in a command counts as running it, behind any
runner (`mise exec --`, `doppler run --`, `direnv exec .`), except in a
lookup that never executes it (`command -v npm`, `rg npm docs/`). A config
or environment value counts too (`git -c core.pager=npx`, `EDITOR=npx`).

Use `yarn add` / `yarn remove` / `yarn dlx` instead of their npm
equivalents. For one-off scripts: `yarn dlx <package>`, never
`npx <package>`.
