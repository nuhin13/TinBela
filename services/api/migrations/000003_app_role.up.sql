-- This is the migration that actually closes the tenant-isolation hole.
--
-- `tinbela` is created by POSTGRES_USER and is therefore a SUPERUSER with
-- BYPASSRLS. Superusers ignore row-level security unconditionally, so
-- neither ENABLE (000001) nor FORCE (000002) had any effect on the API's
-- connection: a session pinned to one tenant read every tenant's rows.
--
-- The only fix is a separate role. Migrations keep running as the owner
-- (`tinbela`); the API connects as `tinbela_app`, which owns nothing, is
-- not a superuser, and does not have BYPASSRLS. RLS finally applies.
--
-- The dev password below matches the rest of the dev-credential convention
-- in .env.example. PRODUCTION MUST ROTATE IT:
--     ALTER ROLE tinbela_app PASSWORD '<from the secret store>';
-- golang-migrate has no parameter substitution, so this cannot be injected
-- at migrate time.
--
-- Grants are deliberately uniform, including UPDATE and DELETE on the
-- append-only tables. Their DO INSTEAD NOTHING rules already neutralise
-- those statements, and task 01.5 specifies that an UPDATE "silently
-- no-ops" -- withholding the grant would raise a permission error instead
-- and contradict that behaviour.

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'tinbela_app') THEN
        CREATE ROLE tinbela_app LOGIN PASSWORD 'tinbela_app'
            NOSUPERUSER NOCREATEDB NOCREATEROLE NOBYPASSRLS NOINHERIT;
    END IF;
END
$$;

GRANT USAGE ON SCHEMA public TO tinbela_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO tinbela_app;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO tinbela_app;

-- Anything a later migration creates is covered without a follow-up grant.
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO tinbela_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT USAGE, SELECT ON SEQUENCES TO tinbela_app;
