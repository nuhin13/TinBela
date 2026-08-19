# ADR-0008 — Postgres row-level security as a backstop, tenant scoping as the primary defence

**Status:** Accepted
**Date:** 2026-08-19

**Context.** Multi-tenant from day one, and a cross-tenant leak in a financial app is fatal to a
new company's reputation.

**Decision.** `tenant_id` on every table. Every query is explicitly tenant-scoped in application
code. RLS policies are enabled as a second, independent layer, with the tenant set as a session
variable by the transport interceptor.

**Consequences.** Two independent failures are required to leak data. Proven by a two-tenant
integration test in CI. Cost: slight query overhead and the discipline of setting the session
variable correctly.

**Revisit when.** Never. Add to it, don't remove it.
