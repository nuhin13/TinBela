-- name: ListMemberships :many
-- Everyone currently in the mess. left_at IS NULL is the "still here" test.
SELECT * FROM memberships
WHERE tenant_id = $1 AND left_at IS NULL
ORDER BY display_name;

-- name: GetMembership :one
SELECT * FROM memberships
WHERE tenant_id = $1 AND id = $2;

-- name: CountActiveMembers :one
SELECT count(*) FROM memberships
WHERE tenant_id = $1 AND left_at IS NULL AND role <> 'MANAGER';
