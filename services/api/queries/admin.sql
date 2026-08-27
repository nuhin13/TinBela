-- Epic 16 — the admin portal's reads. Every one runs as tinbela_admin
-- (ADR-0016): BYPASSRLS for cross-tenant reach, SELECT-only on customer data.
-- The two writes here touch admin's own tables, never a mess's.

-- name: ListTenantsAdmin :many
-- Tenant search + list (task 16.3), most-recently-active first. member_count
-- and last_activity are derived on read, never stored (Invariant 3).
SELECT
    t.id,
    t.name,
    t.kind,
    (SELECT count(*) FROM memberships m
       WHERE m.tenant_id = t.id AND m.left_at IS NULL)::int AS member_count,
    t.created_at,
    GREATEST(
        t.created_at,
        COALESCE((SELECT max(created_at) FROM meal_exceptions me WHERE me.tenant_id = t.id), t.created_at),
        COALESCE((SELECT max(created_at) FROM ledger_entries le WHERE le.tenant_id = t.id), t.created_at)
    )::timestamptz AS last_activity_at
FROM tenants t
WHERE @query::text = '' OR t.name ILIKE '%' || @query::text || '%'
ORDER BY last_activity_at DESC
LIMIT @lim OFFSET @off;

-- name: CountTenantsAdmin :one
SELECT count(*)::int FROM tenants t
WHERE @query::text = '' OR t.name ILIKE '%' || @query::text || '%';

-- name: FindUserByPhoneAdmin :one
SELECT * FROM users WHERE phone_e164 = @phone_e164 AND deleted_at IS NULL;

-- name: FindUserByFirebaseAdmin :one
SELECT * FROM users WHERE firebase_uid = @firebase_uid AND deleted_at IS NULL;

-- name: CountActiveMessesAdmin :one
-- A mess with anyone still in it. Zero-write days keep it "active".
SELECT count(DISTINCT tenant_id)::int FROM memberships WHERE left_at IS NULL;

-- name: CountExceptionsBetweenAdmin :one
SELECT count(*)::int FROM meal_exceptions
WHERE created_at >= @since AND created_at < @until;

-- name: CountClosesBetweenAdmin :one
SELECT count(*)::int FROM periods
WHERE status = 'CLOSED' AND closed_at >= @since AND closed_at < @until;

-- name: CountMemberLinksOpenedAdmin :one
SELECT count(*)::int FROM memberships WHERE invite_opened_at IS NOT NULL;

-- name: ListFeatureFlags :many
SELECT key, value FROM feature_flags ORDER BY key;

-- name: SetFeatureFlag :exec
-- The one write the admin surface makes to a shared switch (task 16.6). Takes
-- effect on the next read of the flag, no deploy.
INSERT INTO feature_flags (key, value, updated_at, updated_by)
VALUES (@key, @value, now(), @updated_by)
ON CONFLICT (key) DO UPDATE
    SET value = EXCLUDED.value, updated_at = now(), updated_by = EXCLUDED.updated_by;

-- name: InsertAdminAudit :exec
-- Task 16.8: who read what, and when.
INSERT INTO admin_audit_log (id, staff_uid, action, target, request_id)
VALUES (@id, @staff_uid, @action, @target, @request_id);
