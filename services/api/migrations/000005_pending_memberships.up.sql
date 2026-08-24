-- A membership has to be able to exist before its user does.
--
-- The onboarding design is invite-first: the manager types seven names at
-- night, alone, and shares seven links. Nobody else installs anything until
-- morning. Those seven memberships are real -- they carry display_name,
-- joined_at, a pattern, and they accrue meals -- but there is no user row to
-- point at until someone opens their link and signs in.
--
-- 000001 declared user_id NOT NULL REFERENCES users, which makes that
-- ordering impossible: AddMember failed with memberships_user_id_fkey and
-- the only way to satisfy it was to invent a users row for a person who has
-- never signed in. That pollutes the table phone matching (04.6) and account
-- deletion (04.9) both key off.
--
-- The FK stays. Only the NOT NULL goes: a membership either points at a real
-- user or at nobody yet, and never at a user that does not exist.
--
-- UNIQUE (tenant_id, user_id) is unaffected in the direction that matters.
-- Postgres treats NULLs as distinct in a unique index, so a mess may hold
-- any number of pending memberships while still admitting each signed-in
-- user exactly once. That is precisely the rule we want.
--
-- RLS needs no change either. The user_self_discovery policy (000004) reads
--     user_id = current_setting('app.user_id', true)::uuid
-- which is NULL for a pending row, and NULL is not true -- so a pending
-- membership is invisible on the self-discovery axis and visible only to a
-- caller already scoped into the mess by app.tenant_id. A member with no
-- account cannot be discovered by anyone outside their mess. Fail closed.

ALTER TABLE memberships
    ALTER COLUMN user_id DROP NOT NULL;

-- Claiming an invite is UPDATE ... WHERE user_id IS NULL, so that lookup is
-- on the hot path of every first sign-in. Partial, because the pending rows
-- are a small minority of a healthy mess and the index should stay that way.
CREATE INDEX memberships_pending_idx ON memberships (tenant_id)
    WHERE user_id IS NULL;
