# TinBela — Build Spec (Go + Postgres)
## The executable form of BRD v4.0
**Droid Builder · for Claude Code / agentic development sessions**

---

## 1. HOW TO USE THIS

Commit BRD v4, the Dev Plan, this file, and the UI Spec to `/docs` on Day 1. Then put a
`CLAUDE.md` at the repo root:

```markdown
# TinBela — Droid Builder

Meal & mess management for Bangladeshi bachelor messes (v1.0),
later madrasha/hostel institutions and small families.

## Read before any task
- docs/BRD_v4.md            §6 (six design laws) and §7.1 (v1.0 scope)
- docs/Build_Spec_Go.md     schema, engine contract, API, invariants
- docs/UI_Spec.md           screens, components, tokens

## Non-negotiable invariants
1. All money is int64 paisa. Never float. Never a decimal string in JSON.
2. ledger_entries and meal_exceptions are APPEND-ONLY. Corrections
   INSERT a new row with void_of set. Never UPDATE. Never DELETE.
3. Daily meal counts are NEVER stored. Always materialized from
   patterns ⊕ exceptions ⊕ day_flags.
4. Every table has tenant_id. Every query is tenant-scoped.
5. All date boundaries resolve in Asia/Dhaka, server-side. Never trust
   the device clock for cutoff decisions.
6. Gated features call Entitlements.Has(). In v1.0 it always returns
   true. Never write billing logic inline.
7. If a change adds a feature not in BRD §7.1, stop and ask.

## Stack
Go 1.23 · chi · pgx/v5 · sqlc · golang-migrate · slog
Postgres 16 · Flutter (Android) · Next.js 15 (web + admin)

## Commands
make test        # must pass before any commit
make lint
make dev
make sqlc        # regenerate queries after editing *.sql
make openapi     # regenerate TS types + Dart client
```

**The one rule:** agents are excellent at handlers, screens, serializers, and wiring. They are
unreliable at append-only ledger arithmetic. **You write §4 by hand. Delegate everything else.**

---

## 2. MONOREPO LAYOUT

```
tinbela/
├── CLAUDE.md
├── docs/                          # the four planning documents
├── Makefile
├── docker-compose.yml             # postgres + api
├── openapi.yaml                   # ★ single source of API truth
├── api/                           # Go
│   ├── cmd/api/main.go
│   ├── migrations/                # golang-migrate, numbered
│   ├── internal/
│   │   ├── core/                  # tenants, users, memberships, groups, RLS
│   │   ├── meals/
│   │   │   ├── engine.go          # ★ PURE — hand-written
│   │   │   └── engine_test.go     # ★ property tests — hand-written
│   │   ├── money/
│   │   │   ├── settle.go          # ★ PURE — hand-written
│   │   │   └── settle_test.go     # ★
│   │   ├── ledger/                # append-only writes, void
│   │   ├── periods/               # preview, close, statements
│   │   ├── invites/               # magic-link tokens
│   │   ├── entitlements/          # interface + alwaysAllow{} for v1.0
│   │   ├── httpx/                 # chi router, middleware, tenant ctx
│   │   └── db/                    # sqlc-generated, do not hand-edit
│   └── testdata/
│       └── vectors/*.json         # ★ golden vectors, shared with Dart
├── app/                           # Flutter, Android
│   └── lib/{core,features}/
├── web/                           # Next.js — landing + member PWA (public)
└── admin/                         # Next.js — admin portal (internal)
```

**Why `openapi.yaml` is not optional:** it generates TypeScript types for both Next.js apps and
the Dart client for Flutter. Hand-written clients across four codebases is where solo projects
quietly accumulate bugs, and it is a category of error agents produce constantly.

---

## 3. SCHEMA (v1.0 — includes the institution hedges from BRD §7.4)

