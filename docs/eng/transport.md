# Transport (Epic 03)

One binary serves gRPC, gRPC-Web and HTTP/JSON on the same paths (ADR-0002).
The Flutter app speaks plain JSON over HTTP with generated Dart message
types (ADR-0003); web and admin use the generated Connect TypeScript client.

## Interceptor order

Outermost first. Order is load-bearing, not stylistic.

| # | Interceptor | Why it sits here |
|---|---|---|
| 1 | `recovery` | a panic must not escape as a dropped connection |
| 2 | `requestID` | everything below logs and returns the same id |
| 3 | `logging` | sees the final client-facing code |
| 4 | `rateLimit` | cheap rejection before any database work |
| 5 | `timeout` | bounds everything below it |
| 6 | `errorMapping` | outside auth, so auth's own errors are mapped too |
| 7 | `auth` | identity; **opens the request transaction** |
| 8 | `tenant` | scope; sets `app.tenant_id` on that transaction |

`errorMapping` logs the original cause for anything that maps to `internal`.
It has to: an unmapped error is by definition one nobody phrased for a user,
so the client gets "internal error" and every layer outside this one sees
only the mapped version. Losing the cause here loses it entirely.

## One transaction per request

`SET LOCAL` is transaction-scoped, so the RLS scope and the unit of work are
necessarily the same object. The auth interceptor opens the transaction and
sets `app.user_id`; the tenant interceptor sets `app.tenant_id` on the same
one. Handlers take it from `TxFrom(ctx)`.

A handler that reaches for the pool instead does not get an error — it gets
**zero rows**, because the policies compare against an unset variable, which
is NULL. That failure is silent and looks like missing data, so it is worth
knowing about before it happens.

## Tenant authorisation is RLS, not an `if`

The tenant interceptor issues its membership check *after* `SET LOCAL
app.tenant_id`. So the authorisation query runs under the same policy as
every other query: a caller outside the mess does not get a rejected row,
they get no row at all. There is no hand-written `if requested != caller`
to forget to write.

## Self-discovery

`GetMe` must work before any tenant is known — a client calls it to learn
which messes it has. Under the 000001 policies it returned nothing, which
was correct fail-closed behaviour and also a deadlock: you needed a mess to
learn your messes.

Migration `000004` adds a second permissive policy keyed on `app.user_id`:
you may always see your own membership rows and the messes they point at.
Postgres ORs permissive policies, so this widens visibility by exactly that
one rule. `tenantFreeProcedures` in `tenant.go` lists the procedures mounted
without tenant scope.

## Authentication in dev

Firebase verification (task 04.1) has landed: `transport.NewVerifier` picks
the Firebase verifier for every `APP_ENV` except `dev`, and refuses to boot
without `FIREBASE_PROJECT_ID`. Under `APP_ENV=dev`, `NewDevVerifier`
accepts `Authorization: Bearer dev:<firebase_uid>` and proves nothing. It
**refuses to construct unless `APP_ENV=dev`**, so deploying it is a startup
failure rather than a silent authentication bypass. `make seed` sets
`firebase_uid` to `dev-<phone without +>`.

```sh
curl -s -X POST localhost:8080/tinbela.core.v1.CoreService/GetMe \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer dev:dev-8801711000001' -d '{}'
```

## Rate limiting

In process, no gateway (ADR-0004). Token bucket, 30 burst and 10/s sustained
by default, keyed on the bearer token where there is one and the peer IP
otherwise. Keying on the token matters: a mess behind one NAT would share a
single IP bucket, and one busy manager would throttle the whole building.

Measured: 60 rapid calls on one token gave 36 allowed, 24 `resource_exhausted`
— burst plus refill over the run.

If TinBela ever runs more than one instance this becomes per-instance and the
effective limit multiplies. Worth revisiting then, not now.

## GATE STATUS — met

Epic 03's gate is *"a generated TypeScript client and a generated Dart model
both round-trip a real call against the running binary."*

Run it: **`make contract-live`**. It boots the stack, migrates, seeds,
restarts the api, and drives both clients against the real process.

- **Go** — met. `internal/transport/contract_test.go` drives the generated
  Connect client over real HTTP through the whole chain, against a real
  database with RLS forced. Run by `make contract`.
- **TypeScript** — met. `packages/api-clients/test/live_round_trip.ts` calls
  `GetMe` against the running binary with the generated client, and asserts
  an unauthenticated call is refused. `test/wire_format.test.ts` proves the
  same codec with no stack, and runs inside `make verify`.
