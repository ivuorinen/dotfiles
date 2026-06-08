#!/usr/bin/env bash
# Pre-tool guard: route output-producing Bash commands to ctx_batch_execute.
#
# Reads Claude Code PreToolUse JSON on stdin, inspects tool_input.command,
# and emits a `deny` decision (with educational reason) when the command
# matches a pattern that .claude/rules/bash-routing.md flags as belonging
# in context-mode. State-mutation commands, in-place formatters, and
# package installs pass through unblocked.
#
# Hook contract: print hookSpecificOutput JSON on stdout, exit 0.
# (Exit 0 with no JSON = no decision; the normal permission flow applies.)

set -u

# Read input; bail out cleanly if jq is unavailable or input is empty/malformed.
if ! command -v jq > /dev/null 2>&1; then
  exit 0
fi

input=$(cat)
command=$(printf '%s' "$input" | jq -r '.tool_input.command // ""' 2> /dev/null)

[[ -z "$command" ]] && exit 0

# Magic opt-out marker as the first token of the command. The escape strips
# the BASH_OK prefix via `updatedInput` and returns `allow` so the underlying
# command actually runs (the shell would otherwise try to execute BASH_OK as a
# command name and fail with "command not found"). Only the leading marker
# triggers the escape — a command that incidentally contains BASH_OK as a
# value or symbol name doesn't bypass.
if printf '%s' "$command" | grep -qE '^[[:space:]]*BASH_OK[[:space:]]+'; then
  stripped=$(printf '%s' "$command" | sed -E 's/^[[:space:]]*BASH_OK[[:space:]]+//')
  jq -n --arg cmd "$stripped" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "allow",
      permissionDecisionReason: "BASH_OK escape — bypassing bash-routing.md hook for this one call.",
      updatedInput: { command: $cmd }
    }
  }'
  exit 0
fi

# Allowlist: commands that mutate state, format in place, install packages, or
# perform short interactive operations. First word of each pipeline segment is
# checked against this set.
allow_first_word_re='^(git|mkdir|chmod|chown|mv|rm|cp|touch|ln|unlink|rmdir|fish_indent|shfmt|yarn|brew|mise|cd|pwd|whoami|date|echo|printf|true|false|exit|return|export|unset|source|\.|alias|unalias|umask)$'

# Allowlist: specific git subcommands that mutate state. Output-readers like
# `git log`, `git diff`, `git show`, `git blame` are explicitly _not_ here.
allow_git_subcmd_re='^(add|commit|mv|rm|checkout|push|fetch|reset|restore|stash|tag|init|clone|branch|merge|remote|cherry-pick|revert|switch|am|apply|format-patch|gc|prune|reflog|worktree|notes|submodule|rerere|update-ref|symbolic-ref|update-index|hash-object|cat-file|rev-parse|rev-list|ls-files|check-ignore|config)$'

# Denylist: first-word commands that almost always produce reviewable output.
# Includes `bash`/`sh`/`zsh`/`dash`/`ksh` to block `bash -c '<denied>'` and
# `bash <<EOF<denied>EOF` heredoc bypasses called out in no-hook-bypass.md.
deny_first_word_re='^(rg|grep|fd|find|shellcheck|biome|yamllint|actionlint|stylua|ruff|pre-commit|dfm|ls|tree|cat|head|tail|wc|awk|sed|jq|less|more|bash|sh|zsh|dash|ksh)$'

# Special denials for compound commands (e.g. `yarn lint`, `git log`, `shfmt --diff`).
# Note: `git status` (with or without `-s`) is _allowed_ — it's a common one-line
# check. `git log/diff/show/blame` always produce reviewable output and route through
# ctx_batch_execute.
deny_compound_res=(
  '^yarn[[:space:]]+(lint|test|check)'
  '^git[[:space:]]+(log|diff|show|blame)'
  '^shfmt[[:space:]]+(--diff|-d)'
  '^fish_indent[[:space:]]+(--check|-c)'
  '^biome[[:space:]]+(check|lint|format)'
  '^ruff[[:space:]]+(check|format[[:space:]]+--check)'
  '^stylua[[:space:]]+(--check|-c)'
  '^pre-commit[[:space:]]+run'
)

