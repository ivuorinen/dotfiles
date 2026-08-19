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
# `status` is here on purpose: bash-routing.md names it as the one git reader
# that stays on Bash ("a common one-line check"). It was missing until an audit
# found the hook denying it against both the rule and the comment below.
# `rebase` sits with merge/cherry-pick/revert: it rewrites history, and its
# `--continue`/`--skip`/`--abort` steps are the same operation. It was missing
# while its siblings were listed, so every rebase needed a BASH_OK escape —
# which trains the habit of reaching for the escape hatch rather than fixing
# the list.
allow_git_subcmd_re='^(status|add|commit|mv|rm|checkout|push|fetch|reset|restore|stash|tag|init|clone|branch|merge|rebase|remote|cherry-pick|revert|switch|am|apply|format-patch|gc|prune|reflog|worktree|notes|submodule|rerere|update-ref|symbolic-ref|update-index|hash-object|cat-file|rev-parse|rev-list|ls-files|check-ignore|config)$'

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
  # prek is the hook runner this repo actually installs (config/mise/config.toml);
  # `pre-commit` was denied while its replacement was not, so the same
  # full-suite output escaped routing under the name that is really used.
  '^prek[[:space:]]+run'
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
#   env -i cmd            — env with flags (the flag group is why `env -i cat`
#                           used to slip through: the VAR= group matched zero
#                           times and `-i` became the first word)
#   env cmd               — env alone
#   VAR=val cmd           — inline shell var assignment (no `env`)
#   VAR=a BAR=b cmd       — chained assignments
strip_env_prefix()
{
  local seg=$1 prev
  # Inline assignments. The value is optional (`[^[:space:]]*`, not `+`):
  # `FOO= cat README.md` is a legal empty assignment, and requiring a value
  # left `FOO=` as the first word, matching nothing on either list.
  while :; do
    prev=$seg
    seg=$(printf '%s' "$seg" | sed -E 's/^[A-Za-z_][A-Za-z_0-9]*=[^[:space:]]*[[:space:]]+//')
    [[ "$seg" == "$prev" ]] && break
  done

  # Matched through normalise_cmd, not literally: `/usr/bin/env cat README.md`
  # is the same invocation and was walking past both env checks.
  if [[ "$(normalise_cmd "$(first_word "$seg")")" == "env" ]]; then
    seg=$(printf '%s' "$seg" | sed -E 's/^[^[:space:]]+[[:space:]]+//')
    while :; do
      prev=$seg
      # -u/-C take a SEPARATE operand naming a variable or directory, so the
      # operand is consumed with the flag. Dropping only the flag left
      # `env -u FOO cat` as `FOO cat`, and `cat` was never classified.
      #
      # -S/--split-string is deliberately NOT here. Its operand is the command
      # itself, so consuming it threw the command away: `env -S cat README.md`
      # became `README.md` and the `cat` was never seen. Only the flag is
      # dropped (by the generic rule below), leaving the split string to be
      # classified like any other command.
      # The -S prefix is removed while its operand is kept, and it is matched
      # BEFORE the generic flag rule. In the attached forms — `-S'cat x'` and
      # `--split-string='cat x'` — the flag and the command share one
      # whitespace-delimited token, so the generic rule would consume the
      # command along with the flag.
      seg=$(printf '%s' "$seg" | sed -E '
        s/^(-S|--split-string=?)[[:space:]]*//
        s/^(-u|--unset|-C|--chdir)[[:space:]]+[^[:space:]]+[[:space:]]+//
        s/^-[^[:space:]]+[[:space:]]+//
        s/^[A-Za-z_][A-Za-z_0-9]*=[^[:space:]]*[[:space:]]+//
      ')
      [[ "$seg" == "$prev" ]] && break
    done
  fi
  printf '%s' "$seg"
  return 0
}

# Reduce a command token to the bare name the deny/allow lists are written
# against. Both regexes are anchored (`^cat$`), so without this `/bin/cat` and
# `\cat` match nothing and fall through to the allow-by-default branch — which
# also defeated the `bash|sh|zsh|dash|ksh` entries whose whole purpose is to
# block `bash -c '<denied>'`, since `/bin/bash -c` was spelled differently.
# Leading quotes are stripped too: `env -S "cat README.md"` leaves the split
# string quoted, so the first word arrives as `"cat` and matches no anchored
# entry.
normalise_cmd()
{
  local w=${1#\\} prev
  # To a fixed point, not once: a split string can nest quotes, so
  # `env -S '"cat" README.md'` arrives as `'"cat"` and one pass leaves `"cat`,
  # which matches no anchored entry. Also drop a trailing quote, since the
  # nested form closes on the same token.
  while :; do
    prev=$w
    w=${w#\"}
    w=${w#\'}
    w=${w%\"}
    w=${w%\'}
    [[ "$w" == "$prev" ]] && break
  done
  printf '%s' "${w##*/}"
}

# Peel wrappers that execute their argument list, so the denied command is not
# hidden in second position. Loops because they nest (`nohup timeout 5 rg …`).
#
# `command -v X` is deliberately exempt: it is a probe that never runs X, and
# bash-routing.md treats single tool probes as fine on Bash.
strip_wrappers()
{
  local seg=$1 next
  while :; do
    if [[ "$seg" =~ ^command[[:space:]]+-[vV]([[:space:]]|$) ]]; then
      break
    fi
    case "$(normalise_cmd "$(first_word "$seg")")" in
      command | builtin | exec | nohup | time | timeout | stdbuf | xargs | nice | ionice)
        # Drop the wrapper, then its own flags and any numeric argument
        # (`timeout 5`), leaving the wrapped command in first position.
        next=$(printf '%s' "$seg" | sed -E '
          s/^[^[:space:]]+[[:space:]]+//
          s/^(-[^[:space:]]+[[:space:]]+|[0-9]+[a-z]?[[:space:]]+)*//
        ')
        # A bare wrapper with nothing after it (`xargs`, `timeout`) matches the
        # case but has no trailing space for the substitutions to bite on, so
        # the value never changes. Without this guard the loop spins forever
        # and the PreToolUse hook never returns — every Bash call hangs.
        [[ "$next" == "$seg" ]] && break
        seg=$next
        ;;
      *) break ;;
    esac
  done
  printf '%s' "$seg"
  return 0
}

deny_reason=""

while IFS= read -r segment; do
  [[ -z "$segment" ]] && continue
  # Wrappers and env prefixes nest in either order — `timeout 5 env -i cat`
  # needs the wrapper peeled before the env prefix is even visible, and a
  # single pass of each in fixed order classified `env` and let `cat` through.
  # Alternate until neither peels anything.
  prev_segment=""
  wrapped=0
  # `env` counts as a wrapper for the fail-closed rule below. Its option
  # grammar is as open-ended as any other wrapper's, so an unrecognised token
  # after peeling it is refused rather than allowed.
  [[ "$(normalise_cmd "$(first_word "$segment")")" == "env" ]] && wrapped=1
  while [[ "$segment" != "$prev_segment" ]]; do
    prev_segment=$segment
    segment=$(strip_env_prefix "$segment")
    before_wrappers=$segment
    segment=$(strip_wrappers "$segment")
    [[ "$segment" != "$before_wrappers" ]] && wrapped=1
  done
  fw=$(normalise_cmd "$(first_word "$segment")")
  [[ -z "$fw" ]] && continue

  # Compound checks run first — `yarn install` (allow) must beat `yarn` allow-first-word.
  for re in "${deny_compound_res[@]}"; do
    if printf '%s' "$segment" | grep -qE "$re"; then
      deny_reason="matched compound pattern '$re' in segment '$segment'"
      break 2
    fi
  done

  # Fail closed on a command word this parser cannot resolve. The shell
  # resolves `c\at` and `$'cat'` to `cat`, but reproducing its quote and
  # escape removal here means writing a shell tokeniser — and every gap in one
  # is a silent bypass. Residual escape or quote syntax in the command word is
  # therefore refused outright; the plain spelling is unaffected, and BASH_OK
  # remains the documented override.
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