```sql
CREATE TABLE tenants (
  id            uuid PRIMARY KEY,
  name          text NOT NULL,
  kind          text NOT NULL CHECK (kind IN ('MESS','INSTITUTION','HOME')),
  billing_mode  text NOT NULL DEFAULT 'RATE_BASED'
                CHECK (billing_mode IN ('RATE_BASED','FIXED_FEE')),
  timezone      text NOT NULL DEFAULT 'Asia/Dhaka',
  created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE users (
  id                  uuid PRIMARY KEY,
  firebase_uid        text UNIQUE,        -- null for manager-added members
  phone_e164          text,               -- links a member to a future login
  name                text NOT NULL,
  locale              text NOT NULL DEFAULT 'bn',
  use_bangla_numerals boolean NOT NULL DEFAULT true,
  created_at          timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX ON users (phone_e164) WHERE phone_e164 IS NOT NULL;

-- INSTITUTION HEDGE: created in v1.0, unused until P3
CREATE TABLE groups (
  id         uuid PRIMARY KEY,
  tenant_id  uuid NOT NULL REFERENCES tenants,
  parent_id  uuid REFERENCES groups,
  name       text NOT NULL,
  kind       text CHECK (kind IN ('BATCH','BLOCK','ROOM'))
);

CREATE TABLE memberships (
  id               uuid PRIMARY KEY,
  tenant_id        uuid NOT NULL REFERENCES tenants,
  user_id          uuid NOT NULL REFERENCES users,
  group_id         uuid REFERENCES groups,          -- hedge
  role             text NOT NULL CHECK (role IN ('MANAGER','MEMBER','ACCOUNTANT','WARDEN','GUARDIAN')),
  fee_category     text CHECK (fee_category IN ('FULL','SUBSIDIZED','FREE')),  -- hedge
  display_name     text NOT NULL,          -- manager adds "সুমাইয়া", no account needed
  joined_at        date NOT NULL,
  left_at          date,                   -- soft leave; prior meals still count
  invite_token     text UNIQUE,
  invite_opened_at timestamptz,
  UNIQUE (tenant_id, user_id)
);

CREATE TABLE slots (
  id           uuid PRIMARY KEY,
  tenant_id    uuid NOT NULL REFERENCES tenants,
  name_bn      text NOT NULL,
  name_en      text NOT NULL,
  sort_order   int  NOT NULL,
  cutoff_local time NOT NULL,              -- resolved in tenant timezone
  active       boolean NOT NULL DEFAULT true
);

CREATE TABLE patterns (                    -- Law 1
  id             uuid PRIMARY KEY,
  tenant_id      uuid NOT NULL REFERENCES tenants,
  membership_id  uuid NOT NULL REFERENCES memberships,
  slot_id        uuid NOT NULL REFERENCES slots,
  dow_mask       smallint NOT NULL DEFAULT 127,  -- bit 0 = Saturday (BD week)
  qty            smallint NOT NULL DEFAULT 1,
  effective_from date NOT NULL,
  UNIQUE (membership_id, slot_id, effective_from)
);

CREATE TABLE day_flags (
  id        uuid PRIMARY KEY,
  tenant_id uuid NOT NULL REFERENCES tenants,
  date      date NOT NULL,
  kind      text NOT NULL CHECK (kind IN ('FEAST','OFF_DAY')),
  note      text
);

CREATE TABLE meal_exceptions (             -- Law 2 + Law 5. APPEND-ONLY.
  id            uuid PRIMARY KEY,
  tenant_id     uuid NOT NULL REFERENCES tenants,
  membership_id uuid NOT NULL REFERENCES memberships,
  slot_id       uuid REFERENCES slots,     -- null = every active slot
  date_from     date NOT NULL,
  date_to       date NOT NULL,             -- == date_from for a single day
  action        text NOT NULL CHECK (action IN ('OFF','ON','SET_QTY','GUEST')),
  qty           smallint,                  -- SET_QTY value, or guest count
  marked_by     uuid NOT NULL REFERENCES users,
  after_cutoff  boolean NOT NULL DEFAULT false,   -- Law 4 audit
  void_of       uuid REFERENCES meal_exceptions,
  created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE ledger_entries (              -- Law 5. APPEND-ONLY.
  id            uuid PRIMARY KEY,
  tenant_id     uuid NOT NULL REFERENCES tenants,
  kind          text NOT NULL CHECK (kind IN
                ('FOOD_COST','SHARED_COST','DEPOSIT','RENT_PAYOUT',
                 'STAFF_SALARY','FIXED_FEE','ADJUST')),
  amount_paisa  bigint NOT NULL,           -- ALWAYS integer paisa
  category      text,
  membership_id uuid REFERENCES memberships,   -- required for DEPOSIT
  occurred_on   date NOT NULL,
  note          text,
  photo_url     text,                      -- P2
  entered_by    uuid NOT NULL REFERENCES users,
  void_of       uuid REFERENCES ledger_entries,
  created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE periods (
  id         uuid PRIMARY KEY,
  tenant_id  uuid NOT NULL REFERENCES tenants,
  start_date date NOT NULL,
  end_date   date NOT NULL,
  status     text NOT NULL CHECK (status IN ('OPEN','CLOSED')),
  closed_at  timestamptz,
  EXCLUDE USING gist (tenant_id WITH =, daterange(start_date, end_date, '[]') WITH &&)
);

CREATE TABLE period_statements (           -- Law 6. Written ONCE. IMMUTABLE.
  id                  uuid PRIMARY KEY,
  tenant_id           uuid NOT NULL REFERENCES tenants,
  period_id           uuid NOT NULL REFERENCES periods,
  membership_id       uuid NOT NULL REFERENCES memberships,
  meals_qty           int    NOT NULL,
  meal_rate_paisa     bigint NOT NULL,
  food_cost_paisa     bigint NOT NULL,
  shared_cost_paisa   bigint NOT NULL DEFAULT 0,
  deposits_paisa      bigint NOT NULL,
  balance_paisa       bigint NOT NULL,     -- positive = mess owes member
  closed_at           timestamptz NOT NULL,
  UNIQUE (period_id, membership_id)
);
```

