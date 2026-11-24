// repo-managed omp adaptation of the extension `sonar integrate pi` writes
// (sonarqube-cli 1.12.0). It is not the generated file, for five reasons:
// - sonar has no omp target and hardcodes ~/.pi/agent with no env override, a
//   directory omp never reads, so `sonar integrate pi` only leaves a stray dotdir.
// - omp's message_end is notification-only, so the generated message redaction
//   would do nothing. The input event replaces the submitted text instead.
// - omp's read path can end in a selector (`file:50-100`, `file:raw`) or name a
//   member of an archive or database. sonar's hook allows a path that does not
//   exist, so the selector would bypass the scan: scan the file it hangs off.
// - omp reads a missing path by unique suffix match anywhere in the workspace
//   (`secrets.env` -> `sub/secrets.env`), which the same hook allows. tool_result
//   scans the file omp actually read when it recovered the path that way.
// - omp's read lists directories, which pi's does not. Handing a directory to the
//   hook scans the whole tree, so a listing is skipped: it exposes names only.
// Why not omp's own `secrets.enabled` alone: it swaps a fixed list of token shapes
// for placeholders that are restored in tool arguments, never blocks a read, and
// has no SonarQube token shape: an `sqp_` token reaches the model literally.
// Not covered: a read of a URL or an internal scheme (nothing local to scan), one
// path string that omp splits into several files, and print or ACP input, where
// omp emits no input event.
// The scanning itself is `sonar hook pi-*`. Unlike the generated file, a machine
// without `sonar` on PATH runs without it instead of blocking every read, the way
// deja-hook exits 0 without deja. On a sonar bump, diff against a fresh
// `sonar integrate pi` run in a throwaway HOME. The Vortex extensions are not
// installed: this connection has no Vortex entitlement.
import { execFile } from 'node:child_process'
import { existsSync, statSync } from 'node:fs'
import { homedir } from 'node:os'
import { join, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'

// omp gives a handler 30 seconds, so a scan that hangs reports itself first.
const HOOK_TIMEOUT_MS = 25000
const UNICODE_SPACES = /[\u00A0\u2000-\u200A\u202F\u205F\u3000]/g
const NARROW_NO_BREAK_SPACE = '\u202F'
const CURLY_APOSTROPHE = '\u2019'
const SECRETS_NOTICE_BLOCKED_TEMPLATE =
  '[SonarQube] Message blocked: {reason}\nBlocked as a precaution — original content was not sent. Let the user know that SonarQube blocked this message.'
const SECRETS_ERROR_SCANNING_TEMPLATE =
  'could not verify this message for secrets ({reason})'
const NO_BYPASS_SENTENCE =
  'Do not attempt to access this file another way (e.g. via bash) — inform the user of the block and ask before taking any other action. Scan only specific files with sonar analyze secrets <files>. Do not scan whole trees with . or a repository-root path.'

interface ExtensionContext {
  cwd: string
  sessionManager: { getSessionId: () => string }
}

interface PiApi {
  on: (...args: unknown[]) => void
}

interface ToolCallEvent {
  toolName?: string
  input?: { path?: string }
}

interface ToolResultEvent {
  toolName?: string
  details?: {
    isDirectory?: boolean
    resolvedPath?: string
    suffixResolution?: { from: string; to: string }
  }
}

interface InputEvent {
  text?: string
}

interface Decision {
  block: boolean
  reason?: string
  redactedText?: string
}

function runHook<T>(subcommand: string, payload: unknown): Promise<T> {
  const { promise, resolve: done, reject } = Promise.withResolvers<T>()
  const child = execFile(
    'sonar',
    ['hook', ...subcommand.split(' ')],
    { timeout: HOOK_TIMEOUT_MS },
    (error, stdout) => {
      if (error) return reject(error)
      try {
        done(JSON.parse(stdout) as T)
      } catch (parseError) {
        reject(parseError)
      }
    },
  )
  child.stdin?.end(JSON.stringify(payload))
  return promise
}

async function runDecisionHook(subcommand: string, payload: unknown): Promise<Decision> {
  const answer = await runHook<Partial<Decision> | null>(subcommand, payload)
  if (
    typeof answer?.block !== 'boolean' ||
    (answer.redactedText !== undefined && typeof answer.redactedText !== 'string')
  ) {
    throw new Error(`unexpected answer from sonar hook ${subcommand}`)
  }
  return answer as Decision
}

function describeError(error: unknown): string {
  return error instanceof Error ? error.message : String(error)
}

// execFile reports a missing `sonar` as ENOENT.
function sonarIsMissing(error: unknown): boolean {
  return (error as NodeJS.ErrnoException | undefined)?.code === 'ENOENT'
}

function blockedMessage(reason: string): string {
  return SECRETS_NOTICE_BLOCKED_TEMPLATE.replace('{reason}', () => reason)
}

function resolveToCwd(path: string, cwd: string): string {
  let normalized = path.replace(UNICODE_SPACES, ' ')
  if (normalized.startsWith('@')) normalized = normalized.slice(1)
  if (normalized === '~') {
    normalized = homedir()
  } else if (normalized.startsWith('~/')) {
    normalized = join(homedir(), normalized.slice(2))
  } else if (/^file:\/\//.test(normalized)) {
    normalized = fileURLToPath(normalized)
  }
  return resolve(cwd, normalized)
}

function resolveReadPath(path: string, cwd: string): string {
  const resolved = resolveToCwd(path, cwd)
  const nfd = resolved.normalize('NFD')
  const candidates = [
    resolved,
    resolved.replace(/ (AM|PM)\./gi, `${NARROW_NO_BREAK_SPACE}$1.`),
    nfd,
    resolved.replace(/'/g, CURLY_APOSTROPHE),
    nfd.replace(/'/g, CURLY_APOSTROPHE),
  ]
  return candidates.find((candidate) => existsSync(candidate)) ?? resolved
}

// The file a read path scans: the path itself, else the longest `:`-prefix that
// exists, so `secrets.env:1-5`, `secrets.env:raw` and `bundle.zip:inner.txt` all
// scan the file the selector hangs off. A literal file named like a selector wins,
// as it does in omp's read.
function resolveScanPath(path: string, cwd: string): string {
  const full = resolveReadPath(path, cwd)
  if (existsSync(full)) return full
  for (let cut = path.lastIndexOf(':'); cut > 0; cut = path.lastIndexOf(':', cut - 1)) {
    const prefix = resolveReadPath(path.slice(0, cut), cwd)
    if (existsSync(prefix)) return prefix
  }
  return full
}

// omp's read also lists directories (pi's does not), and listing exposes names only.
// Handing a directory to the hook scans the whole tree: slow, and it blocks the
// listing whenever a secret sits anywhere below.
function isDirectory(path: string): boolean {
  try {
    return statSync(path).isDirectory()
  } catch {
    return false
  }
}

async function protectText(text: string, sessionID: string): Promise<string> {
  try {
    const decision = await runDecisionHook('pi-chat-message', { text, sessionID })
    if (decision.block) return blockedMessage(decision.reason ?? 'blocked')
    return decision.redactedText ?? text
  } catch (error) {
    if (sonarIsMissing(error)) return text
    return blockedMessage(
      SECRETS_ERROR_SCANNING_TEMPLATE.replace('{reason}', () => describeError(error)),
    )
  }
}

// Why to refuse a read of filePath, or undefined to allow it. `label` is how the
// reason names the file.
async function readBlockReason(
  filePath: string,
  label: string,
  sessionID: string,
): Promise<string | undefined> {
  try {
    const decision = await runDecisionHook('pi-pre-tool-use', {
      tool: 'read',
      filePath,
      sessionID,
    })
    if (!decision.block) return undefined
    return `${decision.reason ?? 'Sonar blocked this file read.'} ${NO_BYPASS_SENTENCE}`
  } catch (error) {
    if (sonarIsMissing(error)) return undefined
    return `Sonar could not verify ${label} for secrets (${describeError(error)}). Blocking as a precaution. ${NO_BYPASS_SENTENCE}`
  }
}

export default function (pi: PiApi) {
  pi.on('tool_call', async (event: ToolCallEvent, ctx: ExtensionContext) => {
    if (event.toolName !== 'read') return
    const path = event.input?.path
    if (!path) return
    const filePath = resolveScanPath(path, ctx.cwd)
    if (isDirectory(filePath)) return
    const reason = await readBlockReason(
      filePath,
      path,
      ctx.sessionManager.getSessionId(),
    )
    if (reason) return { block: true, reason }
  })

  // omp can read a different file than the path named: a missing path recovers by
  // unique suffix match. The result names the file it read (a display path when
  // resolvedPath is absent), and a recovered path is the only case tool_call could
  // not have scanned. A directory is skipped: sonar must not scan whole trees.
  pi.on('tool_result', async (event: ToolResultEvent, ctx: ExtensionContext) => {
    const suffix = event.details?.suffixResolution
    if (event.toolName !== 'read' || !suffix || event.details?.isDirectory) return
    const readPath = event.details?.resolvedPath ?? resolve(ctx.cwd, suffix.to)
    const reason = await readBlockReason(
      readPath,
      readPath,
      ctx.sessionManager.getSessionId(),
    )
    if (reason) return { content: [{ type: 'text', text: reason }], isError: true }
  })

  // Submission ingress, before commands and templates run. Text that scans clean
  // is left alone: a returned text is trimmed before dispatch.
  pi.on('input', async (event: InputEvent, ctx: ExtensionContext) => {
    if (!event.text) return
    const text = await protectText(event.text, ctx.sessionManager.getSessionId())
    if (text !== event.text) return { text }
  })
}
