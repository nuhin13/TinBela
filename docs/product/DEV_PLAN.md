# TinBela — Development Plan, Phase by Phase
**Droid Builder · August 2026 · companion to BRD v4.0**

---

## 0. GROUND RULES

```
 · Deployment, infra, and Play Store are yours. This document is
   product + engineering only.
 · Your Play account (2014) is exempt from the 12-tester rule, so
   v1.0 ships straight to production. 14 days is a real target.
 · When a day slips, CUT SCOPE from BRD §7.1. Never extend the phase.
 · Every phase ends in a shippable release. No phase ends in a branch.
 · One rule for agentic work: you write the money engine by hand
   (Build Spec §4). Delegate everything else.
```

---

## 1. PHASE MAP

```
 P0  FOUNDATION        D1-3      infra · schema · engine + property tests
 P1  v1.0 MVP          D4-14     BACHELOR MESS  →  PLAY STORE
 ──────────────────────── ship, then breathe ────────────────────────
 P2  v1.1 RETENTION    Wk 3-5    the features month-2 managers ask for
 P3  v1.2 INSTITUTION  Wk 6-11   madrasha · hostel · boarding
 P4  v1.3 HOME         Wk 12-13  small family
 P5  v2.0 ENTITLEMENT  Wk 14-15  generic Droid Builder billing core
 P6  v2.1 OFFLINE      Wk 16-20  local-first + sync — THE PAID MOAT
 P7  v2.2 OPERATIONS   Wk 21-23  rooms · rota · maid · multi-mess
```

**Dependency worth noting:** offline is a paid feature, and paid requires entitlements. So
**P5 must precede P6**. That is why the entitlement stub interface goes in during P0 (BRD §7.3) —
so P6 doesn't force a rewrite of every gated call site.

---

## 2. PHASE 0 — FOUNDATION (Days 1–3)

The three days that determine whether the next twenty weeks are pleasant or miserable.

| Day | Work | Done when |
|---|---|---|
| **1** | Monorepo. Go module: chi + pgx + sqlc + golang-migrate + slog. Postgres 16 in Docker. Full schema migration (L0 + L1 + the five institution hedges). RLS policies. `make test` / `make dev` / `make lint`. CI on push. | `make dev` boots, `make test` is green, schema matches Build Spec §3 |
| **2** | ★ **The engine, by hand.** `internal/meals/engine.go` (`Materialize`) and `internal/money/settle.go` (`Settle`) as pure functions. The nine property tests. The golden test-vector file. | All nine properties pass under `rapid`; vectors committed |
| **3** | Auth (Google Sign-In → Firebase ID token verified server-side). Tenant + membership CRUD. OpenAPI spec written. TS types + Dart client generated. Flutter shell with theme tokens + bn/en ARB. Next.js apps scaffolded. | You can create a mess and add a member via the API, and the Flutter app signs in |

**Do not skip Day 2.** This is where money bugs live, and money bugs kill the only thing you're
selling. It is also the one part an agent should not write unsupervised.

---

## 3. PHASE 1 — v1.0 MVP (Days 4–14) · BACHELOR MESS

### 3.1 Feature list

