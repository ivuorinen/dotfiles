// repo-managed adaptation of `deja install omp-auto` (deja-vu 0.24.2).
// omp-auto writes ~/.omp/agent/extensions/deja/index.js, which ignores PI_CONFIG_DIR
// and hardcodes an absolute launcher path, so it would recreate ~/.omp and carry one
// machine's paths into the repo. This runs the `deja-hook` launcher that ./install
// links into ~/.local/bin instead, by its absolute path so no PATH lookup decides
// what runs. The launcher resolves $DEJA_HOOK_BIN itself, so a stale override still
// falls back to deja. The handlers follow the generated file: on a deja bump, diff
// against a fresh `deja install omp-auto` run in a throwaway HOME.
import { execFile } from 'node:child_process'
import { homedir } from 'node:os'
import { join } from 'node:path'

const DEJA = join(homedir(), '.local', 'bin', 'deja-hook')

interface SessionManager {
  getSessionId?: () => string | undefined
  sessionId?: string
  getSessionFile?: () => string | undefined
  sessionFile?: string
}

interface ExtensionContext {
  cwd?: string
  sessionManager?: SessionManager
  ui: {
    setStatus: (name: string, status: string) => void
    notify: (message: string, level: string) => void
  }
}

interface PiApi {
  on: (...args: unknown[]) => void
  registerCommand: (...args: unknown[]) => void
}

interface TextPart {
  type?: string
  text?: string
}

interface Message {
  role?: string
  content?: TextPart[]
}

interface ContextEvent {
  messages?: Message[]
}

interface HookResponse {
  systemMessage?: string
  hookSpecificOutput?: {
    additionalContext?: string
  }
}

interface ToolResultEvent {
  toolName?: string
  toolCallId?: string
  isError?: boolean
  input?: {
    path?: string
    file_path?: string
    input?: string
  }
  content?: TextPart[]
  details?: {
    exitCode?: number
  }
}

// Asynchronous, so omp keeps drawing while deja answers: execFileSync froze its UI
// for up to 3.6 s a call, which omp logged as ui.loop-blocked.
function run(args: string[], input: string, timeout = 10000): Promise<string> {
  const { promise, resolve } = Promise.withResolvers<string>()
  try {
    const child = execFile(
      DEJA,
      args,
      { encoding: 'utf8', timeout, maxBuffer: 4 * 1024 * 1024 },
      (error, stdout) => resolve(error ? '' : stdout.trim()),
    )
    // A deja that exits before reading its input breaks the pipe. The callback
    // reports that exit, so the write error itself carries nothing new.
    child.stdin?.on('error', () => {})
    child.stdin?.end(input)
  } catch {
    // Memory is optional: an extension that throws here takes the session with
    // it, because extensions run in-process with no isolation.
    resolve('')
  }
  return promise
}

function userText(message: Message | undefined): string {
  if (message?.role !== 'user' || !Array.isArray(message.content)) return ''
  return message.content
    .filter((part) => part?.type === 'text' && typeof part.text === 'string')
    .map((part) => part.text)
    .join('\n')
    .trim()
}

