---
name: go-conventions
description: Go code conventions for the TinBela API — package layout, errors, logging, testing.
---

# Go Conventions

## Package layout
Modular monolith (ADR-0001). `internal/` packages are future service
boundaries. Cross-package calls go through interfaces defined by the
*consumer*, not the provider.

```
core/         tenants, users, memberships, groups
meals/        engine.go (pure, hand-owned) + service.go
money/        settle.go (pure, hand-owned) + ledger, accounts
periods/      preview, close, statements
invites/      magic-link tokens
entitlements/ interface + alwaysAllow
telemetry/    server-side events
transport/    Connect handlers, interceptors
db/           sqlc-generated — never hand-edit
```

## Purity rule
`meals/engine.go` and `money/settle.go` import nothing from `db`, `context`,
or `time.Now`. They are pure functions. This is what makes them portable to
Dart in P6 and testable with property tests.

## Errors
Domain errors are typed values in the domain package. `transport/` maps them
to Connect codes. Never return a raw pgx error to a client.
See `docs/eng/errors.md` for the mapping table.

## Logging
`log/slog`, structured, with `request_id` and `tenant_id` on every line.
Never log money amounts with member names together at info level.

## Testing
- Table-driven for units.
- `pgregory.net/rapid` for the nine engine properties.
- Golden vectors for cross-language correctness.
- Two-tenant test for every new tenant-scoped query.
- Integration tests use a real Postgres in Docker, never a mock.

## Style
- `gofmt` + `golangci-lint`, enforced by hook.
- Accept interfaces, return structs.
- No global state except config, loaded once at boot.
- Context first argument, always.
