# ADR-0010 — Entitlements as an interface from day one, with no billing code

**Status:** Accepted
**Date:** 2026-08-19

**Context.** Offline sync will be paid, gated by purchased *periods* rather than a subscription,
and the billing module itself will be generic across Droid Builder products and built later.

**Decision.** Ship `Entitlements.Has(ctx, tenantID, feature string, on time.Time) (bool, error)` in
v1.0, implemented as `alwaysAllow{}`. Every gated feature calls it. No billing code exists in the
repo.

**Consequences.** Zero billing complexity in the MVP and zero refactoring when the real module
arrives. The `on time.Time` parameter is the important detail: purchasing a specific month means
entitlement is a question about a date, not a boolean on an account. Getting that signature right
now costs nothing and avoids rewriting every call site in P5.

**Revisit when.** P5 implements the module behind the same interface.
