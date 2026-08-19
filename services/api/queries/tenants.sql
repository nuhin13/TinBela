-- name: GetTenant :one
SELECT * FROM tenants
WHERE id = $1;

-- name: ListActiveSlots :many
SELECT * FROM slots
WHERE tenant_id = $1 AND active
ORDER BY sort_order;