**Enforce append-only in the database, not just in Go:**

```sql
CREATE RULE no_upd_stmt AS ON UPDATE TO period_statements DO INSTEAD NOTHING;
CREATE RULE no_del_stmt AS ON DELETE TO period_statements DO INSTEAD NOTHING;
CREATE RULE no_upd_ledg AS ON UPDATE TO ledger_entries    DO INSTEAD NOTHING;
CREATE RULE no_del_ledg AS ON DELETE TO ledger_entries    DO INSTEAD NOTHING;
CREATE RULE no_upd_exc  AS ON UPDATE TO meal_exceptions   DO INSTEAD NOTHING;
CREATE RULE no_del_exc  AS ON DELETE TO meal_exceptions   DO INSTEAD NOTHING;
```

An agent will eventually write an `UPDATE` out of habit. Let Postgres refuse it.

---

## 4. ★ THE ENGINE — WRITE THIS YOURSELF (Day 2)

Two pure functions. No I/O, no database, no clock. Everything else in the system is plumbing
around these.

### 4.1 `Materialize`

```go
package meals

type Key struct {
    MembershipID uuid.UUID
    SlotID       uuid.UUID
    Date         civil.Date
}

// Pure. Deterministic. No I/O.
func Materialize(in Input, from, to civil.Date) map[Key]int
```

Resolution order — apply in **exactly** this sequence:

```
 1. PATTERN. qty if dow_mask has the weekday bit, else 0. Use the
    pattern whose effective_from is the latest one <= date.
 2. TENURE. Zero any date outside [joined_at, left_at] (inclusive of
    joined_at, exclusive of left_at).
 3. DAY FLAGS. OFF_DAY zeroes every slot that date.
 4. VOIDS. Resolve first: an exception with void_of set removes its
    target from consideration AND is not itself applied.
 5. EXCEPTIONS, in created_at order (later wins on the same key):
      OFF     → qty  = 0
      ON      → qty  = max(qty, 1)
      SET_QTY → qty  = e.Qty
      GUEST   → qty += e.Qty      ← guests ADD, they never replace
    A null SlotID applies to every active slot that day.
```

### 4.2 `Settle`

```go
package money

func Settle(meals map[meals.Key]int, entries []Entry, ms []Membership, p Period) Settlement
```

```
 total_meals = Σ qty over the period (guests included — a guest ate)
 food_paisa  = Σ FOOD_COST − Σ voided FOOD_COST
 meal_rate   = 0 if total_meals == 0 else food_paisa / total_meals   ← integer FLOOR
 remainder   = food_paisa − (meal_rate × total_meals)
               ← MUST be surfaced as a visible ADJUST line owned by the
                 mess. Never silently absorbed by a member. Someone
                 always asks where the ৳3 went.
 per member:
   meals_qty   = Σ their qty (including guests they brought)
   food_cost   = meal_rate × meals_qty
   shared_cost = 0 in v1.0 (P2 feature)
   deposits    = Σ their DEPOSIT − voided
   balance     = deposits − food_cost − shared_cost
                 positive ⇒ "ফেরত পাবেন" · negative ⇒ "দিতে হবে"

 INVARIANT, asserted in code:
   Σ member.food_cost + remainder == food_paisa
```

