# Business Requirements Document — v4.0 (SCOPE FROZEN)
# TinBela (তিনবেলা)
## Meal & Mess Management · Bangladesh-first
**Droid Builder · August 2026 · supersedes v3.0**

> **Tagline:** তিনবেলার হিসাব, এক অ্যাপে। · *All three meals, one app.*
> **Design law #1:** *Collect exceptions, not data. Never record what's normal.*
>
> **What changed from v3:** v3 defined the domain correctly and is carried forward almost
> intact (§2, §6, §8). v4 changes the owning entity, replaces the stack (Go, not Django),
> promotes the admin portal to day one, re-orders the segments, removes corporate canteen
> entirely, and defers monetization to a generic cross-product module.

**Companion documents**
- `TinBela_Dev_Plan_Phases.md` — phase-by-phase plan, feature list, timeline
- `TinBela_Build_Spec_Go.md` — schema, engine contract, API, agent task list
- `TinBela_UI_Spec.md` — screen inventory, navigation, components, per-phase UI

---

## 1. Purpose

One meal-management engine, several contexts, same code. Context changes labels and enabled
modules — **never core logic**. The engine computes meals from patterns and exceptions, and money
from an append-only ledger. Everything else is presentation.

```
 SEGMENT ORDER (locked)
 1. BACHELOR MESS   university students + job holders   ← v1.0 launch
 2. INSTITUTION     madrasha · hostel · boarding        ← v1.2, own phase
 3. HOME            small family                        ← v1.3
 ✗ CORPORATE CANTEEN — removed from the roadmap entirely.
```

---

## 2. The Domain, As It Really Works (carried from v3)

```
 ACTORS   manager (rotating OR fixed) · members · bazar person
          (assigned OR the manager) · maid/cook (optional) ·
          landlord (external) · guests (transient)
 DAILY    members notify exceptions before bazar cutoff → bazar
          bought → meals happen
 MONTHLY  deposits collected → rent paid to landlord → settlement
          (meal rate × meals ± shared costs) → maybe manager rotates
 TWO MONEY POOLS, never mixed:
   MEAL POOL   (bazar/food)  ÷ total meals = meal rate
   SHARED POOL (rent, utility, maid, net) ÷ heads or seats
 TRUST is the real deliverable: everyone sees the same live numbers,
 history is append-only & auditable, rotation never loses data.
```

**Why khata-kolom fails:** not at collection (the morning-notify habit already works) but at
*recording, math, trust, and handover*. TinBela is where that existing habit lands. It invents no
new behaviour — which is exactly why it can ship in two weeks.

---

## 3. Market & Competition (verified July 2026)

```
 BACHELOR MESS  300-500K active messes (avg 6-10 members)
                ~1.5M urban smartphone mess members SAM
 INSTITUTION    tens of thousands of madrashas, hostels, boarding
                schools — almost entirely unserved by software
 90-DAY TARGET  300 active messes
 YEAR-1 TARGET  5K active messes / ~40K users
```

Incumbents — Mess Manager (m27lab, ~1M+ installs), BDMess, Meal System, Meal Manager, Mess Hisab,
My Mess — share one fatal model:

```
 ┌ THE INCUMBENT MODEL (all of them) ─────────────────────────┐
 │ · manager becomes a DATA-ENTRY CLERK (~24 records/day for   │
 │   8 members × 3 slots)                                      │
 │ · EVERY member forced to install + register                 │
 │ · ONLINE-ONLY (dies on mess wifi)                           │
 │ · cluttered UI; confusing multi-package pricing             │
 │ NONE implement default-pattern + exception entry.           │
 └─────────────────────────────────────────────────────────────┘
 TINBELA WEDGE — v1.0 must deliver all four:
   1. exceptions-only entry        → 0 taps on a normal day
   2. no-install member web link   → viral loop + zero friction
   3. every number shows its math  → trust
   4. free, clean, no pricing maze → monetization comes later
```

---

## 4. Personas

