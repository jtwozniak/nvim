# Testing Requirements

## Minimum Test Coverage: 80%

Test Types (ALL required):
1. **Unit Tests** - Individual functions, utilities, components
2. **Integration Tests** - API endpoints, database operations
3. **E2E Tests** - Critical user flows (Playwright)

## Test-Driven Development

MANDATORY workflow:
1. Write test first (RED)
2. Run test - it should FAIL
3. Write minimal implementation (GREEN)
4. Run test - it should PASS
5. Refactor (IMPROVE)
6. Verify coverage (80%+)

## Validation Strategy (Tiered)

Use a **two-tier** approach to balance speed and safety:

### Tier 1: Quick Check (~20s) — Between steps
Run after each code change during iterative work:
```bash
turbo oxlint test ts:check
```
This catches type errors, broken tests, and obvious lint issues. Skips `format` (16s) and `eslint` (6s) which rarely break from code changes.

### Tier 2: Full Check (~45-120s) — Before commit
Run the full `pnpm ta` before committing/pushing:
```bash
pnpm ta
```
This runs ALL 15 turbo tasks (oxlint, format, eslint, test, ts:check across all workspaces). This is the CI-equivalent gate — never skip this before a commit.

### Rules
- **Iterating on code**: Use Tier 1 (`turbo oxlint test ts:check`)
- **About to commit**: Use Tier 2 (`pnpm ta`) — MANDATORY, no exceptions
- **Fix all errors** before finishing — do not leave lint or test failures for the user to resolve
- If Tier 1 passes but you're not committing yet, do NOT run Tier 2 — save the time

## Troubleshooting Test Failures

1. Use **tdd-guide** agent
2. Check test isolation
3. Verify mocks are correct
4. Fix implementation, not tests (unless tests are wrong)

## Agent Support

- **tdd-guide** - Use PROACTIVELY for new features, enforces write-tests-first
- **e2e-runner** - Playwright E2E testing specialist
