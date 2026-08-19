-- ENABLE ROW LEVEL SECURITY does not apply to a table's owner. The API
-- connects as `tinbela` (see docker-compose.yml), which owns every table,
-- so the policies added in 000001 never evaluated: a session pinned to one
-- tenant could read every tenant's rows. Measured at 500 tenants before
-- this migration -- see docs/eng/indexes.md.
--
-- FORCE makes the policies apply to the owner too. On its own this does
-- NOT fix the hole: `tinbela` is also a SUPERUSER with BYPASSRLS (see
-- 000003), and superusers ignore RLS whether or not it is forced.
--
-- The fix is the separate application role in 000003. Measured: with a
-- non-owner, non-superuser role, plain ENABLE already isolates tenants,
-- so this migration is defence in depth rather than the remedy -- it is
-- what protects us if the API is ever pointed back at an owning role.
--
-- Consequence: every connection must `SET LOCAL app.tenant_id` before
-- touching these tables. current_setting('app.tenant_id', true) is NULL
-- when unset, and `tenant_id = NULL` is NULL, not true -- so an unscoped
-- session now reads zero rows. Fail closed, which is the point.
--
-- The policies carry only USING, so Postgres reuses that expression as
-- WITH CHECK: a session cannot INSERT rows belonging to another tenant
-- either.
--
-- Not forced: `users` has no tenant_id and no policy (a user may belong to
-- several messes). Tenant scoping for users happens through memberships.

ALTER TABLE tenants           FORCE ROW LEVEL SECURITY;
ALTER TABLE groups            FORCE ROW LEVEL SECURITY;
ALTER TABLE memberships       FORCE ROW LEVEL SECURITY;
ALTER TABLE slots             FORCE ROW LEVEL SECURITY;
ALTER TABLE patterns          FORCE ROW LEVEL SECURITY;
ALTER TABLE day_flags         FORCE ROW LEVEL SECURITY;
ALTER TABLE meal_exceptions   FORCE ROW LEVEL SECURITY;
ALTER TABLE ledger_entries    FORCE ROW LEVEL SECURITY;
ALTER TABLE periods           FORCE ROW LEVEL SECURITY;
ALTER TABLE period_statements FORCE ROW LEVEL SECURITY;
