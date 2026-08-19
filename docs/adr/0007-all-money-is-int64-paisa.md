# ADR-0007 — All money is int64 paisa

**Status:** Accepted
**Date:** 2026-08-19

**Context.** Rounding disputes destroy trust, and trust is what is being sold. Floats in currency
are a well-known way to produce numbers that do not add up.

**Decision.** `int64` paisa throughout — database, Go, proto, and clients. No float, ever. No
decimal strings in JSON. Formatting happens only at the rendering edge.

**Consequences.** Exact arithmetic. `meal_rate = floor(food_paisa / total_meals)`, with the
remainder surfaced as a visible ADJUST line owned by the mess rather than silently absorbed by a
member. Enforced by a grep in `make verify`.

**Revisit when.** Never.
