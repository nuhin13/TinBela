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

Firebase verification is Epic 04 task 04.1. Until then `NewDevVerifier`
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

## GATE STATUS — partially met

Epic 03's gate is *"a generated TypeScript client and a generated Dart model
both round-trip a real call against the running binary."*

- **Go** — met. `internal/transport/contract_test.go` drives the generated
  Connect client over real HTTP through the whole chain, against a real
  database with RLS forced. Run by `make contract`.
- **TypeScript** — **not done.** The client generates
  (`packages/api-clients/gen`), but there is no `package.json`, no test
  runner, and nothing in `make verify` that would execute it.
- **Dart** — **blocked.** The models generate
  (`apps/manager/lib/core/api/gen`), but Flutter is not installable here:
  mise's `flutter@stable` 404s, and `apps/manager` has no `pubspec.yaml`
  until Epic 08 task 08.1.

So the epic's own gate does **not** pass yet. Two thirds of it is waiting on
a toolchain, not on the transport layer.

## Open observation

During manual burst testing, a running instance began returning `internal`
for every `GetMe` and kept doing so until restarted; the same burst against
a fresh process has not reproduced it (36/24 split, zero internal errors).
No root cause established. The plausible candidates are a leaked transaction
or a stale process from the test loop. Worth watching under Epic 18's load
work rather than assuming it was a one-off.

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
