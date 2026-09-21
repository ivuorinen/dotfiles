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
#      escape, so the escape can never override them.
#   2. Routing denies — output readers that belong in context-mode. BASH_OK
#      overrides these, but only when the user named the command in their
#      latest prompt (recorded by prompt-record.sh).
#
# Hook contract: print hookSpecificOutput JSON on stdout, exit 0.
# (Exit 0 with no JSON = no decision; the normal permission flow applies.)

set -u

# Read input; bail out cleanly if jq is unavailable or input is empty/malformed.
if ! command -v jq > /dev/null 2>&1; then
  exit 0
fi

# shellcheck source=lib/protected-paths.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib/protected-paths.sh"

input=$(cat)
command=$(printf '%s' "$input" | jq -r '.tool_input.command // ""' 2> /dev/null)

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
# Includes `bash`/`sh`/`zsh`/`dash`/`ksh` to block `bash -c '<denied>'` and
# `bash <<EOF<denied>EOF` heredoc bypasses called out in no-hook-bypass.md.
# The second line is the readers that emit file or system content and used to
# pass as "unknown" (agent-loopholes-63a35580): bash-routing.md routes every
# command whose output you read, not only the famous ones.
deny_first_word_re='^(rg|grep|fd|find|shellcheck|biome|yamllint|actionlint|stylua|ruff|pre-commit|dfm|ls|tree|cat|head|tail|wc|awk|sed|jq|less|more|bash|sh|zsh|dash|ksh|'
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

