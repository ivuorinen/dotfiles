#!/usr/bin/env bash
# Pre-tool guard: route output-producing Bash commands to ctx_batch_execute,
# and enforce the project rules that have a Bash-shaped bypass.
#
# Reads Claude Code PreToolUse JSON on stdin, inspects tool_input.command,
# and emits a `deny` decision (with educational reason) when the command
# matches a pattern that .claude/rules/bash-routing.md flags as belonging
# in context-mode. State-mutation commands, in-place formatters, and
# package installs pass through unblocked.
#
# Two tiers of deny:
#   1. Policy denies — secrets, hook bypass, network fetchers, npm/pip,
#      `git add`, writes to protected paths. These run BEFORE the BASH_OK
#      escape, so the escape can never override them. The tier lives in
#      lib/bash-policy.sh, shared with pre-ctx-write-guard.sh.
#   2. Routing denies — output readers that belong in context-mode. BASH_OK
#      overrides these, but only when the user named the command in their
#      latest prompt (recorded by prompt-record.sh).
#
# Hook contract: print hookSpecificOutput JSON on stdout, exit 0.
# (Exit 0 with no JSON = no decision; the normal permission flow applies.)
# A payload the hook cannot read exits 2, which blocks the call with stderr as
# the reason (Claude Code hooks reference, "exit code 2").

set -u

# Fail closed when jq is missing or the payload is not JSON. Exiting 0 here
# silently switched off the whole policy tier, secrets guard included, while
# pre-edit-block.sh blocked in the same situation (agent-loopholes-468c93a6).
if ! command -v jq > /dev/null 2>&1; then
  echo "BLOCKED: jq is not on PATH, so pre-bash-route.sh cannot read the command; it fails closed." >&2
  exit 2
fi

# shellcheck source=lib/bash-policy.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/bash-policy.sh"

input=$(cat)
if ! command=$(printf '%s' "$input" | jq -r '.tool_input.command // ""' 2> /dev/null); then
  echo "BLOCKED: unparseable hook payload; pre-bash-route.sh fails closed." >&2
  exit 2
fi

[[ -z "$command" ]] && exit 0

# Magic opt-out marker as the first token of the command. The escape strips
# the BASH_OK prefix via `updatedInput` and returns `allow` so the underlying
# command actually runs (the shell would otherwise try to execute BASH_OK as a
# command name and fail with "command not found"). Only the leading marker
# triggers the escape — a command that incidentally contains BASH_OK as a
# value or symbol name doesn't bypass. Everything below classifies the
# stripped command, so the marker hides nothing from the policy tier.
bash_ok=0
if printf '%s' "$command" | grep -qE '^[[:space:]]*BASH_OK[[:space:]]+'; then
  bash_ok=1
  command=$(printf '%s' "$command" | sed -E 's/^[[:space:]]*BASH_OK[[:space:]]+//')
fi

# Allowlist: commands that mutate state, format in place, install packages, or
# perform short interactive operations. First word of each pipeline segment is
# checked against this set.
allow_first_word_re='^(git|mkdir|chmod|chown|mv|rm|cp|touch|ln|unlink|rmdir|fish_indent|shfmt|yarn|brew|mise|cd|pwd|whoami|date|echo|printf|true|false|exit|return|export|unset|source|\.|alias|unalias|umask)$'

# Allowlist: specific git subcommands that mutate state, plus the plumbing
# queries that answer one question. Output-readers like `git log`, `git diff`,
# `git show`, `git blame` are explicitly _not_ here. `status` is here on
# purpose: bash-routing.md keeps it on Bash as a common one-line check.
# `rebase` sits with merge/cherry-pick/revert: it rewrites history, and its
# `--continue`/`--skip`/`--abort` steps are the same operation.
# `add` is deliberately absent: staging goes through git-hunk
# (.claude/rules/git-hunk-commits.md), and the policy tier denies it outright.
allow_git_subcmd_re='^(status|commit|mv|rm|checkout|push|fetch|reset|restore|stash|tag|init|clone|branch|merge|rebase|remote|cherry-pick|revert|switch|am|apply|format-patch|gc|prune|reflog|worktree|notes|submodule|rerere|update-ref|symbolic-ref|update-index|hash-object|cat-file|rev-parse|rev-list|ls-files|check-ignore|config)$'

