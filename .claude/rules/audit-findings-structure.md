---
name: audit-findings-structure
description: Canonical heading hierarchy and required fields for docs/audit/*-findings.md
paths: ["docs/audit/*-findings.md"]
---

# Audit Findings Structure

All `docs/audit/*-findings.md` files must follow the exact heading hierarchy and
field template below. The `post-edit-audit-findings-lint.sh` hook validates this on
every edit and blocks saves that violate the structure.

## Header block

Immediately after `# Nitpicker Findings`, write exactly these three metadata lines
(no other content, in this order):

```
Generated: YYYY-MM-DD
Last validated: YYYY-MM-DD
Last pass: N (YYYY-MM-DD)
```

`Last pass: N (YYYY-MM-DD)` means the pass number and the date it ran —
e.g. `Last pass: 15 (2026-05-19)`. No prose, no scope summaries, no per-pass
narrative in the header block. Pass history belongs in the `## Fixed` section.

## Status JSON sidecar

`.claude/nitpicker-status.json` must be kept in sync with the findings file.
Update it every time the header or summary changes. The hook regenerates it
automatically on every save of the findings file.

```json
{
  "generated": "YYYY-MM-DD",
  "last_validated": "YYYY-MM-DD",
  "last_pass": N,
  "last_pass_date": "YYYY-MM-DD",
  "summary": {
    "total": N,
    "open": N,
    "fixed": N,
    "invalid": N
  }
}
```

## Required top-level sections (in order)

1. `# Nitpicker Findings` — h1 title (followed immediately by the three-line header block)
2. `## Summary` — one bullet: `- Total: N | Open: N | Fixed: N | Invalid: N`
3. `## Open Findings` — contains severity subsections as h3
4. `## Fixed` — contains pass subsections as h3
5. `## Invalid` — contains pass subsections as h3

Each of these five h2 sections must appear exactly once. Never duplicate them.

## Open Findings structure

Severity levels are h3 subsections inside `## Open Findings`:

```
## Open Findings

### Critical

#### [N-XXX] Short title
Category: <correctness|security|reliability|maintainability|performance|tests|docs|conventions>
Area: <path-or-scope>
Problem: <direct description>
Evidence: <proof or failing scenario>
Impact: <why this matters>
Fix: <concrete remediation>

### High
[same six fields]

### Advisory
[same six fields]
```

`### Advisory` lives inside `## Open Findings`. Never write `## Advisory`.
Every open finding — including Advisory — must carry all six fields.

## Fixed and Invalid structure

Pass entries are h3 subsections inside `## Fixed` and `## Invalid`:

```
## Fixed

### Pass N — YYYY-MM-DD

#### [N-XXX] Short title
Fixed: YYYY-MM-DD
Notes: <what changed>

## Invalid

### Pass N — YYYY-MM-DD

#### [N-XXX] Short title
Notes: <why this finding was wrong>
```

All fixed findings go under one `## Fixed` h2, sub-divided by `### Pass N` h3s.
All invalid findings go under one `## Invalid` h2, sub-divided by `### Pass N` h3s.
Never create `## Fixed — Pass N` variants (that duplicates the h2).

## Heading hierarchy rule

Every h4 (`####`) must have an h3 (`###`) parent within the same section. The
sequence h2 → h4 with no h3 between them is a structural gap that the lint hook
will block. Check your heading nesting before saving.

## Summary format

The summary line must use exactly:

```
- Total: N | Open: N | Fixed: N | Invalid: N
```

No additional columns. Advisory findings are a severity level within Open — they
count toward the Open total, not in a separate column.

## Finding IDs

IDs are sequential integers with an `N-` prefix (`N-001`, `N-002`, ...). Never
reuse an ID. Assign the next available integer regardless of which section the
finding goes into.
