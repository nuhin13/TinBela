# ADR-0001 — Modular monolith, not microservices

**Status:** Accepted
**Date:** 2026-08-19

**Context.** Droid Builder is a multi-product company and TinBela is the first product. The
instinct is to start with separate services so the platform "scales." The reality is one engineer,
a 14-day MVP, and zero users.

**Decision.** One Go binary. Domain boundaries expressed as `internal/` packages with explicit
interfaces: `core`, `meals`, `money`, `periods`, `invites`, `entitlements`, `telemetry`,
`transport`.

**Consequences.** One thing to deploy, debug, and trace. Local development is a single process.
Cross-domain calls are function calls, so refactoring boundaries stays cheap while you are still
learning the domain. Cost: no independent scaling or deploy per domain — irrelevant at this size.

**Revisit when.** A single domain needs independent scaling or an independent deploy cadence, or a
second engineer needs an independent ownership boundary. Realistically Phase 5+.
