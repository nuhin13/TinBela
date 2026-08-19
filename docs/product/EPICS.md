# TinBela — MVP Epics & Task Breakdown
**Droid Builder · August 2026 · companion to BRD v4.0**

> Scope of this document: **Epics 00–19 = the complete MVP (v1.0)**, from empty repo to
> published on Play Store. Later phases are summarised at high level in §2 and get their own
> backlog when they start.

---

## 1. HOW TO READ THIS

```
 EPIC nn   a coherent unit of work with one goal and one exit gate.
           Epics run mostly in order; parallel lanes are marked.
 TASK nn.k one focused agent session. Small enough to finish and verify
           in a single sitting.
 OWNER     ★ = YOU, by hand, not delegated.
           otherwise = the agent role from the Harness doc.
 GATE      the epic is not done until the gate passes. No exceptions.
```

**The rule that keeps this honest:** a task is done when `make verify` passes and you have read
the diff. Not when the agent says it is done.

---

## 2. PHASE ROADMAP (high level — targets, not task lists)

| Phase | Name | Target / definition of success | Est. |
|---|---|---|---|
| **P1** | **MVP — Bachelor Mess** | Published on Play Store. A stranger creates a mess, runs a week, closes a month, unaided. Zero taps on a normal day. **Epics 00–19 below.** | **14 days** |
| **P2** | Retention | Manager D30 ≥30% on the first cohort. Handover, shared pool (rent/utility), push, rota, photos, PDF, group view | 3 wks |
| **P3** | Institution Mode | 2 real madrashas/hostels running a full month. Group hierarchy, bulk marking, fixed-fee billing, fee categories, dues, ration store, guardian link | 6 wks |
| **P4** | Home Mode | A 4-person family uses it without seeing a single mess concept | 2 wks |
| **P5** | Entitlement Core | Generic Droid Builder billing module. Period-based purchase, not subscription. Reusable by every future product | 2 wks |
| **P6** | Offline & Sync | The paid moat. Manager device fully offline-capable; Dart engine passes the *same* golden vectors as Go | 5 wks |
| **P7** | Operations | Rooms/seats, cleaning rota, maid module, multi-mess switcher — all opt-in, default OFF | 3 wks |

**Phase gate discipline:** do not start a phase until the prior phase's target is measured, not
assumed. P3 is as large as the whole MVP; entering it without P2's retention number is the single
most likely way this roadmap goes wrong.

---

## 3. EPIC INDEX (MVP)

```
 FOUNDATION LANE
 00  Genesis — repo, structure, ADRs, design system, tooling, harness   ★
 01  Data layer — migrations, RLS, sqlc, seeds
 02  Domain engine — Materialize, Settle, property tests, vectors       ★
 03  Contracts & transport — buf, proto, Connect, codegen, middleware

 BACKEND LANE
 04  Identity, tenancy, membership, invites
 05  Meal service — slots, patterns, exceptions, day/cutoff
 06  Money — ledger, categories, void, accounts + math
 07  Periods & settlement — preview, close, immutable statements
 17  Telemetry, flags, entitlement stub

 CLIENT LANE (can start once 03 lands)
 08  Manager app foundation
 09  Manager app — onboarding & demo mess
 10  Manager app — daily loop  ★ the product
 11  Manager app — money & accounts
 12  Manager app — month close & share
 13  Manager app — members & settings

 WEB LANE (parallel)
 14  Member PWA
 15  Landing site & legal pages
 16  Admin portal

 CLOSING LANE
 18  Quality, security, hardening
 19  Release & deployment
```

---

## 4. THE EPICS

---

### EPIC 00 — GENESIS: Structure, ADRs, Design System, Harness ★

**Goal:** every later decision has a home, and every agent session starts with the same context.
**Depends on:** nothing. **Est:** 1 day. **Owner:** mostly ★ you, with `architect`.

> This epic is the reason the other nineteen go quickly. Do not compress it.

