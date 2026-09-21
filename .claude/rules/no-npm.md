---
description: "Package manager constraint: yarn v4+ only, never npm."
---

# Package manager

Use `yarn` (v4+), never `npm`.

The repo uses Yarn Berry. Running `npm install` corrupts the
lockfile and bypasses the workspace resolver. `pre-bash-route.sh`
denies `npm`, `npx`, `pnpm` and `pnpx` on `Bash` (and `BASH_OK` does not
override it); `pre-edit-block.sh` blocks edits to `yarn.lock` and
`.yarn/`. Bypassing either hook is itself forbidden
(`.claude/rules/no-hook-bypass.md`).

Use `yarn add` / `yarn remove` / `yarn dlx` instead of their npm
equivalents. For one-off scripts: `yarn dlx <package>`, never
`npx <package>`.
