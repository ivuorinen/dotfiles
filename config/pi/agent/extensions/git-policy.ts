// Blocks the git mandates of the global RULES.md that a tool call shows before it runs.
// The rules are prose in every project; in this repo Claude Code enforces the same
// class with .claude/hooks/lib/bash-policy.sh, which omp never runs.
//
// Every tool call's command text is read (bash `command`, eval and ctx_execute `code`,
// ctx_batch `commands`), so a git command cannot slip through by changing tools.
//
// It reads text, not a parsed command. The text is split into simple commands on
// unquoted separators and quoted strings are blanked before the git checks, so a
// commit message or a search pattern that names a banned command passes. A quoted
// string is checked as a command of its own only when something runs it: `sh(...)`,
// subprocess and child_process calls, `bash -c '...'`, a `sh`/`$` tagged template.
// Aliases, variables, `git -c` config (alias.*, core.hooksPath), a message read from a
// file (-F), argument lists and generated commands all get through. It stops an honest
// mistake, not an agent working around it; the rule itself still binds.
// tests/pi-git-policy.bats holds the cases it must block and must let through.

interface ToolCallEvent {
  input?: { command?: unknown; code?: unknown; commands?: unknown }
}

interface PiApi {
  on: (...args: unknown[]) => void
}

interface GitBan {
  subcommands: string
  flags: RegExp
  reason: string
}

const LITERAL = /'([^']*)'|"((?:[^"\\]|\\.)*)"|`([^`]*)`/g
// What precedes a quoted string that is run as a command.
const RUNNER =
  /(?:\b(?:sh|bash|system|popen|Popen|run|call|check_call|check_output|exec|execSync|spawnSync)\s*\(\s*|\b(?:ba|z|da)?sh\s+-[a-z]*c[a-z]*\s+)$/
const TEMPLATE_RUNNER = /(?:\bsh|\$)$/
// Global options that may sit between `git` and its subcommand (-C dir, -c k=v, --x=y).
const GIT_OPTIONS = String.raw`(?:\s+-[Cc]\s+\S+|\s+-{1,2}[\w-]+(?:=\S+)?)*`
const NO_VERIFY_CALL =
  /\bcommit\s*\([^)]*\b(?:no_verify\s*=\s*True|noVerify\s*:\s*true)\b/
// A trailer starts a message line, so a subject that names the trailer passes.
const SESSION_REFERENCE =
  /(?:^|\n|\\n|['"`])\s*Claude-Session:|claude\.ai\/code\/session_/
const PUBLISHING_COMMAND =
  /\bgit\b[^\n]*\b(?:commit|tag|notes)\b|\bgh\s+(?:pr|issue|release)\s+(?:create|edit|comment)\b|\bcommit\s*\(/
const MAX_NESTING = 3

const GIT_BANS: GitBan[] = [
  {
    subcommands: 'commit|push|merge|am|rebase',
    flags: /\s--no-verify(?=[\s)]|$)/,
    reason:
      '--no-verify skips the git hooks (lint, commitlint, secret scan); let them run',
  },
  {
    subcommands: 'commit',
    flags: /\s-[a-zA-Z]*n[a-zA-Z]*(?=[\s)]|$)/,
    reason: 'git commit -n skips the git hooks; let them run',
  },
  {
    subcommands: 'add',
    flags: /\s(?:--all|-[a-zA-Z]*A[a-zA-Z]*|\.|:\/)(?=[\s)]|$)/,
    reason: 'git add -A, --all and . stage the whole tree; stage the explicit paths',
  },
  {
    subcommands: 'commit',
    flags: /\s(?:--all|-[a-zA-Z]*a[a-zA-Z]*)(?=[\s)]|$)/,
    reason: 'git commit -a and --all commit every tracked change; stage explicit paths',
  },
]

/** Simple commands of a text, split on separators outside quotes so a message's lines stay whole. */
function segments(text: string): string[] {
  const parts: string[] = []
  let start = 0
  let quote = ''
  for (let i = 0; i < text.length; i++) {
    const c = text[i]
    if (quote) {
      if (c === '\\' && quote === '"') i++
      else if (c === quote) quote = ''
    } else if (c === "'" || c === '"' || c === '`') {
      quote = c
    } else if (c === ';' || c === '|' || c === '&' || c === '\n') {
      parts.push(text.slice(start, i))
      start = i + 1
    }
  }
  parts.push(text.slice(start))
  return parts
}

/** The quoted strings in a segment that something runs as a command. */
function commandLiterals(segment: string): string[] {
  const found: string[] = []
  for (const match of segment.matchAll(LITERAL)) {
    const before = segment.slice(0, match.index)
    const template = match[3] !== undefined
    if (template ? TEMPLATE_RUNNER.test(before) : RUNNER.test(before)) {
      found.push(match[1] ?? match[2] ?? match[3] ?? '')
    }
  }
  return found
}

/** The arguments after `git <subcommand>` in a segment, or undefined when it is another command. */
function gitArguments(segment: string, subcommands: string): string | undefined {
  const pattern = new RegExp(String.raw`\bgit${GIT_OPTIONS}\s+(?:${subcommands})\b`)
  const match = pattern.exec(segment)
  return match ? segment.slice(match.index + match[0].length) : undefined
}

/** Why a command text breaks a RULES.md git mandate, or undefined when it does not. */
function violation(text: string, depth = 0): string | undefined {
  for (const segment of segments(text)) {
    // Quoted strings emptied, so message and pattern words never read as flags.
    const bare = segment.replace(LITERAL, "''")
    if (NO_VERIFY_CALL.test(bare)) {
      return "no_verify skips the git hooks in omp's commit helper; let them run"
    }
    if (PUBLISHING_COMMAND.test(bare) && SESSION_REFERENCE.test(segment)) {
      return 'session references (Claude-Session: trailers, claude.ai session links) never leave the machine; drop the line'
    }
    for (const ban of GIT_BANS) {
      const args = gitArguments(bare, ban.subcommands)
      if (args !== undefined && ban.flags.test(args)) return ban.reason
    }
    if (depth < MAX_NESTING) {
      for (const inner of commandLiterals(segment)) {
        const reason = violation(inner, depth + 1)
        if (reason) return reason
      }
    }
  }
  return undefined
}

/** Registers the pre-execution check; a throwing handler makes omp block the call. */
export default function (pi: PiApi) {
  pi.on('tool_call', async (event: ToolCallEvent) => {
    const input = event.input ?? {}
    const commands = Array.isArray(input.commands) ? input.commands : []
    for (const text of [input.command, input.code, ...commands]) {
      if (typeof text !== 'string') continue
      const reason = violation(text)
      if (reason) return { block: true, reason: `git-policy: ${reason}` }
    }
    return undefined
  })
}