| ID | Task | Done when | Owner |
|---|---|---|---|
| 00.1 | Create monorepo skeleton per §5 tree; `.editorconfig`, `.gitignore`, LICENSE, README | Tree matches §5 exactly | ★ |
| 00.2 | Write `CLAUDE.md` root context (invariants, stack, commands, read-first list) | An agent given only `CLAUDE.md` names all 7 invariants | ★ |
| 00.3 | Commit the four planning docs to `/docs/product/` | BRD, Dev Plan, Build Spec, UI Spec present | ★ |
| 00.4 | Write ADR 0001–0015 into `/docs/adr/` (see `TinBela_ADRs.md`) | 15 ADRs committed, status Accepted | ★ + `architect` |
| 00.5 | ADR template + `/adr` command so future decisions get recorded | New ADR scaffolds in one command | `architect` |
| 00.6 | Design system tokens as code: `packages/design-tokens/tokens.json` → generates Dart theme + Tailwind config + CSS vars | One token change propagates to all three clients | `architect` |
| 00.7 | Component inventory doc from UI Spec §5 into `/docs/design/components.md` | Every component has a name, purpose, and target platform | ★ |
| 00.8 | Tooling: `mise`/`asdf` version pins (Go 1.23, Node 22, Flutter stable, buf, sqlc) | `mise install` gives a working env from scratch | `devops` |
| 00.9 | `Makefile`: `dev up down test lint verify proto sqlc migrate seed smoke` | `make verify` runs and fails loudly on a seeded violation | ★ |
| 00.10 | CI pipeline: lint → build → unit → property → golden → `buf breaking` → migration check | Green on an empty repo; red when an invariant is violated | `devops` |
| 00.11 | Agent harness: `.claude/agents/`, `.claude/skills/`, `.claude/commands/`, hooks | `/task 01.1` loads correct context (see Harness doc) | ★ |
| 00.12 | Conventions doc: naming, errors, logging, commits, branches, PR template | `/docs/eng/conventions.md` committed | `architect` |
| 00.13 | `docker-compose.yml`: postgres 16, api, caddy, mailhog | `make dev` boots the whole stack cold in <60s | `devops` |
| 00.14 | Secrets strategy: `.env.example`, no secrets in repo, dev-server env notes | CI passes with no secret access | `devops` |

**GATE:** a fresh clone reaches a running stack and green `make verify` in under ten minutes,
with no tribal knowledge.

---

### EPIC 01 — DATA LAYER

**Goal:** the schema is right the first time, because migrating live ledger data is expensive.
**Depends on:** 00. **Est:** 1 day.

| ID | Task | Done when | Owner |
|---|---|---|---|
| 01.1 | Migration tooling (`golang-migrate`), numbering convention, up/down policy | `make migrate` and rollback both work | `db` |
| 01.2 | Core tables: `tenants`, `users`, `groups`, `memberships` | Matches Build Spec §3 | `db` |
| 01.3 | Meal tables: `slots`, `patterns`, `day_flags`, `meal_exceptions` | Matches Build Spec §3 | `db` |
| 01.4 | Money tables: `ledger_entries`, `periods`, `period_statements` | Includes the `EXCLUDE USING gist` non-overlap on periods | `db` |
| 01.5 | **Append-only enforcement rules** on the three protected tables | An `UPDATE` from psql silently no-ops; test proves it | ★ |
| 01.6 | Institution hedges: `groups`, `memberships.group_id`, `billing_mode`, `fee_category` | Present, unused, documented as "P3, do not expose" | `db` |
| 01.7 | RLS policies: every tenant-scoped table, tested with two tenants | Cross-tenant read returns zero rows in a test | ★ |
| 01.8 | Indexes: exceptions by (tenant, date range), ledger by (tenant, occurred_on) | `EXPLAIN` shows index use on the day query | `db` |
| 01.9 | `sqlc` config + first generated queries; `internal/db` marked generated | Hand-edit of generated code is blocked by a hook | `db` |
| 01.10 | Seed script: demo mess, 8 members, 30 days of realistic data | `make seed` produces a browsable mess | `db` |

**GATE:** RLS proven with a two-tenant test; append-only proven by a failing-write test.

---

### EPIC 02 — DOMAIN ENGINE ★ (the most important day of the project)

**Goal:** the money math is provably correct before any UI exists.
**Depends on:** 00. **Est:** 1 day. **Owner:** ★ YOU. Do not delegate this epic.

| ID | Task | Done when | Owner |
|---|---|---|---|
| 02.1 | Define pure input/output types (no DB, no clock, no context) | `engine` package imports nothing from `db` | ★ |
| 02.2 | Write the nine property tests **before** implementations (`pgregory.net/rapid`) | Nine tests exist and fail | ★ |
| 02.3 | Implement `Materialize` — pattern → tenure → day flags → voids → exceptions | Properties P2–P6, P8, P9 pass | ★ |
| 02.4 | Implement `Settle` — floor rate, visible remainder, per-member balances | Properties P1, P7 pass | ★ |
| 02.5 | Assert the conservation invariant in code, not only in tests | Panic/error if `Σ food_cost + remainder ≠ food_paisa` | ★ |
| 02.6 | Generate 30–50 golden vectors incl. every ugly case (month boundary, leave mid-range, guest+off same slot, void-then-readd, zero meals, 500 members) | `testdata/vectors/*.json` committed, CI runs them | ★ |
| 02.7 | Vector runner reusable from Dart later (plain JSON, no Go types leaked) | A schema doc exists for the vector format | ★ |
| 02.8 | Benchmark: materialize 500 members × 31 days × 3 slots | <50ms; documented in the ADR | ★ |

