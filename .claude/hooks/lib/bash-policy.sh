# shellcheck shell=bash disable=SC2034 # BP_* globals are read by the sourcing scripts
# Shell-command policy tier, shared by the PreToolUse guards. Sourced, never
# executed; sources protected-paths.sh itself.
#
# The policy tier (secrets, hook bypass, network fetchers, npm/pip/uv installs,
# `git add`, writes to protected paths) used to live inside pre-bash-route.sh,
# which only the `Bash` matcher reaches. The context-mode execute tools run
# arbitrary shell too, and the routing rules send agents there for nearly every
# command, so the whole tier was skipped on the path agents are told to use
# (agent-loopholes-0e8b508f). One copy here, called by pre-bash-route.sh on
# `tool_input.command` and by pre-ctx-write-guard.sh on sandbox code.
#
# Mechanism: a real shell parser. `shfmt --to-json` ("print syntax tree to
# stdout as a typed JSON", shfmt 3.x; pinned in config/mise/config.toml) turns
# the command into a bash AST, and one jq pass flattens it into records: each
# simple command as its argv with quoting and escapes resolved, every
# assignment, every redirect, and every word that is not a command argument.
# The text splitter this replaces cut on ( ) ; | & with no quote awareness, so
# a conventional-commit message (`-m 'fix(x): y'`) pushed a trailing
# --no-verify into a segment the git checks never saw
# (agent-loopholes-8dfa8203), and words inside quoted messages were scanned as
# if they were paths (agent-hooks-84fa86e9). The parser also models what the
# splitter missed — `time -p`, `coproc`, process and command substitution
# (agent-loopholes-52d63719) — and costs one shfmt and one jq fork per parse
# instead of several awk/sed forks per segment (agent-hooks-cfba86f8): the
# ctx guard on a 20-line batch went from 2.4s to 0.11s, on a 50-line batch
# naming a protected path from 6.0s to 0.16s (2026-10-03, bash 5 and 3.2).
#
# Considered and rejected: making the splitter quote-aware. It closes the
# quoting gap but keeps every other piece of hand-written shell grammar and its
# per-segment forks, while the parser already ships with the formatter
# toolchain the repo requires.
#
# Strings that are code — `bash -c`, `eval`, `trap`, `watch`, `env -S`, a
# heredoc fed to a shell — are parsed recursively. Code in another language
# (`python3 -c`, sandbox code with a non-shell `language`, or text that does
# not parse as shell) gets a string-literal pass: each literal naming a policy
# tool, and each run of literals forming an argv array, is parsed as shell.
#
# Code the guard cannot see through — a `$var` or `$(...)` command word, a
# shell reading stdin, `source <(...)`, a subprocess call with a non-literal
# argument, unparseable text — is denied only when the code also names a policy
# tool (BP_TRIGGER_RE). Denying every dynamic shape would refuse ordinary
# scripts. ponytail: a command assembled from fragments none of which names a
# policy tool (`"gi" + "t"`), argv arrays holding variables, and scripts run
# from files stay unseen; resolving them needs execution, not parsing.
#
# Entry points:
#   bash_policy_check CODE [shell|foreign] — succeed (and set BP_REASON) when
#       CODE violates the policy; fail when it is clean. Shell mode also fills
#       BP_SEGMENTS (each command as a space-joined argv) and BP_WRAPPED
#       (parallel 0/1: reached by peeling a wrapper) for the routing tier, and
#       sets BP_PARSE_FAILED when the text is not valid shell.
#   git_strip_globals SEG  — SEG with git's global options removed.
#   first_word / normalise_cmd — the helpers the routing tier also needs.

# shellcheck source=protected-paths.sh
source "$(dirname "${BASH_SOURCE[0]}")/protected-paths.sh"

