---
description: Run one epic task end to end using the correct agent and skills
argument-hint: <task-id, e.g. 05.3>
---

Task ID: **$1**

1. Read `docs/product/EPICS.md` and locate task $1.
2. Identify the epic, its Depends-on, the task's Done-when and Owner.
3. **If the Owner column is marked with a star, STOP.** Tell me this task is
   hand-written and must not be delegated. Offer to write the test scaffold
   only.
4. Otherwise delegate to the agent named in the Owner column. That agent
   loads its skills and follows the `epic-runner` protocol.
5. Finish by running `make verify` and reporting in the required shape.
