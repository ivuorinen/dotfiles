---
description: "Package manager constraint: yarn v4+ only, never npm."
alwaysApply: true
---

# Package manager

Use `yarn` (v4+), never `npm`.

The repo uses Yarn Berry. Running `npm install` corrupts the
lockfile and bypasses the workspace resolver. The PreToolUse hook
blocks edits to `yarn.lock` and `.yarn/`; bypassing that hook is
itself forbidden (`.claude/rules/no-hook-bypass.md`).

Use `yarn add` / `yarn remove` / `yarn dlx` instead of their npm
equivalents. For one-off scripts: `yarn dlx <package>`, never
`npx <package>`.