| ID | Feature | Detail |
|---|---|---|
| V-01 | Manager onboarding | Google Sign-In → 3 questions (mess name, kind, how many slots) → "how TinBela works" card → invite link |
| V-02 | Members | Add by display name, phone optional. Invite token per member. Phone-match on first link open (no duplicates). Manager can run the mess entirely alone |
| V-03 | Patterns | Weekly default per member per slot, **all slots ON by default**, `dow_mask`, qty, `effective_from` |
| V-04 | Exceptions | OFF / ON / GUEST / SET_QTY · single day and date range · null slot = all slots · append-only with void |
| V-05 | Cutoff card | Per-slot headcount for today, per-slot configurable cutoff time (`Asia/Dhaka`, server-resolved), post-cutoff edits flagged `after_cutoff` and shown in statements |
| V-06 | Khata grid | Notebook-shaped member × slot grid, tap a cell to toggle. Writes the identical exception rows |
| V-07 | Ledger | Bazar (FOOD_COST) with category, deposits (DEPOSIT) per member, void, no edit/delete |
| V-08 | Live math | Meal rate, totals, per-member balance. **Every number returns a `math` object and opens a formula sheet** |
| V-09 | Month close | 3-step wizard → preview → immutable `period_statements` → next period opens → share as image |
| V-10 | Member PWA | `/m/<token>` — Today/Tomorrow (1-tap off, 1-tap guest, cutoff countdown) + আমার হিসাব (read-only, tappable math). <500KB shell, <3s on 3G |
| V-11 | i18n | bn default + en, Bangla numeral toggle, every string in ARB |
| V-12 | Demo mess | Seeded on first run, labelled, "poke anything, nothing breaks", one tap to discard |
| V-13 | Account deletion | In-app (Settings) + `/delete-account` on the landing site + data export request |
| V-14 | Telemetry | Firebase Analytics events (BRD §10), Crashlytics, Remote Config kill-switch |
| V-15 | Admin portal | Next.js: tenant list, tenant detail (members, ledger, exceptions — **read-only**), user lookup, feature flags, basic metrics |
| V-16 | Landing page | Hero, the "0 taps" comparison, screenshots, download CTA, privacy, terms, delete-account |

### 3.2 Build order

| Day | Work |
|---|---|
| **4** | API: patterns + exceptions endpoints. `GET /messes/:id/day` (the cutoff payload). Unit tests against the engine |
| **5** | **Admin portal v0** — tenant list + read-only tenant inspector. Build this now, not later: it is your debugging window for the next nine days. Without Django admin you are otherwise blind |
| **6** | Flutter: Home/Today — cutoff card, exception bottom sheet, `[+বাজার] [+জমা]` buttons |
| **7** | Flutter: date-range exceptions, guest flow, post-cutoff state. Members screen + add member + invite share to Messenger |
| **8** | Flutter: khata grid fallback (V-06) |
| **9** | API: ledger endpoints + `/accounts` with the `math` object. Rounding remainder as a visible ADJUST line |
| **10** | Flutter: হিসাব screen + member statement + **tappable math sheets** |
| **11** | Next.js: member PWA `/m/[token]` — both screens. End-to-end test on two real phones |
| **12** | API + Flutter: month-close preview → close → immutable statement → share-as-image |
| **13** | Landing page. Settings screen (slots, cutoffs, language, numerals, account deletion). Demo mess. Analytics events wired |
| **14** | Bug bash. Bangla copy read aloud by a native speaker who is not you. Backup + **restore drill**. Store assets. Ship |

### 3.3 What slips first, if it slips

```
 1. Khata grid (V-06)     → v1.1   painful but survivable for 2 weeks
 2. Demo mess (V-12)      → v1.1   replace with a good empty state
 3. Landing page polish   → keep only /privacy /terms /delete-account
 4. Admin portal metrics  → keep the read-only inspector, drop charts
 NEVER CUT: V-03, V-04, V-05, V-08, V-10.
 Those five are the entire differentiation. Everything else is table
 stakes that competitors already have.
```

### 3.4 Definition of done

```
 □ All nine engine property tests pass; golden vectors green
 □ A stranger creates a 4-person mess, runs a week, closes the month,
   without you in the room
 □ A normal day costs ZERO taps (verified on a real mess)
 □ An exception costs ≤2 taps, first try, under 10 seconds
 □ Member link opens <3s on throttled 3G, shell <500KB
 □ Every money number on screen opens a math sheet
 □ Statement is immutable at the DB level (rules, not just code)
 □ No crash across 3 days of your own daily use
 □ Bangla reviewed aloud by a native speaker
 □ Postgres backup restored successfully in a drill
 □ Account deletion works in-app AND on the web
```

---