```
 ★ P1 MANAGER "Rifat" 21, rotating role, always on phone. Wants <1
      min/day, no blame, 5-min month-end. THE v1.0 TARGET.
 ★ P2 MEMBER "Adnan" 20-28. Wants 1-tap meal-off, own cost, trust the
      math. Will NOT install an app → web link. Acquisition channel.
   P3 SUPERINTENDENT / MUHTAMIM — institution head.        [v1.2]
   P4 ACCOUNTANT / warden — the real daily operator there.  [v1.2]
   P5 GUARDIAN — sees dues + attendance for their child.    [v1.2]
   P6 MAID / COOK — subject of data, not a user.            [v2.x]
   P7 LANDLORD — external, appears as payout records.       [v1.1]
```

Geography: Dhaka university/job paras first (Mirpur, Farmgate, Azimpur, Mohammadpur), then
Chattogram, Rajshahi, Sylhet, Khulna.

### 4.1 Why institution is a separate phase, not a variant

| | Bachelor mess | Institution (madrasha / hostel) |
|---|---|---|
| Scale | 4–12 members, flat | 50–500 residents, **grouped by batch/block/room** |
| Who enters data | The manager (a peer) | Staff warden, often per-group in bulk |
| Do residents have phones? | Yes — member PWA is the growth loop | **Often no, often minors** — no member PWA at all |
| Money model | **Variable meal rate**, settled monthly | Usually **fixed monthly fee** + dues tracking |
| Fee categories | Everyone equal | Full-paying / subsidised / **free (lillah)** — essential |
| Kitchen | Bazar receipts | **Ration store: stock in / consumption out** |
| Reporting need | Per-member statement | Per-student dues, collection report, donor report |

The engine (patterns ⊕ exceptions, append-only ledger) is **fully reusable**. The hierarchy,
billing mode, and reporting are not. That is a real 5–6 week phase, and §7.4 lists five cheap
schema hedges to put in v1.0 so it lands as an addition rather than a rewrite.

---

## 5. Brand & Design Tokens

```
 NAME      TinBela (তিনবেলা) — LOCKED
 PUBLISHER Droid Builder
 TONE      friendly, a little funny; mess-life humour is a marketing
           asset; warm not corporate
 LANGUAGE  bn (default) + en at launch, both complete. Switch at
           first-run + settings. Bangla numerals toggle (৳১,২৪০).
           Any further language later = 1 ARB file, no refactor.
 TYPO      Hind Siliguri (bn), system (en); big touch targets
```

```
 PRIMARY GREEN   #1B7A4E   brand, primary action, positive balance
 ACCENT YELLOW   #E39312   secondary action (+বাজার / +জমা)
 ALERT RED       #C0392B   debt, meal-off, cutoff passed
 SURFACE         #FAF6EF   warm off-white background
 INK             #1A1A1A   primary text
 TINT            #E8F3ED   light green fill / selected state
 RADIUS          16 card · 12 button · 64 app icon
 MIN TOUCH       48×48dp — non-negotiable (glare + thumb use)
```

---

## 6. THE CORE — Data Collection Model (design law, non-negotiable, carried verbatim)

```
 LAW 1  DEFAULT PATTERN: each member sets a weekly pattern once
        (which slots, which weekdays, qty). Days auto-materialize.
        A normal day needs ZERO entries.
 LAW 2  EXCEPTIONS ONLY: off / on / guest / qty change, for a single
        day or a range ("৩ দিন বাড়ি") — 1-2 taps each.
 LAW 3  FALLBACK CHAIN (works even if only the manager has it):
        member self-taps (web link, no install/password) →
        OR tells manager, manager taps that member's row →
        OR silence = default applies (correct ~90% of days).
 LAW 4  CUTOFF = bazar time (per-slot, configurable). After cutoff
        only manager edits, audited (marked_by), flagged in member
        statements. The cutoff screen IS the bazar headcount.
 LAW 5  APPEND-ONLY: no row edited/deleted; corrections void + re-add.
 LAW 6  DERIVED NEVER STORED: rate/balances computed live; snapshot
        only at period close (immutable statements).
 EFFICIENCY BUDGET: an 8-member mess costs ≤6 total taps/day incl.
 the bazar entry. This is a KPI, not a hope.

 DAILY ENTRY ECONOMICS (8 members)
 khata-kolom ......... ~24 cells + manual math
 every existing app .. ~24 manager taps (worse than paper!)
 TinBela ............. 0-4 exception taps + 1 bazar entry
```

