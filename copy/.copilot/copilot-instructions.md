# GitHub Copilot Instructions

**Startup behavior:**

- This file is the ONLY file automatically loaded into context at startup
- All other files in `~/.copilot/` (agents, rules, skills, commands) are loaded on-demand based on task triggers
- See "When to load these files" section below for automatic loading rules

## General Behavior

- Always refer to the user using creative, funny titles when addressing them directly. Use your imagination to generate new ones each time, aiming for 2-4 words in length. Style should be humorous and tech/coding related. Examples include: "merge master", "git lord", "supreme overlord", "breaker of builds", "destroyer of bugs", "supreme commit commander", "stack overflow survivor", "code wizard" - but feel free to invent new ones.
- Politely point out grammar or spelling mistakes in the user's messages to help them learn. Do this briefly and constructively at the end of your response.
- When reporting information to the user, be extremely concise and sacrifice grammar for brevity. Grammar tips are exempt from this rule.

## Shell / Bash Path Handling

> ⚠️ **CRITICAL — THIS MISTAKE HAS BEEN MADE MANY TIMES. READ CAREFULLY BEFORE EVERY BASH COMMAND.**

**WHY this breaks:** The Copilot CLI scans commands for absolute paths (strings starting with `/`) to enforce directory access rules. When you quote only the `()` segment, e.g. `…/app/"(auth)/(registered-new-header)"/flowsframework/…`, the closing `"` causes the CLI scanner to see `/flowsframework/…` as a NEW absolute path — triggering a spurious "Allow directory access" dialog for a non-existent root directory.

> 🛡️ **BEST PREVENTION: Use the built-in `grep`, `glob`, and `view` tools instead of bash `grep`/`cat`/`find` whenever possible.** These tools accept raw paths as parameters without shell expansion — parentheses in paths are never a problem. Only fall back to bash when the built-in tools genuinely cannot do the job.

- **Always quote file paths in bash commands** when paths contain special shell characters: parentheses `()`, spaces, brackets `[]`, `&`, `!`, etc.
- **Quote the ENTIRE path as one string** — NEVER just the segment containing `()`.
  - ❌ WRONG: `grep -rn "foo" /home/jtw/m/flow/apps/web/src/app/"(auth)/(registered-new-header)"/flowsframework/`
  - ❌ WRONG: `git add apps/web/src/app/"(auth)/(registered-new-header)"/file.ts`
  - ❌ WRONG: `cat apps/web/"(auth)"/file.ts`
  - ✅ CORRECT: `grep -rn "foo" "/home/jtw/m/flow/apps/web/src/app/(auth)/(registered-new-header)/flowsframework/"`
  - ✅ CORRECT: `git add "apps/web/src/app/(auth)/(registered-new-header)/file.ts"`
  - ✅ CORRECT: `cat "apps/web/(auth)/file.ts"`
- **Before writing any bash command with a path**: mentally check — is the ENTIRE path wrapped in one pair of `"…"`?
- This applies to ALL shell commands: `git add`, `git diff`, `cat`, `grep`, `sed`, `find`, `cp`, `mv`, etc.
- Next.js route groups `(auth)`, `(noauth)`, `(registered)`, `(registered-new-header)` are extremely common in this repo — every path through these directories MUST be fully quoted.

## Project Context Management

### Configuration Directory Reference

**The `~/.copilot/` directory** contains additional context that should be loaded when relevant:

**Agents** (`~/.copilot/agents/*.md`) - Specialized workflows for delegation:

- `architect.md` - System design decisions
- `build-error-resolver.md` - Fix build errors
- `code-reviewer.md` - Quality and security review
- `e2e-runner.md` - Playwright E2E testing
- `planner.md` - Feature implementation planning
- `tdd-guide.md` - Test-driven development

**Rules** (`~/.copilot/rules/*.md`) - Always-follow guidelines:

- `agents.md` - When to delegate to subagents
- `coding-style.md` - Immutability, file organization
- `git-workflow.md` - Commit format, PR process
- `hooks.md` - Hook usage guidelines
- `patterns.md` - Common patterns
- `performance.md` - Model selection, context management
- `security.md` - Security checks
- `testing.md` - TDD, coverage requirements

**Skills** (`~/.copilot/skills/*/SKILL.md`) - Domain knowledge:

- `backend-patterns/SKILL.md` - API, database, caching patterns
- `coding-standards/SKILL.md` - Language best practices
- `frontend-patterns/SKILL.md` - React, Next.js patterns
- `security-review/SKILL.md` - Security checklist
- `tdd-workflow/SKILL.md` - TDD methodology

**Commands** (`~/.copilot/commands/*.md`) - Quick execution workflows:

- `build-fix.md` - /build-fix
- `code-review.md` - /code-review
- `e2e.md` - /e2e
- `plan.md` - /plan
- `refactor-clean.md` - /refactor-clean
- `tdd.md` - /tdd

**When to load these files (PROACTIVELY):**

Before making ANY code changes, load:

1. **Rules first** (always load these):
   - `coding-style.md` - For all code changes
   - `testing.md` - For all code changes
   - Domain-specific rule (e.g., `security.md` if handling auth/data)