**GATE:** all nine properties green, all vectors green, benchmark recorded. **Skipping this epic
means discovering a rate bug on the day 200 messes close their first month.**

---

### EPIC 03 — CONTRACTS & TRANSPORT

**Goal:** one contract, three generated clients, no hand-written API code anywhere.
**Depends on:** 00. **Est:** 1 day.

| ID | Task | Done when | Owner |
|---|---|---|---|
| 03.1 | `buf` workspace, lint rules, `buf breaking` against `main` | `make proto` generates; breaking change fails CI | `backend` |
| 03.2 | Proto packages: `tinbela.core.v1`, `meals.v1`, `money.v1`, `admin.v1` | Layout matches service seams from ADR-0004 | `architect` |
| 03.3 | Common types: `Money` (int64 paisa), `Date`, `MathExplain`, error detail | `Money` has no float field anywhere | ★ |
| 03.4 | Connect-Go handlers wired into one binary; JSON + gRPC on same endpoint | `curl` with JSON works; grpcurl works | `backend` |
| 03.5 | Codegen: Go server, TypeScript client (web + admin), **Dart protobuf models for HTTP/JSON** | Three clients generated by `make proto` | `backend` |
| 03.6 | Middleware: request id, slog structured logging, panic recovery, CORS, timeouts | Every response carries a request id | `backend` |
| 03.7 | Auth interceptor: Firebase ID token verify → user context | Invalid token returns `unauthenticated` | `backend` |
| 03.8 | Tenant interceptor: resolve tenant, set RLS session var, deny cross-tenant | Cross-tenant call returns `permission_denied` | ★ |
| 03.9 | Error taxonomy: domain error → Connect code → client message (bn/en) | One table in `/docs/eng/errors.md` | `backend` |
| 03.10 | Rate limiting middleware (per-IP, per-token) — in-process, no Kong | Burst test throttles correctly | `backend` |
| 03.11 | Health, readiness, and version endpoints | `/healthz` `/readyz` `/version` respond | `devops` |

**GATE:** a generated TypeScript client and a generated Dart model both round-trip a real call
against the running binary.

---

### EPIC 04 — IDENTITY, TENANCY & MEMBERSHIP

**Goal:** a manager can sign in and create a mess with members, alone.
**Depends on:** 01, 03. **Est:** 1 day.

| ID | Task | Done when | Owner |
|---|---|---|---|
| 04.1 | Firebase Admin SDK integration, token verification, key caching | Verified in an integration test with a real token | `backend` |
| 04.2 | `CreateSession` / `GetMe` | Returns user + tenants + role | `backend` |
| 04.3 | `CreateMess` — creates tenant + default slots + first open period + manager membership, atomically | One transaction; partial failure leaves nothing | `backend` |
| 04.4 | `AddMember` — display name, optional phone, generates invite token | Member exists with no user account required | `backend` |
| 04.5 | Invite token: long random, revocable, single-member scoped, no expiry in v1.0 | Token brute-force is infeasible; documented | ★ |
| 04.6 | Phone matching on first link open — links member to a user, no duplicates | Test: manager adds phone X, user X opens link, one row | ★ |
| 04.7 | Roles & permission checks (MANAGER vs MEMBER) at the interceptor layer | Member cannot write ledger; test proves it | `backend` |
| 04.8 | `LeaveMember` (soft) — prior meals still count | Property P8 holds through the API | `backend` |
| 04.9 | Account deletion: cascade policy, what is retained for other members' statements | Documented in `/docs/eng/data-retention.md` | ★ |

**GATE:** create mess → add 7 members → generate 7 invite links, all via generated client.

---

### EPIC 05 — MEAL SERVICE (the product)

**Goal:** Laws 1–4 work end to end over the API.
**Depends on:** 02, 04. **Est:** 1.5 days.

