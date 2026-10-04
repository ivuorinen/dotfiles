---
id: skill-safety-b74be0ad
auditor: skill-safety
severity: medium
category: security
area: .claude/skills/graphify
status: open
found: 2026-10-02
location: .claude/skills/graphify/.graphify_version:1-1
location_sha: 842026a49acbaa0c
---

# Vendored graphify skill (0.9.16) differs from the installed upstream copy (0.9.67) that shares its name; no pinned source to verify against

## Problem

Class: provenance-mismatch. vendored-files.md says the tree is "copied in from the plugin cache" and refreshed by re-copying, but no upstream reference or checksum is recorded, NOTICE says "license not recorded", and the copy on disk no longer matches the installed upstream. The user-level skill ~/.claude/skills/graphify carries the same `name: graphify`, so two different versions of one skill are in scope for every session in this repo and which one loads is decided by harness precedence, not by the repo.

## Evidence

.claude/skills/graphify/.graphify_version = `0.9.16`; ~/.claude/skills/graphify/.graphify_version = `0.9.67`. `diff -rq` reports SKILL.md, references/query.md, references/update.md and .graphify_version differ; SKILL.md has 51 differing lines (sample repo-only line: `save_manifest(detect.get('all_files') or detect['files'], root='INPUT_PATH')`). Tree added in one bulk commit bb0f328c (2026-07-15), never updated. NOTICE:33 `graphify skill -- license not recorded`. Mechanical triage over the tree: no zero-width/bidi characters; URL hosts only github.com and usage.jdx.dev; SKILL.md:88-93 runs `uv tool install --upgrade graphifyy` / `pip install ... --break-system-packages` (see the ctx policy-tier finding).

## Impact

The repo cannot show that its vendored instruction text equals any published version; drift from the installed package (0.9.67 CLI driven by 0.9.16 instructions) also risks wrong commands.

## Fix

Record provenance next to the tree: add upstream repo URL, the exact release tag, and a sha256 of SKILL.md and each references/*.md to NOTICE (or `.claude/skills/graphify/.graphify_source`). Re-copy from the installed 0.9.67 skill per vendored-files.md and update the checksums in the same commit. Add a pre-commit check that fails when the recorded checksums do not match the tree.
