# Claude Code Setup Plan

> Created: 2026-01-22
> Source: https://github.com/affaan-m/everything-claude-code

## Available Components

### Agents (9 total)
- ✅ `planner.md` - Feature implementation planning
- ✅ `architect.md` - System design decisions
- ✅ `tdd-guide.md` - Test-driven development
- ✅ `code-reviewer.md` - Quality and security review
- ✅ `security-reviewer.md` - Vulnerability analysis
- ✅ `build-error-resolver.md` - Fix build errors
- ✅ `e2e-runner.md` - Playwright E2E testing
- ✅ `refactor-cleaner.md` - Dead code cleanup
- ✅ `doc-updater.md` - Documentation sync

### Commands (13 total)
- ✅ `/tdd` - Test-driven development
- ✅ `/plan` - Implementation planning
- ✅ `/e2e` - E2E test generation
- ✅ `/code-review` - Quality review
- ✅ `/build-fix` - Fix build errors
- ✅ `/refactor-clean` - Dead code removal
- ⚠️ `/learn` - Extract patterns mid-session (advanced)
- ⚠️ `/checkpoint` - Save verification state (advanced)
- ⚠️ `/verify` - Run verification loop (advanced)
- ⚠️ `/eval` - Evaluation harness
- ⚠️ `/orchestrate` - Orchestrate multiple agents
- ⚠️ `/update-docs` - Update documentation
- ⚠️ `/update-codemaps` - Update code maps
- ⚠️ `/test-coverage` - Test coverage analysis

### Rules (8 total)
- ✅ `security.md` - Mandatory security checks
- ✅ `coding-style.md` - Immutability, file organization
- ✅ `testing.md` - TDD, 80% coverage requirement
- ✅ `git-workflow.md` - Commit format, PR process
- ✅ `agents.md` - When to delegate to subagents
- ⚠️ `performance.md` - Model selection, context management
- ⚠️ `hooks.md` - Hook usage guidelines
- ⚠️ `patterns.md` - Common patterns

### Skills (13 directories)
- ✅ `coding-standards/` - Language best practices
- ✅ `backend-patterns/` - API, database, caching patterns
- ✅ `frontend-patterns/` - React, Next.js patterns
- ✅ `tdd-workflow/` - TDD methodology
- ✅ `security-review/` - Security checklist
- ⚠️ `continuous-learning/` - Auto-extract patterns (advanced)
- ⚠️ `strategic-compact/` - Manual compaction suggestions (advanced)
- ⚠️ `eval-harness/` - Verification loop evaluation (advanced)
- ⚠️ `verification-loop/` - Continuous verification (advanced)
- ⚠️ `clickhouse-io/` - ClickHouse specific
- ⚠️ `project-guidelines-example/` - Example project guidelines

## Recommended Installation Strategy

### Phase 1: Core Essentials (Start Here)
```bash
# Copy essential agents
cp ~/everything-claude-code/agents/{planner,code-reviewer,tdd-guide}.md ~/.claude/agents/

# Copy essential commands
cp ~/everything-claude-code/commands/{plan,code-review,tdd}.md ~/.claude/commands/

# Copy all rules (they're lightweight)
cp ~/everything-claude-code/rules/*.md ~/.claude/rules/

# Copy core skills
cp -r ~/everything-claude-code/skills/coding-standards ~/.claude/skills/
cp -r ~/everything-claude-code/skills/frontend-patterns ~/.claude/skills/
cp -r ~/everything-claude-code/skills/tdd-workflow ~/.claude/skills/
```

### Phase 2: Extended Features (After familiarization)
```bash
# More agents
cp ~/everything-claude-code/agents/{architect,build-error-resolver,e2e-runner}.md ~/.claude/agents/

# More commands
cp ~/everything-claude-code/commands/{build-fix,e2e,refactor-clean}.md ~/.claude/commands/

# Backend skills
cp -r ~/everything-claude-code/skills/backend-patterns ~/.claude/skills/
cp -r ~/everything-claude-code/skills/security-review ~/.claude/skills/
```

### Phase 3: Advanced Features (Optional)
```bash
# Advanced learning & verification
cp ~/everything-claude-code/commands/{learn,checkpoint,verify}.md ~/.claude/commands/
cp -r ~/everything-claude-code/skills/{continuous-learning,eval-harness,verification-loop} ~/.claude/skills/
```

## What to Skip

❌ **Skip for now:**
- Hooks (requires settings.json configuration, complex)
- MCP configs (we already have our own GitHub MCP setup)
- Contexts (advanced system prompt injection)
- clickhouse-io skill (not relevant)
- Plugins (need plugin system understanding)

## Customization Needed

After copying, review and adapt these to match our project:

1. **rules/coding-style.md** - Align with our React 19, Next.js 16 patterns
2. **rules/testing.md** - Ensure matches Vitest setup
3. **rules/git-workflow.md** - Align with our janusz/WEB-XXX branch naming
4. **skills/frontend-patterns/** - Update for React 19, App Router specifics
5. **skills/coding-standards/** - Check TypeScript/ESLint rules match

## Installation Commands Ready

Choose your phase and I can execute the copy commands!

