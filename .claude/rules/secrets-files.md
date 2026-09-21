---
description: "Secrets in secrets.d must never be committed or read directly, and stay owner-only on disk."
---

# Shell secrets

Two directories hold live credentials: `config/fish/secrets.d/`
(sourced by `config/fish/exports.fish`) and `config/secrets.d/`
(sourced by `config/exports` for bash and zsh).

- Never read, print, or echo a real secrets file — through `Read`,
  `Bash`, the ctx sandbox, or `ctx_index`. If you need a value, ask
  the user.
- Never commit anything under either directory except `*.example`
  files and `README.md`. `.gitignore` enforces this with `secrets.d/*`
  plus allowlist entries for the two exceptions.
- Secret directories are `0700` and secret files are `0600`. `dfm check
  perms --fix` repairs drift; `./install` runs it.

This rule loads every session rather than by path: a path-scoped rule
loads only after a matching file is read, which is the very read it
forbids.

## Enforcement

`.claude/hooks/lib/protected-paths.sh` (`secrets_referenced`) is the
one predicate: any reference to a `secrets.d` tree — a file, a glob, a
bare directory, a variable — other than a `*.example` template or
`README.md`. `pre-edit-block.sh` applies it to Read/Edit/Write,
`pre-ctx-write-guard.sh` to the sandbox tools and `ctx_index`, and
`pre-bash-route.sh` to every Bash command before its `BASH_OK` check.
Bypassing them is forbidden (`.claude/rules/no-hook-bypass.md`).

Creating a secret and the reasoning behind the modes: `docs/secrets.md`.
