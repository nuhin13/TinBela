# TinBela — Agentic Development Harness
## Agents · Skills · Commands · Hooks · Verification
**Droid Builder · lives at `.claude/` in the monorepo**

---

## 0. THE PROBLEM THIS SOLVES

You are one person running a build that would normally take a team. Agents make that possible,
but they fail in a specific way: **they are confidently wrong about invariants that are obvious to
you and invisible to them.** An agent will write `UPDATE ledger_entries`, or a `float64` for money,
or a hardcoded Bangla string, not out of carelessness but because those are normal in most
codebases.

The harness exists so that **the machine catches those, not you.** Every layer below is a filter:

```
 1. CONTEXT   agents load the right rules before writing a line
 2. ROLES     narrow agents that cannot wander outside their lane
 3. HOOKS     mechanical blocks at the moment of edit
 4. VERIFY    one command that proves the invariants still hold
 5. REVIEW    your eyes, on a diff that is already known-clean
```

Layers 1–4 mean your review time goes to design, not to catching `float`.

---

## 1. `.claude/` LAYOUT

```
 .claude/
 ├── settings.json           hooks, permissions, MCP servers
 ├── agents/
 │   ├── architect.md        design, ADRs, seams — writes no feature code
 │   ├── backend-go.md       Go services, handlers, sqlc
 │   ├── db.md               migrations, RLS, indexes
 │   ├── flutter.md          Flutter screens per UI Spec
 │   ├── web.md              Next.js PWA, landing, admin
 │   ├── test.md             property, golden, contract, smoke tests
 │   ├── reviewer.md         invariant audit before merge
 │   ├── bangla.md           ARB strings + Bangla copy QA
 │   └── devops.md           CI, docker, release pipeline
 ├── skills/
 │   ├── tinbela-invariants/ the 7 laws — loaded by EVERY backend task
 │   ├── design-system/      tokens, components, UX laws
 │   ├── go-conventions/
 │   ├── flutter-conventions/
 │   ├── proto-contract/     how to write and evolve proto safely
 │   ├── adr-writer/
 │   └── epic-runner/        the session protocol below
 ├── commands/
 │   ├── task.md             /task 05.3
 │   ├── adr.md              /adr "Use Connect over plain REST"
 │   ├── review.md           /review
 │   ├── epic.md             /epic 05     (plan the whole epic)
 │   └── ship.md             /ship
 └── hooks/
     ├── pre-edit-guard.sh
     ├── post-edit-format.sh
     └── stop-verify.sh
```

---

## 2. AGENT ROSTER

Each agent gets a narrow lane. **Narrowness is the point** — a general-purpose agent given the
whole repo will refactor things you did not ask it to touch.

| Agent | Owns | Must never | Loads skills |
|---|---|---|---|
| **architect** | ADRs, package seams, proto layout, design-token pipeline, conventions | Write feature code or migrations | adr-writer, proto-contract |
| **backend-go** | Go handlers, services, interceptors, sqlc queries | Touch `internal/meals/engine.go`, `internal/money/settle.go`, or `internal/db/` (generated) | tinbela-invariants, go-conventions |
| **db** | Migrations, RLS, indexes, seeds | Write application logic; drop or alter an append-only table | tinbela-invariants |
| **flutter** | Screens, widgets, navigation, state | Hardcode a string, a colour, or perform money arithmetic | design-system, flutter-conventions |
| **web** | Next.js PWA, landing, admin | Exceed the PWA size budget; add mutation paths to admin | design-system |
| **test** | Property, golden, contract, smoke, load tests | Change source to make a test pass | tinbela-invariants |
| **reviewer** | Reads diffs against the invariant checklist | Write or edit code | tinbela-invariants, design-system |
| **bangla** | ARB files, Bangla copy, numerals, overflow | Change logic | design-system |
| **devops** | CI, docker, Makefile, release pipeline | Touch application code | go-conventions |

**No agent owns `engine.go` or `settle.go`.** Epic 02 is yours by hand. That restriction is
enforced by a hook, not by discipline.

### Example: `.claude/agents/backend-go.md`

