-- Restores the policies exactly as 000001 and 000004 wrote them, empty-string
-- bug included. Rolling back reintroduces a real defect, which is what a
-- faithful rollback of this migration means.

DROP POLICY tenant_isolation ON tenants;
CREATE POLICY tenant_isolation ON tenants
    USING (id = current_setting('app.tenant_id', true)::uuid);

DROP POLICY tenant_isolation ON groups;
CREATE POLICY tenant_isolation ON groups
    USING (tenant_id = current_setting('app.tenant_id', true)::uuid);

DROP POLICY tenant_isolation ON memberships;
CREATE POLICY tenant_isolation ON memberships
    USING (tenant_id = current_setting('app.tenant_id', true)::uuid);

DROP POLICY tenant_isolation ON slots;
CREATE POLICY tenant_isolation ON slots
    USING (tenant_id = current_setting('app.tenant_id', true)::uuid);

DROP POLICY tenant_isolation ON patterns;
CREATE POLICY tenant_isolation ON patterns
    USING (tenant_id = current_setting('app.tenant_id', true)::uuid);

DROP POLICY tenant_isolation ON day_flags;
CREATE POLICY tenant_isolation ON day_flags
    USING (tenant_id = current_setting('app.tenant_id', true)::uuid);

DROP POLICY tenant_isolation ON meal_exceptions;
CREATE POLICY tenant_isolation ON meal_exceptions
    USING (tenant_id = current_setting('app.tenant_id', true)::uuid);

DROP POLICY tenant_isolation ON ledger_entries;
CREATE POLICY tenant_isolation ON ledger_entries
    USING (tenant_id = current_setting('app.tenant_id', true)::uuid);

DROP POLICY tenant_isolation ON periods;
CREATE POLICY tenant_isolation ON periods
    USING (tenant_id = current_setting('app.tenant_id', true)::uuid);

DROP POLICY tenant_isolation ON period_statements;
CREATE POLICY tenant_isolation ON period_statements
    USING (tenant_id = current_setting('app.tenant_id', true)::uuid);

DROP POLICY user_self_discovery ON memberships;
CREATE POLICY user_self_discovery ON memberships
    USING (user_id = current_setting('app.user_id', true)::uuid);

DROP POLICY user_self_discovery ON tenants;
CREATE POLICY user_self_discovery ON tenants
    USING (EXISTS (
        SELECT 1 FROM memberships m
        WHERE m.tenant_id = tenants.id
          AND m.user_id = current_setting('app.user_id', true)::uuid
          AND m.left_at IS NULL
    ));
