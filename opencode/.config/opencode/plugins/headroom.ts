import type { Plugin } from "@opencode-ai/plugin"
import { rename, writeFile } from "node:fs/promises"
import { HeadroomClient, compress } from "headroom-ai"
import type { CompressResult } from "headroom-ai"

type OpenAIMessage = {
  role: "assistant" | "system" | "tool"
  content: string | null
  tool_call_id?: string
}

type ToolPatch = {
  type: "tool"
  messageIndex: number
  partIndex: number
}

type TextPatch = {
  type: "text"
  messageIndex: number
  partIndex: number
}

type Patch = ToolPatch | TextPatch

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

type HeadroomClientOptions = ConstructorParameters<typeof HeadroomClient>[0] & {
  config?: Record<string, unknown>
}

const HEADROOM_BASE_URL = process.env.HEADROOM_BASE_URL ?? "http://127.0.0.1:8787"
const HEADROOM_STATS_URL = new URL("./headroom-process-stats.json", import.meta.url)
const HEADROOM_STATS_TMP_URL = new URL("./headroom-process-stats.json.tmp", import.meta.url)
const headroomStats: HeadroomStats = {
  requests: 0,
  compressed: 0,
  tokensBefore: 0,
  tokensAfter: 0,
  tokensSaved: 0,
  lastCompressionRatio: 1,
  lastTransformsApplied: [],
  transformsApplied: {},
  updatedAt: 0,
}

const HEADROOM_CLIENT = new HeadroomClient({
  baseUrl: HEADROOM_BASE_URL,
  fallback: true,
  retries: 0,
  stack: "opencode-plugin",
  timeout: 1_500,
  config: {
    compressSystemMessages: true,
  },
} as HeadroomClientOptions)
const HEADROOM_OPTIONS = { client: HEADROOM_CLIENT }

function recordHeadroomStats(result: CompressResult) {
  if (!Number.isFinite(result.tokensBefore)) return
  if (!Number.isFinite(result.tokensAfter)) return
  if (!Number.isFinite(result.tokensSaved)) return
  if (!Number.isFinite(result.compressionRatio)) return

  headroomStats.requests += 1
  headroomStats.compressed += result.compressed ? 1 : 0
  headroomStats.tokensBefore += result.tokensBefore
  headroomStats.tokensAfter += result.tokensAfter
  headroomStats.tokensSaved += result.tokensSaved
  headroomStats.lastCompressionRatio = result.compressionRatio
  headroomStats.lastTransformsApplied = result.transformsApplied
  headroomStats.updatedAt = Date.now()

  for (const transform of result.transformsApplied) {
    headroomStats.transformsApplied[transform] = (headroomStats.transformsApplied[transform] ?? 0) + 1
  }

  void persistHeadroomStats()
}

async function persistHeadroomStats() {
  const stats: HeadroomStatsFile = {
    updatedAt: Date.now(),
    stats: headroomStats,
  }

  try {
    await writeFile(HEADROOM_STATS_TMP_URL, `${JSON.stringify(stats, null, 2)}\n`)
    await rename(HEADROOM_STATS_TMP_URL, HEADROOM_STATS_URL)
  } catch {
    // Stats are diagnostic only; compression must stay fail-open.
  }
}

export const HeadroomOpenCodePlugin: Plugin = async () => {
  return {
    "experimental.chat.system.transform": async (input, output) => {
      if (!Array.isArray(output.system) || output.system.length === 0) return

      const messages: OpenAIMessage[] = []
      const sourceIndexes: number[] = []

      for (let index = 0; index < output.system.length; index++) {
        const content = output.system[index]
        if (!content) continue

        sourceIndexes.push(index)
        messages.push({ role: "system", content })
      }

      if (messages.length === 0) return

      try {
        const result = await compress(messages, {
          ...HEADROOM_OPTIONS,
        })
        recordHeadroomStats(result)

        if (!result.compressed || !Array.isArray(result.messages)) return

        for (let index = 0; index < result.messages.length; index++) {
          const message = result.messages[index]
          const sourceIndex = sourceIndexes[index]
          const original = sourceIndex === undefined ? undefined : output.system[sourceIndex]
          if (message?.role !== "system" || typeof message.content !== "string" || !original) continue
          if (message.content.length >= original.length) continue

          output.system[sourceIndex] = message.content
        }
      } catch {
        // Headroom failed; preserve original system context.
      }
    },
    "experimental.chat.messages.transform": async (_input, output) => {
      const source = output.messages
      if (!Array.isArray(source) || source.length === 0) return

      const messages: OpenAIMessage[] = []
      const patches: Array<Patch | undefined> = []

      for (let messageIndex = 0; messageIndex < source.length; messageIndex++) {
        const message = source[messageIndex]
        if (!message) continue

        if (message.info.role === "assistant") {
          const textParts = message.parts
            .map((part, partIndex) => ({ part, partIndex }))
            .filter(({ part }) => part.type === "text" && typeof part.text === "string")
          const text = textParts[0]?.part.type === "text" ? textParts[0].part.text : ""

          if (textParts.length === 1 && text) {
            patches.push({ type: "text", messageIndex, partIndex: textParts[0].partIndex })
            messages.push({ role: "assistant", content: text })
          }
        }

        for (let partIndex = 0; partIndex < message.parts.length; partIndex++) {
          const part = message.parts[partIndex]
          if (part.type !== "tool") continue
          if (part.state.status !== "completed") continue

          patches.push({ type: "tool", messageIndex, partIndex })
          messages.push({
            role: "tool",
            content: part.state.output,
            tool_call_id: part.callID,
          })
        }
      }

      if (!patches.some(Boolean)) return

      try {
        const result = await compress(messages, {
          ...HEADROOM_OPTIONS,
        })
        recordHeadroomStats(result)

        if (!result.compressed || !Array.isArray(result.messages)) return

        for (let index = 0; index < result.messages.length; index++) {
          const message = result.messages[index]
          const patch = patches[index]
          if (!patch || typeof message?.content !== "string") continue

          const part = source[patch.messageIndex]?.parts[patch.partIndex]
          if (patch.type === "text") {
            if (message.role !== "assistant" || part?.type !== "text") continue
            if (message.content.length >= part.text.length) continue
            part.text = message.content
            continue
          }

          if (message.role !== "tool" || part?.type !== "tool" || part.state.status !== "completed") continue
          if (message.content.length >= part.state.output.length) continue

          part.state.output = message.content
        }
      } catch {
        // Headroom failed; preserve original context.
      }
    },
  }
}
