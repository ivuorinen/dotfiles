# shellcheck shell=bash
# Shared path predicates for the PreToolUse guards. Sourced, never executed.
#
# One copy of the protected-path list and the secrets predicate, because the
# hand-kept copies in pre-edit-block.sh, pre-ctx-write-guard.sh and the rule
# prose drifted apart repeatedly (N-091, audit-2631ff95, audit-19fe64a4).
# tests/protected-paths-parity.bats checks every `paths:` entry in
# .claude/rules/vendored-files.md against the three hooks that source this.

# Vendored files, lock files and submodule trees: never edited in place.
# Unanchored on the left so it matches absolute paths (Edit/Write payloads) and
# relative ones (Bash and sandbox code). The right edge is bounded so
# `tools/dotbot` does not also claim a sibling such as `tools/dotbotx`.
# shellcheck disable=SC2034 # consumed by the scripts that source this file
PROTECTED_RE='(local/bin/fzf-tmux([^[:alnum:]._-]|$)|local/man/man1/fzf(-tmux)?\.1|config/fzf/(completion\.(bash|zsh)|key-bindings\.(bash|zsh|fish))|yarn\.lock|\.yarn/|tools/(dotbot|dotbot-include|antidote)([^[:alnum:]._-]|$)|config/cheat/cheatsheets/(community|tldr)([^[:alnum:]._-]|$)|config/fish/functions/(fisher\.fish|bass\.fish|__bass\.py|__z_add\.fish|__z_clean\.fish)|\.claude/skills/graphify/|local/bin/iterm2_shell_integration\.zsh)'

# secrets_referenced TEXT — succeed when TEXT names a secrets.d tree or any
# file in one other than a `*.example` template or README.md.
#
# Covers both credential trees — config/fish/secrets.d/ (fish) and
# config/secrets.d/ (bash/zsh) — because the fish-only predicates it replaces
# left the .sh tree unguarded (agent-loopholes-da375736). A bare directory, a
# glob (`secrets.d/*.fish`) or a variable (`secrets.d/$f`) all count: each
# expands to real secret files at run time.
#
# The matches are captured before the exemption filter runs: piping grep -o
# straight into grep -q lets the reader exit early, and under a caller's
# `set -o pipefail` the writer's SIGPIPE would turn a hit into a miss.
secrets_referenced()
{
  local refs
  refs=$(printf '%s\n' "$1" | grep -oE 'secrets\.d(/[^[:space:]"'\''`;|&<>()]*)?') || return 1
  printf '%s\n' "$refs" | grep -qvE '^secrets\.d/([[:alnum:]._-]+\.example|README\.md)$'
}
