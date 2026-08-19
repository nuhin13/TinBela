# Engineering Conventions

## Commits

```
<epic>.<task>: <imperative summary>

Examples
  05.3: add CreateException endpoint with append-only write
  02.4: implement Settle with floor rate and visible remainder
  00.4: record ADR-0004 (no API gateway for MVP)
```

Every commit references the task it completes. When you later ask "why is
this here", the epic backlog answers it.

## Branches

`main` is always shippable. Work directly on `main` while solo — branching
costs coordination you do not need and slows `buf breaking`, which compares
against `main`.

## Naming

| Thing | Convention | Example |
|---|---|---|
| Go packages | short, lowercase, no underscores | `meals`, `periods` |
| Go files | snake_case | `create_exception.go` |
| Proto messages | PascalCase | `CreateExceptionRequest` |
| Proto fields | snake_case | `membership_id` |
| SQL | snake_case, plural tables | `meal_exceptions` |
| Dart files | snake_case | `cutoff_card.dart` |
| ARB keys | camelCase, screen-prefixed | `todayNoChangesTitle` |

## Money naming

Any variable holding paisa ends in `Paisa` / `_paisa`. If it does not, a
reader cannot tell whether it is taka or paisa, and that ambiguity is how
rounding bugs get written.

```go
amountPaisa int64   // yes
amount      int64   // no
```

## Comments

Comment **why**, not what. The `what` is in the code; the `why` is in your
head and will not be there in three months.

```go
// Guests ADD to the member's own meal rather than replacing it, because a
// member who brings a friend still eats. Property P9 pins this down.
```

## Error handling

Domain errors are typed values in the domain package. `transport/` maps them
to Connect codes. Never return a raw pgx error to a client. See `errors.md`.

## Logging

`log/slog`, structured. `request_id` and `tenant_id` on every line. Never log
a money amount together with a member name at info level.

## Tests

- Table-driven for units
- `rapid` for the nine engine properties
- Golden vectors for cross-language correctness
- A two-tenant test for every new tenant-scoped query
- Integration tests use a real Postgres in Docker, never a mock

## Definition of done

`make verify` green **and** a human has read the diff. Not one or the other.
