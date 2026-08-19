# APPLY — what changes and why

Extract over your repo root. Ten files: **7 new, 1 replaced, 7 deleted.**

```bash
cd /path/to/TinBela
unzip -o ~/Downloads/tinbela-patch.zip
# then the deletions:
rm .claude/agents/architect.md \
   .claude/agents/backend-go.md \
   .claude/agents/bangla.md \
   .claude/agents/db.md \
   .claude/agents/devops.md \
   .claude/agents/flutter.md \
   .claude/agents/web.md
git add -A && git commit -m "00.11: portable AGENTS.md harness + nav shell"
```

---

## 1. NEW — `AGENTS.md` (root) · **your entry point**

The cross-tool standard. Codex, OpenCode, Cursor, Zed, and Aider all read
`AGENTS.md`; Claude Code reads it via the `CLAUDE.md` pointer. One file, every
tool.

Deliberately short (~90 lines) because it is **always in context**. Detail
lives in nested files that load only when needed.

## 2. REPLACED — `CLAUDE.md`

Was a full copy of the rules. Now a 15-line pointer to `AGENTS.md`.

Two sources of truth drift within a week. With several tools in play, that
drift is guaranteed — so there is now exactly one.

## 3. NEW — four nested `AGENTS.md`

```
services/api/AGENTS.md    Go, SQL, purity rules, error mapping
proto/AGENTS.md           contract evolution, never renumber a field
apps/manager/AGENTS.md    Flutter, Bangla voice, the non-negotiables
apps/web/AGENTS.md        PWA size budget, no browser storage
```

**These replace most of the agent role files.** "You are the backend agent"
was really "you are working in `services/api/`" — and every tool understands
a directory. Tools load the nearest `AGENTS.md` automatically, so this is
also your context-budget strategy (§ Memory below).

## 4. NEW — `apps/manager/lib/app.dart` + `main.dart` · **the missing UI**

You were right that there was no navigation. There is now:

```
┌──────────┬──────────┬──────────┬──────────┐
│   আজ     │  খাতা    │  হিসাব   │   আরও    │
└──────────┴──────────┴──────────┴──────────┘
```

Four tabs, theme wired to your generated tokens, Bangla labels, placeholders
naming the epic that fills each one. Run it:

```bash
cd apps
flutter create --org com.droidbuilder --project-name tinbela_manager \
  --platforms android manager
# these two files replace the generated lib/main.dart
make tokens        # generates core/theme/tokens.g.dart — required
cd manager && flutter run
```

## 5. DELETED — 7 of 9 agent files

Kept: `reviewer`, `test`. Both are defined by a **behavioural** constraint —
*never write code*, *never change source to pass a test*. A directory brief
cannot express that.

Deleted: `architect`, `backend-go`, `db`, `devops`, `flutter`, `web`,
`bangla`. Each was really "work in directory X", now covered by nested
`AGENTS.md` — and portable to every tool instead of Claude Code only.

---

# Where to start

**`services/api/internal/meals/engine.go` — Epic 02.**

Everything else is blocked on it: `GetDay` calls `Materialize`,
`GetAccounts` calls `Settle`, the Today screen renders `GetDay`. Build any
of those first and you will rewrite them.

```
Day 1  02.2  the nine property tests           ← write these FIRST
Day 1  02.3  Materialize
Day 2  02.4  Settle
Day 2  02.6  27+ more golden vectors (3 seeded)
Day 3  03.4  Connect handlers → first live endpoint
Day 3  08.1  flutter create → you can see the nav shell
```

By hand. A hook blocks agents from those files on purpose. A rate bug here
surfaces on the day 200 messes close their first month.

---

# Memory management

Four tiers, by how often each is read:

| Tier | What | Loaded | Size |
|---|---|---|---|
| **1** | `AGENTS.md` root | always, every tool | keep under ~100 lines |
| **2** | nested `AGENTS.md` | when the tool touches that directory | ~60 lines each |
| **3** | `docs/product/*`, `docs/adr/*` | on demand, by path reference | unbounded |
| **4** | `PROGRESS.md`, `docs/adr/`, commit messages | written back by you | grows |

**The mechanism:** every tool loads the *nearest* `AGENTS.md`. Work in
`services/api/` and you get the Go brief; work in `apps/manager/` and you get
the Flutter brief. Neither pollutes the other. That is lazy-loading, and it is
why the root file must stay small — bloat it and you pay on every request in
every tool.

**Tier 4 is the part people skip.** Context resets between sessions; these
three survive:

- `PROGRESS.md` — tick every task. First thing to read at session start.
- `docs/adr/` — every decision, with a revisit trigger.
- Commit messages prefixed `05.3:` — six months on, `git log` answers "why".

Start each session with: *"Read AGENTS.md and PROGRESS.md. What is next?"*
End each with: tick `PROGRESS.md`, commit with the task id.

**Do not use tool-specific memory features** (`/memory`, `.cursorrules`,
Codex config). They fragment across tools and you will not keep them in sync.
The repo is the memory.

---

# What still does not exist

Honest list, so nothing surprises you:

- No Flutter project — `flutter create` is yours to run (SDK version)
- No Next.js apps — Epics 14–16
- `Materialize` and `Settle` panic by design — Epic 02
- No Connect handlers — Epic 03.4
- `internal/db/` empty until you write `queries/*.sql` and run `make sqlc`
- 3 golden vectors of a target 30–50

`make verify` fails today. That is correct — those failures are your backlog.