# Denylist: first-word commands that almost always produce reviewable output.
# Includes `bash`/`sh`/`zsh`/`dash`/`ksh`/`fish` to block `bash script.sh` and
# `bash <<EOF<denied>EOF` heredoc bypasses called out in no-hook-bypass.md
# (the `-c` form is parsed into its commands by bash-policy.sh). `fish` is the
# user's login shell and was missing (agent-loopholes-6bc32964).
# The second line is the readers that emit file or system content and used to
# pass as "unknown" (agent-loopholes-63a35580): bash-routing.md routes every
# command whose output you read, not only the famous ones.
deny_first_word_re='^(rg|grep|fd|find|shellcheck|biome|yamllint|actionlint|stylua|ruff|pre-commit|dfm|ls|tree|cat|head|tail|wc|awk|sed|jq|less|more|bash|sh|zsh|dash|ksh|fish|'
deny_first_word_re+='diff|cmp|bat|xxd|od|strings|base64|column|sort|uniq|cut|nl|fold|rev|tac|paste|comm|join|file|stat|du|lsof|ps)$'

# Special denials for compound commands (e.g. `yarn lint`, `git log`, `shfmt --diff`).
deny_compound_res=(
  '^yarn[[:space:]]+(lint|test|check)'
  '^git[[:space:]]+(log|diff|show|blame)'
  '^shfmt[[:space:]]+(--diff|-d)'
  '^fish_indent[[:space:]]+(--check|-c)'
  '^biome[[:space:]]+(check|lint|format)'
  '^ruff[[:space:]]+(check|format[[:space:]]+--check)'
  '^stylua[[:space:]]+(--check|-c)'
  '^pre-commit[[:space:]]+run'
  # prek is the hook runner this repo actually installs (config/mise/config.toml);
  # `pre-commit` was denied while its replacement was not, so the same
  # full-suite output escaped routing under the name that is really used.
  '^prek[[:space:]]+run'
  # Readers that project rules name explicitly: git-hunk-commits.md says to
  # route `git-hunk list` through context-mode, graphify-first.md mandates
  # graphify queries. The git-hunk mutations (commit/add/reset/stash) stay on Bash.
  '^git-hunk[[:space:]]+(list|show|diff)'
  '^graphify[[:space:]]+(query|path|explain)'
  # gh readers return raw API JSON; settings.local.json pre-allows `gh api`.
  '^gh[[:space:]]+(api|pr[[:space:]]+(view|diff|list)|issue[[:space:]]+(view|list)|run[[:space:]]+view)'
  # Inline-code interpreters are file readers with extra steps.
  '^(python3?|node|perl|ruby)[[:space:]]+(-c|-e)'
)

# Emit a policy deny. Unlike the routing deny below, the reason offers no
# BASH_OK override: these rules bind regardless of the escape.
deny_policy()
{
  jq -n --arg cmd "$command" --arg why "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: ("\($why)\n\nOriginal command: \($cmd)\n\n" +
        "BASH_OK does not override this; only the user authorising it in the conversation does.")
    }
  }'
  exit 0
}

if bash_policy_check "$command"; then
  deny_policy "$BP_REASON"
fi

# The policy check parsed the command once; the routing tier classifies the
# commands it found.
segments=("${BP_SEGMENTS[@]+"${BP_SEGMENTS[@]}"}")
wrapped_flags=("${BP_WRAPPED[@]+"${BP_WRAPPED[@]}"}")

