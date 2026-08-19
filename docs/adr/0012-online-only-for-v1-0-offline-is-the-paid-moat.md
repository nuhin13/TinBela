# ADR-0012 — Online-only for v1.0; offline is the paid moat

**Status:** Accepted
**Date:** 2026-08-19

**Context.** Offline is the strongest differentiator against incumbents, who are all
architecturally cloud-first. It is also four to five weeks of work.

**Decision.** v1.0 is online-only with cached reads and queued writes for brief blips. Full
local-first with Drift lands in P6, gated by entitlement per purchased period.

**Consequences.** The MVP halves in size. Free users are never at risk of data loss because the
server is always the source of truth. When entitlement lapses, the app falls back to online mode
and never locks anyone out of their own data. The append-only design (ADR-0005) is what makes P6
tractable when it arrives.

**Revisit when.** P6.
