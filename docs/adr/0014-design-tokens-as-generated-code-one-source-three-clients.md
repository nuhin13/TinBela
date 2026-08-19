# ADR-0014 — Design tokens as generated code, one source, three clients

**Status:** Accepted
**Date:** 2026-08-19

**Context.** Flutter, the member PWA, and the admin portal must look like one product. Manually
kept-in-sync colour constants diverge within weeks.

**Decision.** `packages/design-tokens/tokens.json` is the source. `make tokens` generates a Dart
theme, a Tailwind config, and CSS custom properties. Hardcoded colours are blocked by a check in
`make verify`.

**Consequences.** One change propagates everywhere. Agents cannot invent a shade of green. Cost: a
small generation step in the build.

**Revisit when.** Never.
