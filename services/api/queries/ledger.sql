-- name: ListLedgerEntriesForRange :many
-- Hits ledger_tenant_date_idx (tenant_id, occurred_on).
SELECT * FROM ledger_entries
WHERE tenant_id = $1
  AND occurred_on BETWEEN sqlc.arg(range_start)::date AND sqlc.arg(range_end)::date
ORDER BY occurred_on, created_at;

-- name: SumFoodCostForRange :one
-- Voided entries are cancelled by their negative counterpart, so a plain
-- SUM over both is already correct -- no filtering on void_of.
SELECT COALESCE(sum(amount_paisa), 0)::bigint FROM ledger_entries
WHERE tenant_id = $1
  AND kind = 'FOOD_COST'
  AND occurred_on BETWEEN sqlc.arg(range_start)::date AND sqlc.arg(range_end)::date;

-- name: SumDepositsForMembership :one
SELECT COALESCE(sum(amount_paisa), 0)::bigint FROM ledger_entries
WHERE tenant_id = $1
  AND membership_id = $2
  AND kind = 'DEPOSIT';

-- name: InsertLedgerEntry :one
-- Append only. Corrections insert a negative row with void_of set.
INSERT INTO ledger_entries (
    id, tenant_id, kind, amount_paisa, category, membership_id,
    occurred_on, note, photo_url, entered_by, void_of
) VALUES (
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11
)
RETURNING *;

-- name: GetOpenPeriod :one
SELECT * FROM periods
WHERE tenant_id = $1 AND status = 'OPEN'
ORDER BY start_date DESC
LIMIT 1;
