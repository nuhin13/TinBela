# ADR-0006 — Derived values are never stored

**Status:** Accepted
**Date:** 2026-08-19

**Context.** Every competitor stores a row per member per slot per day. That design is why their
managers type ~24 records a day.

**Decision.** Daily meal counts are materialized on read from patterns ⊕ exceptions ⊕ day_flags.
The only persisted snapshot is `period_statements`, written once at close and immutable thereafter.

**Consequences.** A normal day costs zero writes — this is the entire product wedge expressed as a
data decision. No possibility of stored counts drifting from their inputs. Cost: materialization
runs on every read; benchmarked at <50ms for 500 members × 31 days × 3 slots, with caching
available if needed.

**Revisit when.** Materialization exceeds 200ms p95 at real scale. The fix is a cache with the
inputs' hash as key, not stored counts.
