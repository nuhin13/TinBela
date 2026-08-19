---
description: Full verification, smoke test, version bump, changelog, release build
---

Use the `devops` agent.

1. `make verify` — must be fully green. Stop if not.
2. `make smoke` against the dev environment.
3. Confirm the Epic 18 hardening checklist in `docs/product/EPICS.md` is
   complete. Stop if not.
4. Bump the version, generate the changelog from commit messages since the
   last tag.
5. Build the signed release AAB.
6. Print the Epic 19 pre-publish checklist for me to walk manually — store
   listing, data safety form, permissions audit, rollback plan.

Never publish. Building is yours; publishing is mine.