| ID | Task | Done when | Owner |
|---|---|---|---|
| 05.1 | Slots CRUD + per-slot `cutoff_local`; defaults on mess creation | 3 slots exist with sane cutoffs | `backend` |
| 05.2 | `SetPatterns` — all slots ON by default for a new member | New member needs zero setup to be correct | `backend` |
| 05.3 | `CreateException` — OFF / ON / GUEST / SET_QTY, single day | Row appended, never updated | `backend` |
| 05.4 | Date-range exceptions; null slot = all active slots | Property P4 holds through the API | `backend` |
| 05.5 | `VoidException` — appends a void row, never deletes | Property P2 holds through the API | ★ |
| 05.6 | Cutoff evaluation in `Asia/Dhaka`, server-side; never trusts device clock | Test with a device clock skewed 6h | ★ |
| 05.7 | `after_cutoff` stamping + `marked_by` audit | Post-cutoff edit is flagged and attributable | `backend` |
| 05.8 | `GetDay` — per-slot headcount, per-member qty, cutoff state, exception list | The single call that renders the Today screen | `backend` |
| 05.9 | Bulk exception endpoint accepting optional `group_id` (unused in v1.0) | Contract exists; mess app never sends it | `backend` |
| 05.10 | Day flags (`OFF_DAY`) — FEAST deferred to P2 | Off-day zeroes all slots | `backend` |
| 05.11 | Integration tests: 30-day scenario with 20 mixed exceptions | Result matches a golden vector | `test` |

**GATE:** a scripted 30-day mess produces the exact meal counts a hand-computed spreadsheet does.

---

### EPIC 06 — MONEY & LEDGER

**Goal:** every number is correct, append-only, and explains itself.
**Depends on:** 02, 04. **Est:** 1 day.

| ID | Task | Done when | Owner |
|---|---|---|---|
| 06.1 | `AddLedgerEntry` — FOOD_COST, DEPOSIT (v1.0 kinds only) | int64 paisa; float rejected at the type level | `backend` |
| 06.2 | Expense categories (bazar, gas, rice, fish…) — seeded, editable later | Category list localised bn/en | `backend` |
| 06.3 | `VoidLedgerEntry` — append a void row | Totals adjust; original still visible | ★ |
| 06.4 | `GetAccounts` — meal rate, totals, per-member balances | Uses `Settle` directly, no reimplementation | ★ |
| 06.5 | **`MathExplain` on every money field** | Every number in the response has formula + terms | ★ |
| 06.6 | Rounding remainder surfaced as a visible ADJUST line owned by the mess | Never silently absorbed by a member | ★ |
| 06.7 | Deposit attribution to a member; unattributed deposits rejected | Test enforces `membership_id` on DEPOSIT | `backend` |
| 06.8 | Member statement query (one member, current period) | Includes after-cutoff flags | `backend` |
| 06.9 | Money formatting service: paisa → bn/en, Bangla numerals, tabular | Shared contract used by all three clients | `backend` |

**GATE:** `Σ member.food_cost + remainder == Σ FOOD_COST` asserted at the API boundary, not just
in the engine.

---

### EPIC 07 — PERIODS & SETTLEMENT

**Goal:** the month ends, immutably, and everyone sees the same numbers forever.
**Depends on:** 06. **Est:** 1 day.

| ID | Task | Done when | Owner |
|---|---|---|---|
| 07.1 | Period lifecycle: auto-open on mess creation, non-overlap constraint | Overlapping period insert fails at DB level | `backend` |
| 07.2 | `PreviewClose` — exactly what the statement will say, no writes | Idempotent, callable repeatedly | `backend` |
| 07.3 | `ClosePeriod` — writes `period_statements`, closes period, opens next | Single transaction | ★ |
| 07.4 | Immutability proven: update/delete on statements no-ops | Test asserts it | ★ |
| 07.5 | Property P7: closing twice yields identical numbers | Green | ★ |
| 07.6 | Rollover: carry-forward balances into the new period as opening ADJUST | Documented and tested | ★ |
| 07.7 | Guard rails: refuse to close a period with zero meals or zero food cost, with a clear message | Manager sees why, not a 500 | `backend` |
| 07.8 | `GetStatement` — historical, read-only, forever | Old statements render after schema changes | `backend` |

**GATE:** close a month, change nothing, reopen the statement a week later, get identical numbers.

---

### EPIC 08 — MANAGER APP FOUNDATION

**Goal:** the Flutter shell where every later screen simply drops in.
**Depends on:** 03. **Est:** 1 day. **Runs parallel with 05–07.**

| ID | Task | Done when | Owner |
|---|---|---|---|
| 08.1 | Flutter project, `minSdk 24`, flavors (dev/prod), package `com.droidbuilder.tinbela` | Builds a debug APK | `flutter` |
| 08.2 | Theme from `design-tokens` — colours, type scale, radii, 48dp touch | No hardcoded colour anywhere; lint rule enforces | `flutter` |
| 08.3 | i18n: ARB bn + en, bn default, no hardcoded strings | Lint fails on a literal string in a widget | ★ |
| 08.4 | **Bangla numeral formatter + `MoneyText` component** | Every number in the app routes through it | ★ |
| 08.5 | Generated Dart models + HTTP/JSON client against Connect | Round-trips `GetMe` | `flutter` |
| 08.6 | State management + repository layer, offline-shaped seams for P6 | Repos return domain types, not DTOs | `architect` |
| 08.7 | Bottom nav shell: আজ · খাতা · হিসাব · আরও | Navigates, thumb-zone, labelled icons | `flutter` |
| 08.8 | Error/loading/empty primitives: skeleton, retry, toast | No spinner without a skeleton | `flutter` |
| 08.9 | Google Sign-In flow + token refresh + sign-out | Survives token expiry mid-session | `flutter` |

