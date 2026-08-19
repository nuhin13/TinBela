-- name: GetUserByFirebaseUID :one
-- Auth runs before any tenant is known, which is why `users` carries no RLS
-- policy: a user may belong to several messes, and identity is resolved
-- before scope is.
SELECT * FROM users
WHERE firebase_uid = $1 AND deleted_at IS NULL;

-- name: GetUser :one
SELECT * FROM users
WHERE id = $1 AND deleted_at IS NULL;

-- name: ListMessesForUser :many
-- Every mess this user still belongs to, with their membership in it.
SELECT t.*, m.id AS membership_id, m.role, m.display_name
FROM tenants t
JOIN memberships m ON m.tenant_id = t.id
WHERE m.user_id = $1 AND m.left_at IS NULL
ORDER BY t.name;

-- name: GetMembershipForUserInTenant :one
-- The tenant interceptor's authorisation check: is this caller in this mess?
SELECT * FROM memberships
WHERE user_id = $1 AND tenant_id = $2 AND left_at IS NULL;
