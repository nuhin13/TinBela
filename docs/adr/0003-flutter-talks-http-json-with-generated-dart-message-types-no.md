# ADR-0003 — Flutter talks HTTP/JSON with generated Dart message types, not a Connect Dart client

**Status:** Accepted
**Date:** 2026-08-19

**Context.** Connect's Go and TypeScript tooling is mature. The Dart side is considerably less so,
and the MVP cannot absorb a dependency risk on the critical path.

**Decision.** Generate Dart protobuf message types with `protoc-gen-dart` and call Connect's
JSON codec over plain HTTP from Flutter.

**Consequences.** Type-safe models shared with the contract, minimal dependency surface, ordinary
debuggable HTTP. Cost: a thin hand-written transport layer in Dart (~100 lines) instead of a
generated client.

**Revisit when.** Connect Dart tooling matures, or P6 offline sync makes streaming worthwhile.
