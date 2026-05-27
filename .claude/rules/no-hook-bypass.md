---
description: "Git and tool hook bypass prevention — no --no-verify or --no-gpg-sign flags."
alwaysApply: true
---

# Never bypass project hooks

Never invoke `git`, `npm`, `yarn`, `pre-commit`, or any other tool
with a flag that bypasses the project's hook chain. The forbidden
flags include — but are not limited to:

- `git commit --no-verify` / `git push --no-verify`
- `git commit --no-gpg-sign` / `-c commit.gpgsign=false`
- `pre-commit run --no-verify`
- Any option that disables a configured PreToolUse / PostToolUse /
  Stop hook in `.claude/settings.json` or in any active plugin's
  `hooks.json` (e.g. the context-mode plugin)
- Workarounds for `pre-bash-route.sh` other than the documented
  `BASH_OK` prefix (see `bash-routing.md`). Editing the hook script
  to broaden its allow list, removing the hook entry from
  `.claude/settings.json`, or using `Bash -c '…'` / heredoc tricks to
  hide a denied command inside an allowed one all count as bypass

If a hook fails, fix the underlying problem. The hook chain
(commitlint, shellcheck, shfmt, biome, prettier, yamllint,
actionlint, stylua, fish_indent, ruff, the `yarn lint` Stop gate)
is the project's quality bar — bypassing it pushes broken code
forward and creates work for the next contributor.

The single exception is an explicit user instruction in the current
conversation authorising a bypass for a named operation. An agent's
own judgement ("just this once") is not authorisation, and authorisation
from a prior session does not carry over. Without that explicit
instruction, the rule holds for every invocation.