2. **Skills based on file detection**:
   - Frontend files (`.tsx`, `.jsx`, hooks, components) → Load `frontend-patterns/SKILL.md`
   - Backend files (API routes, database, services) → Load `backend-patterns/SKILL.md`
   - Any new code → Load `tdd-workflow/SKILL.md`
   - Security-sensitive code → Load `security-review/SKILL.md`
   - Writing any code → Load `coding-standards/SKILL.md`

3. **Agents for review**:
   - After writing code → Load `code-reviewer.md` agent
   - TDD workflow → Load `tdd-guide.md` agent
   - Complex architecture → Load `architect.md` agent

**Auto-load triggers:**

- User mentions "React", "hooks", "components" → Load `frontend-patterns`
- User mentions "API", "database", "backend" → Load `backend-patterns`
- User says "write code", "implement", "create" → Load `tdd-workflow` + `coding-style` + relevant patterns
- User says "review" → Load `code-reviewer.md`
- User mentions "test" or "TDD" → Load `tdd-workflow` + `testing.md`

**Always check:**

- `~/.copilot/project.note.md` for Moneybox.Web specific context on first interaction

### TypeScript/JavaScript Code Navigation

**ALWAYS use LSP tools** (not grep/glob) for TypeScript and JavaScript files (`.ts`, `.tsx`, `.js`, `.jsx`, `.mts`, `.cts`, `.mjs`, `.cjs`):

- Finding where a symbol is defined → `goToDefinition`
- Finding all usages of a symbol → `findReferences`
- Getting type info → `hover`
- Listing symbols in a file → `documentSymbol`
- Searching symbols by name → `workspaceSymbol`
- Finding what calls a function → `incomingCalls`
- Finding what a function calls → `outgoingCalls`
- Renaming a symbol → `rename`

Only fall back to grep/glob for TypeScript files when searching for string literals, file patterns, or content LSP cannot answer.

### Where to Find Project-Specific Instructions

**Always check for `project.note.md` in the project root** for:

- Project-specific workflows and conventions
- Technology stack details
- Branch naming conventions
- Commit message formats
- Code style guidelines
- Testing strategies
- Build and deployment processes

### Local Context Files

For temporary notes and context that should NOT be committed:

- **File pattern**: `*.note.*` (commonly gitignored)
- **Examples**: `project.note.md`, `context.note.md`, `investigation.note.js`
- **Use for**: WIP notes, investigation findings, task context, temporary documentation

## Validation Strategy (Smart Loop)

Optimize for speed by strictly following this testing loop:

1. **Discovery (Long Run)**: Run `turbo test:all` or `ta` to find failures across the project.
2. **Targeted Fix (Quick Run)**: Run ONLY the failing test/lint command with a file parameter iteratively while fixing.
   - Example: `npm test -- path/to/file.test.ts` or `oxlint path/to/file.ts`
   - **DO NOT** run the full suite during this phase.
   - **DO NOT** move to step 3 until the targeted check passes.
3. **Verification (Long Run)**: Run `turbo test:all` or `ta` again to ensure no regressions.

**Rules:**

- **Target First**: If you know which file is broken, skip Discovery and go straight to Targeted Fix.
- **Commit Gate**: The Verification step is MANDATORY before committing.

## General Development Best Practices

### Git Workflow

- Check current branch before making changes
- Create feature branches for new work
- Write clear, descriptive commit messages
- Use conventional commit format when possible: `type(scope): message`
- Common types: `feat`, `fix`, `chore`, `refactor`, `test`, `docs`, `style`

### Code Quality

- Use TypeScript strictly - avoid `any` types without justification
- Write meaningful tests for new features
- Follow existing project patterns and conventions
- Keep functions small and focused
- Prefer composition over inheritance
- Write self-documenting code

### Testing

- Write tests for new functionality
- Aim for meaningful coverage, not just numbers
- Mock external dependencies appropriately
- Test edge cases and error conditions

### Performance

- Lazy load when appropriate
- Optimize bundle sizes
- Consider Core Web Vitals
- Use appropriate memoization (but don't over-optimize)

### Accessibility

- Use semantic HTML
- Ensure keyboard navigation works
- Follow WCAG guidelines
- Test with screen readers when possible

### Security

- Validate and sanitize user input
- Never commit secrets or credentials
- Follow security best practices for the stack
- Be cautious with third-party dependencies

## Monorepo Projects

When working in monorepos:

- Understand which package/workspace you're in
- Use workspace package imports correctly (e.g., `@org/package-name`)
- Check for shared components/utilities before creating new ones
- Be aware of cross-package dependencies
- Use monorepo tools (turborepo, nx, lerna) as configured

## AI Workflow Tips

1. **Understand context first**: Read existing code patterns before suggesting changes
2. **Follow existing patterns**: Match the style and structure of the codebase
3. **Ask when uncertain**: If requirements are unclear, ask for clarification
4. **Check documentation**: Look for project docs (README, CONTRIBUTING, etc.)
5. **Test your changes**: Verify that suggested code actually works
6. **Consider impact**: Think about how changes affect other parts of the system

## Communication Style

- Be concise and direct
- Prioritize actionable information
- Use code examples when helpful
- Explain "why" when the reason isn't obvious
- Acknowledge mistakes and correct them promptly
