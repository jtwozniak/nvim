/** @jsxImportSource @opentui/solid */
import type { TuiPlugin, TuiPluginApi, TuiPluginModule } from "@opencode-ai/plugin/tui"
import { readFile } from "node:fs/promises"
import { createSignal, onCleanup } from "solid-js"

type HeadroomStats = {
  requests: number
  compressed: number
  tokensBefore: number
  tokensAfter: number
  tokensSaved: number
  lastCompressionRatio: number
  lastTransformsApplied: string[]
  transformsApplied: Record<string, number>
  updatedAt: number
}

type HeadroomStatsFile = {
  updatedAt: number
  stats: HeadroomStats
}

const SIDEBAR_ORDER = 155
const REFRESH_INTERVAL_MS = 2_000
const HEADROOM_STATS_URL = new URL("./headroom-process-stats.json", import.meta.url)

function formatRatio(ratio: number) {
  return `${(ratio * 100).toFixed(1)}%`
}

function formatTokens(tokens: number) {
  if (tokens >= 1_000_000) return `${(tokens / 1_000_000).toFixed(tokens >= 10_000_000 ? 0 : 1)}M`
  if (tokens >= 1_000) return `${(tokens / 1_000).toFixed(tokens >= 10_000 ? 0 : 1)}K`
  return `${tokens}`
}

function compressionRatio(stats: HeadroomStats) {
  if (stats.tokensBefore <= 0) return stats.lastCompressionRatio
  return stats.tokensAfter / stats.tokensBefore
}

async function readHeadroomStats(): Promise<HeadroomStats | undefined> {
  try {
    const content = await readFile(HEADROOM_STATS_URL, "utf8")
    const stats = JSON.parse(content) as HeadroomStatsFile
    return stats.stats
  } catch {
    return undefined
  }
}

function HeadroomStatsView(props: { api: TuiPluginApi }) {
  const [stats, setStats] = createSignal<HeadroomStats>()

  const refresh = () => {
    void readHeadroomStats().then(setStats)
  }

  refresh()
  const interval = setInterval(refresh, REFRESH_INTERVAL_MS)
  onCleanup(() => clearInterval(interval))

  const lines = () => {
    const current = stats()
    if (!current) return ["no session data yet"]

    return [
      `requests ${current.requests}, compressed ${current.compressed}`,
      `tokens ${formatTokens(current.tokensAfter)} / ${formatTokens(current.tokensBefore)} (${formatRatio(
        compressionRatio(current),
      )})`,
      `saved ${formatTokens(current.tokensSaved)}`,
    ]
  }

  return (
    <box gap={0}>
      <text fg={props.api.theme.current.text}>
        <b>Headroom</b>
      </text>
      <box gap={0}>
        {lines().map((line) => (
          <text fg={props.api.theme.current.textMuted} wrapMode="none">
            {line}
          </text>
        ))}
      </box>
    </box>
  )
}

const tui: TuiPlugin = async (api) => {
  api.slots.register({
    order: SIDEBAR_ORDER,
    slots: {
      sidebar_content(_ctx, props: { session_id: string }) {
        return <HeadroomStatsView api={api} />
      },
    },
  })
}

export default {
  id: "headroom-session-stats",
  tui,
} satisfies TuiPluginModule