## 4. PHASE 2 — v1.1 RETENTION (Weeks 3–5)

Ship weekly. Everything here is driven by what the first ~100 managers actually do.

| Feature | Why now | Est. |
|---|---|---|
| **Manager handover** (1-tap rotation, data stays with the mess) | Month 2 is exactly when rotation happens. Miss it and you lose the mess | 2d |
| **Rent & utility shared pool** (per-head / per-seat split) + landlord payout log | The single most-requested thing after meals. This is the second money pool from BRD §2 that v1.0 deliberately skipped | 4d |
| **Budgets** (daily bazar / monthly) with soft alerts | Cheap once the ledger exists | 1d |
| **Bazar duty rota** + "আপনার বাজারের দিন" push | First real reason for a notification | 2d |
| **Push notifications** — cutoff reminder, bazar day, month-end nudge | The habit reinforcement loop. Do not ship push before there is a habit to reinforce | 2d |
| **Photo receipts** on expenses | Trust feature; needs storage + compression | 1d |
| **PDF export** of statements | Managers forward these to members | 1d |
| **FEAST / good-food-day flag** + custom slots (snacks) | Cultural fit; cheap | 1d |
| **Group view** in member PWA (3rd screen) | Members want to see the whole mess, not just themselves | 1d |
| **Opening-balance import / rollover polish** | Messes joining mid-month | 1d |

**Gate to leave P2:** manager D30 ≥30% on the first cohort. If it isn't, the problem is §6, and
building P3 will not help.

---

## 5. PHASE 3 — v1.2 INSTITUTION MODE (Weeks 6–11)

Madrasha · hostel · boarding school. **This is a different product shape sharing one engine.**
Timeboxed to 6 weeks; write a 3-page mini-BRD before week 6 based on interviews with at least
three superintendents.

### 5.1 What is genuinely new

| Area | Requirement |
|---|---|
| **Hierarchy** | Institution → block/batch → room → resident. The `groups` table from BRD §7.4 activates. Every list, filter, and report becomes group-aware |
| **Bulk operations** | Mark a whole batch off (exam leave, vacation, Ramadan). One tap, hundreds of rows. The API already accepts `group_id` — the UI now uses it |
| **No member PWA** | Residents are often minors without phones. Data entry is staff-side. **The growth loop does not exist here — this segment is sold, not spread** |
| **Fixed-fee billing** | `billing_mode = FIXED_FEE`: monthly charge per resident, not a computed meal rate. The engine branches once; the ledger is unchanged |
| **Fee categories** | FULL / SUBSIDIZED / **FREE (লিল্লাহ)** — free students are funded by donation and must not distort per-head math. Non-negotiable for madrasha |
| **Dues tracking** | Who has paid, who hasn't, how long overdue. Collection report. This is the superintendent's real daily question |
| **Ration store** | Stock in (chal, dal, tel, gas) → consumption out → closing stock. Institutions buy in bulk monthly, not daily. This is a small inventory module |
| **Cook headcount forecast** | Tomorrow's expected meals per slot, per kitchen. The one thing that saves them real money |
| **Staff module** | Cook / warden / cleaner — salary ledger, advance, attendance |
| **Roles** | Superintendent (full) · Accountant (money) · Warden (attendance only) · Guardian (read-only, own child) |
| **Guardian link** | Same magic-link mechanism as the member PWA, different payload: attendance + dues. Reuses V-10 wholesale |
| **Reports** | Monthly consumption, per-student dues, collection summary, donor/lillah fund report |

### 5.2 Build order

```
 Wk 6    mini-BRD from 3+ superintendent interviews. Do NOT skip.
         groups hierarchy activated · roles · bulk exception UI
 Wk 7    FIXED_FEE billing mode · fee categories · dues tracking
 Wk 8    ration store module (stock in/out, closing balance)
 Wk 9    staff module · cook headcount forecast
 Wk 10   reports (consumption, dues, collection, lillah fund)
         guardian link (reuses the member-PWA token mechanism)
 Wk 11   admin portal institution views · pilot with 2 real madrashas
```

