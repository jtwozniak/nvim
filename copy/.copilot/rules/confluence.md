# Confluence Integration Rules

## When to Use Confluence MCP

**ALWAYS** fetch Confluence documentation when:

1. User mentions a ticket number (e.g., "MON-1234", "JIRA-567")
2. User says "work on ticket", "implement ticket", "fix ticket"
3. Starting work on a new feature or bug fix with a ticket reference
4. User asks about requirements, acceptance criteria, or specifications for a ticket
5. Need clarification on ticket details, design decisions, or context

## How to Use Confluence MCP

When a ticket is mentioned:

1. **Extract ticket number** from user message (format: PROJECT-NUMBER)
2. **Use Confluence MCP** to fetch:
   - Ticket description and acceptance criteria
   - Related documentation pages
   - Design decisions and technical specifications
   - Comments and discussion history
3. **Load context** before writing any code or making suggestions
4. **Reference ticket details** in commit messages and PR descriptions

## Ticket Number Patterns

Common patterns to recognize:
- `MON-1234` (Moneybox tickets)
- `JIRA-567`
- `TICKET-123`
- `#1234` (if project uses GitHub issues linked to Confluence)

## Example Workflow

```
User: "Can you implement MON-1234?"

1. Use Confluence MCP to fetch MON-1234 details
2. Read acceptance criteria and requirements
3. Review related technical documentation
4. Plan implementation based on ticket context
5. Write code following ticket specifications
6. Reference ticket in commits: "feat(MON-1234): implement feature"
```

## Integration with Git Workflow

- **Commits**: Include ticket number in conventional commit format
  - `feat(MON-1234): add user authentication`
  - `fix(MON-567): resolve login issue`
- **Branches**: Use ticket number in branch names
  - `feature/MON-1234-user-auth`
  - `fix/MON-567-login-bug`
- **PRs**: Include ticket link and summary in PR description

## Error Handling

If Confluence MCP is not available or ticket not found:
- Ask user for ticket details manually
- Proceed with available context
- Note in response that Confluence context was unavailable
