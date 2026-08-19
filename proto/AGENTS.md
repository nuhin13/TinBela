# AGENTS.md — API contract

This directory is the **single source of truth** for the API (ADR-0002). It
generates the Go server, the TypeScript clients, and the Dart models.

A change here changes three codebases. Treat it accordingly.

## Layout

```
tinbela/core/v1/    common types (Money, Date, MathExplain), auth, tenants, members
tinbela/meals/v1/   slots, patterns, exceptions, day
tinbela/money/v1/   ledger, accounts, periods, statements
tinbela/admin/v1/   admin read-only surface
```

## Evolution rules

- **Never renumber a field. Never reuse a number.** `reserved` it.
- Adding an optional field is safe. Removing or renaming one is not.
- `buf breaking --against main` runs in CI. A failure means you would break
  a shipped client.
- Once the app is on Play, **an old client version exists forever.** Design
  as if you can never remove a field.

## Money in proto

```protobuf
message Money {
  int64 paisa = 1;       // NEVER float, NEVER string
  string display = 2;    // server-formatted, respects locale + numerals
  MathExplain math = 3;  // how this number was derived
}
```

Every money field in every response carries `MathExplain`. Encoding it in
the contract is what stops a client quietly dropping the trust feature.

## Dates

`string` in `YYYY-MM-DD`, resolved `Asia/Dhaka` server-side. **Not
timestamps.** A meal belongs to a calendar day, not an instant.

## Workflow

1. Edit the `.proto`
2. `buf lint && buf breaking --against '.git#branch=main'`
3. `make proto`
4. **Update all consumers in the same commit** — that atomicity is the main
   reason for the monorepo (ADR-0015)
