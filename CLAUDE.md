# TinBela

**All project context lives in [`AGENTS.md`](./AGENTS.md).** Read it first.

This file exists only so Claude Code finds the context too. It is
deliberately a pointer, not a copy — two sources of truth drift within a
week, and this project is worked on with several different tools.

Directory-specific rules are in nested `AGENTS.md` files:
`services/api/` · `apps/manager/` · `apps/web/` · `proto/`

Claude-Code-only extras (these do NOT work in Codex or OpenCode):
- `.claude/agents/` — two subagents whose role is behavioural, not directional
- `.claude/skills/` — reusable instruction bundles
- `.claude/commands/` — `/task`, `/epic`, `/review`, `/adr`, `/ship`
- `.claude/hooks/` — mechanical edit guards

Everything enforced by those extras is **also** enforced by `make verify`,
so the rules hold no matter which tool you run.