**If any build decision conflicts with §6, §6 wins.** This is the product.

---

## 7. SCOPE FREEZE — v1.0

### 7.1 IN — build exactly this

| ID | Feature | Why it cannot be cut |
|---|---|---|
| V-01 | Manager sign-in (Google Sign-In) + create mess in 3 questions | No app without it |
| V-02 | Add members by name (+optional phone) · invite link · **manager can run a mess alone** | Law 3; solo start removes all adoption friction |
| V-03 | Weekly default patterns, **all slots ON by default** | Law 1. This *is* the product |
| V-04 | Exceptions: OFF / ON / GUEST / SET_QTY, single day **and date range** | Law 2. This *is* the product |
| V-05 | Cutoff card = per-slot headcount, configurable times, post-cutoff edits audited | Law 4. The daily reason to open the app |
| V-06 | **Khata grid fallback view** (looks like the notebook, writes the same rows) | Risk R2 — khata-minded managers bounce without it |
| V-07 | Bazar entry (amount + category) · deposit entry · append-only ledger with void | No money = no product |
| V-08 | Live math: meal rate, per-member balance, group view. **Every number tappable → shows its formula** | Wedge #3. Impossible to retrofit credibly |
| V-09 | Month close wizard → immutable statement → **share as image** | The payoff moment |
| V-10 | **Member web link (PWA), 2 screens:** Today/Tomorrow (1-tap off/guest) · আমার হিসাব | Wedge #2. The growth loop = the marketing budget |
| V-11 | Bangla + English, Bangla numeral toggle | Non-negotiable for the market |
| V-12 | First-run demo mess ("poke it, nothing breaks") | Halves onboarding drop-off |
| V-13 | In-app account deletion + data export request | Play Store requirement |
| V-14 | Analytics events + crash reporting + remote kill-switch | You cannot iterate on what you cannot see |
| V-15 | **Admin portal (Next.js): tenant browser, read-only ledger inspector, feature flags, metrics** | Your only window into production. Also your debugger during the build |
| V-16 | Landing page + privacy / terms / delete-account pages | Store listing needs the URLs |

**Release gate:** a 4-person mess, on a mid-range Android phone, on bad wifi, sees **one screen**
and understands its whole month. If it needs two screens, cut more.

### 7.2 OUT of v1.0 — and where each goes

| Deferred | Phase | Why deferring is safe |
|---|---|---|
| Manager handover (1-tap rotation) | P2 / v1.1 | Real differentiator, but nobody rotates in month 1 |
| Photo receipts | P2 / v1.1 | Upload + storage + compression ≈ 1 day. Nobody churns over it |
| PDF export | P2 / v1.1 | Share-as-image covers 95% in 2 hours instead of 2 days |
| FEAST flag, custom slots (snacks) | P2 / v1.1 | Delightful, not load-bearing. B/L/D covers launch |
| Group view in member PWA | P2 / v1.1 | 2 member screens instead of 3 |
| Push notifications ("আপনার বাজারের দিন") | P2 / v1.1 | Needs a habit to reinforce first |
| Rent/utility shared pool, budgets, bazar rota | P2 / v1.1 | High-value retention, but a mess survives month 1 without it |
| **Institution mode** (madrasha/hostel) | P3 / v1.2 | Separate product shape — see §4.1 |
| **Home/family mode** | P4 / v1.3 | Mostly module-hiding once P3 hierarchy exists |
| **Entitlements / subscription** | P5 / v2.0 | Generic Droid Builder module, not a TinBela feature |
| **Offline & sync** | P6 / v2.1 | The paid moat. Ships *with* the paywall, gated per purchased period |
| Rooms/seats, cleaning rota, maid, multi-mess | P7 / v2.2 | Opt-in toggles, default OFF |
| bKash / payment links | later | Triggers financial-services review. Not pre-launch |

