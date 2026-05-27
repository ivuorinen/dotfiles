# Read routing — ctx_execute_file is the default for analysis

Every byte `Read` returns enters the conversation and stays there for
the rest of the session. `ctx_execute_file` runs code in the sandbox
and only what you `print()` enters context. Default to the sandbox
for any read whose purpose is anything other than a follow-up `Edit`.

This rule is the Read-side companion to `bash-routing.md`. Same
discipline, different tool.

## The default rule

If a file read produces output you intend to **analyze, summarise,
extract from, count, search within, parse, or reason about the
structure of**, use `ctx_execute_file(path, language, code)`. Only
your printed answer enters context.

`Read` is correct in exactly these cases:

1. **You are about to `Edit` the file.** `Edit` matches `old_string`
    against the bytes in your conversation, so those bytes must be
    there. Read the line range you need, no more.
2. **The file is under ~50 lines AND you need every line for the
    response.** Below that threshold the sandbox round-trip costs as
    much as the bytes themselves; above it the bytes dominate.
3. **You must quote the file verbatim to the user.** Even then, use
    `ctx_execute_file` + `print()` of the slice; only fall back to
    `Read` when the full bytes are essential to the response.

If none of those three apply, you are in default-rule territory and
must route through the sandbox.

## Forbidden patterns

- `Read` a config file → describe what's in it.
  → `ctx_execute_file` with a parser.
- `Read` a script → summarise what it does.
  → `ctx_execute_file` with a line-by-line scan that prints only the
    sections you'll discuss.
- `Read` a file, then `Read` it again to find a specific section.
  → One `ctx_execute_file` call with the slice logic built in.
- `Read` a 200-line YAML to "see what's defined".
  → `ctx_execute_file` with a YAML parser, print the keys.
- `Read` a Brewfile to identify tool candidates.
  → `ctx_execute_file` with a regex extractor, print only matches.
- `Read offset=N limit=M` to truncate a large file's window into
  context. The truncation is a tell that the file is too big to read
  whole — route the analysis through the sandbox instead.

## Practical patterns

Identify CLI tools (vs libraries) in a Brewfile:

```python
import re
with open("config/homebrew/Brewfile") as f:
    for line in f:
        m = re.match(r'brew "([^"]+)"', line)
        if m:
            print(m.group(1))
```

Parse mise tool entries:

```python
import re
with open("config/mise/config.toml") as f:
    for line in f:
        m = re.match(r'"?([\w:./-]+)"?\s*=\s*"([^"]+)"', line)
        if m:
            print(f"{m.group(1)}={m.group(2)}")
```

Summarise a long markdown doc:

```python
with open("docs/audit/foo.md") as f:
    section = None
    for line in f:
        if line.startswith("#"):
            section = line.strip()
            print(section)
```

## Why there is no PreToolUse hook

`Read` is heavily used for legitimate Edit prep, where the bytes
genuinely must be in context. A hook cannot tell intent from input.
The PreToolUse:Read hook surfaces a one-line tip every invocation
instead — treat that tip as a checklist, not background noise.

The discipline is the safety net. Same shape as
`no-schema-guessing.md`: the rule exists because no automated gate
will catch the failure mode for you.

## Cost model

A 400-line `Read` consumes ~5 KB of cache plus the same in input
tokens. A `ctx_execute_file` returning ten lines of summary consumes
~150 bytes. Multiply across a session and the cheap path keeps the
conversation focused; the expensive path forces earlier compaction
and degrades recall of the work that actually mattered.
