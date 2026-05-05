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

### Bash (>20 lines output)

Bash is ONLY for: `git`, `mkdir`, `rm`, `mv`, `cd`, `ls`, `npm install`,
`pip install`, and other short-output commands. For everything else:

- `ctx_batch_execute(commands, queries)` — run multiple commands +
  search in ONE call
- `ctx_execute(language: "shell", code: "...")` — run in sandbox; only
  stdout enters context

### Read for analysis

Reading a file to **Edit** it → Read is correct (Edit needs content
in context). Reading to **analyze, explore, or summarize** → use
`ctx_execute_file(path, language, code)` instead. Only your printed
summary enters context.

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
