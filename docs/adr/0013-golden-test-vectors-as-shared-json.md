# ADR-0013 — Golden test vectors as shared JSON

**Status:** Accepted
**Date:** 2026-08-19

**Context.** In P6 the settlement engine is reimplemented in Dart for on-device computation. If the
Go and Dart engines ever disagree, a mess sees two different numbers — which destroys the exact
thing being sold.

**Decision.** 30–50 golden vectors in `testdata/vectors/*.json`, containing inputs and expected
outputs in a language-neutral schema. The Go engine runs them in CI from Day 2. The Dart engine
runs the *same files* in P6.

**Consequences.** Cross-language correctness is proven mechanically rather than assumed. Vectors
also serve as executable documentation of every ugly edge case. Cost: an afternoon on Day 2 and
discipline in keeping vectors free of language-specific types.

**Revisit when.** Never. Extend the set whenever a bug is found — every fixed bug becomes a vector.
