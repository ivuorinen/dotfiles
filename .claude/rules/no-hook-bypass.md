---
description: "Git and tool hook bypass prevention — no --no-verify or --no-gpg-sign flags."
---

# Never bypass project hooks

Never invoke `git`, `npm`, `yarn`, `pre-commit`, or any other tool
with a flag that bypasses the project's hook chain. The forbidden
flags include — but are not limited to:

- `git commit --no-verify` / `git push --no-verify`
- `git commit -n` (the short form of `--no-verify`)
- `git commit --no-gpg-sign` / `-c commit.gpgsign=false`
- `git config core.hooksPath …` and `prek uninstall` / `pre-commit uninstall`
- A config file that can carry `core.hooksPath`: `-c include.path=…`,
  `-c includeIf.*`, or `git config include.path …`
- A git alias, which renames a subcommand past the checks: `-c alias.*`,
  `--config-env=alias.*`, or `git config alias.* …`
- `pre-commit run --no-verify`
- Environment that skips hooks: `SKIP=<hook-ids>`,
  `PRE_COMMIT_ALLOW_NO_CONFIG`, `GIT_CONFIG_COUNT` /
  `GIT_CONFIG_KEY_<n>` / `GIT_CONFIG_PARAMETERS` setting `core.hooksPath`,
  and `GIT_CONFIG_GLOBAL` / `GIT_CONFIG_SYSTEM` / `GIT_CONFIG` pointing
  git at a config file
- Removing or overwriting files under `.git/hooks/`, or editing
  `.git/config` by hand
- Any option that disables a configured PreToolUse / PostToolUse /
  Stop hook in `.claude/settings.json` or in any active plugin's
  `hooks.json` (e.g. the context-mode plugin)
- Workarounds for `pre-bash-route.sh` other than the documented
  `BASH_OK` prefix (see `bash-routing.md`). Editing the hook script
  to broaden its allow list, removing the hook entry from
  `.claude/settings.json`, or using `Bash -c '…'` / heredoc tricks to
  hide a denied command inside an allowed one all count as bypass

`pre-bash-route.sh` denies the git and hook-runner forms above before
its `BASH_OK` check, so the escape cannot override them, and
`pre-ctx-write-guard.sh` denies the same forms in context-mode sandbox
code (both call `.claude/hooks/lib/bash-policy.sh`). Reads pass:
`git config --get core.hooksPath` and `--get-regexp alias` set nothing.
A persistent alias is resolved with `git config --get alias.<name>` and
its expansion checked as the command that runs. A `git`, `pip`, `python`,
`uv` or hook-runner word anywhere in a command's argv is checked as the
start of a command, so `mise exec --`, `setsid` or `flock FILE` in front
hides nothing; neither does a runner of any other name. A tool banned by
name alone (`curl`, `npm`) counts as run wherever it stands as a word of its
own, and a shell `-c` string, `eval` words and `VAR=value` words behind a
runner are checked as they are at the front, except in a lookup that never
executes an operand (`which`, `rg`, `git log`). The value half of every
`KEY=VALUE` word — an assignment, an `env` operand, `git -c key=value`, a
`git config` value — is parsed as a command and held to the same checks,
since pagers, editors and `GIT_SSH_COMMAND` run it. So is the value of an
option the tool runs as a command — `git grep -O`/`--open-files-in-pager`,
`man -P`/`--pager`, `rg --pre`, `fd -x`/`-X`/`--exec` — and any of these ends
a lookup's exemption. A git `-m`/`--message` value is message text and is
never read as a command.

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
