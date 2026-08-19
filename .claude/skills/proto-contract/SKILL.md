---
name: proto-contract
description: How to write and evolve TinBela protobuf contracts safely. Load before touching proto/.
---

# Proto Contract

`proto/` is the single source of truth for the API (ADR-0002). It generates
the Go server, the TypeScript clients, and the Dart models.

## Layout
```
proto/tinbela/core/v1/    common types, auth, tenants, members
proto/tinbela/meals/v1/   slots, patterns, exceptions, day
proto/tinbela/money/v1/   ledger, accounts, periods, statements
proto/tinbela/admin/v1/   admin read-only surface
```

## Evolution rules
- **Never renumber a field.** Never reuse a number. `reserved` it instead.
- Adding an optional field is safe. Removing or renaming one is not.
- `buf breaking --against main` runs in CI. If it fails, you are doing
  something that would break a shipped client.
- Once the app is on Play, an old client version exists forever. Design as
  if you can never remove a field.

## Money in proto
```protobuf
message Money {
  int64 paisa = 1;      // NEVER a float, NEVER a string
  string display = 2;   // server-formatted, respects locale + numerals
  MathExplain math = 3; // how this number was derived
}
```
Every money field in every response carries its `MathExplain`. That is
Wedge 3 — trust — expressed in the contract so it cannot be quietly dropped
by a client.

## Dates
`string` in `YYYY-MM-DD`, resolved `Asia/Dhaka` server-side. Not timestamps.
A meal belongs to a calendar day, not an instant.

## Workflow
1. Edit the `.proto`.
2. `buf lint` then `buf breaking`.
3. `make proto` to regenerate all three clients.
4. Update the consumers in the same commit — that atomicity is the main
   reason for the monorepo (ADR-0015).
