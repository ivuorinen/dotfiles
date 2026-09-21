---
id: agent-rules-296b9ec8
auditor: agent-rules
severity: advisory
category: conventions
area: .claude/rules/context-mode.md
status: open
found: 2026-09-17
---

# Reply-length and artifact-delivery constraints are user preferences, better as user-level rules

## Problem

"Keep responses under 500 words" and "Write artifacts (code, configs, PRDs) to FILES — never return them as inline text" carry no project-specific justification; they describe how the user wants replies, in every repo.

## Evidence

`.claude/rules/context-mode.md` § "Output constraints"; memory `feedback_style.md` records the same brevity preference as a user trait.

## Impact

Project-committed personal preferences apply to any contributor or agent session in this repo and are absent from the user's other repos.

## Fix

Move both lines to `~/.claude/CLAUDE.md` (or `~/.claude/rules/response-format.md`) and delete the section from the project rule.

## Status (2026-09-21)

Project half applied: the section is gone from `context-mode.md` (only the ctx index-label line stayed, as a routing concern). The user chose `~/.claude/CLAUDE.md` as the destination, but the session blocks reads outside the working directory, so the append was handed to the user. Resolve once both lines are in the global file.
