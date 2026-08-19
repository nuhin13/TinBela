---
name: adr-writer
description: How to write a TinBela architecture decision record. Load when recording any structural decision.
---

# ADR Writer

## When an ADR is required
- Adding or removing a deployed component (gateway, queue, cache, service)
- Changing a data model invariant
- Choosing or replacing a library that is hard to reverse
- Changing a boundary between packages
- Any decision a future reader would otherwise ask "why on earth" about

## When it is not
Renaming a variable. Adding a screen. Fixing a bug.

## Format

```markdown
# ADR-nnnn — <short imperative title>

**Status:** Proposed | Accepted | Superseded by ADR-mmmm
**Date:** YYYY-MM-DD

## Context
What forces are at play? What is true today that makes this a decision
rather than an obvious choice?

## Decision
What we are doing. Present tense, specific.

## Consequences
What becomes easier. What becomes harder. What it costs.
Be honest about the downside — an ADR with no downside is usually not
recording a real decision.

## Revisit when
The concrete trigger that should make a future reader reopen this.
```

## Quality bar
The **Revisit when** section is what separates a useful ADR from
documentation theatre. "Revisit when we have three or more deployed
services" is useful. "Revisit if needed" is not.

Number sequentially. Never delete an ADR — supersede it and link both ways.
