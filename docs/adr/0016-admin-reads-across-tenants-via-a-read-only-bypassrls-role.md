# ADR-0016 — The admin portal reads across tenants through a read-only BYPASSRLS role

**Status:** Accepted
**Date:** 2026-08-27

**Context.** The admin portal (Epic 16) is the operator's window into production: it lists every
mess, searches users, and reports fleet-wide metrics. That is a cross-tenant read by definition,
which the rest of the system is built to prevent. The API connects as `tinbela_app`
(ADR-0008, migration 000003): `NOBYPASSRLS`, under `FORCE ROW LEVEL SECURITY`, so a query with no
`app.tenant_id` set returns zero rows. Admin aggregate reads are therefore impossible on that role
— correctly. Two wrong ways to "fix" it: connect admin as the superuser `tinbela` (full write access
to every mess — the exact blast radius the whole design exists to remove), or loosen an RLS policy
(weakens the backstop for the member-facing services too).

**Decision.** Add a third role, `tinbela_admin`: `LOGIN`, `BYPASSRLS`, `NOSUPERUSER`, granted
`SELECT` on customer tables and nothing else — no `INSERT`/`UPDATE`/`DELETE` on any mess-owned table.
The admin service runs on its own pool as this role. Its own operational tables (`feature_flags`,
`admin_audit_log`) are the sole exceptions it may write. `GetTenant`'s inspector (task 16.4 ★) and
every other admin read run under it.

**Consequences.** Admin sees across tenants, as it must, while "READ-ONLY on customer data — no
mutation path exists in the code" (task 16.4) stops being a code-review promise and becomes a
database grant: even a bug, or a handler a future contributor adds carelessly, cannot mutate a
mess's rows, because the connection lacks the privilege and Postgres refuses the statement. The
member-facing RLS is untouched. Cost: a second connection pool and DSN to configure, and staff
authorisation must be enforced in the transport layer (a read-only superpower is still a superpower
— the role is the floor, not the gate). `SetFlag` and the audit-log write are the only writes the
role can perform, and they touch no customer data.

**Revisit when.** The admin surface needs to mutate customer data (it should not; that belongs in
the member-facing services under tenant scope), or a dedicated reporting replica makes reading from
the primary undesirable.
