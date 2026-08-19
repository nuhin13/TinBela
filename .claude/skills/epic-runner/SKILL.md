---
name: epic-runner
description: The session protocol for executing one task from the TinBela epic backlog. Load at the start of every /task run.
---

# Epic Runner Protocol

## For every task

1. **Locate.** Read `docs/product/EPICS.md`, find the task ID. Note its
   epic, Done-when, and Owner.
2. **Check the Owner column.** If it is marked with a star, **STOP**. That
   task is hand-written by the founder. Offer to scaffold tests only.
3. **Check dependencies.** Read the epic's Depends-on. If unmet, stop and
   say which epic must land first.
4. **Load skills** named for your agent role.
5. **State a plan** in 3–6 bullets. Wait for approval if the plan touches
   proto, the engine, or a migration against an existing table.
6. **Test first** when the task touches money or the engine.
7. **Implement** the smallest change that satisfies Done-when. Not the
   most complete change — the smallest one.
8. **Run `make verify`.** If red, fix before reporting.
9. **Report** in this exact shape:

```
Changed:            files and why
NOT done:           anything in the task deliberately skipped
Needs human review: judgement calls made
Next task:          id only
```

## Anti-patterns to avoid

- Building the next task too because it "made sense while I was in there".
- Adding a feature the task did not ask for because it seemed obviously
  useful. If it is not in BRD section 7.1, propose it as a P2 item.
- Refactoring adjacent code. Note it instead; the founder decides.
- Reporting done without running `make verify`.
