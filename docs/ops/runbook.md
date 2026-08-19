# Runbook

## Daily

- Crash-free rate (Crashlytics) — investigate anything below 99%
- API error rate and p95 latency
- `mess_created` and `exception_marked` counts
  ← **the second number is the one that matters.** High installs with low
  exceptions means managers set up and never came back

## Backup

Automated nightly `pg_dump`, retained 30 days, stored off the dev server.

**The ledger is the product.** A lost ledger is not a data incident, it is
the end of the company's reputation in a market that runs on word of mouth.

## Restore drill — Epic 18, task 18.5

Run this **before launch**, and monthly after.

```bash
# 1. take a fresh dump
pg_dump "$PG_DSN" -Fc > /tmp/tinbela-$(date +%F).dump

# 2. restore into a scratch database
createdb tinbela_restore_test
pg_restore -d tinbela_restore_test /tmp/tinbela-*.dump

# 3. verify — row counts and one full statement
psql tinbela_restore_test -c "select count(*) from period_statements;"

# 4. record the elapsed time in docs/ops/incidents.md
dropdb tinbela_restore_test
```

An untested backup is not a backup. Time it, so you know what an outage
actually costs.

## Kill switch

Firebase Remote Config `kill_switch=true` shows a maintenance screen in the
app without a deploy. Test it against production before launch (task 19.9),
not during an incident.

## Rollback

The previous AAB stays in Play Console. Halt the staged rollout first, then
promote the previous build. Backend rollback is the previous container tag —
but **check whether a migration ran**. Migrations are forward-only in
practice once real ledgers exist; prefer a fix-forward.

## On-call reality

You are on call. Alerts go to your phone (task 19.10). Set a threshold you
will actually respond to, not one that trains you to ignore notifications.
