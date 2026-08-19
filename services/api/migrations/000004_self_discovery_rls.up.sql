-- GetMe answers "which messes am I in", and must work before any tenant is
-- known. Under the 000001 policies it returned nothing: with app.tenant_id
-- unset the policies compare against NULL and every row is invisible. That
-- is correct fail-closed behaviour, and it makes discovery impossible --
-- you would need to know a mess to learn which messes you have.
--
-- The fix is a second axis, keyed on the authenticated user rather than the
-- tenant. Postgres ORs permissive policies together, so this WIDENS
-- visibility by exactly one rule: you may always see your own membership
-- rows, and the messes those rows point at. Nothing else changes -- a
-- caller still cannot see anyone else's membership, or any other row in a
-- mess they have not scoped into.
--
-- The transport auth interceptor sets app.user_id for every request, in the
-- same transaction the tenant interceptor later sets app.tenant_id in.

CREATE POLICY user_self_discovery ON memberships
    USING (user_id = current_setting('app.user_id', true)::uuid);

CREATE POLICY user_self_discovery ON tenants
    USING (EXISTS (
        SELECT 1 FROM memberships m
        WHERE m.tenant_id = tenants.id
          AND m.user_id = current_setting('app.user_id', true)::uuid
          AND m.left_at IS NULL
    ));