```markdown
---
name: backend-go
description: Go service, handler, and query work for the TinBela API.
  Use for Epics 03-07, 16, 17 backend tasks.
tools: Read, Edit, Bash, Grep, Glob
---

You implement Go backend code for TinBela.

ALWAYS load the `tinbela-invariants` skill before writing code.

## Your lane
services/api/internal/{core,periods,invites,transport,telemetry,entitlements}
services/api/internal/{meals,money}/service.go and handlers — NOT engine.go
or settle.go.

## Hard rules
- Money is int64 paisa. If you type `float`, you are wrong.
- Never UPDATE or DELETE ledger_entries, meal_exceptions, period_statements.
  Corrections INSERT a void row.
- Never store a derived meal count. Call meals.Materialize.
- Never reimplement settlement arithmetic. Call money.Settle.
- Never hand-edit internal/db/ — it is sqlc-generated. Edit the .sql and
  run `make sqlc`.
- Every query is tenant-scoped. Every handler resolves tenant from context.
- Dates resolve in Asia/Dhaka server-side. Never trust a client clock.
- Gated features call entitlements.Has(). Never inline a billing check.

## Workflow
1. Read the task in docs/product/Epics.md.
2. Write or extend the test first.
3. Implement.
4. Run `make verify`. If red, fix before reporting.
5. Report: what changed, what you did NOT do, what needs human review.

## When to stop and ask
- The task implies a feature not in BRD §7.1.
- You need to change proto in a way `buf breaking` would reject.
- You need to alter an append-only table.
```

---

## 3. SKILLS (reusable instruction bundles)

### `tinbela-invariants` — the most important file in the harness

```markdown
---
name: tinbela-invariants
description: The seven non-negotiable rules of the TinBela codebase.
  Load for ANY task touching the API, database, or money.
---

1. MONEY IS int64 PAISA. Never float, never a decimal string in JSON.
   ৳12.40 is 1240. Formatting happens at the edge, never in logic.

2. APPEND-ONLY. ledger_entries, meal_exceptions, period_statements are
   never UPDATEd or DELETEd. A correction INSERTs a row with void_of set.
   Postgres rules enforce this — if your code needs an UPDATE, your design
   is wrong.

3. DERIVED IS NEVER STORED. Daily meal counts do not exist as rows. They
   are materialized from patterns ⊕ exceptions ⊕ day_flags on every read.
   The only snapshot is period_statements, written once at close.

4. TENANT ON EVERY ROW, TENANT ON EVERY QUERY. RLS is a backstop, not the
   primary defence.

5. Asia/Dhaka, SERVER-SIDE. Cutoff correctness is a trust feature. Never
   trust the device clock.

6. ENTITLEMENTS GO THROUGH Has(ctx, tenant, feature, on_date). In v1.0 it
   always returns true. Never write inline billing logic.

7. IF IT IS NOT IN BRD §7.1, IT IS NOT IN v1.0. Propose it as a P2 item
   instead of building it.

## The self-check before you report done
- Did I introduce a float in a money path?         → grep
- Did I write UPDATE or DELETE on a protected table? → grep
- Did I store a computed meal count?                → review
- Is every new query tenant-scoped?                 → review
- Did `make verify` pass?                           → run it
```

### `design-system`

Loads UI Spec §1 (tokens), §5 (components), §6 (the ten UX laws), plus:

```
 · No hardcoded colours. Import from the generated theme.
 · No hardcoded strings. Every user-visible string is an ARB key.
 · Every number renders through MoneyText. No exceptions.
 · Minimum touch target 48dp.
 · No spinner without a skeleton. No error without retry.
 · A zero-exception day must LOOK FINISHED, not empty.
 · Client never computes money. It renders the MathExplain the API sent.
```

### `epic-runner` — the session protocol

```markdown
For every task:
1. Read docs/product/Epics.md — find the task ID, its Done-when, its Owner.
2. Read the epic's Depends-on. If unmet, stop and say so.
3. Load the skills named for your agent role.
4. State your plan in 3-6 bullets. Wait if the plan touches proto, the
   engine, or a migration on an existing table.
5. Write the test first when the task touches money or the engine.
6. Implement the smallest change that satisfies Done-when.
7. Run `make verify`.
8. Report in this shape:
   - Changed: files and why
   - NOT done: anything in the task you deliberately skipped
   - Needs human review: judgement calls you made
   - Next task suggested: id only
```