### 4.3 The nine property tests (`pgregory.net/rapid`)

Write these **before** the implementations.

```
 P1  CONSERVATION      Σ food_cost + remainder == Σ FOOD_COST, always,
                       for any generated input.
 P2  VOID SYMMETRY     apply an exception then void it ⇒ identical
                       materialization to never applying it.
 P3  ORDER INDEPENDENCE shuffling input slices never changes output.
                       ← guards the bug that will bite you in P6 offline
 P4  RANGE == UNION    one exception over [d1..d5] == five single-day
                       exceptions.
 P5  EMPTY DAY IS FREE full pattern + zero exceptions over 30 days ==
                       pattern_qty × matching weekdays. (Law 1 as a test)
 P6  NON-NEGATIVE      qty >= 0 in every cell, for any exception mix.
 P7  IDEMPOTENT CLOSE  Settle() twice on the same closed period returns
                       identical numbers.
 P8  TENURE BOUNDARY   a member joining d and leaving d+n has zero meals
                       outside that window regardless of pattern.
 P9  GUEST ADDITIVITY  n GUEST exceptions of qty 1 == one of qty n.
```

If these hold, your money math is correct and agents can build freely on top. Skip them and you
discover a rate bug on the day 200 messes close their first month — the worst possible day.

### 4.4 Golden vectors — the P6 insurance policy

```
 api/testdata/vectors/*.json
 { "name": "range_off_with_guest",
   "input":  { patterns, exceptions, flags, memberships, slots, range },
   "expect": { cells: {...}, settlement: {...} } }
```

The Go engine runs these in CI today. In **P6 (offline)** the Dart engine runs the *same files*.
That is the only practical guarantee that on-device math equals server math — and if they ever
disagree, the mess sees two different numbers, which destroys the exact thing you are selling.

Generate 30–50 vectors on Day 2, including every ugly case: month boundaries, leave mid-range,
guest + off on the same slot, voided-then-re-added, zero total meals, single member, 500 members.

---

## 5. API CONTRACT (v1.0)

```
 AUTH
 POST /v1/auth/session            Firebase ID token → session
 GET  /v1/me

 MESS
 POST /v1/messes                  {name, kind, slots[]} → tenant+slots+period
 GET  /v1/messes/:id
 PATCH /v1/messes/:id             name, slot cutoffs, timezone

 MEMBERS
 GET  /v1/messes/:id/members
 POST /v1/messes/:id/members      {display_name, phone?} → invite_token
 POST /v1/members/:mid/leave      {left_at}
 PUT  /v1/members/:mid/patterns   [{slot_id, dow_mask, qty}]

 THE DAILY LOOP  ★
 GET  /v1/messes/:id/day?date=    per-slot headcount · per-member qty ·
                                  cutoff state · today's exceptions
 POST /v1/exceptions              {membership_id|group_id, slot_id?,
                                   date_from, date_to, action, qty?}
                                  ← group_id accepted from day 1, unused
                                    by the mess app until P3
 POST /v1/exceptions/:id/void

 MONEY
 POST /v1/ledger                  {kind, amount_paisa, category?,
                                   membership_id?, occurred_on, note?}
 POST /v1/ledger/:id/void
 GET  /v1/messes/:id/accounts     meal_rate · totals · per-member balances,
                                  each with a `math` object

 CLOSE
 POST /v1/periods/:id/preview     what the statement WOULD say
 POST /v1/periods/:id/close       writes statements, opens next period
 GET  /v1/periods/:id/statement

 MEMBER PWA  (token auth, no session, no password)
 GET  /v1/m/:token/today
 POST /v1/m/:token/exception      {slot_id, action, date_from, date_to, qty?}
 GET  /v1/m/:token/hisab

 ADMIN  (staff role required)
 GET  /v1/admin/tenants           search, paginate
 GET  /v1/admin/tenants/:id       members · ledger · exceptions (READ-ONLY)
 GET  /v1/admin/users?phone=
 GET  /v1/admin/metrics
 GET|PUT /v1/admin/flags
```