export default function (pi: PiApi) {
  // The same prompt reaches the context event more than once in a turn, once per
  // provider request, so the pending answer is cached: a repeat waits on it rather
  // than asking again or reading the previous prompt's answer.
  let asked = ''
  let recalled = Promise.resolve('')
  // No event carries a session id; the session manager does, and every handler
  // reaches it through ctx. Recall skips what it already showed a session, so
  // without the id the same block goes out on every message.
  let session = ''
  let sessionFile = ''
  const remember = (ctx: ExtensionContext) => {
    try {
      const manager = ctx.sessionManager
      const id = manager?.getSessionId ? manager.getSessionId() : manager?.sessionId
      if (id) session = String(id)
      const file = manager?.getSessionFile
        ? manager.getSessionFile()
        : manager?.sessionFile
      if (file) sessionFile = String(file)
    } catch {
      // memory is optional: never break the session over it
    }
  }
  const sessionID = () => session

  // The footer line deja keeps: sessions, hits and what is still being indexed.
  const statusline = async () =>
    (
      await run(
        ['statusline'],
        JSON.stringify({
          session_id: sessionID(),
          transcript_path: sessionFile,
          cwd: process.cwd(),
        }),
      )
    )
      .split(' · ')
      .slice(0, 3)
      .map((part, i) => (i === 2 ? part.replace(/^(\d+\s+earlier)\b.*/, '$1') : part))
      .join(' · ')

  pi.on('session_start', async (_event: unknown, ctx: ExtensionContext) => {
    try {
      remember(ctx)
      // omp keeps a footer line, so a first index that is still building is
      // visible instead of looking like memory that does not work.
      ctx.ui.setStatus('deja', (await run(['warmup-status'], '')) || (await statusline()))
    } catch {
      // memory is optional: never break the session over it
    }
  })

  // Registered commands show up in omp's prompt box, which is how someone who
  // never read the docs finds this at all.
  pi.registerCommand('deja', {
    description: 'Search your own past coding sessions',
    handler: async (args: string, ctx: ExtensionContext) => {
      const query = (args || '').trim()
      if (!query) {
        ctx.ui.notify('Usage: /deja <what you are looking for>', 'info')
        return
      }
      // The user is waiting on this one, so it gets a longer budget than a
      // hook: a first search can rebuild the index. "--" keeps a query that
      // starts with a dash out of deja's own flag parsing.
      const commandArgs = query.startsWith('-')
        ? ['search', '--', query]
        : ['search', query]
      const found = await run(commandArgs, '', 120000)
      ctx.ui.notify(found || `Nothing in your history matches ${query}`, 'info')
    },
  })

  // Once per session, before the first answer: what this project's recent
  // sessions were about. omp stores what a before_agent_start handler returns as
  // a message of its own, so the digest is in the conversation rather than
  // stapled onto the user's first prompt.
  //
  // Once per session, not once per process: /new, a resume and a fork keep the
  // process and switch the session, and a flag set on the first one left every
  // later session with no digest. The set is keyed by the session manager's id,
  // read fresh on each turn.
  const injected = new Set<string>()
  pi.on('before_agent_start', async (_event: unknown, ctx: ExtensionContext) => {
    try {
      remember(ctx)
      const key = sessionID()
      if (injected.has(key)) return
      injected.add(key)
      // The session goes with it: hook-context marks the one starting as live,
      // which keeps it out of its own MCP recall on this first turn (#4394, as
      // #4246 and #4273 did for Hermes and opencode).
      const raw = await run(
        ['hook-context'],
        JSON.stringify({ session_id: sessionID(), cwd: process.cwd() }),
      )
      if (!raw) return
      let digest = raw
      let receipt = ''
      try {
        const parsed = JSON.parse(raw) as HookResponse
        digest = parsed?.hookSpecificOutput?.additionalContext || ''
        receipt = parsed?.systemMessage || ''
      } catch {
        // not JSON: the raw text is the digest
      }
      if (!digest) return
      // Without the receipt the recall is invisible and reads as the model
      // guessing; with it the user knows where the answer came from.
      if (receipt) ctx.ui.notify(receipt, 'info')
      const stats = await statusline()
      if (stats) ctx.ui.setStatus('deja', stats)
      return { message: { customType: 'deja-recall', content: digest, display: false } }
    } catch {
      // memory is optional: never break the session over it
    }
  })

  pi.on('context', async (event: ContextEvent, ctx: ExtensionContext) => {
    remember(ctx)
    const messages = Array.isArray(event?.messages) ? event.messages : null
    if (!messages || messages.length === 0) return
    let at = -1
    for (let i = messages.length - 1; i >= 0; i--) {
      if (messages[i]?.role === 'user') {
        at = i
        break
      }
    }
    if (at < 0) return
    const target = messages[at]
    const prompt = userText(target)
    if (!prompt) return
    if (prompt !== asked) {
      asked = prompt
      recalled = run(
        ['hook-prompt', '--plain'],
        JSON.stringify({
          prompt,
          session_id: sessionID(),
          cwd: ctx?.cwd || process.cwd(),
        }),
      )
    }
    // Silence is the common case: the hook speaks only when this machine's
    // history actually answers the question.
    const recall = await recalled
    if (!recall) return
    const out = messages.slice()
    out[at] = {
      ...target,
      content: [{ type: 'text', text: recall }, ...(target.content ?? [])],
    }
    return { messages: out }
  })

  // The point of action: a command just failed, and this machine has fixed that
  // same error before. tool_result hands over the content the model is about to
  // read and takes a replacement back, so the repair arrives beside the error in
  // the same turn instead of a turn later.
  const repaired: Record<string, Promise<string>> = {}
  pi.on('tool_result', async (event: ToolResultEvent) => {
    try {
      if (!event) return
      // A file the agent just opened is the step before it changes that file,
      // and omp has no handler that runs earlier whose return the model reads.
      // So the file's own history goes out here: what past sessions decided about
      // it. deja answers once per session per fact, so re-reading the same file
      // stays quiet. An edit or a write without a read before it gets the same
      // line, for the edits after it.
      if (
        event.toolName === 'read' ||
        event.toolName === 'edit' ||
        event.toolName === 'write'
      ) {
        // omp's edit names its file only in the anchor its input opens with,
        // "[path#HASH]".
        const anchor = /^\s*\[([^\]#]+)#/.exec(String(event.input?.input ?? ''))
        const path = String(
          event.input?.path || event.input?.file_path || anchor?.[1] || '',
        )
        if (!path) return
        const parts = Array.isArray(event.content) ? event.content : []
        const id = `file:${String(event.toolCallId ?? '')}`
        if (!(id in repaired)) {
          repaired[id] = run(
            ['hook-tool', '--plain'],
            JSON.stringify({
              tool_name: event.toolName,
              tool_input: { file_path: path },
              session_id: sessionID(),
              cwd: process.cwd(),
            }),
          )
        }
        const note = await repaired[id]
        if (!note) return
        return { content: parts.concat([{ type: 'text', text: note }]) }
      }
      if (event.toolName !== 'bash') return
      // omp's bash tool reports a non-zero exit in details.exitCode and leaves
      // isError false: gating on isError alone stays silent on every failed build.
      const failed =
        event.isError === true ||
        (typeof event.details?.exitCode === 'number' && event.details.exitCode !== 0)
      if (!failed) return
      const parts = Array.isArray(event.content) ? event.content : []
      const output = parts
        .filter((part) => part?.type === 'text' && typeof part.text === 'string')
        .map((part) => part.text)
        .join('\n')
      if (!output.trim()) return
      const id = String(event.toolCallId ?? '')
      if (!(id in repaired)) {
        repaired[id] = run(
          ['hook-tool-after', '--plain'],
          JSON.stringify({
            tool_name: 'bash',
            tool_response: output,
            session_id: sessionID(),
            cwd: process.cwd(),
          }),
        )
      }
      const line = await repaired[id]
      if (!line) return
      return { content: parts.concat([{ type: 'text', text: line }]) }
    } catch {
      // never turn a failed command into a failed session
    }
  })

  // Compaction throws away the blocks this session was shown, and the list that
  // stops them repeating outlives them. The session file still holds the turns
  // the summary replaced: deja reads them from it, and the next prompt's recall
  // carries what the agent was in the middle of.
  pi.on('session_compact', async (_event: unknown, ctx: ExtensionContext) => {
    try {
      remember(ctx)
      await run(
        ['hook-precompact'],
        JSON.stringify({
          session_id: sessionID(),
          transcript_path: sessionFile,
          cwd: process.cwd(),
          harness: 'omp',
        }),
      )
    } catch {
      // memory is optional: never break the session over it
    }
  })

  // A session is over when omp exits or switches to another one (/new, /resume,
  // a fork). Its live stamp goes with it, so the next session's MCP recall can
  // answer with it now rather than twenty minutes from now (#4210). On a switch
  // the id remembered so far is the session left behind: endSession reads it
  // before its first await. The 2 s timeout is omp's session_shutdown budget.
  const endSession = async () => {
    const id = sessionID()
    if (id)
      await run(
        ['hook-session-end'],
        JSON.stringify({ session_id: id, cwd: process.cwd() }),
        2000,
      )
  }
  pi.on('session_switch', async (_event: unknown, ctx: ExtensionContext) => {
    try {
      const ending = endSession()
      remember(ctx)
      await ending
    } catch {
      // memory is optional: never break the session over it
    }
  })
  pi.on('session_shutdown', async () => {
    try {
      await endSession()
    } catch {
      // memory is optional: never break the session over it
    }
  })
}
