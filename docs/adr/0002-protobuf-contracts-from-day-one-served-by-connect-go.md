# ADR-0002 — Protobuf contracts from day one, served by Connect-Go

**Status:** Accepted
**Date:** 2026-08-19

**Context.** Four consumers of the API (Flutter, member PWA, admin portal, future services) and
one engineer. Hand-written clients across four codebases is where solo projects accumulate silent
bugs, and it is a category of error agents produce constantly.

**Decision.** Define all API surface in protobuf under `/proto`, managed by `buf`. Serve with
Connect-Go, which exposes gRPC, gRPC-Web, and HTTP/JSON on the same handler. Generate: Go server,
TypeScript clients (web + admin), Dart message types.

**Consequences.** One source of truth for the contract. `buf breaking` in CI prevents an agent from
silently altering the API — a meaningful safety property for agentic development. Browsers speak
JSON with no proxy. When a package later becomes its own binary, the contract already exists and
the boundary becomes a network hop with no client change. Cost: ~half a day of buf tooling on Day 1
and slightly less agent familiarity than plain chi.

**Revisit when.** Never expected. If buf tooling proves painful on Day 1, the fallback is chi +
OpenAPI and the epic structure is unchanged.
