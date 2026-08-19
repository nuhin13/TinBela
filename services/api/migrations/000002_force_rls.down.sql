-- Reverting leaves the policies in place but inert for the owning role.
ALTER TABLE tenants           NO FORCE ROW LEVEL SECURITY;
ALTER TABLE groups            NO FORCE ROW LEVEL SECURITY;
ALTER TABLE memberships       NO FORCE ROW LEVEL SECURITY;
ALTER TABLE slots             NO FORCE ROW LEVEL SECURITY;
ALTER TABLE patterns          NO FORCE ROW LEVEL SECURITY;
ALTER TABLE day_flags         NO FORCE ROW LEVEL SECURITY;
ALTER TABLE meal_exceptions   NO FORCE ROW LEVEL SECURITY;
ALTER TABLE ledger_entries    NO FORCE ROW LEVEL SECURITY;
ALTER TABLE periods           NO FORCE ROW LEVEL SECURITY;
ALTER TABLE period_statements NO FORCE ROW LEVEL SECURITY;
