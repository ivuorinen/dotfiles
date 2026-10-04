---
id: skill-safety-c89685a4
auditor: skill-safety
severity: low
category: security
area: .claude/skills/adversarial-reviewer
status: open
found: 2026-10-02
location: .claude/skills/adversarial-reviewer/SKILL.md:1-5
location_sha: c000f8a7faca4344
---

# adversarial-reviewer skill has no recorded origin; it arrived inside an unrelated mise commit

## Problem

Class: provenance-unrecorded. Under the trust model a unit is installed unless history shows it was authored incrementally. This skill appeared whole in a squash-merged commit about a mise Python arch helper, has never been modified since, is generic (web-application checklist, no repo-specific content), and is listed in neither NOTICE nor vendored-files.md.

## Evidence

`git log --diff-filter=A -- .claude/skills/adversarial-reviewer/` → ff8a1427 2026-04-17 "feat(mise): add MISE_PYTHON_PRECOMPILED_ARCH detection helper (#344)" (1 commit total touching the dir). SKILL.md:3 `description: Deterministic adversarial code review focused on provable failures. Optimized for agent execution, minimal tokens, and high signal findings across web applications.` Body read in full (4104 bytes): no override, concealment, exfiltration, credential or command content; "Silence = approval." / "If unsure → omit." are review-scope directives.

## Impact

No source to compare against or refresh from; a future modification cannot be distinguished from upstream content.

## Fix

If it was copied from an upstream, add its source URL, version and license to NOTICE and list it under vendored-files.md (and PROTECTED_RE). If it was written here, say so in NOTICE or a one-line header comment so the authored classification is recorded.