---

## 4. SLASH COMMANDS

| Command | Does |
|---|---|
| `/epic 05` | Reads the epic, lists tasks, checks dependencies, proposes an order and which agent takes each. Plans only — writes no code. |
| `/task 05.3` | Loads the task + epic + skills, runs the `epic-runner` protocol end to end. |
| `/adr "title"` | Scaffolds the next-numbered ADR from the template, prompts for context/decision/consequences. |
| `/review` | Runs `reviewer` over the working diff against the invariant checklist. Run before every commit. |
| `/ship` | Runs full verify + smoke, bumps version, generates changelog, builds the release AAB. |

**Example `.claude/commands/task.md`:**

```markdown
---
description: Run one epic task end to end using the correct agent and skills
argument-hint: <task-id, e.g. 05.3>
---

Task ID: $1

1. Read docs/product/TinBela_MVP_Epics_and_Tasks.md and locate task $1.
2. Identify the epic, its Depends-on, the task's Done-when and Owner.
3. If Owner is ★, STOP and tell the user this task is hand-written and
   must not be delegated. Offer to write the test scaffold only.
4. Otherwise delegate to the named agent, which loads its skills and
   follows the `epic-runner` protocol.
5. Finish by running `make verify` and reporting in the required shape.
```

That step 3 is worth more than it looks. It is what stops an agent from quietly writing your
settlement engine at 2am because the task was next in the list.

---

## 5. HOOKS — mechanical enforcement

Hooks fire regardless of what any agent intends, which is exactly why they work.

| Hook | Trigger | Action |
|---|---|---|
| **pre-edit-guard** | Before `Edit`/`Write` | **Block** edits to `internal/db/**` (sqlc-generated), `internal/meals/engine.go`, `internal/money/settle.go`, `migrations/*` already applied to prod, and `testdata/vectors/**` |
| **post-edit-format** | After editing `*.go` | `gofmt`, `go vet` |
| **post-edit-format** | After editing `*.dart` | `dart format`, `flutter analyze` |
| **post-edit-format** | After editing `*.proto` | `buf lint`, `buf breaking --against main` |
| **stop-verify** | End of an agent turn | `make verify` — the turn is not clean until it is green |

**`pre-edit-guard.sh` core:**

```bash
#!/usr/bin/env bash
PROTECTED=(
  "services/api/internal/db/"
  "services/api/internal/meals/engine.go"
  "services/api/internal/money/settle.go"
  "services/api/testdata/vectors/"
)
for p in "${PROTECTED[@]}"; do
  case "$CLAUDE_TOOL_FILE_PATH" in
    *"$p"*)
      echo "BLOCKED: $p is protected. Engine and generated code are hand-owned." >&2
      exit 2 ;;
  esac
done
```

---

## 6. `make verify` — the single gate

Everything above funnels into one command. If this is green, the invariants hold.

```makefile
verify: lint test property golden contract invariants migrate-check
	@echo "✓ verify green"

lint:
	golangci-lint run ./...
	cd apps/manager && flutter analyze
	cd apps/web && pnpm lint
	buf lint

test:            ## unit + integration
	go test ./... -race

property:        ## the nine engine properties
	go test ./services/api/internal/meals ./services/api/internal/money -run Property -rapid.checks=1000

golden:          ## the shared vectors — Go now, Dart in P6
	go test ./services/api/internal/... -run Golden

contract:        ## generated clients round-trip against the binary
	buf breaking --against '.git#branch=main'
	go test ./services/api/internal/transport -run Contract

invariants:      ## grep-level guards that types cannot express
	@! grep -rn "float32\|float64" services/api/internal/money services/api/internal/meals \
		|| (echo "✗ float in a money path" && exit 1)
	@! grep -rniE "UPDATE (ledger_entries|meal_exceptions|period_statements)" services/api \
		|| (echo "✗ update on an append-only table" && exit 1)
	@! grep -rn "localStorage\|sessionStorage" apps/web/app/m \
		|| (echo "✗ browser storage in the member PWA" && exit 1)
	@./harness/check-hardcoded-strings.sh apps/manager/lib
	@./harness/check-hardcoded-colors.sh apps/manager/lib

migrate-check:   ## every migration is reversible and applies cleanly
	./harness/migrate-roundtrip.sh

smoke:           ## full scenario against a running env
	go run ./harness/smoke -env=$(ENV)
```

