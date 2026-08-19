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

## Initialise

```bash
cd apps
pnpm create next-app@latest admin --typescript --tailwind --app --no-src-dir
pnpm add @radix-ui/react-* class-variance-authority   # shadcn/ui base
```