# BASH_OK is honoured only for a command the user named in their latest
# prompt, which bash-routing.md requires and the hook used to take on trust
# (agent-loopholes-ab4a6d36). prompt-record.sh writes that prompt. Every
# command in the line must be named, not only the first: `BASH_OK yarn build;
# git log -p` otherwise carried an unbounded reader through (audit-7b087cc6).
if [[ "$bash_ok" -eq 1 ]]; then
  prompt_file="${CLAUDE_PROJECT_DIR:-$PWD}/.claude/.last-prompt"
  ok_fw=""
  named=0
  if [[ -r "$prompt_file" && ${#segments[@]} -gt 0 ]]; then
    named=1
    for segment in "${segments[@]}"; do
      ok_fw=$(normalise_cmd "$(first_word "$segment")")
      if [[ -z "$ok_fw" ]] || ! grep -qwF -- "$ok_fw" "$prompt_file"; then
        named=0
        break
      fi
    done
  fi
  if [[ "$named" -eq 1 ]]; then
    jq -n --arg cmd "$command" '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "allow",
        permissionDecisionReason: "BASH_OK escape — the user named this command in their latest prompt.",
        updatedInput: { command: $cmd }
      }
    }'
    exit 0
  fi
  deny_policy "BASH_OK requires the user to name \`${ok_fw:-the command}\` in their latest message (.claude/rules/bash-routing.md case 4). Route it through ctx_batch_execute instead."
fi

deny_reason=""

# Text the shell parser rejects has no commands to classify. Bash would reject
# it too, but only from the bad line on, so it is refused rather than passed.
if [[ "$BP_PARSE_FAILED" -eq 1 ]]; then
  deny_reason="the command does not parse as shell, so its commands cannot be classified"
fi

for i in "${!segments[@]}"; do
  [[ -n "$deny_reason" ]] && break
  segment=${segments[$i]}
  wrapped=${wrapped_flags[$i]}
  fw=$(normalise_cmd "$(first_word "$segment")")
  [[ -z "$fw" ]] && continue

  # git's global options (`git -C dir status`) are dropped first, so the
  # subcommand checks below see the real subcommand (agent-loopholes-e0092417).
  [[ "$fw" = "git" ]] && segment=$(git_strip_globals "$segment")

  # Compound checks run first — `yarn install` (allow) must beat `yarn` allow-first-word.
  for re in "${deny_compound_res[@]}"; do
    if printf '%s' "$segment" | grep -qE "$re"; then
      deny_reason="matched compound pattern '$re' in segment '$segment'"
      break 2
    fi
  done

  # Fail closed on a command word that is not a fixed name. The parser has
  # already resolved quoting and escapes (`c\at`, `$'cat'` and `"cat"` arrive
  # as `cat`), so what is left here is a word decided at run time — `$var`,
  # `$(...)` — or a literal quote inside a nested string. BASH_OK remains the
  # documented override.
  case "$fw" in
    *\\* | *\'* | *\"* | *\$* | *\`*)
      deny_reason="command word '$fw' in segment '$segment' carries unresolved quote or escape syntax"
      break
      ;;
  esac

  # First-word denylist.
  if printf '%s' "$fw" | grep -qE "$deny_first_word_re"; then
    deny_reason="first-word '$fw' in segment '$segment' is on the deny list"
    break
  fi

  # Specific git subcommand check: `git log` denied, `git commit` allowed.
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

  # Fail closed on a wrapper form this parser could not fully normalise.
  # Wrapper options with operands are open-ended — `stdbuf -o L`, `xargs -E EOF`,
  # `timeout --signal KILL` — and enumerating them all is a losing game: each
  # miss leaves the operand as the first word, so `stdbuf -o L cat README.md`
  # was classified as `L` and allowed. Anything peeled from a wrapper that
  # lands on neither list is refused rather than waved through; the unwrapped
  # command is still checked normally, and BASH_OK remains the documented
  # override.
  if [[ "$wrapped" -eq 1 ]]; then
    deny_reason="wrapper form could not be normalised — '$fw' in segment '$segment' is on neither list"
    break
  fi

  # ponytail: unknown command, on neither list — allowed by default. A reader
  # missing from deny_first_word_re passes; add it there when one turns up.
  # Deny-by-default would need an allowlist of every legitimate tool.
done

if [[ -n "$deny_reason" ]]; then
  jq -n --arg cmd "$command" --arg why "$deny_reason" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: (
        "Routed to ctx_batch_execute per .claude/rules/bash-routing.md (\($why)).\n\n" +
        "Bash is reserved for state mutations (git-hunk commit, git mv/rm/push, mkdir, chmod, mv, rm, touch), " +
        "in-place formatters (shfmt -w, fish_indent --write), and package installs (yarn install, brew install, mise install).\n\n" +
        "Output-producing commands belong in:\n" +
        "  - mcp__plugin_context-mode_context-mode__ctx_batch_execute  (multi-command sweeps with queries)\n" +
        "  - mcp__plugin_context-mode_context-mode__ctx_execute(language: \"shell\", code: ...)  (single command, print only what you need)\n\n" +
        "Original command: \($cmd)\n\n" +
        "BASH_OK overrides this only for a command the user named in their latest message."
      )
    }
  }'
fi

exit 0
