# Never bypass project hooks

Never invoke `git`, `npm`, `yarn`, `pre-commit`, or any other tool
with a flag that bypasses the project's hook chain. The forbidden
flags include — but are not limited to:

- `git commit --no-verify` / `git push --no-verify`
- `git commit --no-gpg-sign` / `-c commit.gpgsign=false`
- `pre-commit run --no-verify`
- Any option that disables a configured PreToolUse / PostToolUse /
  Stop hook in `.claude/settings.json`

If a hook fails, fix the underlying problem. The hook chain
(commitlint, shellcheck, shfmt, biome, prettier, yamllint,
actionlint, stylua, fish_indent, ruff, the `yarn lint` Stop gate)
is the project's quality bar — bypassing it pushes broken code
forward and creates work for the next contributor.

This rule is unconditional. There is no "just this once" exception:
the user must explicitly authorise a bypass in the conversation
before any `--no-verify`-style flag is used.
