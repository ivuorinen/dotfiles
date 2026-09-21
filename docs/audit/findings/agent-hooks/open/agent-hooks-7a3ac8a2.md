---
id: agent-hooks-7a3ac8a2
auditor: agent-hooks
severity: high
category: security
area: .github/copilot-instructions.md
status: open
found: 2026-09-17
---

# Copilot cloud agent runs with no hooks: every guard is prose-only and the prose is stale

## Problem

Class: harness-mismatch. `.github/copilot-instructions.md` targets "GitHub Copilot Cloud Agent" and states mandates ("Files You Must NOT Modify", "MANDATORY: Run `yarn lint` before every commit"). Per GitHub's hooks reference, cloud agent loads hook configuration only from `.github/hooks/*.json`, and "Cloud agent does not load `settings.json`" — so none of `.claude/settings.json`'s guards run for it. `.github/hooks/` does not exist. The prose itself has drifted: the must-not-modify table lists only `local/bin/fzf-tmux` among vendored files (not the other fzf files, graphify, iTerm2, fish plugins, `config/secrets.d/*.sh`), POSIX scripts are listed as five (nine exist), and single-file test runs use `./node_modules/.bin/bats`.

## Evidence

Fetched this session, docs.github.com/en/copilot/reference/hooks-configuration: "**Copilot cloud agent** — … Hook configuration is loaded from `.github/hooks/*.json` files in the cloned repository." and "Cloud agent does not load `settings.json`."
`ls .github/hooks` → No such file or directory.
`.github/copilot-instructions.md:1` title; `:143-151` must-not-modify table; `:157-159` five POSIX scripts; `:50,181` `./node_modules/.bin/bats`.

## Impact

A Copilot cloud agent job can read/edit secrets, overwrite vendored files, and commit without lint, with no deterministic guard, in the same repo where the Claude session is hook-guarded.

## Fix

Add `.github/hooks/guards.json` (version 1) using the documented Claude-compatible PascalCase form so the existing scripts receive `tool_name`/`tool_input`: `{"version":1,"hooks":{"PreToolUse":[{"type":"command","matcher":"Edit|Write|Read","bash":"CLAUDE_PROJECT_DIR=/workspace .claude/hooks/pre-edit-block.sh","cwd":"/workspace","timeoutSec":10},{"type":"command","matcher":"Bash","bash":"CLAUDE_PROJECT_DIR=/workspace .claude/hooks/pre-bash-route.sh","cwd":"/workspace","timeoutSec":10}]}}`. Confirm the `matcher` field name for command entries against the fetched reference before committing (no-schema-guessing.md). Regenerate the must-not-modify table from `vendored-files.md` + `secrets-files.md` and replace `./node_modules/.bin/bats` with `bats`. Proof: run a cloud agent task that attempts `Edit local/bin/fzf-tmux` and show the deny in the session log; until then this finding stays open.

## Status (2026-09-21)

Prose half applied: the must-not-modify table now covers every vendored group and both secrets trees and points at the two rule files as authority; the POSIX list defers to `posix-scripts.md` (nine scripts); both `./node_modules/.bin/bats` lines use bare `bats`.

Hooks half NOT applied. The reference (re-fetched 2026-09-21) confirms `matcher`, `bash`, `cwd`, `timeoutSec`, PascalCase `PreToolUse` with Claude tool names, and top-level `permissionDecision` output — but types `tool_input` as `unknown` and documents no argument names for `view`/`edit`/`create`/`bash`. `pre-edit-block.sh` reads `.tool_input.file_path` and fails closed without it, so wiring it on a guessed payload either denies every cloud-agent edit (if the field is `path`) or works; no-schema-guessing.md forbids shipping on the guess. Next step: capture one real PreToolUse payload from a cloud-agent run (an `http` hook to an allow-listed host, since the sandbox filesystem is discarded), then add `.github/hooks/guards.json` plus a small adapter that maps the observed argument names and translates `hookSpecificOutput` into the top-level decision.
