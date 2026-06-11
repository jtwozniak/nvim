# Learnings

Durable coding-session knowledge. Referenced automatically on start.

## 2026-06-11 - Simplification request handling

- When user asks to optimize, simplify, or reduce code because it “does not look good”, start with deletion-only/minimal-diff approach.
- Do not add state, callbacks, hooks, new data flow, or preservation plumbing unless user explicitly asks or behavior would clearly break.
- If a possible edge case appears that requires more code, stop and explain tradeoff before implementing.
- For simplification work, prove necessity before adding lines; default to preserving current architecture and removing redundancy.

## 2026-06-08 - a repo: Marketing Blueprint schema transforms

- Marketing Blueprint schemas using `richTextSchema` output React nodes; compare against component `*Props` types that widen generated API string fields (`BlueprintBannerProps`, `BlueprintTextAreaProps`, `BlueprintCardLayoutProps`).
- For Blueprint buttons from marketing CMS, zod transforms should emit the clean generated API shape and preserve `navigationActionSchema` output so required action fields like `openInNewTab` remain present.
- In modern TypeScript, `Array.filter` can narrow discriminated unions from inline comparisons like `item.__typename === "Button"`; do not add one-off `item is Type` helper functions unless reusable or inference fails.

## 2026-05-28 - b repo: Transfer-in CTA schema + button quirks

- When bespoke step `data` gains required fields, remove `.default({})` from zod object wrapper or TS/Zod default typing breaks.
- `TextButton` in `@mb/components` constrains `data-testid` to pattern ``button-${string}``; arbitrary test ids fail type-check.
- For mocked child components in Vitest, expose drilled props via `data-*` attributes to assert wiring without coupling tests to mock call shapes.

## 2026-05-25 - a repo: Cloudflare Turnstile + Next.js API Routes

- `initRouteLogger("name")` — standard observability for Next.js API routes; returns `{info, warn, error}` logger.
- `request.json()` returns `unknown` in strict TS — use `as Record<string, unknown>`, not interface assertion.
- `vi.doMock` + `vi.resetModules()` — pattern for testing Next.js routes with varying server configs per test.
- Cloudflare Turnstile Siteverify: tokens single-use, 5min TTL, `idempotency_key` prevents replay.
- `@marsidev/react-turnstile` callbacks: `onSuccess(token)`, `onError(errorCode)`, `onExpire()`, `onTimeout()`; `ref.reset()` for retry.
- Next.js route resolution: specific routes (`/api/turnstile/verify`) win over catch-all (`/api/[...slugs]`).
- `a` repo overrides react-query `DefaultError` in `types/react-query.d.ts` — `{Message, Name, ErrorCode?, ValidationErrors?}` (capitalized). When throwing plain `Error`, annotate `onError: (error: Error)` explicitly.

## 2025-05-20 - b repo: Flows Framework Patterns

- Flows use step-based arch: each step component gets `step` + `stepProps` ({newState, onComplete, onBack, onCancel}).
- BE state arrives as `FlowStateProperties` = array of `{key, values}` pairs; `getStateProperties()` parses via Zod with optional fallback schema + Datadog error reporting.
- `FocusedViewForm` — schema-validated form wrapper (Zod schema, defaultValues, render-prop children with formState/watch).
- All form values are strings: `"Yes"/"No"`, `"true"/"false"`, `"Full"/"Partial"`. Zod discriminated unions handle branching validation.
- Nested discriminated unions for multi-level conditional form logic (e.g., type→contribution→include→amount).
- `useTrackers().tap(eventName)` — standard tracking from `@mb/components`.
- `<Loading {...useQuery()}>{(data) => ...}</Loading>` — render-prop wrapper for react-query results.