**The `invariants` target is the highest-value 20 lines in the repo.** Types catch some mistakes;
these greps catch the ones types cannot express, and they cost nothing to run.

---

## 7. MCP SERVERS WORTH CONNECTING

| Server | Why | Caution |
|---|---|---|
| **Postgres (read-only role)** | Agents inspect real schema and data instead of guessing | Read-only role only. Never give an agent write credentials to a database holding customer ledgers |
| **GitHub** | Issues per task, PR creation, CI status | Fine |
| **Filesystem** | Scoped to the repo | Default |
| **Sentry / error tracking** | From Epic 19 onward, agents can triage from real stack traces | Post-launch |

Do not connect a payment, email, or production-write MCP during the MVP. There is nothing an agent
needs from them and a real cost if one misfires.

---

## 8. SKILL SET — WHAT *YOU* NEED TO BE GOOD AT

Agents cover breadth. These are the places where your own judgement is the load-bearing element,
in rough order of how expensive it is to get wrong.

```
 1. DOMAIN MODELLING          Epic 02. Append-only ledgers, materialization,
                              integer money. Nobody can check this for you.
 2. READING DIFFS             Your only real defence. Budget 20% of every
                              day for it. An unreviewed agent diff is
                              technical debt that compounds silently.
 3. SCOPE DISCIPLINE          Saying no to good ideas for 14 days. This is
                              the hardest one and the highest leverage.
 4. POSTGRES                  RLS, constraints, indexes, EXPLAIN, backup
                              and restore. You are the DBA.
 5. GO — INTERFACES & SEAMS   Where the package boundaries go now decides
                              whether P6 offline is weeks or months.
 6. FLUTTER — STATE & PERF    60fps on a 4-year-old device is a product
                              requirement, not a nicety.
 7. PROTO EVOLUTION           Adding fields safely, never renumbering.
                              `buf breaking` helps, understanding is better.
 8. BANGLA UX COPY            The single biggest quality differentiator
                              against incumbents, and completely
                              un-delegatable to an agent.
 9. TALKING TO MANAGERS       From P2 onward this outranks everything above.
```

---

## 9. THE DAILY LOOP

```
 MORNING   /epic nn         → plan, check dependencies, assign agents
           pick 3-5 tasks. Not eight. Verification is the bottleneck,
           not generation.

 EACH TASK /task nn.k       → agent works, verify runs, agent reports
           you read the diff                       ← never skip
           commit with the task id in the message

 ★ TASKS   you write them. Agent may scaffold tests only.

 EVENING   /review          → invariant audit across the day's diff
           make smoke       → the scenario still works end to end
           update the epic checklist in docs/
           write an ADR if you made a decision worth remembering
```

**The one metric for the harness itself:** how often does `make verify` catch something before you
do? If the answer is never, your gates are too loose. If it is constantly, your agent context is
too thin — fix the skill, not the code.

---

## 10. WHAT NOT TO AUTOMATE

Some things look automatable and are traps.

```
 ✗ The settlement engine (Epic 02). Correct-looking arithmetic that is
   subtly wrong is the worst possible failure here, and it surfaces on
   the day 200 messes close their first month.
 ✗ Bangla user-facing copy. An agent produces grammatical Bangla that
   sounds like a bank. Your brand is a friend who is good at maths.
 ✗ The scope decision. Agents are helpful by nature and will happily
   build P3 features in week one.
 ✗ Schema changes to live tables. Once real ledgers exist, every
   migration is a hand-reviewed event.
 ✗ Security decisions — token entropy, RLS policy, permission checks.
   Review each personally, once, properly.
```
