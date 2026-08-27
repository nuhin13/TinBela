# AGENTS.md — Admin portal (Next.js)

Read the root `AGENTS.md` first. This is the operator's window into
production (Epic 16), and its debugger during the build.

## The one rule

**READ-ONLY on customer data. No mutation path may exist that touches a mess.**

This is not just a code convention — it is enforced beneath the app by the
database. The admin API reads through the `tinbela_admin` role (ADR-0016):
`BYPASSRLS` so it sees every mess, `SELECT`-only on customer tables so even a
bug cannot write one. The only writes the whole surface can make are feature
flags and its own audit log.

The single write in this app is the feature-flag toggle (`app/flags/`). If you
find yourself adding another write against mess data, stop — it belongs in the
member-facing services under tenant scope, not here.

## Auth

- The API gates the surface: staff Firebase uid (`STAFF_UIDS`) + IP allow-list.
  A valid manager token is refused (task 16.1). Non-staff gets 403.
- This portal holds a staff credential server-side (`ADMIN_API_STAFF_TOKEN`)
  and forwards it. The token never reaches the browser — keep every API call in
  a server component or server action. Portal-level SSO is a later hardening
  step.

## Conventions

- Server components fetch; `lib/api.ts` is the only place that talks to the API.
- Operator chrome is English; mess data is Bangla, so the Bangla font is still
  loaded.
- Colours and spacing come from `packages/design-tokens` via Tailwind
  (`make tokens`). Never a hex literal.
- `GetTenant` — the read-only tenant inspector (task 16.4) — is founder-owned
  (★). The route (`app/tenants/[id]`) is a placeholder until it lands.

## Env

```
ADMIN_API_URL            the API origin (default http://localhost:8080)
ADMIN_API_STAFF_TOKEN    the staff bearer (dev: `dev:<uid>`)
```
