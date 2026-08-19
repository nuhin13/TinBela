# START HERE

You extracted the TinBela repo scaffold. Here is the first hour.

---

## 1. What you have

**Epic 00 is done.** Structure, ADRs, design system, tooling, CI, and the
full agent harness are in place. Epic 01 (schema) is written. Epic 02 (the
engine) is scaffolded with its nine property tests waiting for you.

Everything else is a backlog of ~170 tasks with IDs, done-when conditions,
and assigned agents.

```
CLAUDE.md      the context every agent loads
PROGRESS.md    tick as you go — this is your board
docs/product/  BRD · dev plan · build spec · UI spec · epics · harness
docs/adr/      15 decisions, each with a revisit trigger
.claude/       9 agents · 7 skills · 5 commands · 3 hooks
proto/         the API contract — single source of truth
services/api/  Go modular monolith
apps/          manager (Flutter) · web (landing + PWA) · admin
harness/       smoke · load · fixtures · invariant checks
```

---

## 2. First 20 minutes — verify the scaffold before trusting it

```bash
git init && git add -A && git commit -m "00.1: repo genesis"
mise install                    # or install Go 1.23, Node 22, buf, sqlc, migrate
cp .env.example .env
make dev                        # postgres + api
curl localhost:8080/healthz     # {"status":"ok"}
make tokens                     # generates Dart theme, Tailwind, CSS
```

`make verify` will fail on Epic 02 — that is correct. Those panics are your
next task.

---

## 3. Read, in this order

1. `docs/adr/README.md` — the table. Fifteen decisions in five minutes.
2. `CLAUDE.md` — the seven invariants. Know them cold.
3. `docs/product/EPICS.md` §2 — the phase roadmap.
4. `PROGRESS.md` — where you are.

---

## 4. Your Day 2 — the one that matters

**Epic 02. By hand. Do not delegate it.**

```
services/api/internal/meals/engine.go          ← Materialize
services/api/internal/meals/engine_test.go     ← 7 properties, waiting
services/api/internal/money/settle.go          ← Settle
services/api/internal/money/settle_test.go     ← 2 properties, waiting
services/api/testdata/vectors/                 ← 3 seeded, write 27+ more
```

Write the properties first, then the implementations. Remove each `t.Skip`
as you go.

A hook blocks agents from editing these files. That is deliberate. This is
where money bugs live, and a money bug surfaces on the day 200 messes close
their first month — the worst possible day to find one.

---

## 5. Then run tasks

```
/epic 03        plan an epic, check dependencies, assign agents
/task 03.4      run one task end to end
/review         invariant audit on your working diff
/adr "title"    record a decision
/ship           full verify + smoke + release build
```

If a task's Owner column is ★, the harness stops and tells you it is yours.

---

## 6. The daily rhythm

```
MORNING   /epic nn  → pick 3–5 tasks. Not eight.
                     Verification is the bottleneck, not generation.
EACH TASK /task nn.k → agent works, verify runs, you READ THE DIFF
                     commit with the task id in the message
EVENING   /review    → invariant audit across the day
          make smoke → the scenario still works end to end
          tick PROGRESS.md
```

---

## 7. The three rules

1. **A task is done when `make verify` is green AND you have read the diff.**
   Not one or the other.
2. **When a day slips, cut scope from BRD §7.1.** Never extend the phase.
   The cut order is at the bottom of `PROGRESS.md`.
3. **If it is not in BRD §7.1, it is not in v1.0.** Agents are helpful by
   nature and will cheerfully build Phase 3 features in week one.

---

## 8. What the MVP is actually proving

Not features. One number: **do managers still open it on day 30?**

The whole product is one idea — a normal day costs zero taps. If the
tap-count audit in task 10.12 fails, nothing downstream matters. If it
passes, you have something no competitor in this market has.

তিনবেলার হিসাব, এক অ্যাপে।
