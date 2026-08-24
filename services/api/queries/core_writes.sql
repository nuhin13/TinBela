-- name: CreateTenant :one
INSERT INTO tenants (id, name, kind, billing_mode, timezone)
VALUES ($1, $2, $3, 'RATE_BASED', 'Asia/Dhaka')
RETURNING *;

-- name: CreateSlot :one
INSERT INTO slots (id, tenant_id, name_bn, name_en, sort_order, cutoff_local, active)
VALUES ($1, $2, $3, $4, $5, sqlc.arg(cutoff_local)::time, true)
RETURNING *;

-- name: CreatePeriod :one
INSERT INTO periods (id, tenant_id, start_date, end_date, status)
VALUES ($1, $2, $3, $4, 'OPEN')
RETURNING *;

-- name: CreateMembership :one
INSERT INTO memberships (
    id, tenant_id, user_id, role, display_name, joined_at, invite_token
) VALUES ($1, $2, $3, $4, $5, $6, $7)
RETURNING *;

-- name: ListMembersWithUser :many
-- Members of a mess, with the linked user where one exists. A member may
-- have no account at all -- the manager adds them by name, and the invite
-- link is what turns them into a user later.
SELECT m.*, u.phone_e164 AS user_phone
FROM memberships m
LEFT JOIN users u ON u.id = m.user_id
WHERE m.tenant_id = $1 AND m.left_at IS NULL
ORDER BY m.display_name;

-- name: GetSlotsForTenant :many
SELECT * FROM slots
WHERE tenant_id = $1
ORDER BY sort_order;
