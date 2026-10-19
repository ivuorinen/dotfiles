// repo-managed adaptation of `deja install pi-auto`.
// Uses `deja-hook` from PATH (or $DEJA_HOOK_BIN) so the file stays portable
import { execFileSync } from 'node:child_process'

const DEJA = process.env.DEJA_HOOK_BIN || 'deja-hook'

type SessionManager = {
  getSessionId?: () => string | undefined
  sessionId?: string
  getSessionFile?: () => string | undefined
  sessionFile?: string
}

type ExtensionContext = {
  sessionManager?: SessionManager
  ui: {
    setStatus: (name: string, status: string) => void
    notify: (message: string, level: string) => void
  }
}

type PiApi = {
  on: (...args: unknown[]) => void
  registerCommand: (...args: unknown[]) => void
}

type BeforeAgentStartEvent = {
  prompt?: string
}

type HookResponse = {
  systemMessage?: string
  hookSpecificOutput?: {
    additionalContext?: string
  }
}

type ToolTextPart = {
  type: 'text'
  text: string
}

type ToolResultEvent = {
  toolName?: string
  input?: {
    path?: string
    file_path?: string
  }
  content?: unknown[]
  toolCallId?: string
  isError?: boolean
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === 'object' && value !== null
}

function isTextPart(value: unknown): value is ToolTextPart {
  return isRecord(value) && value.type === 'text' && typeof value.text === 'string'
}

function run(args: string[], input: string, timeout = 10000): string {
  try {
    return execFileSync(DEJA, args, {
      input,
      encoding: 'utf8',
      timeout,
      maxBuffer: 4 * 1024 * 1024,
      stdio: ['pipe', 'pipe', 'ignore'],
    }).trim()
  } catch {
    return ''
  }
}

