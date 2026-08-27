# TinBela Admin Portal (Next.js, internal)

**Scaffolded in Epic 16 — start it on Day 5, not at the end.**

Dropping Django means losing its admin for free. Without a read-only tenant
inspector you are blind for the following nine days of the build. This is
your debugger first and an ops tool second.

## Screens

| Screen | Purpose |
|---|---|
| Dashboard | active messes, exceptions today, closes this month |
| Tenants | search, then **read-only** inspector: members, ledger, exceptions, statements |
| Users | lookup by phone or firebase uid |
| Flags | feature flags, kill switch |
| Metrics | the events from BRD section 10 |

## The rule

**READ-ONLY on customer data.** No mutation path may exist in the code.
Flags and the kill switch are the only writes in the whole app.

Every admin read is written to an audit log. You will need that for trust
conversations later.

## Run

```bash
cd apps/admin
pnpm install
# point it at a running API (make dev in services/api) with a staff token:
ADMIN_API_URL=http://localhost:8080 ADMIN_API_STAFF_TOKEN=dev:dev-staff pnpm dev
# → http://localhost:3100
```

The API must be started with the admin surface configured — `ADMIN_PG_DSN`,
`STAFF_UIDS` (see `.env.example`) — or every call returns 403.

`GetTenant`, the read-only tenant **inspector** (task 16.4), is founder-owned
(★); its route is a placeholder until it lands. Everything else is built and
verified end to end. See `AGENTS.md` for the rules.
