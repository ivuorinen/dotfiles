---
description: "Shell command routing — ctx_batch_execute is the default tool for all commands producing output."
---

# Bash routing — ctx_batch_execute is the default

ALWAYS use `mcp__plugin_context-mode_context-mode__ctx_batch_execute` for shell
commands. The default tool for ANY shell invocation in this repo is
`ctx_batch_execute` — `Bash` is the exception, not the rule.

## The default rule

If a shell command produces output you intend to read, use
`ctx_batch_execute`. This includes:

- `rg`, `fd`, `grep`, `find` — every search.
- `shellcheck`, `shfmt --diff`, `fish_indent --check` — every lint/format check.
- `biome check`, `yamllint`, `actionlint`, `stylua --check` — every formatter check.
- `ruff check`, `ruff format --check` — every Python check.
- `prek run` (and `pre-commit run`), `yarn lint`, `yarn test` — every quality gate
  (the prefix match covers `yarn lint:ec`, `yarn lint:bandit`, and friends).
- `dfm <subcommand>` — dotfiles manager commands.
- `git log`, `git diff`, `git diff --stat`, `git show`, `git blame` — always.
  The hook lets `git status` (with or without `-s`) through as a one-line
  check, along with the state and plumbing subcommands on its allowlist;
  every other git subcommand is denied as a reader.
- `git-hunk list`/`show`/`diff`, `graphify query`/`path`/`explain`, and
  `gh api` / `gh pr view` and friends — readers the project rules mandate.
- `ls`, `tree`, `cat`, `head`, `tail`, `wc`, `less`, `more`, `awk`, `sed`,
  `jq`, `diff`, `bat`, `sort`, `cut`, `base64`, `stat`, `python3 -c` —
  anything reading or transforming file content for analysis.
- `which <tool>`, `<tool> --version` when probing more than one tool at once
  — batch the probes.
- `bash -c '<denied command>'` and `sh`/`zsh`/`dash`/`ksh` wrappers, including
  heredoc forms that hide a denied command inside an allowed one.

Even when output is short, batch related commands together: one
`ctx_batch_execute` call with five commands costs less than five `Bash`
calls.

## When Bash is acceptable

Only these narrow cases:

1. **Side-effect commands that produce no output you need to read:**
    `git-hunk commit <hash>... -m '...'`, `git-hunk add <hash>`, `git mv`,
    `git rm`, `git checkout <branch>`, `git push`, `git rebase` (including its
    `--continue`/`--skip`/`--abort` steps), `mkdir -p <dir>`, `chmod`,
    `chown`. `git add` and `git commit -a` are forbidden —
    `.claude/rules/git-hunk-commits.md`.
    The exit code is the signal; the stdout is irrelevant. The hook's git
    allowlist also passes plumbing queries (`rev-parse`, `ls-files`,
    `cat-file`, `check-ignore`, `config`) — they answer one question rather
    than producing a review.
2. **In-place formatters with no output to capture:**
    `fish_indent --write <file>`, `shfmt -w <file>`.
3. **Package installations that must stream output interactively:**
    `yarn install`, `yarn add <pkg>`, `brew install <pkg>`.
4. **A single one-line command the user names by tool in their most
    recent message** (e.g. they typed "run `yarn build`" in the
    immediately preceding turn) **whose expected output is under
    twenty lines.** A user instruction does not waive the routing
    rule for unbounded output. If the named command can emit more
    than ~twenty lines (`find /`, `rg` without `--max-count`,
    `git log` without `-n`), route it through `ctx_batch_execute`
    even when the user asked for it explicitly. Authorisation does
    not carry over from earlier in the session or from another
    conversation.

If you pipe through `head`, `tail`, or `grep` to truncate output, route
the command through `ctx_batch_execute` instead. The truncation is a
tell that the raw output is bigger than you want in chat context.

## Programmatic enforcement

A `PreToolUse` hook (`.claude/hooks/pre-bash-route.sh`, registered in
`.claude/settings.json` under matcher `Bash`) inspects every `Bash`
invocation and denies the call with an educational reason when the
command matches the routing rules above. The hook splits the command
on pipeline separators (`|`, `&&`, `||`, `;`, `&`), command
substitutions (`$( … )`, backticks), subshells and brace groups, and
drops leading shell keywords (`if`, `do`, `!`), then checks each
segment, so `git status | grep modified`, `echo $(rg foo src/)` and
`(cat README.md)` are all caught.

The same hook carries a policy tier that runs before any routing
decision: secrets paths, hook-bypass flags, network fetchers, npm/npx,
hand-run pip/uv installs, `git add`, and writes to vendored paths. The
policy tier is not a routing choice, so `BASH_OK` never overrides it.

The hook denies (not asks) so that `permissionDecisionReason` reaches
the model in-context, teaching it to route correctly on the next
turn. `ask` would only prompt the user silently and Claude would
learn nothing.

To override a routing deny for a single one-off call (case #4 above),
prepend `BASH_OK` to the command. The hook honours the marker only when
the command's name appears in the user's latest prompt, which
`.claude/hooks/prompt-record.sh` (a `UserPromptSubmit` hook) records in
the gitignored `.claude/.last-prompt`; otherwise it denies. It is the
escape hatch for the "user named it in this turn" case, not a general
opt-out. The hook cannot check the twenty-line output bound — that half
of case #4 stays on you. Settings.json `permissions.allow` entries do **not** override
the hook — the hook's `deny` takes precedence so user-allowlisted
patterns from earlier sessions are still routed through context-mode.

## Forbidden patterns

- `Bash` with `rg -n ... | head -20` — use `ctx_batch_execute` with a
  focused `queries:` array instead.
- Chaining many small `ctx_execute` calls — one `ctx_batch_execute` with
  multiple `commands` and `queries` is the right shape.
- `ctx_execute` / `ctx_execute_file` to write files — use `Write` / `Edit`.
- `WebFetch` for documentation — use `ctx_fetch_and_index`.

## Practical patterns

Investigation pass — one `ctx_batch_execute`, many queries:

```yaml
commands:
  - label: "shellcheck on changed scripts"
    command: "shellcheck local/bin/dfm local/bin/msgr"
  - label: "shfmt diff"
    command: "shfmt --diff local/bin/dfm"
  - label: "yamllint on install config"
    command: "yamllint install.conf.yaml"
queries:
  - "shellcheck errors"
  - "shfmt formatting differences"
  - "yamllint violations"
```

Lint pass — batch the full quality gate:

```yaml
commands:
  - label: "yarn lint"
    command: "yarn lint"
queries:
  - "lint errors"
  - "editorconfig violations"
```

Search pass — rg with follow-up:

```yaml
commands:
  - label: "functions referencing theme apply"
    command: "rg -n 'theme apply' config/fish/"
  - label: "handlers list"
    command: "ls config/theme/handlers.d/"
queries:
  - "theme apply callers"
  - "handler names"
```