export default function (pi: PiApi) {
  // Once per session, not once per process: /new, a resume and a fork keep the
  // process and switch the session, and a flag set on the first one left every
  // later session with no digest.
  const injected = new Set<string>()
  let toldBuilding = false
  // The tool and compaction events carry no session id, and recall dedupes per
  // session: without one it repeats itself and forgets nothing. pi keeps the id
  // on the session manager, which every handler gets through ctx.
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
    } catch {}
  }
  const sessionID = () => session

  // pi keeps a footer status line: while the first index builds, that is
  // where the user can see it happening instead of wondering why recall is
  // quiet. Cleared as soon as the build finishes.
  const showBuild = (ctx: ExtensionContext) => {
    const status = run(['warmup-status'], '')
    if (status) {
      ctx.ui.setStatus('deja', status)
      return true
    }
    ctx.ui.setStatus('deja', '')
    return false
  }

  pi.on('session_start', async (_event: unknown, ctx: ExtensionContext) => {
    try {
      remember(ctx)
      showBuild(ctx)
    } catch {
      // memory is optional: never break the session over it
    }
  })

  // pi surfaces registered commands in the prompt box, which is how someone
  // who never read the docs finds this at all.
  pi.registerCommand('deja', {
    description: 'Search your own past coding sessions',
    handler: async (args: string, ctx: ExtensionContext) => {
      const query = (args || '').trim()
      if (!query) {
        ctx.ui.notify('Usage: /deja <what you are looking for>', 'info')
        return
      }
      // The user is waiting on this one, so it may outlive the hook budget:
      // a first search can rebuild the index.
      //
      // "--" when the query names one of deja's own flags: searching for
      // "--json" or "--all-matches" otherwise dies in flag parsing and comes
      // back as an empty history.
      const commandArgs = query.startsWith('-')
        ? ['search', '--', query]
        : ['search', query]
      const found = run(commandArgs, '', 120000)
      ctx.ui.notify(found || `Nothing in your history matches ${query}`, 'info')
    },
  })

  pi.on(
    'before_agent_start',
    async (event: BeforeAgentStartEvent, ctx: ExtensionContext) => {
      try {
        remember(ctx)
        if (!injected.has(sessionID())) {
          // The session goes with it: hook-context marks the one starting as
          // live, which keeps it out of its own MCP recall on this first turn
          // (#4394, as #4246 and #4273 did for Hermes and opencode). pi has no
          // MCP of its own, so the lead names the shell command, not the tool
          // (#4584).
          const raw = run(
            ['hook-context'],
            JSON.stringify({
              session_id: sessionID(),
              cwd: process.cwd(),
              deja_shell: true,
            }),
          )
          let digest = ''
          let receipt = ''
          try {
            const parsed = JSON.parse(raw) as HookResponse
            digest = parsed.hookSpecificOutput?.additionalContext || ''
            receipt = parsed.systemMessage || ''
          } catch {
            digest = raw
          }
          if (digest) {
            injected.add(sessionID())
            ctx.ui.setStatus('deja', '')
            // The receipt is what tells the user memory arrived; without it the
            // recall is invisible and reads as the model guessing.
            if (receipt) ctx.ui.notify(receipt, 'info')
            // pi keeps the footer until it is cleared, so the session carries a
            // quiet reminder that memory is on rather than a one-off toast.
            const stats = run(['statusline'], '')
            if (stats) ctx.ui.setStatus('deja', stats)
            return {
              message: {
                customType: 'deja-recall',
                content: digest,
                display: false,
              },
            }
          }
          // Nothing to recall: either there is no history yet, or the first
          // index is still building. Only the second is worth saying, once.
          if (!toldBuilding && showBuild(ctx)) {
            toldBuilding = true
            ctx.ui.notify(run(['warmup-status'], ''), 'info')
          }
          return
        }
        const raw = run(
          ['hook-prompt'],
          JSON.stringify({ prompt: event.prompt || '', session_id: sessionID() }),
        )
        if (!raw) return
        const resp = JSON.parse(raw) as HookResponse
        if (resp.systemMessage) ctx.ui.notify(resp.systemMessage, 'info')
        const extra = resp.hookSpecificOutput?.additionalContext
        if (!extra) return
        return {
          message: { customType: 'deja-recall', content: extra, display: false },
        }
      } catch {
        // memory is optional: never break the session over it
      }
    },
  )

  // The other half of the point of action: a command has just failed, and this
  // machine has fixed that same error before. pi hands tool_result the content
  // the model is about to read and uses what the handler returns, so the repair
  // goes in beside the error in the same turn. tool_execution_start and
  // tool_execution_end are observe-only — their return reaches nothing — which
  // is why this is the one that carries it.
  const repaired: Record<string, string> = {}
  pi.on('tool_result', async (event: ToolResultEvent) => {
    try {
      if (!event) return
      // A file the agent just opened is the step before it changes that file,
      // and pi has no handler that runs earlier whose return the model reads.
      // So the file's own history goes out here: what was decided about it,
      // from the sessions that decided it. deja answers once per session per
      // fact, so re-reading the same file stays quiet. An edit or a write
      // without a read before it gets the same line, for the edits after it.
      if (
        event.toolName === 'read' ||
        event.toolName === 'edit' ||
        event.toolName === 'write'
      ) {
        const path = String(event.input?.path || event.input?.file_path || '')
        if (!path) return
        const parts = Array.isArray(event.content) ? event.content : []
        const id = `file:${String(event.toolCallId || '')}`
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
        const note = repaired[id]
        if (!note) return
        return { content: parts.concat([{ type: 'text', text: note }]) }
      }
      if (!event.isError) return
      // Senpi and Kimchi's pi have a powershell tool beside bash (#4523).
      if (event.toolName !== 'bash' && event.toolName !== 'powershell') return
      const parts = Array.isArray(event.content) ? event.content : []
      const output = parts
        .filter(isTextPart)
        .map((part) => part.text)
        .join('\n')
      if (!output.trim()) return
      const id = String(event.toolCallId || '')
      if (!(id in repaired)) {
        repaired[id] = run(
          ['hook-tool-after', '--plain'],
          JSON.stringify({
            tool_name: event.toolName,
            tool_response: output,
            session_id: sessionID(),
            cwd: process.cwd(),
          }),
        )
      }
      const line = repaired[id]
      if (!line) return
      return { content: parts.concat([{ type: 'text', text: line }]) }
    } catch {
      // never turn a failed command into a failed session
    }
  })

  // Compaction throws away the blocks this session was shown, and the list that
  // stops them repeating outlives them. session_compact fires once the summary
  // has replaced the history, which is exactly when the session should be
  // allowed to see those blocks again. The session file keeps the turns the
  // summary replaced, so deja reads them from it and the next prompt carries
  // what the agent was in the middle of.
  pi.on('session_compact', async (_event: unknown, ctx: ExtensionContext) => {
    try {
      remember(ctx)
      run(
        ['hook-precompact'],
        JSON.stringify({
          session_id: sessionID(),
          transcript_path: sessionFile,
          cwd: process.cwd(),
        }),
      )
    } catch {}
  })

  // The session is over: quit, /new, /resume, /fork or a reload. Its live
  // stamp goes with it, so the next session's MCP recall can answer with it
  // now rather than twenty minutes from now (#4210). The id is the one this
  // extension saw last; on a switch ctx may already name the next session.
  pi.on('session_shutdown', async (_event: unknown) => {
    try {
      const id = sessionID()
      if (id) run(['hook-session-end'], JSON.stringify({ session_id: id }), 2000)
    } catch {}
  })
}
