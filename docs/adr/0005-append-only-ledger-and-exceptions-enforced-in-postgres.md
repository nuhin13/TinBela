# ADR-0005 — Append-only ledger and exceptions, enforced in Postgres

**Status:** Accepted
**Date:** 2026-08-19

**Context.** Trust is the actual product. Managers rotate, disputes happen, and a mess that cannot
audit its own history has no reason to prefer software over a notebook. Additionally, P6 offline
sync needs conflict-free merges.

**Decision.** `ledger_entries`, `meal_exceptions`, and `period_statements` are append-only.
Corrections INSERT a row with `void_of` set. Enforced by Postgres rules, not only by application
code.

**Consequences.** Full audit trail for free. Offline merges become conflict-free by construction
because nothing is ever updated — this is the architectural reason P6 is achievable at all. Every
read must resolve voids, and the tables grow monotonically. Both are acceptable at this data volume.

**Revisit when.** Table size becomes a real problem. Mitigation is archival of closed periods, not
mutation.
