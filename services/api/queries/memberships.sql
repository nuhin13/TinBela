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

-- name: LeaveMembership :one
-- Soft leave (task 04.8): mark a member gone as of @left_at. Never a DELETE --
-- their prior meals still count toward the months they were present (P8), and
-- meal_exceptions references this row. The `left_at IS NULL` guard makes a
-- repeat call affect no rows rather than moving an existing leave date, so the
-- handler can tell "already left" from "just left".
UPDATE memberships
SET left_at = @left_at
WHERE tenant_id = @tenant_id AND id = @id AND left_at IS NULL
RETURNING *;
