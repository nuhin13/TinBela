-- name: ListExceptionsForDate :many
-- The day query. Hits meal_exceptions_lookup_idx (tenant_id, date_from,
-- date_to) -- see docs/eng/indexes.md. A row is in force on a date when the
-- date falls inside its closed range.
SELECT * FROM meal_exceptions
WHERE tenant_id = $1
  AND date_from <= sqlc.arg(on_date)::date
  AND date_to   >= sqlc.arg(on_date)::date
ORDER BY created_at;

-- name: ListExceptionsForRange :many
SELECT * FROM meal_exceptions
WHERE tenant_id = $1
  AND date_from <= sqlc.arg(range_end)::date
  AND date_to   >= sqlc.arg(range_start)::date
ORDER BY created_at;

-- name: ListPatterns :many
-- Law 1 defaults. effective_from lets a pattern change mid-period without
-- rewriting history.
SELECT * FROM patterns
WHERE tenant_id = $1 AND effective_from <= sqlc.arg(as_of)::date
ORDER BY membership_id, slot_id, effective_from DESC;

-- name: ListDayFlags :many
SELECT * FROM day_flags
WHERE tenant_id = $1
  AND date BETWEEN sqlc.arg(range_start)::date AND sqlc.arg(range_end)::date
ORDER BY date;

-- name: InsertMealException :one
-- Append only. A correction sets void_of; nothing is ever updated.
INSERT INTO meal_exceptions (
    id, tenant_id, membership_id, slot_id, date_from, date_to,
    action, qty, marked_by, after_cutoff, void_of
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11
)
RETURNING *;

-- name: UpsertPattern :one
-- Law 1: a member's weekly default (dow_mask bit 0 = Saturday, 127 = every
-- day; qty = plates on an active day). patterns is NOT append-only — a change
-- updates the row for its effective date. effective_from lets a change apply
-- forward without rewriting past days: ListPatterns picks the latest
-- effective_from <= the query date, so history is preserved by a new date, not
-- a mutated one.
INSERT INTO patterns (
    id, tenant_id, membership_id, slot_id, dow_mask, qty, effective_from
) VALUES (
    $1, $2, $3, $4, $5, $6, $7
)
ON CONFLICT (membership_id, slot_id, effective_from)
DO UPDATE SET dow_mask = EXCLUDED.dow_mask, qty = EXCLUDED.qty
RETURNING *;
