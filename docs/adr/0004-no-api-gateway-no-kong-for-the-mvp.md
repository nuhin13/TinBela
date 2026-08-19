# ADR-0004 — No API gateway (no Kong) for the MVP

**Status:** Accepted
**Date:** 2026-08-19

**Context.** Kong, Traefik, and similar gateways offer routing, auth offload, rate limiting,
quotas, and plugins. The question is whether those are worth an additional deployed component now.

**Decision.** Caddy in front of the single Go binary for TLS, compression, and reverse proxy.
Rate limiting, auth, CORS, request IDs, and timeouts live in Go middleware.

**Consequences.** One less component to deploy, configure, secure, and debug. Middleware is
testable in the same test suite as the handlers. Cost: no centralised policy layer — which matters
only when there are multiple services or external API consumers, and there are neither.

**Revisit when.** Any of: three or more deployed services; external API consumers needing API keys
or quotas; cross-product rate limiting or WAF at the edge; a second product sharing auth. At that
point put Kong (or Traefik) at the edge and let internal traffic be gRPC on a private network —
the proto contracts from ADR-0002 make that a configuration change, not a rewrite.