**GATE:** signed-in shell navigating four empty tabs, in Bangla, on a real device.

---

### EPIC 09 — ONBOARDING & DEMO MESS

**Goal:** a stranger reaches a working mess in under 90 seconds.
**Depends on:** 08, 04. **Est:** 1 day.

| ID | Task | Done when | Owner |
|---|---|---|---|
| 09.1 | Splash + language picker (bn default, en one tap) | Persisted | `flutter` |
| 09.2 | Sign-in screen per prototype | 1 tap | `flutter` |
| 09.3 | 3-question mess setup: name · kind · slots | No fourth question. Ever. | ★ |
| 09.4 | "তিনবেলা যেভাবে কাজ করে" explainer card (pattern → exception → done) | 3 lines, skippable | `flutter` |
| 09.5 | Mess created → invite link screen, copy + Messenger share | Share sheet opens Messenger first | `flutter` |
| 09.6 | "সদস্য না থাকলেও চলবে" path — solo manager start | Reachable in one tap | ★ |
| 09.7 | Demo mess: seeded locally, labelled, poke-safe, one-tap discard | Nothing the user does breaks it | `flutter` |
| 09.8 | Empty states across all four tabs that teach, not apologise | Each has one action | `flutter` |

**GATE:** timed test — a person who has never seen the app reaches a usable Today screen in <90s.

---

### EPIC 10 — DAILY LOOP ★ (the differentiation)

**Goal:** zero taps on a normal day, ≤2 taps and <10s for an exception.
**Depends on:** 05, 08. **Est:** 2 days. **The most important client epic — supervise closely.**

| ID | Task | Done when | Owner |
|---|---|---|---|
| 10.1 | **Cutoff card** — per-slot headcount, countdown, passed state | Above the fold, nothing above it | ★ |
| 10.2 | Today screen layout: cutoff card, two action buttons, exception list | Nothing else above the fold | ★ |
| 10.3 | **"বাকি সবাই ডিফল্ট প্যাটার্নে ✓ / কিছু করার নেই"** empty-day success state | A zero-exception day looks *finished* | ★ |
| 10.4 | **Exception sheet** — slot chips, অফ/গেস্ট/সংখ্যা pills, আজ/কাল/কয়েকদিন | 2 taps from member row to done | ★ |
| 10.5 | Range picker ("৩ দিন বাড়ি যাচ্ছি") | Writes one row, not N | `flutter` |
| 10.6 | Guest flow — additive, never replacing | Matches property P9 | `flutter` |
| 10.7 | Optimistic write + rollback on failure, with a visible retry | Bad-network test passes | ★ |
| 10.8 | Post-cutoff state: greyed slot, "ম্যানেজার এন্ট্রি" stamp | Audited and shown later in statements | `flutter` |
| 10.9 | **Khata grid tab** — member × slot table, tap cell → same sheet | Writes identical rows to Today | `flutter` |
| 10.10 | Void UX: "বাতিল হলো", original still visible | Never says "deleted" | `flutter` |
| 10.11 | Instrument `exception_marked` with role, tap count, elapsed ms | Feeds the efficiency KPI | `flutter` |
| 10.12 | **Tap-count audit**: 8-member mess, one normal day + 2 exceptions | ≤6 taps total, measured | ★ |

**GATE:** the tap-count audit passes on a real device with a real mess. This gate *is* the
product; if it fails, nothing downstream matters.

---

### EPIC 11 — MONEY & ACCOUNTS (client)

**Depends on:** 06, 08. **Est:** 1.5 days.

| ID | Task | Done when | Owner |
|---|---|---|---|
| 11.1 | `+বাজার` sheet: amount, category, date, note | Numeric keypad, paisa-safe, no typed decimals | `flutter` |
| 11.2 | `+জমা` sheet: member, amount, date | Member picker defaults to none | `flutter` |
| 11.3 | হিসাব screen: meal rate, totals, per-member balance list | Positive/negative colour-coded | `flutter` |
| 11.4 | **Math sheet** rendering the API `MathExplain` — never recomputed client-side | Every number opens it | ★ |
| 11.5 | Member statement screen with after-cutoff flags | Matches server statement exactly | `flutter` |
| 11.6 | Ledger history with void action and void banner | Append-only visible in the UI | `flutter` |
| 11.7 | Bangla numeral toggle verified across every money surface | One setting, global effect | ★ |
| 11.8 | Instrument `number_tapped_for_math` | Tells you if trust UX is used | `flutter` |

