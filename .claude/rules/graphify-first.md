---
description: "Query the graphify knowledge graph before browsing source; update it after code changes."
---

# graphify before raw source

For any question about this codebase — architecture, file relationships,
where something lives — run `graphify query "<question>"` first whenever
`graphify-out/graph.json` exists. Use `graphify path "<A>" "<B>"` for
relationships and `graphify explain "<concept>"` for a focused concept.
These return a scoped subgraph, far smaller than `GRAPH_REPORT.md` or raw
grep output.

Use `graphify-out/wiki/index.md` for broad navigation when it exists, never
raw source browsing.

Read `graphify-out/GRAPH_REPORT.md` only for broad architecture review, or
when query/path/explain did not surface enough context.

After modifying code, run `graphify update .` to keep the graph current
(AST-only, no API cost).

When the user types `/graphify`, invoke the graphify skill
(`.claude/skills/graphify/SKILL.md`) before anything else.

A `PreToolUse` hook on `Read` restates the first mandate on every file read;
the rule is the reason the hook exists, not a duplicate of it. Pass the same
instruction to subagents doing code exploration.
