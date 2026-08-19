# ADR-0011 — Institution schema hedges land in v1.0, unused

**Status:** Accepted
**Date:** 2026-08-19

**Context.** Institution mode (P3) needs a group hierarchy, fixed-fee billing, and fee categories.
By then there will be live ledger data, and migrating live financial tables is expensive and risky.

**Decision.** Create `groups`, `memberships.group_id`, `tenants.billing_mode`, and
`memberships.fee_category` in the v1.0 schema. Accept an optional `group_id` on the bulk-exception
endpoint. Expose none of it in the v1.0 UI.

**Consequences.** P3 becomes additive rather than a migration of production data. Cost: four
unused columns and one unused table — free. Documented as "P3, do not expose" so no agent surfaces
them early.

**Revisit when.** P3 activates them.