# Split the command on pipeline separators (|, &&, ||, ;, &), command
# substitutions ($( ... ) and backticks), subshells and brace groups. For each
# segment, extract the first bareword; that is the command being invoked. Uses
# awk for portable newline substitution (BSD sed does not support \n in the
# replacement). `(`, `{`, `}` and a lone `&` were missing, so `(cat x)`,
# `{ cat x; }` and `true & cat x` reached the classifier with `(cat`, `{` or
# `true` as the first word (agent-loopholes-9bfab590).
split_segments()
{
  local cmd=$1
  printf '%s' "$cmd" | awk '
    {
      gsub(/\$\(/, "\n")
      gsub(/`/, "\n")
      gsub(/\|\|/, "\n")
      gsub(/&&/, "\n")
      gsub(/&/, "\n")
      gsub(/\|/, "\n")
      gsub(/;/, "\n")
      gsub(/\(/, "\n")
      gsub(/[{}]/, "\n")
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

# Drop leading shell keywords so the command they introduce is classified:
# `if cat x`, `then cat x`, `! cat x`, `do cat x`. A `for`/`case`/`select`
# header names words, not a command, so the whole segment is dropped — the
# body arrives as its own segment after the `;` split.
strip_keywords()
{
  local seg=$1 prev
  while :; do
    prev=$seg
    case "$(first_word "$seg")" in
      for | case | select)
        seg=""
        break
        ;;
      if | then | elif | else | do | while | until | time | '!')
        seg=$(printf '%s' "$seg" | sed -E 's/^[^[:space:]]+[[:space:]]*//')
        ;;
      *) ;;
    esac
    [[ "$seg" == "$prev" ]] && break
  done
  printf '%s' "$seg"
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

# Whole-string policy checks: these match paths and tokens anywhere in the
# command, including inside arguments the segment parser would split apart.
if secrets_referenced "$command"; then
  deny_policy "The command names a secrets.d tree or a real secrets file, which hold live credentials (.claude/rules/secrets-files.md). Ask the user instead."
fi
if printf '%s' "$command" | grep -q 'node_modules/\.bin/bats'; then
  deny_policy "Use bare \`bats\` from PATH (mise); node_modules/.bin/bats is broken (fails with 'rm: command not found')."
fi

# Normalise every segment once: wrappers and env prefixes nest in either
# order — `timeout 5 env -i cat` needs the wrapper peeled before the env prefix
# is even visible — so alternate until neither peels anything.
segments=()
wrapped_flags=()
while IFS= read -r segment; do
  segment=$(strip_keywords "$segment")
  [[ -z "$segment" ]] && continue
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
    segment=$(strip_keywords "$segment")
    [[ "$segment" != "$before_wrappers" ]] && wrapped=1
  done
  [[ -z "$segment" ]] && continue
  segments+=("$segment")
  wrapped_flags+=("$wrapped")
done < <(split_segments "$command")

# Write-shaped segment: redirects, copy/move/remove tools, in-place sed, and
# the git subcommands that rewrite worktree files.
write_seg_re='>|(^|[[:space:]])(tee|cp|mv|rm|ln|truncate|install|dd|chmod|unlink)([[:space:]]|$)|sed[[:space:]].*-i|git[[:space:]]+(checkout|restore|rm|mv|apply|reset)'

# Per-segment policy checks.
for segment in "${segments[@]+"${segments[@]}"}"; do
  fw=$(normalise_cmd "$(first_word "$segment")")
  sub=$(printf '%s' "$segment" | awk '{print $2}')

  case "$fw" in
    curl | wget | http | https | xh | aria2c)
      deny_policy "Network fetchers are banned on Bash (.claude/rules/context-mode.md). Use ctx_fetch_and_index(url, source), or ctx_execute with fetch()."
      ;;
    npm | npx | pnpm | pnpx)
      deny_policy "This repo uses Yarn Berry, never npm (.claude/rules/no-npm.md). Use yarn / yarn add / yarn dlx <package>."
      ;;
    pip | pip3)
      [[ "$sub" == "install" ]] \
        && deny_policy "Python packages come from config/mise/default-python-packages, never pip by hand (.claude/rules/mise-packages.md)."
      ;;
    python | python3)
      printf '%s' "$segment" | grep -qE '[[:space:]]-m[[:space:]]+pip[[:space:]]+install' \
        && deny_policy "Python packages come from config/mise/default-python-packages, never pip by hand (.claude/rules/mise-packages.md)."
      ;;
    uv)
      printf '%s' "$segment" | grep -qE '^[^[:space:]]+[[:space:]]+(tool|pip)[[:space:]]+install' \
        && deny_policy "Python packages come from config/mise/default-python-packages, never uv installs by hand (.claude/rules/mise-packages.md)."
      ;;
    prek | pre-commit)
      [[ "$sub" == "uninstall" ]] \
        && deny_policy "Uninstalling the hook runner bypasses every commit-time gate (.claude/rules/no-hook-bypass.md)."
      ;;
    git)
      if printf '%s' "$segment" | grep -qE -- '--no-verify|--no-gpg-sign|core\.hooksPath|commit\.gpgsign=false'; then
        deny_policy "The command bypasses the project's hook chain (.claude/rules/no-hook-bypass.md). Fix the failing hook instead."
      fi
      if [[ "$sub" == "commit" ]] && printf '%s' "$segment" | grep -qE '[[:space:]]-[A-Za-z]*n[A-Za-z]*([[:space:]]|$)'; then
        deny_policy "\`git commit -n\` is --no-verify and bypasses the hook chain (.claude/rules/no-hook-bypass.md)."
      fi
      if [[ "$sub" == "add" ]]; then
        deny_policy "Stage with git-hunk, never git add (.claude/rules/git-hunk-commits.md): git-hunk list, then git-hunk commit <hash>... -m '...'."
      fi
      if [[ "$sub" == "commit" ]] && printf '%s' "$segment" | grep -qE '[[:space:]](--all|-[A-Za-z]*a[A-Za-z]*)([[:space:]]|$)'; then
        deny_policy "\`git commit -a\` stages by file, not by hunk (.claude/rules/git-hunk-commits.md). Use git-hunk commit <hash>... -m '...'."
      fi
      ;;
    *) ;;
  esac

  if printf '%s' "$segment" | grep -qE "$PROTECTED_RE" \
    && printf '%s' "$segment" | grep -qE "$write_seg_re"; then
    deny_policy "The command writes to a vendored, lock or submodule path (.claude/rules/vendored-files.md). Refresh it from upstream instead."
  fi
done

# BASH_OK is honoured only for a command the user named in their latest
# prompt, which bash-routing.md requires and the hook used to take on trust
# (agent-loopholes-ab4a6d36). prompt-record.sh writes that prompt.
if [[ "$bash_ok" -eq 1 ]]; then
  prompt_file="${CLAUDE_PROJECT_DIR:-$PWD}/.claude/.last-prompt"
  ok_fw=$(normalise_cmd "$(first_word "${segments[0]:-}")")
  if [[ -n "$ok_fw" && -r "$prompt_file" ]] && grep -qwF -- "$ok_fw" "$prompt_file"; then
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

for i in "${!segments[@]}"; do
  segment=${segments[$i]}
  wrapped=${wrapped_flags[$i]}
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
