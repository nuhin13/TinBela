-- Every RLS policy casts a session setting to uuid. A MISSING setting gives
-- NULL, and NULL::uuid is harmless -- the policy matches nothing, which is
-- the fail-closed behaviour 000002 describes and relies on.
--
-- But SET LOCAL does not restore "missing" when the transaction ends. It
-- restores the SESSION value, and for a custom GUC first introduced inside a
-- transaction that value is the empty string. Then ''::uuid raises 22P02:
--
--     fresh session   current_setting('app.tenant_id', true) IS NULL  -> t
--     BEGIN; set_config('app.tenant_id', '<uuid>', true); COMMIT;
--     same connection current_setting('app.tenant_id', true)          -> ''
--                     current_setting('app.tenant_id', true)::uuid
--                     ERROR: invalid input syntax for type uuid: ""
--
-- So a pooled connection is poisoned by its first tenant-scoped request, and
-- every later query on it whose policy performs this cast fails -- including
-- the tenant-free ones. GetMe reads tenants and memberships, so it is the
-- first thing to break. It never reproduces on a fresh process, it is
-- load-dependent, it worsens as more connections are used, and a restart
-- "fixes" it by discarding the pool.
--
-- NULLIF collapses '' back to NULL, restoring the intended semantics. This
-- changes no data and no schema: it only makes "unset" and "reset to empty"
-- mean the same thing again, which is what every one of these policies
-- already assumed.
--
-- Recorded in docs/eng/transport.md.

-- ───────────────── 000001: tenant isolation ─────────────────

DROP POLICY tenant_isolation ON tenants;
CREATE POLICY tenant_isolation ON tenants
    USING (id = NULLIF(current_setting('app.tenant_id', true), '')::uuid);

DROP POLICY tenant_isolation ON groups;
CREATE POLICY tenant_isolation ON groups
    USING (tenant_id = NULLIF(current_setting('app.tenant_id', true), '')::uuid);

DROP POLICY tenant_isolation ON memberships;
CREATE POLICY tenant_isolation ON memberships
    USING (tenant_id = NULLIF(current_setting('app.tenant_id', true), '')::uuid);

DROP POLICY tenant_isolation ON slots;
CREATE POLICY tenant_isolation ON slots
    USING (tenant_id = NULLIF(current_setting('app.tenant_id', true), '')::uuid);

DROP POLICY tenant_isolation ON patterns;
CREATE POLICY tenant_isolation ON patterns
    USING (tenant_id = NULLIF(current_setting('app.tenant_id', true), '')::uuid);

DROP POLICY tenant_isolation ON day_flags;
CREATE POLICY tenant_isolation ON day_flags
    USING (tenant_id = NULLIF(current_setting('app.tenant_id', true), '')::uuid);

DROP POLICY tenant_isolation ON meal_exceptions;
CREATE POLICY tenant_isolation ON meal_exceptions
    USING (tenant_id = NULLIF(current_setting('app.tenant_id', true), '')::uuid);

DROP POLICY tenant_isolation ON ledger_entries;
CREATE POLICY tenant_isolation ON ledger_entries
    USING (tenant_id = NULLIF(current_setting('app.tenant_id', true), '')::uuid);

DROP POLICY tenant_isolation ON periods;
CREATE POLICY tenant_isolation ON periods
    USING (tenant_id = NULLIF(current_setting('app.tenant_id', true), '')::uuid);

DROP POLICY tenant_isolation ON period_statements;
CREATE POLICY tenant_isolation ON period_statements
    USING (tenant_id = NULLIF(current_setting('app.tenant_id', true), '')::uuid);

-- ───────────────── 000004: self discovery ─────────────────
-- app.user_id has the identical shape and the identical failure.

DROP POLICY user_self_discovery ON memberships;
CREATE POLICY user_self_discovery ON memberships
    USING (user_id = NULLIF(current_setting('app.user_id', true), '')::uuid);

DROP POLICY user_self_discovery ON tenants;
CREATE POLICY user_self_discovery ON tenants
    USING (EXISTS (
        SELECT 1 FROM memberships m
        WHERE m.tenant_id = tenants.id
          AND m.user_id = NULLIF(current_setting('app.user_id', true), '')::uuid
          AND m.left_at IS NULL
    ));
