-- Restoring NOT NULL means there is nowhere to put a pending membership, so
-- the rollback has to drop them. This is destructive and deliberately so: a
-- down migration that leaves the column nullable has not rolled anything
-- back, and one that errors out on existing data cannot be run at all.
--
-- memberships is not one of the append-only tables (ledger_entries,
-- meal_exceptions, period_statements), so DELETE is permitted here -- no
-- DO INSTEAD NOTHING rule silently swallows it. Migrations run as the owner
-- `tinbela`, a superuser, which bypasses RLS unconditionally, so the DELETE
-- sees every tenant's pending rows rather than an empty scope.
--
-- What is lost: members the manager had added but who had not yet opened
-- their invite link. Their meals and ledger entries cascade with them.
-- Anyone who had signed in is untouched.

DROP INDEX IF EXISTS memberships_pending_idx;

DELETE FROM memberships WHERE user_id IS NULL;

ALTER TABLE memberships
    ALTER COLUMN user_id SET NOT NULL;