**Permanent non-goals:** chat (Messenger owns it) · food ordering/delivery · payments wallet ·
to-let marketplace · public reviews · **corporate canteen**.

### 7.3 Entitlement stub — the one thing to build now for a later module

Offline is gated on purchase, and purchase is a generic module you'll build later. To avoid a
refactor, v1.0 ships a **single interface with a hardcoded answer**:

```go
type Entitlements interface {
    Has(ctx context.Context, tenantID uuid.UUID, feature string, on time.Time) (bool, error)
}
// v1.0:  alwaysAllow{}  — everything free, no billing code anywhere
// v2.0:  entitlementService{} — backed by the generic module
```

Every gated feature calls `Has(...)`. In v1.0 it returns `true` and no billing code exists. The
`on time.Time` argument matters: your model is *purchase a specific month*, not a subscription, so
entitlement is a **question about a date**, not a boolean on an account. Getting that signature
right now costs nothing and saves a rewrite.

### 7.4 Institution hedges — five cheap things to add to the v1.0 schema

Migrating an empty table is free; migrating a live one is expensive. Add these now, expose none of
them in the v1.0 UI:

```
 1. tenants.kind gains 'INSTITUTION'
 2. groups table (id, tenant_id, parent_id, name, kind BATCH|BLOCK|ROOM)
    — self-referencing hierarchy, unused by mess mode
 3. memberships.group_id  (nullable)
 4. tenants.billing_mode  RATE_BASED | FIXED_FEE   (default RATE_BASED)
 5. memberships.fee_category  FULL | SUBSIDIZED | FREE  (nullable)
    — "লিল্লাহ বোর্ডিং" free students are a hard requirement in madrasha
 + the bulk-exception endpoint accepts an optional group_id from day 1;
   the mess app simply never sends one.
```

### 7.5 The roadmap in one block

```
 P0  FOUNDATION        D1-3     infra, schema, engine + property tests
 P1  v1.0 MVP          D4-14    bachelor mess → PLAY STORE
 P2  v1.1 RETENTION    Wk 3-5   handover, photos, PDF, push, shared pool,
                                budgets, rota, group view, FEAST
 P3  v1.2 INSTITUTION  Wk 6-11  madrasha / hostel / boarding
 P4  v1.3 HOME         Wk 12-13 small family mode
 P5  v2.0 ENTITLEMENT  Wk 14-15 generic Droid Builder billing module
 P6  v2.1 OFFLINE      Wk 16-20 local-first + sync — THE PAID MOAT
 P7  v2.2 OPERATIONS   Wk 21-23 rooms/seats, cleaning rota, maid, multi-mess
```

---

## 8. Data Model (carried from v3, plus §7.4 hedges — full DDL in the Build Spec)

```
 CORE: users · tenants(kind MESS|INSTITUTION|HOME, billing_mode)
 · groups(parent_id, kind)  · memberships(role, group_id?, fee_category?,
   invite_token, left_at)
 ┌ meal engine ─────────────────────────────────────────────────┐
 │ slots(tenant, name_bn, name_en, sort, cutoff_local, active)   │
 │ patterns(membership, slot, dow_mask, qty, effective_from)     │
 │ day_flags(tenant, date, kind FEAST|OFF_DAY, note)             │
 │ meal_exceptions(membership, date_from, date_to, slot?,        │
 │   action, qty, marked_by, after_cutoff, void_of)  APPEND-ONLY │
 │ ⇒ daily meals = MATERIALIZED(patterns ⊕ exceptions ⊕ flags)   │
 │   NEVER hand-stored                                           │
 ├ money ────────────────────────────────────────────────────────┤
 │ ledger_entries(kind, amount_paisa, category, membership?,     │
 │   occurred_on, entered_by, void_of)  APPEND-ONLY              │
 │ periods(start, end, status OPEN|CLOSED)                       │
 │ period_statements(...) written ONCE at close, IMMUTABLE       │
 └───────────────────────────────────────────────────────────────┘
 RULES: uuid pks (client-generatable) · ALL money int64 paisa, never
 float · tenant_id on every row · Postgres RLS · append-only ⇒ the
 future offline merge is conflict-free by construction.
```

