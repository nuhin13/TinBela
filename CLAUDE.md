# TinBela — Droid Builder

Meal & mess management for Bangladeshi bachelor messes (v1.0), later
madrasha/hostel institutions (P3) and small families (P4).

**Tagline:** তিনবেলার হিসাব, এক অ্যাপে।
**Design law #1:** Collect exceptions, not data. Never record what's normal.

---

## Read before ANY task

| File | When |
|---|---|
| `docs/product/BRD.md` §6 (six laws) and §7.1 (v1.0 scope) | always |
| `docs/product/EPICS.md` | to find your task ID + Done-when |
| `docs/product/BUILD_SPEC.md` §3–§5 | backend tasks |
| `docs/product/UI_SPEC.md` | any client task |
| `docs/adr/` | before proposing an architectural change |

---

## The seven invariants (non-negotiable)

1. **Money is `int64` paisa.** Never float. Never a decimal string in JSON.
   ৳12.40 is `1240`. Formatting happens at the edge, never in logic.
2. **Append-only.** `ledger_entries`, `meal_exceptions`, `period_statements`
   are never `UPDATE`d or `DELETE`d. A correction INSERTs a row with
   `void_of` set. Postgres rules enforce this.
3. **Derived is never stored.** Daily meal counts do not exist as rows.
   They are materialized from patterns ⊕ exceptions ⊕ day_flags on read.
   The only snapshot is `period_statements`, written once at close.
4. **`tenant_id` on every row, tenant scope on every query.** RLS is a
   backstop, not the primary defence.
5. **`Asia/Dhaka`, server-side.** Cutoff correctness is a trust feature.
   Never trust the device clock.
6. **Entitlements go through `Has(ctx, tenant, feature, on_date)`.**
   In v1.0 it always returns true. Never write inline billing logic.
7. **If it is not in BRD §7.1, it is not in v1.0.** Propose it as a P2
   item instead of building it.

---

## Protected paths — DO NOT EDIT

A pre-edit hook blocks these. If you believe one needs changing, stop and
say so.

```
services/api/internal/db/            sqlc-generated — edit queries/*.sql
services/api/internal/meals/engine.go    ★ hand-owned (Epic 02)
services/api/internal/money/settle.go    ★ hand-owned (Epic 02)
services/api/testdata/vectors/           ★ golden vectors
```

---

## Stack

```
Backend    Go 1.23 · Connect-Go · pgx/v5 · sqlc · golang-migrate · slog
Database   Postgres 16 (tenant_id + RLS)
Contract   protobuf + buf  →  Go server, TS clients, Dart models
Manager    Flutter (Android, minSdk 24)
Web        Next.js 15 — apps/web (landing + member PWA), apps/admin
Edge       Caddy. No API gateway in v1.0 (see ADR-0004)
```

---

## Commands

```bash
make dev        # boot the full stack
make verify     # ★ THE GATE — lint, test, property, golden, contract, invariants
make test
make proto      # regenerate Go server + TS client + Dart models
make sqlc       # regenerate db layer after editing queries/*.sql
make migrate
make seed
make smoke      # end-to-end scenario
```

**A task is not done until `make verify` is green and a human has read the
diff.**

---

## Reporting format

End every task with:

```
Changed:            files and why
NOT done:           anything in the task deliberately skipped
Needs human review: judgement calls made
Next task:          id only
```

---

## Stop and ask when

- The task implies a feature not in BRD §7.1.
- You need a proto change that `buf breaking` would reject.
- You need to alter an append-only table.
- The task's Owner column is ★ (hand-written by the founder).
