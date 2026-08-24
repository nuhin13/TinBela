-- Restoring NOT NULL means there is nowhere to put a pending membership.
-- The obvious rollback -- delete them, then restore the constraint -- is not
-- available, and it is worth writing down why, because the failure is
-- opaque:
--
--   referential integrity query on "memberships" from constraint
--   "meal_exceptions_membership_id_fkey" on "meal_exceptions"
--   gave unexpected result
--
-- meal_exceptions references memberships ON DELETE CASCADE, and carries the
-- append-only DO INSTEAD NOTHING rules from task 01.5. Deleting a membership
-- makes Postgres run the cascade as a DELETE against meal_exceptions; the
-- rule rewrites that statement to nothing, and the RI machinery aborts on
-- the result it did not expect. This happens whether or not the membership
-- has any exceptions -- the cascade fires on the constraint, not on matching
-- rows -- so NO membership can be hard-deleted while those rules exist.
--
-- That is Invariant 2 reaching further than it reads: meal history is
-- append-only, therefore the rows meal history hangs off are undeletable
-- too. Removing members is `left_at` (soft leave, task 04.8), never DELETE.
--
-- So the rollback is only possible from a state that has no pending
-- memberships, and this migration says so plainly instead of dying on
-- SET NOT NULL with an error about a NULL value. Give the pending members
-- accounts, or restore from backup.

DROP INDEX IF EXISTS memberships_pending_idx;

DO $$
DECLARE pending int;
BEGIN
    SELECT count(*) INTO pending FROM memberships WHERE user_id IS NULL;
    IF pending > 0 THEN
        RAISE EXCEPTION
            'cannot roll back 000005: % membership(s) have no user. They '
            'cannot be deleted either -- the append-only rules on '
            'meal_exceptions block every DELETE on memberships. Link them '
            'to real users first.', pending;
    END IF;
END
$$;

ALTER TABLE memberships
    ALTER COLUMN user_id SET NOT NULL;