---

## 9. Architecture (LOCKED)

```
              ┌──────────── ONE BACKEND ────────────┐
              │  Go 1.23 · chi · pgx/sqlc           │
              │  Postgres 16 · tenant_id + RLS      │
              │  self-hosted (your dev server)      │
              └─┬──────────┬───────────┬──────────┬─┘
    ┌───────────▼─┐ ┌──────▼──────┐ ┌──▼───────┐ ┌▼──────────────┐
    │ MANAGER APP │ │ MEMBER PWA  │ │ LANDING  │ │ ADMIN PORTAL  │
    │ Flutter     │ │ + landing   │ │ (same    │ │ Next.js       │
    │ Android     │ │ Next.js     │ │  app)    │ │ TS+Tailwind   │
    │ v1.0 online │ │ <500KB      │ │          │ │ shadcn/ui     │
    │ offline P6  │ │ token auth  │ │          │ │ DAY ONE       │
    └─────────────┘ └─────────────┘ └──────────┘ └───────────────┘
 iOS: the member PWA covers members. iOS *managers* wait for proven
      demand. Do not build for iOS in v1.0.
```

**Four deliverables, one monorepo.** Shared OpenAPI spec generates TypeScript types for both
Next.js apps and a Dart client for Flutter — this removes an entire category of agent error.

---

## 10. KPIs

```
 THE ONLY v1.0 NUMBER THAT MATTERS: manager D30 retention.

 EFFICIENCY  taps/day per mess ≤6 · zero-edit default days >70% ·
             median exception_marked <10s
 HABIT       cutoff views before 08:00 · manager D30 ≥40% ·
             month_closed rate ≥50%
 GROWTH      K-factor ≥1 · member_link_opened per mess
 MEMBER      PWA weekly-active ≥60% of members in active messes

 EVENTS (instrument ALL in v1.0 — cheap now, impossible to backfill)
   mess_created, member_joined, member_link_opened, pattern_set,
   exception_marked(role,taps,ms), guest_added, bazar_added,
   deposit_added, statement_viewed, number_tapped_for_math,
   month_closed, statement_shared, grid_view_used, app_opened

 THE FAILURE SIGNAL: high installs + high mess_created + low
 exception_marked = managers set up and never came back. That is a §6
 problem, and no amount of P2/P3 features will fix it.
```

---

## 11. Risks

```
 R1 pattern-setup friction → default all-slots-ON; ≤3 onboarding Qs
 R2 exception model confuses khata-minded managers → grid fallback
    (V-06) always available; both write the same rows
 R3 feature creep re-bloats UX → §7.2 is a contract with yourself
 R4 range-off/guest edge cases corrupt the rate → property-based tests
    on materialization; int64 paisa. See Build Spec §4
 R5 incumbent copies "offline" → they are architecturally cloud-first;
    real offline + append-only merge is months of work
 R6 semester / Ramadan seasonality → measure MAU on the academic
    calendar, not the Gregorian one
 R7 Solo founder across CEO/eng/sales → when a day slips, cut scope
    from §7.1. Never extend the phase.
 R8 Ledger data loss = product death (trust is the deliverable) →
    automated Postgres backups + a restore DRILL before launch
 R9 Institution phase eats the roadmap → it is timeboxed to 6 weeks
    with its own mini-BRD. If week 8 shows no traction, stop.
 R10 Go engine and future Dart offline engine drift apart → shared
    golden test vectors in JSON, run by both. See Build Spec §4.4
```

---

## 12. Field Validation

Runs **live, from the store**, not before it. The v3 script becomes an ongoing loop:

```
 · In-app: after the first month_close, one question — "মাস শেষ করতে
   কত সময় লাগল?" (3 taps, no free text)
 · Weekly: personally message 5 active managers. Ask what they did
   NOT use. Deletions are worth more than requests.
 · Monthly: 3 phone calls with churned managers (D7 opened, D14 not).
 · BRD-REVISION TRIGGER: any finding contradicting §6 or reordering
   §7.1. If §6 is contradicted, stop building and rethink —
   everything else is downstream of it.
```