# Split the command on pipeline separators (|, &&, ||, ;) and command
# substitutions ($( ... ) and backticks). For each segment, extract the first
# bareword; that is the command being invoked. Uses awk for portable newline
# substitution (BSD sed does not support \n in the replacement).
split_segments()
{
  local cmd=$1
  printf '%s' "$cmd" | awk '
    {
      gsub(/\$\(/, "\n")
      gsub(/`/, "\n")
      gsub(/\|\|/, "\n")
      gsub(/&&/, "\n")
      gsub(/\|/, "\n")
      gsub(/;/, "\n")
      gsub(/\)/, "")
      n = split($0, parts, /\n/)
      for (i = 1; i <= n; i++) {
        gsub(/^[ \t]+/, "", parts[i])
        gsub(/[ \t]+$/, "", parts[i])
        if (parts[i] != "") print parts[i]
      }
    }
  '
  return 0
}

# Extract the first word (the command name) of a pipeline segment.
first_word()
{
  local segment=$1
  printf '%s' "$segment" | awk '{print $1}'
  return 0
}

# Strip a leading wrapper prefix so we match the real command. Handles:
#   env VAR=val cmd       — env with var-list
#   env cmd               — env alone
#   VAR=val cmd           — inline shell var assignment (no `env`)
#   VAR=a BAR=b cmd       — chained assignments
strip_env_prefix()
{
  local segment=$1
  printf '%s' "$segment" | sed -E '
    s/^env[[:space:]]+([A-Za-z_][A-Za-z_0-9]*=[^[:space:]]+[[:space:]]+)*//
    s/^([A-Za-z_][A-Za-z_0-9]*=[^[:space:]]+[[:space:]]+)+//
  '
  return 0
}

deny_reason=""

while IFS= read -r segment; do
  [[ -z "$segment" ]] && continue
  segment=$(strip_env_prefix "$segment")
  fw=$(first_word "$segment")
  [[ -z "$fw" ]] && continue

  # Compound checks run first — `yarn install` (allow) must beat `yarn` allow-first-word.
  for re in "${deny_compound_res[@]}"; do
    if printf '%s' "$segment" | grep -qE "$re"; then
      deny_reason="matched compound pattern '$re' in segment '$segment'"
      break 2
    fi
  done

  # First-word denylist.
  if printf '%s' "$fw" | grep -qE "$deny_first_word_re"; then
    deny_reason="first-word '$fw' in segment '$segment' is on the deny list"
    break
  fi

  # Specific git subcommand check: `git log` denied, `git add` allowed.
  if [[ "$fw" = "git" ]]; then
    git_sub=$(printf '%s' "$segment" | awk '{print $2}')
    if [[ -n "$git_sub" ]] && ! printf '%s' "$git_sub" | grep -qE "$allow_git_subcmd_re"; then
      deny_reason="git subcommand '$git_sub' is not on the allow list (output-reader)"
      break
    fi
  fi

  # First-word allowlist — anything else falls through to the catch-all below.
  if printf '%s' "$fw" | grep -qE "$allow_first_word_re"; then
    continue
  fi

  # Unknown command: not on either list. Allow by default — bash-routing.md is
  # explicit that only the listed patterns are forbidden; everything else is
  # the model's judgement call.
done < <(split_segments "$command")

if [[ -n "$deny_reason" ]]; then
  jq -n --arg cmd "$command" --arg why "$deny_reason" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: (
        "Routed to ctx_batch_execute per .claude/rules/bash-routing.md (\($why)).\n\n" +
        "Bash is reserved for state mutations (git add/commit/mv/rm/push, mkdir, chmod, mv, rm, touch), " +
        "in-place formatters (shfmt -w, fish_indent --write), and package installs (yarn install, brew install, mise install).\n\n" +
        "Output-producing commands belong in:\n" +
        "  - mcp__plugin_context-mode_context-mode__ctx_batch_execute  (multi-command sweeps with queries)\n" +
        "  - mcp__plugin_context-mode_context-mode__ctx_execute(language: \"shell\", code: ...)  (single command, print only what you need)\n\n" +
        "Original command: \($cmd)\n\n" +
        "To override for this one call, prepend BASH_OK to the command; the hook will pass it through. " +
        "Use sparingly — the rule is the default."
      )
    }
  }'
fi

exit 0
