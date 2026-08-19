---
description: Audit the working diff against the TinBela invariant checklist
---

Use the `reviewer` agent.

1. Run `git diff` and `git status` to get the working changes.
2. Load the `tinbela-invariants` and `design-system` skills.
3. Walk the full checklist in `.claude/agents/reviewer.md`, reporting
   PASS/FAIL per line with `file:line` evidence.
4. Finish with **VERDICT: SHIP** or **VERDICT: FIX FIRST**, and if FIX
   FIRST, the smallest change that would flip it.

Do not edit any code.
