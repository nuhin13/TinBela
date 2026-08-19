# sqlc queries

Hand-written SQL here generates `internal/db`. **Never hand-edit
`internal/db`** — a pre-edit hook blocks it.

Workflow: edit a `.sql` file here → `make sqlc` → use the generated method.

Rules:
- Every query filters by `tenant_id`. RLS is a backstop, not the filter.
- Never write `UPDATE` or `DELETE` against `ledger_entries`,
  `meal_exceptions`, or `period_statements`. Postgres rules will silently
  no-op them, which is worse than an error.
- Money columns are `bigint` paisa.