**GATE:** every visible number opens a correct math sheet. Zero client-side arithmetic on money —
verified by grepping for arithmetic operators in money widgets.

---

### EPIC 12 — MONTH CLOSE & SHARE

**Depends on:** 07, 11. **Est:** 1 day.

| ID | Task | Done when | Owner |
|---|---|---|---|
| 12.1 | Step 1: review — final rate, balances, warnings | Shows unresolved balances | `flutter` |
| 12.2 | Step 2: confirm — explicit irreversibility copy | The one dialog in the app | ★ |
| 12.3 | Step 3: done — statement created, new period opened | "হিসাব শেষ, আপনি মুক্ত" | `flutter` |
| 12.4 | Statement card render → 1080×1920 image | Legible on a phone, Bangla renders correctly | `flutter` |
| 12.5 | Share sheet → Messenger/WhatsApp first | Two taps from statement to sent | `flutter` |
| 12.6 | Historical statement viewer | Old months open forever | `flutter` |
| 12.7 | Instrument `month_closed`, `statement_shared` | Feeds the habit KPI | `flutter` |

**GATE:** close a month on a real device, share the image to Messenger, reopen it a day later
unchanged.

---

### EPIC 13 — MEMBERS & SETTINGS

**Depends on:** 04, 08. **Est:** 1 day.

| ID | Task | Done when | Owner |
|---|---|---|---|
| 13.1 | Members list with invite state (পাঠানো / খুলেছেন / যুক্ত) | State visible at a glance | `flutter` |
| 13.2 | Add member sheet + immediate invite share | 2 taps to send | `flutter` |
| 13.3 | Member pattern editor (all slots ON default) | Rarely needed — that is the point | `flutter` |
| 13.4 | Remove/leave member (soft, date-bounded) | Prior meals still count | `flutter` |
| 13.5 | Mess profile: name, kind | | `flutter` |
| 13.6 | Slots & cutoff time editor | Per-slot times, `Asia/Dhaka` | `flutter` |
| 13.7 | Language + Bangla numerals settings | Instant, no restart | `flutter` |
| 13.8 | **In-app account deletion** with clear consequences copy | Play requirement | ★ |
| 13.9 | Data export request (email to you in v1.0) | Play requirement | `flutter` |
| 13.10 | About: version, Droid Builder, privacy/terms links | | `flutter` |

**GATE:** account deletion works in-app and matches the web page behaviour.

---

### EPIC 14 — MEMBER PWA

**Goal:** the growth loop. No install, no password, fast on bad networks.
**Depends on:** 05, 06. **Est:** 1 day. **Parallel lane.**

| ID | Task | Done when | Owner |
|---|---|---|---|
| 14.1 | Next.js route `/m/[token]`, token auth, no session | Works in a fresh incognito window | `web` |
| 14.2 | আজ/কাল screen: my slots, cutoff countdown | Renders from one API call | `web` |
| 14.3 | 1-tap অফ and গেস্ট | Optimistic with rollback | `web` |
| 14.4 | আমার হিসাব: meals, deposits, balance, math sheets | Read-only | `web` |
| 14.5 | **Performance budget: <500KB shell, <3s first paint on throttled 3G** | Lighthouse CI gate in the pipeline | ★ |
| 14.6 | A2HS prompt on second visit ("হোমস্ক্রিনে যোগ করুন") | Not on first visit | `web` |
| 14.7 | bn/en + Bangla numerals, shared tokens with the app | Visually identical to the Flutter app | `web` |
| 14.8 | Token revocation and invalid-token friendly screen | No stack traces to users | `web` |
| 14.9 | Instrument `member_link_opened` | The K-factor input | `web` |

**GATE:** Lighthouse CI passes the size and speed budget. This is a marketing surface — a member
who waits 8 seconds never returns, and the growth loop dies with them.

---

### EPIC 15 — LANDING SITE & LEGAL

**Depends on:** 00. **Est:** 0.5 day. **Parallel lane.**

| ID | Task | Done when | Owner |
|---|---|---|---|
| 15.1 | Home page — one idea: "স্বাভাবিক দিনে কিছুই করতে হবে না" | Not a feature list | ★ |
| 15.2 | The khata-vs-apps-vs-TinBela tap comparison graphic | The single differentiating visual | `web` |
| 15.3 | Screenshots + Play badge CTA | | `web` |
| 15.4 | `/privacy` — matches the Play data safety form exactly | Reviewed line by line against the form | ★ |
| 15.5 | `/terms` | | ★ |
| 15.6 | `/delete-account` — web deletion request flow | Play requirement | ★ |
| 15.7 | bn/en, SEO basics, OG images for Messenger link previews | Link preview looks right in Messenger | `web` |

