---
name: tinbela-invariants
description: The seven non-negotiable rules of the TinBela codebase. Load for ANY task touching the API, database, money, or the meal engine.
---

# TinBela Invariants

Violating any of these is a defect regardless of whether tests pass.

## 1. Money is int64 paisa
Never float. Never a decimal string in JSON. `৳12.40` is `1240`.
Formatting happens at the rendering edge, never in logic.
`meal_rate = floor(food_paisa / total_meals)`. The remainder is surfaced as
a visible ADJUST line owned by the mess — never silently absorbed by a
member. Someone always asks where the ৳3 went.

## 2. Append-only
`ledger_entries`, `meal_exceptions`, `period_statements` are never UPDATEd
or DELETEd. A correction INSERTs a row with `void_of` set. Postgres RULES
enforce this — **if your code needs an UPDATE, your design is wrong.**
This is also why P6 offline sync is possible: append-only means merges are
conflict-free by construction.

## 3. Derived is never stored
Daily meal counts do not exist as rows. They are materialized from
`patterns ⊕ exceptions ⊕ day_flags` on every read. The only persisted
snapshot is `period_statements`, written once at close and immutable after.
A normal day costs zero writes — that is the entire product wedge expressed
as a data decision.

## 4. tenant_id on every row, tenant scope on every query
RLS is a backstop, not the primary defence. Two independent failures should
be required to leak data across messes.

## 5. Asia/Dhaka, server-side
Cutoff correctness is a trust feature. Never trust the device clock for a
date boundary or a cutoff decision.

## 6. Entitlements go through Has(ctx, tenant, feature, on_date)
In v1.0 it always returns true and no billing code exists. The `on_date`
parameter matters: purchase is per-period, not a subscription, so
entitlement is a question about a date rather than a flag on an account.

## 7. If it is not in BRD section 7.1, it is not in v1.0
Propose it as a P2 item instead of building it. Agents are helpful by
nature and will cheerfully build Phase 3 features in week one.

---

## Self-check before reporting done

| Check | How |
|---|---|
| float in a money path? | `grep -rn "float" internal/money internal/meals` |
| UPDATE/DELETE on a protected table? | `grep -rniE "(update\|delete).*(ledger_entries\|meal_exceptions\|period_statements)"` |
| stored a computed meal count? | review the diff |
| every new query tenant-scoped? | review the diff |
| `make verify` green? | run it |