### 5.3 Honest cost note

This phase is roughly **as large as the entire v1.0 build**. It is worth it — the segment is
almost completely unserved and institutions pay properly, unlike students. But it earns its place
only *after* the bachelor-mess product retains. If P2's D30 gate fails, this phase is premature.

---

## 6. PHASE 4 — v1.3 HOME MODE (Weeks 12–13)

Cheap, because P3 already built the flexibility.

```
 · tenants.kind = HOME → hides shared pool, rota, rooms, staff, grid
 · "one screen for a 4-person home mess" is the release gate again
 · no meal rate by default — just "what did we spend, who owes what"
 · optional: single-cook household mode (maid salary only)
 · relabelled strings: "মেস" → "বাসা", "সদস্য" → "সদস্য/পরিবার"
 Est. 6-8 days, mostly configuration and copy.
```

---

## 7. PHASE 5 — v2.0 ENTITLEMENT CORE (Weeks 14–15)

Generic, cross-product. Built once for Droid Builder, used by TinBela and everything after it.

```
 · entitlements(tenant_id, product, feature, valid_from, valid_to,
   source PURCHASE|REFERRAL|GRANT|TRIAL, receipt_ref)
 · Has(ctx, tenant, feature, on_date) — the interface already in use
   since v1.0, now actually backed by data
 · PERIOD-BASED, NOT SUBSCRIPTION: you buy specific months. This
   matches how messes actually live (they dissolve at semester break)
   and it is the shape the offline gate needs
 · Play Billing + a manual bKash/Nagad unlock-code path
 · Admin portal: grant, revoke, audit, refund
 · Remote-config prices — never hardcoded
 Est. 8-10 days.
```

---

## 8. PHASE 6 — v2.1 OFFLINE & SYNC (Weeks 16–20) · THE PAID MOAT

```
 WHY IT IS THE MOAT: every incumbent is architecturally cloud-first.
 Append-only + uuid client-generated pks means TinBela's merge is
 conflict-free by construction. They cannot copy this quickly.

 · Drift (SQLite) local store on the manager device
 · The Go engine ports to Dart — SAME golden test vectors run in both.
   This is why the vectors exist from Day 2.
 · Outbox queue + background sync + last-write-wins is never needed,
   because nothing is ever updated — only appended
 · Multi-device for the same manager
 · Gated: Has(tenant, "offline", today) — a mess that bought March gets
   offline in March. Lapse → falls back to online mode, never loses data
 · Free users stay fully functional online (never punish the broke)
 Est. 4-5 weeks. The single largest engineering item on the roadmap.
```

---

## 9. PHASE 7 — v2.2 OPERATIONS (Weeks 21–23)

All opt-in toggles, default OFF. The home screen renders only active modules — that rule is what
keeps the UI from re-bloating.

```
 · rooms & seats + "সিট খালি" shareable vacancy card
 · generic duty rota (cleaning, washroom, water)
 · maid module — salary ledger, advance, 1-tap attendance, meal pattern
 · multi-mess switcher (one manager, several messes)
 Est. 3 weeks.
```

---

## 10. RESOURCE REALITY

You are one person doing four jobs. The plan above assumes roughly full-time engineering through
P1, then a split.

```
 P0-P1   ~95% engineering. Sales and marketing wait.
 P2      ~70% engineering / 30% talking to managers. The talking is
         what tells you what P2 should contain.
 P3      ~60% engineering / 40% institution sales. Institutions are
         sold face to face — there is no viral loop in that segment.
 P5-P6   back to ~90% engineering.

 THE STANDING RISK: P3 is large and P6 is larger. If both slip, the
 bachelor-mess product goes six months without meaningful updates and
 churns. Mitigation: ship something small to the mess app every
 fortnight, even during P3 and P6, even if it is only copy and bug
 fixes. Visible progress is a retention feature.
```
