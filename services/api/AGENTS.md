# AGENTS.md — Go API

You are working in the TinBela backend: one Go binary, modular monolith
(ADR-0001), Connect over HTTP/JSON + gRPC (ADR-0002).

Read the root `AGENTS.md` first. The seven invariants apply here most of all.

## Layout

```
cmd/api/              entrypoint
migrations/           golang-migrate, numbered, every up has a down
queries/              hand-written SQL → generates internal/db via sqlc
internal/
  core/               tenants, users, memberships, groups
  meals/              engine.go ★ PROTECTED · service.go yours
  money/              settle.go ★ PROTECTED · ledger, accounts yours
  periods/            preview, close, immutable statements
  invites/            magic-link tokens
  entitlements/       interface + alwaysAllow (no billing code)
  telemetry/          server-side events
  transport/          Connect handlers, interceptors
  db/                 ★ GENERATED — never hand-edit
testdata/vectors/     ★ PROTECTED golden vectors
```

## Rules specific to this directory

- **Purity:** `meals/engine.go` and `money/settle.go` import nothing from
  `db`, `context`, or `time.Now`. They are pure functions. That is what makes
  them property-testable and portable to Dart in P6.
- **Never reimplement math.** Call `meals.Materialize` and `money.Settle`.
- **Never store a derived meal count.**
- Any variable holding paisa ends in `Paisa` / `_paisa`. Without that suffix
  a reader cannot tell taka from paisa, and that ambiguity is how rounding
  bugs get written.
- Every money field in a response carries its `MathExplain`. No exceptions —
  that is the trust feature, and a client cannot recreate it.
- The rounding remainder is a visible `ADJUST` line owned by the mess, never
  silently absorbed by a member.
- Errors: typed values in the domain package, mapped to Connect codes in
  `transport/`. Never return a raw pgx error. See `docs/eng/errors.md`.
- `ErrTenantMismatch` returns a generic "not found" — never confirm another
  tenant's resource exists.
- Logging: `log/slog`, with `request_id` and `tenant_id` on every line.

## Workflow

```bash
# after editing queries/*.sql
make sqlc
# after editing ../../proto/**
make proto
# always
make verify
```

## Tests

- Table-driven for units
- `pgregory.net/rapid` for the nine engine properties
- Golden vectors for cross-language correctness
- **A two-tenant test for every new tenant-scoped query**
- Integration tests use real Postgres in Docker, never a mock