# AST flattener. Record kinds, fields separated by \x1f, newlines inside a
# field encoded as \x1e so one record is one line:
#   C <heredoc bodies> <argv...>  — a simple command (CallExpr) and the
#                                   heredocs attached to its statement
#   A <name> <value>              — an assignment (prefix, export, standalone)
#   R <op> <target>               — a redirect other than a heredoc
#   W <word>                      — a word that is not a command argument
#                                   (assignment values, loop items, redirect
#                                   targets, heredoc bodies, test operands)
# A dynamic part renders with a leading `$` (`$name`, `$(...)`, `<(...)`), so
# a command word built from one is recognisable as unresolved.
#
# The jq programs are read from quoted heredocs, which keep every character
# literal, so the single quotes their regexes need do not end a shell string.
IFS= read -r -d '' BP_JQ_AST << 'JQ' || true
def lit_u: gsub("\\\\\n"; "") | gsub("\\\\(?<c>.)"; "\(.c)");
def dq_u: gsub("\\\\\n"; "") | gsub("\\\\(?<c>[$`\"\\\\])"; "\(.c)");
def part(dq):
  if .Type == "Lit" then (.Value | if dq then dq_u else lit_u end)
  elif .Type == "SglQuoted" then .Value
  elif .Type == "DblQuoted" then ([.Parts[]? | part(true)] | join(""))
  elif .Type == "ParamExp" then "$" + (.Param.Value // "")
  elif .Type == "CmdSubst" then "$(...)"
  elif .Type == "ProcSubst" then "<(...)"
  elif .Type == "ArithmExp" then "$((...))"
  else "$?" end;
def word: [.Parts[]? | part(false)] | join("");
def enc: gsub("\n"; "\u001e");
([.. | objects | select(.Type? == "CallExpr") | .Args[]?.Pos.Offset | tostring]
  | map({(.): true}) | add // {}) as $args
| (.. | objects | select(.Cmd?.Type? == "CallExpr" and ((.Cmd.Args // []) | length) > 0)
    | (["C", ([.Redirs[]? | select(.Hdoc != null) | [.Hdoc.Parts[]? | part(true)] | join("")]
        | join("\n") | enc)] + [.Cmd.Args[] | word | enc]) | join("\u001f")),
  (.. | objects | select(.Type? == null and (.Name? | type) == "object")
    | ["A", (.Name.Value // ""), ((.Value // {}) | word | enc)] | join("\u001f")),
  (.. | objects | select(.Redirs? != null) | .Redirs[] | select(.Hdoc == null)
    | ["R", (.Op | tostring), ((.Word // {}) | word | enc)] | join("\u001f")),
  (.. | objects | select((.Type? // "Word") == "Word" and .Parts? != null)
    | select($args[.Pos.Offset | tostring] | not)
    | "W\u001f" + (word | enc))
JQ

# String-literal pass for code that is not shell. Prints `L\x1f<candidate>`
# for every literal naming a policy tool and every run of adjacent literals
# (an argv array such as ["git", "add", "-A"] or spawnSync("git", ["add"]),
# joined with shell quoting), and `D` when a subprocess or exec call takes a
# non-literal first argument while the code names a policy tool.
IFS= read -r -d '' BP_JQ_FOREIGN << 'JQ' || true
def trig: test("(^|[^A-Za-z0-9_-])(git|git-hunk|npm|npx|pnpm|pnpx|pip|pip3|uv|curl|wget|xh|aria2c|prek|pre-commit)([^A-Za-z0-9_-]|$)");
def enc: gsub("\n"; "\u001e");
. as $src
| [match("\"((?:[^\"\\\\\n]|\\\\.)*)\"|'((?:[^'\\\\\n]|\\\\.)*)'|`([^`]*)`"; "g")
    | {o: .offset, e: (.offset + .length),
      v: ([.captures[].string | select(. != null)] | first // "")}] as $l
| ($l[] | .v | select(trig) | "L\u001f" + enc),
  (reduce range(0; $l | length) as $i ({runs: [], cur: []};
      if (.cur | length) > 0
        and ($src[$l[$i - 1].e:$l[$i].o]
          | test("^[\\s,\\[\\]]*$|^\\)\\s*\\.\\s*args?\\s*\\(\\s*[\\[&]*\\s*$"))
      then .cur += [$l[$i].v]
      else .runs += [.cur] | .cur = [$l[$i].v] end)
    | (.runs + [.cur])[] | select(length > 1) | map(@sh) | join(" ")
    | select(trig) | "L\u001f" + enc),
  (select($src | trig)
    | select($src | test("(os\\.system|os\\.popen|os\\.exec[a-z]*|os\\.spawn[a-z]*|subprocess\\.[a-z_]+|\\bPopen|\\bexecSync|\\bexecFileSync|\\bexecFile|\\bspawnSync|\\bspawn|child_process\\.exec|(?<![.\\w])exec|\\bsystem|\\bshell_exec|\\bpassthru|\\bpopen|\\bproc_open|IO\\.popen|Open3\\.[a-z0-9_]+|exec\\.Command|Command::new)\\s*\\(\\s*(?![\"'`\\[]|[fbrFBR]{1,2}[\"']|vec!|&\\[)"))
    | "D")
JQ

# Policy tools. Word-anchored: the substring match it replaces fired on `digit`
# (git), every URL (http) and any word containing `uv` (agent-hooks-cfba86f8).
# It gates the dynamic-code denials only; the per-command checks match exact
# command names.
BP_TRIGGER_RE='(^|[^[:alnum:]_-])(git|git-hunk|npm|npx|pnpm|pnpx|pip|pip3|uv|curl|wget|xh|aria2c|prek|pre-commit)([^[:alnum:]_-]|$)'

# Arguments that make a dynamic command word worth refusing on their own:
# `$(printf 'gi%s' t) add -A` names no policy tool, but its `add` does.
BP_STAGE_WORD_RE='^(add|stage|commit|install|uninstall|update-index)$'

# Tools whose denial depends on the words after them (`git add`, `pip
# install`). Any command can run its arguments as a command — `mise exec --`,
# `setsid`, `flock FILE` — and a fixed wrapper list missed each new one
# (audit-a5c76774), so every argv position holding one of these is checked as
# the start of a command. The verb it needs keeps the scan from firing on a
# mere mention (`rg git`).
BP_VERB_TOOL_RE='^(git|git-hunk|pip[0-9.]*|python[0-9.]*|uv|prek|pre-commit)$'
# Tools banned by name alone, whatever follows them.
BP_NET_RE='^(curl|wget|http|https|xh|aria2c)$'
BP_NPM_RE='^(npm|npx|pnpm|pnpx)$'

# Environment that switches off the hook chain without a flag on the command
# line: prek and pre-commit honour SKIP= and PRE_COMMIT_ALLOW_NO_CONFIG, and
# GIT_CONFIG_COUNT/KEY/VALUE (or GIT_CONFIG_PARAMETERS) set core.hooksPath
# with no `-c` for the bypass scan to see (agent-loopholes-63eb3265).
# GIT_CONFIG_GLOBAL / GIT_CONFIG_SYSTEM / GIT_CONFIG point git at a whole
# config file, which can carry the same key (audit-c36f6a78).
BP_ENV_BYPASS_RE='^(SKIP|PRE_COMMIT_ALLOW_NO_CONFIG|GIT_CONFIG_COUNT|GIT_CONFIG_KEY_[0-9]+|GIT_CONFIG_VALUE_[0-9]+|GIT_CONFIG_PARAMETERS|GIT_CONFIG_GLOBAL|GIT_CONFIG_SYSTEM|GIT_CONFIG)$'
# The same names in non-shell code (`env={"SKIP": ...}`, `SKIP: "x"`).
BP_ENV_BYPASS_TEXT_RE='(^|[^[:alnum:]_])(SKIP|PRE_COMMIT_ALLOW_NO_CONFIG|GIT_CONFIG_COUNT|GIT_CONFIG_KEY_[0-9]+|GIT_CONFIG_VALUE_[0-9]+|GIT_CONFIG_PARAMETERS|GIT_CONFIG_GLOBAL|GIT_CONFIG_SYSTEM|GIT_CONFIG)["'"'"']?\]?[[:space:]]*[:=]'

# Write-shaped command: copy/move/remove tools, in-place sed, and the git
# subcommands that rewrite worktree files. Redirects are checked separately
# from the AST's redirect records. The in-place editors (perl/ruby -i, the vi
# family, ed, patch, rsync) and an awk program's own `print > file` write too
# (audit-5a6f71da); they are anchored to the command word, since `patch` and
# `vim` are ordinary search terms in a read of yarn.lock.
BP_WRITE_SEG_RE='(^|[[:space:]])(tee|cp|mv|rm|ln|truncate|install|dd|chmod|unlink)([[:space:]]|$)|sed[[:space:]].*-i|git[[:space:]]+(checkout|restore|rm|mv|apply|reset)'
BP_WRITE_SEG_RE+='|^(perl|ruby)[[:space:]](.*[[:space:]])?-[A-Za-z0-9]*i([[:space:]]|$|\.)|^(ed|ex|vi|vim|nvim|patch|rsync)([[:space:]]|$)'
BP_WRITE_SEG_RE+='|^g?awk[[:space:]].*(printf?[^;}]*>|-i[[:space:]]*inplace)'
BP_WRITE_OPS_RE='^(>|>>|>\||&>|&>>|<>)$'

# Hook-bypass spellings, matched per argument. git's parse-options accepts any
# unambiguous prefix of a long option, so the literal `--no-verify` let
# `--no-verif` through (agent-loopholes-e0092417); every prefix of
# `--no-verify` and `--no-gpg-sign` is matched. Config keys are
# case-insensitive (`core.HooksPath`), hence the bracket classes: bash 3.2 has
# no case-folding expansion. `include.path` and `includeIf.*` pull in a file
# that can set core.hooksPath where the key itself never appears in argv
# (audit-c36f6a78).
BP_NOVERIFY_RE='^--no-v(e(r(i(f(y)?)?)?)?)?(=.*)?$'
BP_NOGPG_RE='^--no-g(p(g(-(s(i(g(n)?)?)?)?)?)?)?(=.*)?$'
BP_HOOKCFG_RE='[Cc][Oo][Rr][Ee]\.[Hh][Oo][Oo][Kk][Ss][Pp][Aa][Tt][Hh]'
BP_HOOKCFG_RE+='|[Ii][Nn][Cc][Ll][Uu][Dd][Ee]\.[Pp][Aa][Tt][Hh]|[Ii][Nn][Cc][Ll][Uu][Dd][Ee][Ii][Ff]\.'
BP_HOOKCFG_RE+='|[Cc][Oo][Mm][Mm][Ii][Tt]\.[Gg][Pp][Gg][Ss][Ii][Gg][Nn][[:space:]]*=[[:space:]]*([Ff][Aa][Ll][Ss][Ee]|[Nn][Oo]|[Oo][Ff][Ff]|0)'
# An alias renames a subcommand, so every check keyed on `add`/`commit` misses
# `git -c alias.st=add st` (audit-8559f9b1). Matched per word, after `=` too
# for `--config-env=alias.x=VAR`.
BP_ALIASCFG_RE='(^|=)[Aa][Ll][Ii][Aa][Ss]\.'

BP_R_NET="Network fetchers are banned in shell commands (.claude/rules/context-mode.md). Use ctx_fetch_and_index(url, source), or ctx_execute(language: \"javascript\") with fetch()."
BP_R_NPM="This repo uses Yarn Berry, never npm (.claude/rules/no-npm.md). Use yarn / yarn add / yarn dlx <package>."
BP_R_PIP="Python packages come from config/mise/default-python-packages, never pip or uv installs by hand (.claude/rules/mise-packages.md)."
BP_R_BYPASS="The command bypasses the project's hook chain (.claude/rules/no-hook-bypass.md). Fix the failing hook instead."
BP_R_STAGE="Stage with git-hunk, never git add (.claude/rules/git-hunk-commits.md): git-hunk list, then git-hunk commit <hash>... -m '...'."
BP_R_SECRETS="The command names a secrets.d tree or a real secrets file, which hold live credentials (.claude/rules/secrets-files.md). Ask the user instead."
BP_R_PROTECTED="The command writes to a protected path — vendored, lock, submodule or git hook file (.claude/rules/vendored-files.md, .claude/rules/no-hook-bypass.md). Refresh vendored files from upstream instead."

# Extract the first word (the command name) of a space-joined segment.
first_word()
{
  local segment=$1
  printf '%s' "$segment" | awk '{print $1}'
  return 0
}

# Reduce a command token to the bare name the routing lists are written
# against: `/bin/cat` and `\cat` are `cat`. Quotes are stripped to a fixed
# point at both ends, since a split string can nest them (`'"cat"`).
normalise_cmd()
{
  local w=${1#\\} prev
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

# Drop git's global options so the subcommand is the second word
# (agent-loopholes-e0092417). The operand-taking options (`git help git`
# SYNOPSIS) are consumed with their operand. Used by the routing tier on a
# space-joined segment; the policy tier walks the argv in _bp_git instead.
git_strip_globals()
{
  local seg=$1 prev
  while :; do
    prev=$seg
    seg=$(printf '%s' "$seg" | sed -E '
      :again
      s/^([^[:space:]]+)[[:space:]]+(-C|-c|--git-dir|--work-tree|--namespace)[[:space:]]+[^[:space:]]+/\1/
      t again
      s/^([^[:space:]]+)[[:space:]]+-[^[:space:]]+/\1/
    ')
    [[ "$seg" == "$prev" ]] && break
  done
  printf '%s' "$seg"
  return 0
}

# _bp_deny WHY — record a violation. The first one wins so the reason names
# what tripped first.
_bp_deny()
{
  [[ -n $BP_REASON ]] || BP_REASON=$1
  return 0
}

# _bp_dyn WHY — note code the parser cannot see through. bash_policy_check
# turns it into a denial only when the code names a policy tool.
_bp_dyn()
{
  [[ -n $BP_DYN ]] || BP_DYN=$1
  return 0
}

# _bp_ast CODE — print CODE's flattened AST records; fail when CODE does not
# parse as bash.
_bp_ast()
{
  local json
  json=$(printf '%s\n' "$1" | shfmt -ln bash --to-json 2> /dev/null) || return 1
  printf '%s' "$json" | jq -r "$BP_JQ_AST"
}

# _bp_walk CODE DEPTH WRAPPED — parse CODE and feed every record to the
# checks. Text that does not parse is kept for the quote-stripping secrets
# scan and handed to the string-literal pass, so a quoted command inside it is
# still seen.
_bp_walk()
{
  local code=$1 depth=$2 wrapped=$3 recs i
  local -a f
  # Dynamic scope: _bp_value, reached from any check below, nests from here.
  local BP_DEPTH=$depth
  if ((depth > 6)); then
    _bp_dyn "command strings nested deeper than the guard follows"
    return 0
  fi
  if ! recs=$(_bp_ast "$code"); then
    ((depth == 0)) && BP_PARSE_FAILED=1
    BP_RAW_SCAN+=$'\n'$code
    _bp_dyn "text that does not parse as shell"
    _bp_foreign "$code" "$((depth + 1))"
    return 0
  fi
  while IFS=$'\x1f' read -r -a f; do
    ((${#f[@]} > 0)) || continue
    for i in "${!f[@]}"; do
      f[i]=${f[i]//$'\x1e'/$'\n'}
    done
    case ${f[0]} in
      C) ((${#f[@]} > 2)) && _bp_call "$depth" "$wrapped" "${f[1]}" "${f[@]:2}" ;;
      A)
        BP_ASSIGNS+=" ${f[1]-}"
        BP_SCAN+=$'\n'${f[2]-}
        _bp_value "${f[2]-}"
        ;;
      R) _bp_redir "${f[1]-}" "${f[2]-}" ;;
      W) BP_SCAN+=$'\n'${f[1]-} ;;
      *) ;;
    esac
  done <<< "$recs"
  return 0
}

# _bp_value VALUE — the value half of a KEY=VALUE word: an assignment, an
# `env` operand, `git -c key=value`, a `git config` value. Whatever reads it
# may run it as a command (MANPAGER, GIT_EDITOR, core.pager, sequence.editor,
# GIT_SSH_COMMAND, ...), and enumerating those keys would miss the next one,
# so every value is parsed as command text and held to the same checks.
# Only its denials count. Most values are not commands (`LC_ALL=C`,
# `PATH=$HOME/bin:$PATH`), so the unseeable shapes, routing segments and
# per-command state the walk records are put back afterwards. A value naming
# no policy tool cannot be denied, so it costs no parse.
_bp_value()
{
  local v=$1 dyn=$BP_DYN
  local -a v_segs v_wrap v_keep v_cdir
  [[ $v =~ $BP_TRIGGER_RE || $v =~ (^|[[:space:]/])(https?|xh)([[:space:]]|$) ]] || return 0
  v_segs=(${BP_SEGMENTS[@]+"${BP_SEGMENTS[@]}"})
  v_wrap=(${BP_WRAPPED[@]+"${BP_WRAPPED[@]}"})
  v_keep=(${BP_KEEP[@]+"${BP_KEEP[@]}"})
  v_cdir=(${BP_GIT_CDIR[@]+"${BP_GIT_CDIR[@]}"})
  _bp_walk "$v" "$((${BP_DEPTH:-0} + 1))" 1
  BP_DYN=$dyn
  BP_SEGMENTS=(${v_segs[@]+"${v_segs[@]}"})
  BP_WRAPPED=(${v_wrap[@]+"${v_wrap[@]}"})
  BP_KEEP=(${v_keep[@]+"${v_keep[@]}"})
  BP_GIT_CDIR=(${v_cdir[@]+"${v_cdir[@]}"})
  return 0
}

# _bp_redir OP TARGET — a redirect that writes to a protected path. The
# routine `2>&1` and `> /dev/null` never reach the predicate.
_bp_redir()
{
  local op=$1 target=$2
  BP_SCAN+=$'\n'$target
  [[ $op =~ $BP_WRITE_OPS_RE ]] || return 0
  case $target in
    /dev/null | /dev/std* | [0-9] | -) return 0 ;;
    *) ;;
  esac
  if _bp_protected "$target"; then
    _bp_deny "$BP_R_PROTECTED"
  fi
  return 0
}

# _bp_protected WORD... — succeed when a word names a protected path, read as
# given or, when the caller set BP_CWD (the ctx tools' `cwd`), relative to it:
# `echo x > setup.py` run in tools/dotbot names no protected text of its own
# (audit-80f9f36c). Absolute and home paths ignore the cwd.
_bp_protected()
{
  local a
  protected_referenced "$*" && return 0
  for a in "$@"; do
    # The normaliser reads `{...}` as a brace expansion and collapses it to
    # `*`, which swallowed the target of awk's `{print > "yarn.lock"}`.
    if [[ $a == *[{}]* ]] && protected_referenced "${a//[\{\}]/ }"; then
      return 0
    fi
    [[ -n ${BP_CWD:-} ]] || continue
    case $a in
      /* | '~'* | -*) ;;
      *) protected_referenced "$BP_CWD/$a" && return 0 ;;
    esac
  done
  return 1
}

# _bp_peel_flags — drop leading option and numeric words from BP_W, keeping at
# least one word (`timeout 5 rg`, `nice -n 5 git push`).
_bp_peel_flags()
{
  while ((${#BP_W[@]} > 1)) && [[ ${BP_W[0]} == -* || ${BP_W[0]} =~ ^[0-9]+[a-z]?$ ]]; do
    BP_SCAN+=" ${BP_W[0]}"
    BP_W=("${BP_W[@]:1}")
  done
  return 0
}

# _bp_call DEPTH WRAPPED HEREDOC ARGV... — peel wrappers that run their
# arguments as a command, recursing into command strings, then check what is
# left with _bp_final.
#
# `eval`, `watch`, `trap`, `env -S` and a shell given `-c` take a string that
# is itself code, so it is parsed. `sudo`, `xargs`, `timeout` and friends take
# an argv, so the wrapper and its own options are dropped; an option operand
# the generic rule cannot recognise (`stdbuf -o L`) is left in first position
# with the wrapped flag set, and the routing tier refuses it rather than guess.
# `command -v X` is a probe that never runs X, so it is not peeled.
_bp_call()
{
  local depth=$1 wrapped=$2 hdoc=$3 fw a s q i n
  shift 3
  BP_W=("$@")
  local -a orig sub
  while ((${#BP_W[@]} > 0)); do
    fw=${BP_W[0]##*/}
    case $fw in
      env)
        wrapped=1
        BP_SCAN+=" ${BP_W[0]}"
        BP_W=("${BP_W[@]:1}")
        while ((${#BP_W[@]} > 0)); do
          a=${BP_W[0]}
          s=""
          case $a in
            -S | --split-string)
              s=${BP_W[1]-}
              BP_W=("${BP_W[@]:2}")
              ;;
            -S* | --split-string=*)
              s=${a#-S}
              s=${s#--split-string=}
              BP_W=("${BP_W[@]:1}")
              ;;
            -u | --unset | -C | --chdir)
              BP_SCAN+=" $a ${BP_W[1]-}"
              BP_W=("${BP_W[@]:2}")
              continue
              ;;
            -*)
              BP_SCAN+=" $a"
              BP_W=("${BP_W[@]:1}")
              continue
              ;;
            *)
              if [[ $a =~ ^[A-Za-z_][A-Za-z_0-9]*= ]]; then
                BP_ASSIGNS+=" ${a%%=*}"
                BP_SCAN+=" $a"
                _bp_value "${a#*=}"
                BP_W=("${BP_W[@]:1}")
                continue
              fi
              break
              ;;
          esac
          # -S: the operand is a command line env splits itself; the words
          # after it are appended as-is, so they are re-quoted.
          for a in ${BP_W[@]+"${BP_W[@]}"}; do
            printf -v q '%q' "$a"
            s+=" $q"
          done
          _bp_walk "$s" "$((depth + 1))" 1
          return 0
        done
        ;;
      command)
        [[ ${BP_W[1]-} == -v || ${BP_W[1]-} == -V ]] && break
        orig=("${BP_W[@]}")
        wrapped=1
        BP_W=("${BP_W[@]:1}")
        if ((${#BP_W[@]} == 0)); then
          BP_W=("${orig[@]}")
          break
        fi
        _bp_peel_flags
        ;;
      eval)
        s="${BP_W[*]:1}"
        _bp_walk "$s" "$((depth + 1))" 1
        return 0
        ;;
      watch)
        BP_W=("${BP_W[@]:1}")
        ((${#BP_W[@]} > 0)) || return 0
        _bp_peel_flags
        s="${BP_W[*]}"
        _bp_walk "$s" "$((depth + 1))" 1
        return 0
        ;;
      trap)
        BP_W=("${BP_W[@]:1}")
        while ((${#BP_W[@]} > 0)) && [[ ${BP_W[0]} == -* ]]; do
          BP_W=("${BP_W[@]:1}")
        done
        ((${#BP_W[@]} > 0)) || return 0
        BP_SCAN+=" ${BP_W[*]:1}"
        _bp_walk "${BP_W[0]}" "$((depth + 1))" 1
        return 0
        ;;
      bash | sh | zsh | dash | ksh | fish)
        n=${#BP_W[@]}
        i=1
        while ((i < n)); do
          a=${BP_W[i]}
          case $a in
            -o | +o | -O | +O | --rcfile | --init-file) i=$((i + 2)) ;;
            --)
              i=$((i + 1))
              break
              ;;
            --command | -*c*)
              [[ $a == --command || $a != --* ]] || {
                i=$((i + 1))
                continue
              }
              _bp_walk "${BP_W[i + 1]-}" "$((depth + 1))" 1
              return 0
              ;;
            -* | +*) i=$((i + 1)) ;;
            *) break ;;
          esac
        done
        # No script operand: the shell reads its commands from stdin, which
        # is a heredoc the parser can read or a pipe it cannot.
        if ((i >= n)); then
          if [[ -n $hdoc ]]; then
            _bp_walk "$hdoc" "$((depth + 1))" 1
          else
            _bp_dyn "a shell reading commands from stdin"
          fi
        fi
        break
        ;;
      find)
        # -exec/-execdir/-ok/-okdir run their words as a command per file,
        # up to `;` or `+`.
        n=${#BP_W[@]}
        i=1
        while ((i < n)); do
          case ${BP_W[i]} in
            -exec | -execdir | -ok | -okdir)
              sub=()
              i=$((i + 1))
              while ((i < n)) && [[ ${BP_W[i]} != ";" && ${BP_W[i]} != "+" ]]; do
                sub+=("${BP_W[i]}")
                i=$((i + 1))
              done
              if ((${#sub[@]} > 0)); then
                orig=("${BP_W[@]}")
                _bp_call "$depth" 0 "" "${sub[@]}"
                BP_W=("${orig[@]}")
              fi
              ;;
            *) ;;
          esac
          i=$((i + 1))
        done
        break
        ;;
      sudo | doas | xargs | nohup | builtin | exec | time | timeout | stdbuf | nice | ionice)
        orig=("${BP_W[@]}")
        wrapped=1
        BP_SCAN+=" ${BP_W[0]}"
        BP_W=("${BP_W[@]:1}")
        if ((${#BP_W[@]} == 0)); then
          BP_W=("${orig[@]}")
          break
        fi
        _bp_peel_flags
        ;;
      *) break ;;
    esac
  done
  if ((${#BP_W[@]} > 0)); then
    _bp_final "$depth" "$wrapped" "$hdoc" "${BP_W[@]}"
  fi
  return 0
}

# _bp_final DEPTH WRAPPED HEREDOC ARGV... — record and check one resolved
# command.
_bp_final()
{
  local depth=$1 wrapped=$2 hdoc=$3 fw seg a i k lookup
  shift 3
  local -a w=("$@")
  fw=${w[0]##*/}

  _bp_check_argv "${w[@]}"
  BP_SCAN+=$'\n'"${BP_KEEP[*]}"
  seg="${w[*]}"
  BP_SEGMENTS+=("$seg")
  BP_WRAPPED+=("$wrapped")

  case $fw in
    git | git-hunk | prek | pre-commit) BP_HOOKED=1 ;;
    *'$'*)
      # A command word from a variable or substitution: what runs is decided
      # at run time.
      for a in "${w[@]:1}"; do
        if [[ $a =~ $BP_STAGE_WORD_RE ]]; then
          _bp_deny "The command word '${w[0]}' is computed at run time and its arguments name '$a'; the guard cannot see what runs (.claude/rules/no-hook-bypass.md). Spell the command out."
        fi
      done
      _bp_dyn "a command word built from a variable or substitution"
      ;;
    python | python[0-9]* | node | perl | ruby)
      # Inline code is another language: scan its string literals.
      for ((i = 1; i < ${#w[@]}; i++)); do
        if [[ ${w[i]} =~ ^(-[A-Za-z]*[ceE]|--eval)$ ]]; then
          _bp_foreign "${w[i + 1]-}" "$((depth + 1))"
          break
        fi
      done
      [[ -n $hdoc ]] && _bp_foreign "$hdoc" "$((depth + 1))"
      ;;
    source | .)
      for a in "${w[@]:1}"; do
        [[ $a == *'$'* || $a == *'<('* ]] && _bp_dyn "source of generated code"
      done
      ;;
    *) ;;
  esac

  # A wrapper whose own operands the generic rule cannot peel (`sudo -u root
  # -g wheel git add`, `stdbuf -o L -e L git add`, `xargs -I {} git add {}`)
  # leaves operands in front of the wrapped command, so every suffix of the
  # argv is re-checked. Two dropped words were not enough for a wrapper with
  # two operand-taking options (agent-loopholes-2b2e90ee).
  #
  # Any other command can run its arguments as a command too — `doppler run
  # --`, `direnv exec .`, `uvx --from x`, a runner nobody has heard of — and
  # every fixed runner list missed the next one (audit-a5c76774). So no runner
  # is named; each later word that starts a policy command is checked as one:
  #   - a verb tool (git, pip, uv) from that word on; its verb keeps a mention
  #     (`rg -n git local/bin`) from firing;
  #   - a name-only ban (curl, npm) as a bare word, since it has no verb and
  #     `uvx --from x curl` runs it with nothing after it;
  #   - a shell's -c string and eval's words, which are code;
  #   - VAR=value words, for the env-bypass check `env SKIP=1` would get.
  # The last three would refuse every search for these names, so they skip
  # commands that never execute an operand (_bp_lookup). That list is closed in
  # the safe direction: a lookup missing from it costs a reroute, not a hole.
  # A peeled wrapper's leftover operand is no lookup (`sudo -u which`).
  lookup=0
  [[ $wrapped -eq 0 ]] && _bp_lookup "${w[@]}" && lookup=1
  if [[ -z $BP_REASON ]]; then
    for ((k = 1; k < ${#w[@]}; k++)); do
      a=${w[k]##*/}
      if ((lookup == 0)); then
        [[ ${w[k]} =~ ^[A-Za-z_][A-Za-z_0-9]*= ]] && BP_ASSIGNS+=" ${w[k]%%=*}"
        [[ ${w[k]} =~ ^[A-Za-z_][A-Za-z_0-9.-]*= ]] && _bp_value "${w[k]#*=}"
        case $a in
          git | git-hunk | prek | pre-commit) BP_HOOKED=1 ;;
          eval) _bp_walk "${w[*]:k+1}" "$((depth + 1))" 1 ;;
          bash | sh | zsh | dash | ksh | fish)
            if [[ ${w[k + 1]-} == --command || ${w[k + 1]-} =~ ^-[A-Za-z]*c[A-Za-z]*$ ]]; then
              _bp_walk "${w[k + 2]-}" "$((depth + 1))" 1
            fi
            ;;
          *) ;;
        esac
      fi
      if [[ $wrapped -eq 1 || $a =~ $BP_VERB_TOOL_RE ]]; then
        _bp_check_argv "${w[@]:k}"
      elif ((lookup == 0)) && [[ $a =~ $BP_NET_RE || $a =~ $BP_NPM_RE ]]; then
        _bp_check_argv "${w[@]:k}"
      fi
      [[ -n $BP_REASON ]] && break
    done
  fi

  if [[ ${w[0]} == *node_modules/.bin/bats ]]; then
    _bp_deny "Use bare \`bats\` from PATH (mise); node_modules/.bin/bats is broken (fails with 'rm: command not found')."
  fi

  if [[ $seg =~ $BP_WRITE_SEG_RE ]] && ((${#w[@]} > 1)) && _bp_protected "${w[@]:1}"; then
    _bp_deny "$BP_R_PROTECTED"
  fi
  return 0
}

# _bp_lookup ARGV... — succeed when the command only looks a name up or
# searches text for it and never executes an operand: `which curl npm`, `rg
# npm docs/`, `git log -S curl -- docs/`. The options that make one of these
# run a command (`rg --pre`, `fd --exec`, `man -P`) disqualify it.
_bp_lookup()
{
  local tool=${1##*/} a verb="" i runs
  case $tool in
    which | type | whereis | echo | printf | grep | egrep | fgrep) return 0 ;;
    command) [[ ${2-} == -v || ${2-} == -V ]] ;;
    mise) [[ ${2-} == which || ${2-} == where ]] ;;
    rg | fd | man)
      runs='^(-P.*|--pager.*)$'
      [[ $tool == rg ]] && runs='^--pre(=.*)?$'
      [[ $tool == fd ]] && runs='^(--exec.*|-[^-]*[xX].*)$'
      for a in "${@:2}"; do
        [[ $a =~ $runs ]] && return 1
      done
      return 0
      ;;
    git)
      for ((i = 2; i <= $#; i++)); do
        a=${!i}
        case $a in
          -C | -c | --git-dir | --work-tree | --namespace) i=$((i + 1)) ;;
          -*) ;;
          *)
            verb=$a
            break
            ;;
        esac
      done
      [[ $verb =~ ^(log|grep|show|diff|blame)$ ]]
      ;;
    *) return 1 ;;
  esac
}

# _bp_check_argv ARGV... — the per-command policy. Sets BP_KEEP to the words
# the secrets scan should see: commit messages are dropped, since a message
# about the secrets rule or the --no-verify ban is prose, not a path or flag
# (agent-hooks-84fa86e9).
_bp_check_argv()
{
  local fw sub i
  local -a w=("$@")
  BP_KEEP=("${w[@]}")
  fw=${w[0]##*/}
  sub=${w[1]-}
  [[ $fw =~ $BP_NET_RE ]] && _bp_deny "$BP_R_NET"
  [[ $fw =~ $BP_NPM_RE ]] && _bp_deny "$BP_R_NPM"
  case $fw in
    # mise installs versioned binaries (pip3.12, python3.12), and python takes
    # `-mpip` as one word (audit-8f8345da).
    pip | pip[0-9]*) [[ $sub == install ]] && _bp_deny "$BP_R_PIP" ;;
    python | python[0-9]*)
      for ((i = 1; i + 1 < ${#w[@]}; i++)); do
        if [[ ${w[i]} == -mpip && ${w[i + 1]} == install ]] \
          || [[ ${w[i]} == -m && ${w[i + 1]} == pip && ${w[i + 2]-} == install ]]; then
          _bp_deny "$BP_R_PIP"
        fi
      done
      ;;
    uv) [[ ($sub == tool || $sub == pip) && ${w[2]-} == install ]] && _bp_deny "$BP_R_PIP" ;;
    prek | pre-commit)
      [[ $sub == uninstall ]] && _bp_deny "Uninstalling the hook runner bypasses every commit-time gate (.claude/rules/no-hook-bypass.md)."
      ;;
    git) _bp_git "${w[@]}" ;;
    git-hunk) _bp_hunk "${w[@]}" ;;
    *) ;;
  esac
  return 0
}

# _bp_bypass_args ARGS... — deny when an argument is a hook-bypass flag or a
# hook-disabling config key.
_bp_bypass_args()
{
  local a
  for a in "$@"; do
    if [[ $a =~ $BP_NOVERIFY_RE || $a =~ $BP_NOGPG_RE || $a =~ $BP_HOOKCFG_RE ]]; then
      _bp_deny "$BP_R_BYPASS"
    fi
  done
  return 0
}

# _bp_long TOKEN NAME MIN — succeed when TOKEN (`--xyz`) is an abbreviation of
# `--NAME` at least MIN characters long; git accepts any unambiguous prefix.
_bp_long()
{
  local t=${1#--}
  [[ ${#t} -ge $3 && $2 == "$t"* ]]
}

# _bp_commit_opts ARGS... — parse `git commit` (or `git-hunk commit`)
# options. Sets BP_C_KEEP (every word but the message values), BP_C_FLAGS
# (short flags seen, plus a/i/o/p for --all/--include/--only/
# --pathspec-from-file) and BP_C_OPERANDS (the non-option count).
_bp_commit_opts()
{
  local a c j kept stop i=0 n ddash=0
  local -a w=("$@")
  n=${#w[@]}
  BP_C_KEEP=()
  BP_C_FLAGS=""
  BP_C_OPERANDS=0
  while ((i < n)); do
    a=${w[i]}
    if ((ddash)); then
      BP_C_KEEP+=("$a")
      BP_C_OPERANDS=$((BP_C_OPERANDS + 1))
      i=$((i + 1))
      continue
    fi
    case $a in
      --) ddash=1 ;;
      --*)
        c=${a%%=*}
        if _bp_long "$c" message 1; then
          [[ $a == *=* ]] || i=$((i + 1))
        else
          BP_C_KEEP+=("$a")
          _bp_long "$c" all 3 && BP_C_FLAGS+="a"
          _bp_long "$c" include 3 && BP_C_FLAGS+="i"
          _bp_long "$c" only 1 && BP_C_FLAGS+="o"
          _bp_long "$c" pathspec-from-file 4 && BP_C_FLAGS+="p"
          if [[ $a != *=* ]] && {
            _bp_long "$c" file 3 || _bp_long "$c" author 2 || _bp_long "$c" date 2 \
              || _bp_long "$c" reuse-message 3 || _bp_long "$c" reedit-message 3 \
              || _bp_long "$c" fixup 3 || _bp_long "$c" squash 2 || _bp_long "$c" template 2 \
              || _bp_long "$c" trailer 2 || _bp_long "$c" cleanup 2 \
              || _bp_long "$c" pathspec-from-file 4
          }; then
            BP_C_KEEP+=("${w[i + 1]-}")
            i=$((i + 1))
          fi
        fi
        ;;
      -?*)
        # A short-option cluster: `-am msg`, `-mmsg`, `-nm x`. m takes the
        # message (attached or next word); F/C/c/t take a kept value; S and u
        # take an optional attached value.
        kept=-
        stop=0
        j=1
        while ((j < ${#a})); do
          c=${a:j:1}
          case $c in
            m)
              ((j + 1 < ${#a})) || i=$((i + 1))
              [[ $kept != - ]] && BP_C_KEEP+=("$kept")
              stop=1
              break
              ;;
            F | C | c | t)
              BP_C_KEEP+=("$a")
              if ((j + 1 >= ${#a})); then
                BP_C_KEEP+=("${w[i + 1]-}")
                i=$((i + 1))
              fi
              stop=1
              break
              ;;
            S | u) break ;;
            *)
              BP_C_FLAGS+=$c
              kept+=$c
              ;;
          esac
          j=$((j + 1))
        done
        ((stop)) || BP_C_KEEP+=("$a")
        ;;
      *)
        BP_C_KEEP+=("$a")
        BP_C_OPERANDS=$((BP_C_OPERANDS + 1))
        ;;
    esac
    i=$((i + 1))
  done
  return 0
}

# _bp_git ARGV... — git: global options, then the subcommand checks.
_bp_git()
{
  local -a w=("$@") rest=() globals=() cdir=()
  local i=1 n=$# a sub
  while ((i < n)); do
    a=${w[i]}
    case $a in
      -C | -c | --git-dir | --work-tree | --namespace | --config-env | --exec-path)
        globals+=("$a" "${w[i + 1]-}")
        [[ $a == -C ]] && cdir+=(-C "${w[i + 1]-}")
        # core.pager, core.editor, sequence.editor, diff.external, ... run
        # their value as a command.
        [[ $a == -c ]] && _bp_value "${w[i + 1]#*=}"
        i=$((i + 2))
        ;;
      -*)
        globals+=("$a")
        i=$((i + 1))
        ;;
      *) break ;;
    esac
  done
  # The alias lookup reads the repository `-C` names, not the hook's cwd.
  BP_GIT_CDIR=(${cdir[@]+"${cdir[@]}"})
  # `-c core.hooksPath=…` is itself a global option.
  _bp_bypass_args ${globals[@]+"${globals[@]}"}
  for a in ${globals[@]+"${globals[@]}"}; do
    [[ $a =~ $BP_ALIASCFG_RE ]] && _bp_deny "A git alias defined on the command line renames the subcommand past every check (.claude/rules/git-hunk-commits.md). Spell the subcommand out."
  done
  sub=${w[i]-}
  ((i + 1 < n)) && rest=("${w[@]:i+1}")
  case $sub in
    *'$'*) _bp_deny "The git subcommand '$sub' is computed at run time, so the guard cannot check it (.claude/rules/git-hunk-commits.md). Spell it out." ;;
    *) ;;
  esac
  _bp_git_alias "$sub" ${rest[@]+"${rest[@]}"}

  if [[ $sub == commit ]]; then
    _bp_commit_opts ${rest[@]+"${rest[@]}"}
    BP_KEEP=("${w[0]}" ${globals[@]+"${globals[@]}"} "$sub" ${BP_C_KEEP[@]+"${BP_C_KEEP[@]}"})
    _bp_bypass_args ${BP_C_KEEP[@]+"${BP_C_KEEP[@]}"}
    [[ $BP_C_FLAGS == *n* ]] && _bp_deny "\`git commit -n\` is --no-verify and bypasses the hook chain (.claude/rules/no-hook-bypass.md)."
    [[ $BP_C_FLAGS == *a* ]] && _bp_deny "\`git commit -a\` stages by file, not by hunk (.claude/rules/git-hunk-commits.md). Use git-hunk commit <hash>... -m '...'."
    # `git commit <path>`, `-i`/`-o` and --pathspec-from-file stage whole
    # files exactly like `-a` (agent-loopholes-63eb3265).
    if [[ $BP_C_FLAGS == *[iop]* || $BP_C_OPERANDS -gt 0 ]]; then
      _bp_deny "\`git commit\` with a pathspec, -i/--include or -o/--only stages whole files, not hunks (.claude/rules/git-hunk-commits.md). Use git-hunk commit <hash>... -m '...'."
    fi
    return 0
  fi

  if [[ $sub == config ]]; then
    # A stored value runs later, as `-c key=value` would now.
    for a in ${rest[@]+"${rest[@]}"}; do
      [[ $a == -* ]] || _bp_value "$a"
    done
    _bp_git_config ${rest[@]+"${rest[@]}"}
    return 0
  fi
  _bp_bypass_args ${rest[@]+"${rest[@]}"}
  # `stage` is git's alias for add.
  [[ $sub == update-index ]] && _bp_update_index ${rest[@]+"${rest[@]}"}
  if [[ $sub == add || $sub == stage ]]; then
    _bp_deny "$BP_R_STAGE"
  fi
  return 0
}

# _bp_git_config ARGS... — `git config`. A read (`--get`, `--list`, `get`)
# sets nothing, so naming core.hooksPath or an alias key is allowed there:
# checking the hook state is what commit-format.md asks for
# (audit-b668407e). Any other form may write, so the bypass keys and alias
# definitions are refused (audit-8559f9b1).
_bp_git_config()
{
  local a read=0 write=0
  for a in "$@"; do
    case $a in
      --get | --get-all | --get-regexp | --get-urlmatch | --get-color | --get-colorbool | --list | -l | get | list) read=1 ;;
      --add | --replace-all | --unset | --unset-all | --rename-section | --remove-section | --edit | -e | set | unset | rename-section | remove-section | edit) write=1 ;;
      *) ;;
    esac
  done
  ((read && !write)) && return 0
  _bp_bypass_args "$@"
  for a in "$@"; do
    [[ $a =~ $BP_ALIASCFG_RE ]] && _bp_deny "Defining a git alias renames a subcommand past every check (.claude/rules/git-hunk-commits.md). Spell the subcommand out."
  done
  return 0
}

# _bp_update_index ARGS... — update-index records the worktree content of
# every path operand, so it is `git add` under another name (audit-4bd3f195).
# Allowed: the refresh forms with no paths, and the flag-only marks
# (assume-unchanged, skip-worktree, fsmonitor-valid) whose paths are not
# re-hashed. `--add` is matched by any unambiguous prefix, `--ad` up.
_bp_update_index()
{
  local a mark=0 skip=0
  for a in "$@"; do
    if ((skip)); then
      skip=0
      continue
    fi
    case $a in
      --index-version) skip=1 ;;
      --assume-unchanged | --no-assume-unchanged | --skip-worktree | --no-skip-worktree | --fsmonitor-valid | --no-fsmonitor-valid) mark=1 ;;
      --again | -g | --cacheinfo* | --index-info | --stdin | --replace | --remove | --force-remove | --chmod*)
        _bp_deny "$BP_R_STAGE"
        ;;
      --) ;;
      -*) [[ $a =~ ^--add?(=.*)?$ ]] && _bp_deny "$BP_R_STAGE" ;;
      *) ((mark)) || _bp_deny "$BP_R_STAGE" ;;
    esac
  done
  return 0
}

# _bp_git_alias SUB ARGS... — a persistent alias (`git config alias.st add`
# made earlier, or in the user's global config) renames the subcommand the
# same way the `-c` form does, so it is resolved and its expansion checked as
# the command that really runs. A `!` alias is shell code and is parsed as
# such. git ignores an alias that shadows a builtin, so a hit on one is
# checked in vain but harmlessly.
_bp_git_alias()
{
  local sub=$1 exp a q s=""
  shift
  [[ $sub =~ ^[A-Za-z0-9][A-Za-z0-9_-]*$ ]] || return 0
  if ((${BP_ALIAS_DEPTH:-0} > 4)); then
    _bp_dyn "git aliases nested deeper than the guard follows"
    return 0
  fi
  exp=$(git ${BP_GIT_CDIR[@]+"${BP_GIT_CDIR[@]}"} config --get "alias.$sub" 2> /dev/null) || return 0
  [[ -n $exp ]] || return 0
  for a in "$@"; do
    printf -v q '%q' "$a"
    s+=" $q"
  done
  if [[ $exp == '!'* ]]; then
    s="${exp#!}$s"
  else
    s="git $exp$s"
  fi
  # The expansion is checked for policy only; its commands are not the
  # user's segments, so the routing tier never sees them, and the caller's
  # BP_KEEP survives the nested checks.
  local -a seg=(${BP_SEGMENTS[@]+"${BP_SEGMENTS[@]}"}) wr=(${BP_WRAPPED[@]+"${BP_WRAPPED[@]}"})
  local -a keep=(${BP_KEEP[@]+"${BP_KEEP[@]}"})
  BP_ALIAS_DEPTH=$((${BP_ALIAS_DEPTH:-0} + 1))
  _bp_walk "$s" 1 1
  BP_ALIAS_DEPTH=$((BP_ALIAS_DEPTH - 1))
  BP_SEGMENTS=(${seg[@]+"${seg[@]}"})
  BP_WRAPPED=(${wr[@]+"${wr[@]}"})
  BP_KEEP=(${keep[@]+"${keep[@]}"})
  return 0
}

# _bp_hunk ARGV... — git-hunk: hashes are its operands, so only the bypass
# scan applies, with `commit` messages dropped first.
_bp_hunk()
{
  local -a w=("$@") rest=()
  (($# > 2)) && rest=("${w[@]:2}")
  if [[ ${w[1]-} == commit ]]; then
    _bp_commit_opts ${rest[@]+"${rest[@]}"}
    BP_KEEP=("${w[0]}" commit ${BP_C_KEEP[@]+"${BP_C_KEEP[@]}"})
    _bp_bypass_args ${BP_C_KEEP[@]+"${BP_C_KEEP[@]}"}
    [[ $BP_C_FLAGS == *n* ]] && _bp_deny "$BP_R_BYPASS"
    return 0
  fi
  _bp_bypass_args ${rest[@]+"${rest[@]}"}
  return 0
}

# _bp_foreign CODE DEPTH — the string-literal pass for non-shell code.
_bp_foreign()
{
  local code=$1 depth=$2 recs line
  if ((depth > 6)); then
    return 0
  fi
  if ! recs=$(printf '%s' "$code" | jq -Rrs "$BP_JQ_FOREIGN" 2> /dev/null); then
    _bp_deny "The guard could not scan embedded code for policy commands; it fails closed."
    return 0
  fi
  if [[ $code =~ $BP_ENV_BYPASS_TEXT_RE && $code =~ $BP_TRIGGER_RE ]]; then
    _bp_deny "$BP_R_BYPASS"
  fi
  while IFS= read -r line; do
    case $line in
      D) _bp_deny "The code passes a non-literal command to a subprocess or exec call and names a policy tool; the guard cannot see what runs (.claude/rules/no-hook-bypass.md). Pass a literal argv." ;;
      L$'\x1f'*)
        line=${line#L$'\x1f'}
        _bp_walk "${line//$'\x1e'/$'\n'}" "$((depth + 1))" 1
        ;;
      *) ;;
    esac
  done <<< "$recs"
  return 0
}

# bash_policy_check CODE [shell|foreign] — succeed and set BP_REASON when CODE
# violates the policy tier. The deny reason never offers BASH_OK: these rules
# bind regardless of any escape.
bash_policy_check()
{
  local code=$1 mode=${2:-shell} name
  BP_REASON=""
  BP_DYN=""
  BP_SCAN=""
  BP_RAW_SCAN=""
  BP_ASSIGNS=""
  BP_HOOKED=0
  BP_PARSE_FAILED=0
  BP_SEGMENTS=()
  BP_WRAPPED=()

  if [[ $mode == shell ]]; then
    if ! command -v shfmt > /dev/null 2>&1; then
      BP_REASON="shfmt is not on PATH, so the policy tier cannot parse the command; it fails closed. Install it with mise (config/mise/config.toml)."
      return 0
    fi
    _bp_walk "$code" 0 0
  else
    BP_RAW_SCAN=$code
    _bp_foreign "$code" 0
  fi

  # Secrets outrank the per-command reasons: the harm is the read itself. The
  # parsed words are already unquoted, so they are matched as they are; text
  # that never parsed gets the quote-stripping match.
  if secrets_referenced "$BP_SCAN" parsed; then
    BP_REASON=$BP_R_SECRETS
    return 0
  fi
  if [[ -n $BP_RAW_SCAN ]] && secrets_referenced "$BP_RAW_SCAN"; then
    BP_REASON=$BP_R_SECRETS
    return 0
  fi
  if [[ $BP_HOOKED -eq 1 ]]; then
    for name in $BP_ASSIGNS; do
      [[ $name =~ $BP_ENV_BYPASS_RE ]] && _bp_deny "Setting $name around a git or hook-runner command skips the hook chain (.claude/rules/no-hook-bypass.md). Fix the failing hook instead."
    done
  fi
  if [[ -n $BP_DYN && $code =~ $BP_TRIGGER_RE ]]; then
    _bp_deny "The code runs something the guard cannot inspect ($BP_DYN) and names a policy tool (git, npm, pip, curl, ...). Spell the command out so the policy tier can check it."
  fi
  [[ -n $BP_REASON ]]
}
