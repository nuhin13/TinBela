# ADR-0015 — Single repository, all services, docs, and harness together

**Status:** Accepted
**Date:** 2026-08-19

**Context.** Four deliverables (Go API, Flutter app, two Next.js apps), shared contracts, shared
tokens, and one engineer.

**Decision.** One repository containing `proto/`, `services/`, `apps/`, `packages/`, `docs/`,
`harness/`, and `.claude/`.

**Consequences.** Atomic commits across a contract change and all its consumers — which is the
single biggest practical advantage at this size. One CI pipeline. Agents have full context in one
place, which measurably improves their output. Documentation and ADRs live beside the code they
describe, so they stay current. Cost: the CI must be path-filtered so a Flutter change does not
rebuild everything.

**Revisit when.** A product outgrows the shared pipeline, or a team boundary requires separate
access control. Not before multiple products ship.