**GATE:** privacy page and data safety declaration say the same thing.

---

### EPIC 16 — ADMIN PORTAL

**Goal:** your window into production — and your debugger during the build. **Build it early.**
**Depends on:** 03, 04. **Est:** 1 day. **Start after Epic 04, not at the end.**

| ID | Task | Done when | Owner |
|---|---|---|---|
| 16.1 | Next.js app, staff-role auth, IP allowlist on the dev server | Non-staff gets 403 | `web` |
| 16.2 | Dashboard: active messes, exceptions today, closes this month | One screen | `web` |
| 16.3 | Tenant search + list | Paginated | `web` |
| 16.4 | **Tenant inspector — members, ledger, exceptions, statements, READ-ONLY** | No mutation path exists in the code | ★ |
| 16.5 | User lookup by phone / firebase uid | | `web` |
| 16.6 | Feature flags + kill switch UI | Toggles take effect without deploy | `web` |
| 16.7 | Metrics: BRD §10 events | Enough to answer "is anyone using this" | `web` |
| 16.8 | Audit log of admin reads | You will need this for trust later | `backend` |

**GATE:** you can answer "what did mess X do last Tuesday" in under 30 seconds.

---

### EPIC 17 — TELEMETRY, FLAGS & ENTITLEMENT STUB

**Depends on:** 03, 08. **Est:** 0.5 day.

| ID | Task | Done when | Owner |
|---|---|---|---|
| 17.1 | Firebase Analytics wired in Flutter; event schema doc | Names match BRD §10 exactly | `flutter` |
| 17.2 | All 14 events emitted with correct params | Verified in DebugView | ★ |
| 17.3 | Crashlytics + symbol upload in CI | A forced crash appears in console | `devops` |
| 17.4 | Remote Config: kill switch, min-version, message banner | Toggled remotely, verified on device | `flutter` |
| 17.5 | **`Entitlements.Has(ctx, tenant, feature, on_date)` interface + `alwaysAllow{}`** | Zero billing code in the repo | ★ |
| 17.6 | Every future-gated feature routes through `Has()` | Grep shows no inline entitlement logic | ★ |
| 17.7 | Server-side event sink for events the client cannot see | Month closes counted server-side | `backend` |

**GATE:** you can answer "how many messes marked an exception yesterday" from a dashboard.

---

### EPIC 18 — QUALITY, SECURITY & HARDENING

**Depends on:** all. **Est:** 1 day.

| ID | Task | Done when | Owner |
|---|---|---|---|
| 18.1 | **Smoke test script**: create mess → members → patterns → exceptions → bazar → deposits → close → statement | `make smoke` green against a live env | ★ |
| 18.2 | Load test: 500 messes, 5k members, day query + close | p95 <300ms | `devops` |
| 18.3 | Security pass: token entropy, RLS proof, IDOR attempts, rate limits | Documented pentest checklist, all passing | ★ |
| 18.4 | Dependency and secret scanning in CI | Green | `devops` |
| 18.5 | **Backup + RESTORE DRILL** — actually restore into a scratch DB | Timed and documented | ★ |
| 18.6 | Bangla copy pass — every string read aloud by a native speaker who is not you | Sign-off recorded | ★ |
| 18.7 | Font scaling at 130%, Bangla overflow check on every screen | No clipping | `flutter` |
| 18.8 | Low-end device test: 4-year-old mid-range Android, 60fps | Documented device + result | ★ |
| 18.9 | Bad-network matrix: offline, flaky, high-latency | Retry works everywhere; no data loss | ★ |
| 18.10 | Crash-free session rate over 3 days of own daily use | 100% | ★ |

**GATE:** `make smoke` green, restore drill done, Bangla signed off.

---

### EPIC 19 — RELEASE & DEPLOYMENT

**Depends on:** 18. **Est:** 1 day. **You own the infra; these are the product-side tasks.**

