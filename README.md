# TinBela · তিনবেলা

**Meal & mess management for Bangladesh.** A product of Droid Builder.

> তিনবেলার হিসাব, এক অ্যাপে।
> *Collect exceptions, not data. Never record what's normal.*

---

## What this is

Every competitor makes the mess manager type ~24 records a day. TinBela makes
a normal day cost **zero** entries: each member has a standing weekly pattern,
and only *exceptions* (off / guest / qty change) get tapped. Members never
install anything — they get a no-password web link.

## Quick start

```bash
mise install          # pins Go 1.23, Node 22, Flutter, buf, sqlc, migrate
cp .env.example .env
make dev              # postgres + api, migrated and seeded
make verify           # the gate — must be green before any commit
```

Then open `docs/product/EPICS.md` and start at **Epic 00**.

## Repository map

```
.claude/      agent harness — agents, skills, commands, hooks
docs/
  product/    BRD, dev plan, build spec, UI spec, epics, harness guide
  adr/        architecture decision records 0001–0015
  design/     tokens, components
  eng/        conventions, errors, data retention
  ops/        runbooks, backup + restore drill
proto/        ★ the API contract — single source of truth
packages/     design-tokens, generated api-clients
services/api/ Go modular monolith (one binary)
apps/
  manager/    Flutter — Android
  web/        Next.js — landing page + member PWA
  admin/      Next.js — internal admin portal
harness/      smoke, load, fixtures, invariant checks
```

## Reading order for your first session

1. `docs/adr/` — why things are the way they are
2. `docs/product/EPICS.md` — Epic 00
3. `docs/product/HARNESS.md` — how to run agent sessions

## The rule

A task is done when `make verify` is green **and** a human has read the diff.
Not when an agent says it is done.
