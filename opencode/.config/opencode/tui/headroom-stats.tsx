/** @jsxImportSource @opentui/solid */
import { readFileSync } from "node:fs"
import type { TuiPlugin, TuiPluginApi, TuiPluginModule } from "@opencode-ai/plugin/tui"
import { createSignal, onCleanup } from "solid-js"

const STATS_FILE = new URL("../.headroom-stats.json", import.meta.url)
const SIDEBAR_ORDER = 151

type HeadroomSessionStats = {
  calls: number
  compressedCalls: number
  tokensBefore: number
  tokensAfter: number
  tokensSaved: number
  lastTokensBefore: number
  lastTokensAfter: number
  lastTokensSaved: number
  updatedAt: string
}

type HeadroomStatsFile = {
  sessions?: Record<string, HeadroomSessionStats>
}

const readSessionStats = (sessionID: string) => {
  try {
    const parsed = JSON.parse(readFileSync(STATS_FILE, "utf8")) as HeadroomStatsFile
    return parsed.sessions?.[sessionID]
  } catch {
    return undefined
  }
}

const formatTokens = (value: number) => Math.round(value).toLocaleString("en-US")

const savingsPercent = (before: number, saved: number) => {
  if (before <= 0) return "0.0%"
  return `${((saved / before) * 100).toFixed(1)}%`
}

const HeadroomSidebar = (props: { api: TuiPluginApi; sessionID: string }) => {
  const [stats, setStats] = createSignal(readSessionStats(props.sessionID))
  const reload = () => setStats(readSessionStats(props.sessionID))

  const cleanup = [
    props.api.event.on("session.updated", reload),
    props.api.event.on("message.updated", reload),
    props.api.event.on("message.removed", reload),
    props.api.event.on("tui.session.select", reload),
  ]
  const interval = setInterval(reload, 5000)

  onCleanup(() => {
    cleanup.forEach((dispose) => dispose())
    clearInterval(interval)
  })

  return (
    <box gap={0}>
      <text fg={props.api.theme.current.text}>
        <b>Headroom</b>
      </text>
      {stats() ? (
        <box gap={0}>
          <text fg={props.api.theme.current.textMuted} wrapMode="none">
            Session {formatTokens(stats()!.tokensBefore)} -&gt; {formatTokens(stats()!.tokensAfter)}
          </text>
          <text fg={props.api.theme.current.textMuted} wrapMode="none">
            Saved {formatTokens(stats()!.tokensSaved)} ({savingsPercent(stats()!.tokensBefore, stats()!.tokensSaved)})
          </text>
          <text fg={props.api.theme.current.textMuted} wrapMode="none">
            Last {formatTokens(stats()!.lastTokensBefore)} -&gt; {formatTokens(stats()!.lastTokensAfter)} saved {formatTokens(stats()!.lastTokensSaved)}
          </text>
          <text fg={props.api.theme.current.textMuted} wrapMode="none">
            Calls {stats()!.compressedCalls}/{stats()!.calls}
          </text>
        </box>
      ) : (
        <text fg={props.api.theme.current.textMuted} wrapMode="none">
          No compression yet
        </text>
      )}
    </box>
  )
}

const tui: TuiPlugin = async (api) => {
  api.slots.register({
    order: SIDEBAR_ORDER,
    slots: {
      sidebar_content(_ctx, props: { session_id: string }) {
        return <HeadroomSidebar api={api} sessionID={props.session_id} />
      },
    },
  })
}

const pluginModule: TuiPluginModule & { id: string } = {
  id: "headroom-stats",
  tui,
}

export default pluginModule