| ID | Task | Done when | Owner |
|---|---|---|---|
| 19.1 | Play App Signing, keystore secured and backed up **off the dev server** | Documented recovery path | ★ |
| 19.2 | Release build pipeline → signed AAB, versioned, changelog | One command | `devops` |
| 19.3 | Store listing bn-BD **and** en-US | bn-BD is the ASO that matters | ★ |
| 19.4 | Assets: 512 icon, 1024×500 feature graphic, 6 screenshots with Bangla captions | First two screenshots = cutoff card + statement | ★ |
| 19.5 | Data safety form matching the shipped app exactly | Re-verified after the final build | ★ |
| 19.6 | Content rating; target audience **18+** | Avoids the Families policy programme | ★ |
| 19.7 | Permissions audit: `INTERNET` only, no `READ_SMS` | Manifest reviewed | ★ |
| 19.8 | Production deploy: Caddy TLS, Postgres backups on cron, log retention | Verified on the dev server | ★ |
| 19.9 | Rollback plan: previous AAB retained, remote kill switch tested live | Drill completed | ★ |
| 19.10 | Post-launch watch: crash dashboard, error alerting, day-1 metric check | Alerts reach your phone | ★ |

**GATE:** published, installable from Play, and you get a phone alert when the API errors.

---

## 5. REPO STRUCTURE (one repo, everything, in order)

```
tinbela/
├── CLAUDE.md                    ★ root agent context
├── Makefile                     dev · test · verify · proto · smoke · ship
├── docker-compose.yml
├── .mise.toml                   pinned tool versions
│
├── .claude/                     ── THE HARNESS ──
│   ├── agents/                  role definitions (see Harness doc)
│   ├── skills/                  reusable instruction bundles
│   ├── commands/                /task /adr /review /ship
│   └── hooks/                   format · lint · invariant guards
│
├── docs/
│   ├── product/                 BRD, Dev Plan, Build Spec, UI Spec, Epics
│   ├── adr/                     0001…nnnn — every architectural decision
│   ├── design/                  tokens, components, screen inventory
│   ├── eng/                     conventions, errors, runbooks, retention
│   └── ops/                     deploy, backup, restore drill, incidents
│
├── proto/                       ★ THE CONTRACT
│   ├── buf.yaml · buf.gen.yaml
│   └── tinbela/{core,meals,money,admin}/v1/*.proto
│
├── packages/
│   ├── design-tokens/           tokens.json → Dart theme + Tailwind + CSS
│   └── api-clients/             generated TS client (web + admin)
│
├── services/
│   └── api/                     Go — one binary, modular monolith
│       ├── cmd/api/
│       ├── migrations/
│       ├── internal/
│       │   ├── core/            tenants · users · memberships · groups
│       │   ├── meals/           engine.go ★ · service
│       │   ├── money/           settle.go ★ · ledger · accounts
│       │   ├── periods/         preview · close · statements
│       │   ├── invites/
│       │   ├── entitlements/    interface + alwaysAllow
│       │   ├── telemetry/
│       │   ├── transport/       Connect handlers · interceptors
│       │   └── db/              sqlc-generated — DO NOT HAND EDIT
│       └── testdata/vectors/    ★ golden vectors (shared with Dart in P6)
│
├── apps/
│   ├── manager/                 Flutter — Android
│   ├── web/                     Next.js — landing + member PWA (public)
│   └── admin/                   Next.js — admin portal (internal)
│
├── harness/
│   ├── smoke/                   end-to-end scenario scripts
│   ├── load/                    k6 scripts
│   └── fixtures/                seed data
│
└── .github/workflows/           ci.yml · release.yml
```

**Why `internal/` packages and not services:** ADR-0004. The package boundaries are the future
service boundaries. When one needs to become its own binary, the proto contract already exists
and the boundary becomes a network hop with no contract change.

---

## 6. CRITICAL PATH & PARALLEL LANES

```
 D1   ├─ 00 Genesis ★
 D2   ├─ 01 Data layer          ┊  02 Engine ★  ← do not delegate
 D3   ├─ 03 Contracts           ┊
 D4   ├─ 04 Identity            ┊  08 Flutter foundation  (parallel)
 D5   ├─ 05 Meal service        ┊  16 Admin portal v0     ← your debugger
 D6   ├─ 05 Meal service        ┊  09 Onboarding
 D7   ├─ 06 Money               ┊  10 Daily loop ★
 D8   ├─ 07 Periods             ┊  10 Daily loop ★
 D9   ├─ 14 Member PWA          ┊  11 Money & accounts
 D10  ├─ 15 Landing             ┊  11 Money & accounts
 D11  ├─ 16 Admin complete      ┊  12 Month close
 D12  ├─ 13 Members & settings  ┊  17 Telemetry
 D13  ├─ 18 Hardening ★
 D14  ├─ 19 Release ★
```

**If a day slips, cut in this order:** khata grid (10.9) → demo mess (09.7) → admin metrics
(16.7) → landing polish (15.2, 15.3). **Never cut:** Epic 02, task 10.4, task 11.4, Epic 14.
Those four *are* the differentiation; everything else is table stakes your competitors already
ship.
