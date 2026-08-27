-- Epic 16: the admin portal's operational tables and the read-only
-- cross-tenant role that serves them (ADR-0016).
--
-- feature_flags and admin_audit_log are global, not tenant-scoped: a flag is a
-- fleet-wide switch and an audit row records a staff action, neither of which
-- belongs to any one mess. They carry no tenant_id and no RLS.

CREATE TABLE feature_flags (
    key        text PRIMARY KEY,
    value      boolean NOT NULL DEFAULT false,
    updated_at timestamptz NOT NULL DEFAULT now(),
    updated_by text
);

-- Every admin READ is logged (task 16.8). Trust later depends on being able to
-- say who looked at which mess, and when.
CREATE TABLE admin_audit_log (
    id         uuid PRIMARY KEY,
    staff_uid  text NOT NULL,
    action     text NOT NULL,
    target     text,
    request_id text,
    created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX admin_audit_log_created_idx ON admin_audit_log (created_at DESC);

-- The read-only cross-tenant role (ADR-0016). BYPASSRLS so the admin surface
-- sees every mess; SELECT-only on customer data so no bug or careless handler
-- can mutate a mess's rows -- "no mutation path exists" (task 16.4) becomes a
-- database grant, not a code-review promise. The dev password matches the
-- rest of the dev-credential convention; PRODUCTION MUST ROTATE IT:
--     ALTER ROLE tinbela_admin PASSWORD '<from the secret store>';
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'tinbela_admin') THEN
        CREATE ROLE tinbela_admin LOGIN PASSWORD 'tinbela_admin'
            NOSUPERUSER NOCREATEDB NOCREATEROLE BYPASSRLS NOINHERIT;
    END IF;
END
$$;

GRANT USAGE ON SCHEMA public TO tinbela_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO tinbela_admin;
-- A later migration's customer table is readable by admin without a follow-up.
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO tinbela_admin;

-- Its own operational tables are the ONLY writes the role may perform, and
-- neither is customer data.
GRANT INSERT ON admin_audit_log TO tinbela_admin;
GRANT INSERT, UPDATE ON feature_flags TO tinbela_admin;

-- The member-facing API role (tinbela_app) has no business in the audit log,
-- and may read flags but never set them. Migration 000003's default privileges
-- granted it CRUD on new tables; narrow that back here.
REVOKE ALL ON admin_audit_log FROM tinbela_app;
REVOKE INSERT, UPDATE, DELETE ON feature_flags FROM tinbela_app;