- **Dart** — met. `apps/manager/tool/live_round_trip.dart` does the same
  through the hand-rolled HTTP/JSON client (ADR-0003, task 08.5).
  `test/core/api/connect_client_test.dart` is the stackless half, run by
  `flutter test` in CI.

### Why there are two tests per language

The stackless tests are fed **response bytes captured verbatim from the
running binary**, not JSON the test author composed. A self-composed fixture
proves only that the client agrees with whoever wrote the test. The captured
bytes carry the server's real choices — proto3 JSON lowerCamelCase, enums as
names rather than ordinals, omitted default fields — and every one of those
is a way a client can silently disagree with the server while staying green.

The live tests then prove the process, the socket and the database. They are
kept out of `verify` because they need Docker, and a gate that is red
whenever Postgres is down gets ignored — but they are one command, so
"needs Docker" never becomes "nobody runs it".

## Root-caused: the instance that returned `internal` until restarted

Previously recorded here as an open observation: *"a running instance began
returning `internal` for every `GetMe` and kept doing so until restarted; no
root cause established."*

**Cause: `SET LOCAL` reverts a custom GUC to the empty string, not to unset.**

Every RLS policy in `000001_init.up.sql` reads the tenant like this:

```sql
USING (tenant_id = current_setting('app.tenant_id', true)::uuid)
```

The `true` makes a *missing* setting return NULL, and `NULL::uuid` is
harmless — the policy simply matches nothing. That is the fail-closed
behaviour 000002's comment describes, and it is correct.

But `SET LOCAL` does not restore "missing" at commit. It restores the
**session** value, and for a custom GUC first introduced inside a
transaction that value is `''`. Demonstrated on a real connection:

```
fresh session          current_setting('app.tenant_id', true) IS NULL  -> t
BEGIN; set_config('app.tenant_id', '<uuid>', true); COMMIT;
same connection        current_setting('app.tenant_id', true)          -> ''
                       current_setting('app.tenant_id', true)::uuid
                       ERROR:  invalid input syntax for type uuid: "" (SQLSTATE 22P02)
```

So a pooled connection is **poisoned by its first tenant-scoped request**.
Every later query on that connection whose policy casts the setting fails —
including the tenant-free ones. `GetMe` reads `tenants` and `memberships`,
so it is the first thing to break.

Why it looks like a haunting rather than a bug:

- It never reproduces on a fresh process, because no connection is poisoned yet.
- It is intermittent and load-dependent: whether a given call fails depends on
  which pooled connection it draws.
- It gets monotonically worse, because every tenant-scoped request poisons one
  more connection, until effectively all of them are.
- A restart "fixes" it by discarding the pool.

**The fix is one line per policy**, and it is a migration against existing
tables, so it is the founder's call:

```sql
USING (tenant_id = NULLIF(current_setting('app.tenant_id', true), '')::uuid)
```

`app.user_id` in 000004 and 000005 has the identical shape and needs the
same treatment.

Note that `make verify` is green with this bug present: the dbtest harness
opens a fresh connection per test, which is exactly the condition under
which the bug cannot occur. A regression test has to reuse one connection
across two transactions.

## Also fixed: errors that masqueraded as authentication failures

`repo.ByFirebaseUID` mapped *every* error to `core.ErrNotFound`, which
`authInterceptor` turns into a bare `unauthenticated`. A database fault
therefore told the user "sign in again" and logged nothing at all.

Only `pgx.ErrNoRows` now means "no account"; anything else is wrapped so
`errorMappingInterceptor` maps it to `internal` **and** writes the cause to
the log. The GUC bug above was found in minutes once that was true, having
been invisible before.

Separately, `make contract-live` restarts the api after migrating: rolling
migrations down and up recreates tables, and pooled connections keep cached
statement plans for the old ones.

## Known: `buf breaking` fails against master until this lands

`make contract` currently reports:

```
File option "go_package" changed from "" to "...;corev1"   (x5)
```

This is real and expected exactly once. buf's `FILE` category includes
`FILE_SAME_GO_PACKAGE`, so setting an option that was previously absent
counts as a change. It breaks no shipped client: without `go_package`,
`make proto` failed outright, so no Go client could ever have been
generated. Once these protos are on `master`, the baseline contains the
option and the check goes quiet.

**No buf exclusion was added to silence it.** `proto/AGENTS.md` says a
`buf breaking` failure means you would break a shipped client; an ignore
rule here would make that sentence untrue for every future change to these
files.

Note also that `make contract` previously ended in
`|| echo "(no main branch yet — skipping)"`, which reported *every* buf
failure — including genuine breaking changes — as a skip. It now skips only
when the baseline branch does not exist, and fails otherwise. These
`go_package` findings are the first output that gate has ever produced.
