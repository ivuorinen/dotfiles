---
description: "MCP routing rules for context window protection — curl, WebFetch, Bash, and Read tool routing."
alwaysApply: true
---

# context-mode — mandatory routing rules

context-mode MCP tools protect the context window from flooding. A
single unrouted command can dump 56 KB into context and waste the
session. These rules are not optional.

## BLOCKED commands — never attempt these

### curl / wget

Never run a Bash command containing `curl` or `wget`. The hook
intercepts them and replaces the output with an error. Do not retry.
Use instead:

- `ctx_fetch_and_index(url, source)` — fetch and index web pages
- `ctx_execute(language: "javascript", code: "const r = await fetch(...)")`
  — run HTTP calls in sandbox

### Inline HTTP

Never run a Bash command containing `fetch('http`, `requests.get(`,
`requests.post(`, `http.get(`, or `http.request(`. The hook
intercepts and replaces with an error. Do not retry with Bash.
Use `ctx_execute(language, code)` to run HTTP calls in the sandbox —
only stdout enters context.

### WebFetch

WebFetch is denied entirely. The hook extracts the URL and tells you
to use `ctx_fetch_and_index` instead. Then `ctx_search(queries)` to
query the indexed content.

## REDIRECTED tools — use sandbox equivalents

### Bash shell commands

The authoritative Bash routing rule is in `.claude/rules/bash-routing.md`,
and it is enforced programmatically by the `.claude/hooks/pre-bash-route.sh`
`PreToolUse` hook. `ctx_batch_execute` is the default for any command that
produces output you intend to read.

The following invocations are denied by the hook and must be routed through
`ctx_batch_execute` (or `ctx_execute(language: "shell", …)` for a single
command):

- Searches — `rg`, `grep`, `fd`, `find`
- Lint/format checkers — `shellcheck`, `shfmt --diff`, `fish_indent --check`,
  `biome check`, `yamllint`, `actionlint`, `stylua --check`, `ruff check`,
  `ruff format --check`, `pre-commit run`, `yarn lint`/`yarn test`/`yarn check`
- File readers — `cat`, `head`, `tail`, `wc`, `ls`, `tree`, `less`, `more`,
  `awk`, `sed`, `jq` (when emitting output to read)
- Git readers — `git log`, `git diff`, `git show`, `git blame`, `git status`
  (any flag)
- Dotfiles manager — `dfm <subcommand>` for any subcommand
- Pipeline/subshell variants of the above (`git status | grep …`,
  `echo $(rg …)`, `false || cat file`) — the hook splits on `|`, `&&`,
  `||`, `;`, `$( )`, and backticks before matching.

These pass through the hook unchanged (state mutations, in-place formatters,
package installs, short interactive ops):

- `git add`/`commit`/`mv`/`rm`/`checkout`/`push`/`fetch`/`reset`/`stash`/
  `tag`/`merge`/`remote`/`submodule`/etc. (mutation subcommands only)
- `mkdir`, `chmod`, `chown`, `mv`, `rm`, `cp`, `touch`, `ln`
- `fish_indent --write`, `shfmt -w`
- `yarn install`/`add`/`remove`/`dlx`, `brew install`/`upgrade`,
  `mise install`/`upgrade`
- `cd`, `pwd`, `whoami`, `date`, `echo`, `printf`, `export`, `source`

`bash-routing.md` carries the full rationale and the one-off `BASH_OK`
escape hatch for the "user named it in this turn" case.

### Read for analysis

Reading a file to **Edit** it → Read is correct (Edit needs content
in context). Reading to **analyze, explore, or summarize** → use
`ctx_execute_file(path, language, code)` instead. Only your printed
summary enters context.

Full Read-vs-sandbox routing rules live in
`.claude/rules/read-routing.md`, including the three narrow cases
where Read remains correct, the forbidden patterns, and the cost
model. That file is to Read what `bash-routing.md` is to Bash.

### Grep with large results

Grep results can flood context. Use
`ctx_execute(language: "shell", code: "grep ...")` to run searches in
the sandbox. Only your printed summary enters context.

## Tool selection hierarchy

1. **GATHER**: `ctx_batch_execute(commands, queries)` — primary tool.
    Runs all commands, auto-indexes output, returns search results.
    ONE call replaces 30+ individual calls.
2. **FOLLOW-UP**: `ctx_search(queries: ["q1", "q2", ...])` — query
    indexed content. Pass ALL questions as one array in ONE call.
3. **PROCESSING**: `ctx_execute(language, code)` /
    `ctx_execute_file(path, language, code)` — sandbox execution. Only
    stdout enters context.
4. **WEB**: `ctx_fetch_and_index(url, source)` then
    `ctx_search(queries)` — fetch, chunk, index, query. Raw HTML never
    enters context.
5. **INDEX**: `ctx_index(content, source)` — store content in FTS5
    knowledge base for later search.

## Subagent routing

When spawning subagents (Agent/Task tool), the routing block is
automatically injected into their prompt. Bash-type subagents are
upgraded to general-purpose so they have access to MCP tools. Do NOT
manually instruct subagents about context-mode.

## Output constraints

- Keep responses under 500 words.
- Write artifacts (code, configs, PRDs) to FILES — never return them
  as inline text. Return only: file path + 1-line description.
- When indexing content, use descriptive source labels so others can
  `ctx_search(source: "label")` later.

## ctx commands

| Command       | Action                                                                                |
|---------------|---------------------------------------------------------------------------------------|
| `ctx stats`   | Call the `ctx_stats` MCP tool and display the full output verbatim                    |
| `ctx doctor`  | Call the `ctx_doctor` MCP tool, run the returned shell command, display as checklist  |
| `ctx upgrade` | Call the `ctx_upgrade` MCP tool, run the returned shell command, display as checklist |