**The `math` object — this is Wedge #3. Do not let it get dropped.**

Every money number carries its own derivation, so no client ever recomputes and no client can lie:

```json
{
  "value_paisa": 4000,
  "display": "৳৪০",
  "math": {
    "formula": "মোট বাজার ÷ মোট মিল",
    "terms": [
      {"label": "মোট বাজার", "display": "৳১২,৪০০"},
      {"label": "মোট মিল",  "display": "৩১০"}
    ],
    "note": "বাকি ৳০ মেসের হিসাবে যোগ আছে"
  }
}
```

---

## 6. AGENT TASK BREAKDOWN

One focused session each, with a clear done-condition. ★ = yours, not an agent's.

```
 BACKEND (Go)
 A1   monorepo scaffold · Makefile · docker-compose · CI
 A2   migrations (full §3 schema) · RLS policies · sqlc setup
 ★A3  meals/engine.go + money/settle.go + nine property tests +
      golden vectors                                        ← YOU, Day 2
 A4   httpx: chi router, auth middleware, tenant context, error shape
 A5   core: tenants, users, memberships, groups, invite tokens
 A6   meals: pattern + exception endpoints, GET /day payload
 A7   ledger: append-only writes, void, categories
 A8   accounts endpoint with the `math` object + rounding remainder
 A9   periods: preview, close, immutable statement write
 A10  entitlements: interface + alwaysAllow{} (no billing code)
 A11  admin endpoints (read-only inspector, flags, metrics)
 A12  openapi.yaml + TS type generation + Dart client generation

 FLUTTER (Android)
 A13  scaffold · theme from tokens · bn/en ARB · Bangla numeral
      formatter · generated API client · Google Sign-In
 A14  onboarding: sign-in → 3 questions → how-it-works → invite link
 A15  Home/Today: cutoff card · exception sheet · [+বাজার][+জমা]
 A16  date-range exceptions · guest flow · post-cutoff state
 A17  khata grid fallback view
 A18  Members: list · add · invite share to Messenger
 A19  হিসাব screen · member statement · tappable math sheets
 A20  month-close wizard · share-as-image
 A21  Settings · language · numerals · in-app account deletion
 A22  first-run demo mess (seeded locally)
 A23  Firebase Analytics events · Crashlytics · Remote Config

 WEB (Next.js — public)
 A24  landing page · /privacy · /terms · /delete-account
 A25  member PWA /m/[token] — Today/Tomorrow + আমার হিসাব, <500KB

 ADMIN (Next.js — internal)
 A26  auth (staff role) · tenant list · tenant read-only inspector
 A27  user lookup · feature flags · metrics dashboard
```

### Prompting notes that measurably improve output here

```
 · Open every session with: "Read docs/BRD_v4.md §6 and §7.1, and
   docs/Build_Spec_Go.md §3-§5 first."
 · Every backend task: "Do not store derived meal counts. Do not UPDATE
   or DELETE any append-only row. Money is int64 paisa."
 · Every Flutter task: "Bangla is the default locale. Every string goes
   through ARB — no hardcoded text. Minimum touch target 48dp."
 · Anything touching money: ask for the test first, implementation second.
 · Never let an agent hand-write an API client. Regenerate from
   openapi.yaml.
 · After each task run `make test` and READ THE DIFF. On a solo team,
   your review is the only thing between you and a silent rate bug.
 · When an agent proposes a feature outside §7.1 — and it will, they are
   helpful by nature — decline. The cut list is the plan.
```

---

## 7. DEFINITION OF DONE — v1.0

```
 □ Nine property tests pass · golden vectors green in CI
 □ Append-only enforced by Postgres rules, not only by Go
 □ A stranger creates a mess, runs a week, closes the month, alone
 □ A normal day costs ZERO taps (verified on a real mess)
 □ An exception costs ≤2 taps, first try, under 10 seconds
 □ Member link <3s on throttled 3G, shell <500KB
 □ Every money number opens a math sheet
 □ Admin portal shows any tenant's full ledger, read-only
 □ Backup restored successfully in a drill
 □ Account deletion works in-app AND on the web
 □ Bangla read aloud by a native speaker who is not you
```
