# Smoke test (Epic 18, task 18.1)

The end-to-end scenario that must always work:

```
create mess
  → add 7 members
  → set patterns (all slots ON by default)
  → mark 3 exceptions (one OFF, one GUEST, one range)
  → add bazar entries
  → add deposits
  → read accounts, assert the conservation invariant
  → preview close
  → close period
  → read the statement, assert it matches the preview exactly
  → re-read the statement, assert it is unchanged
```

Run: `make smoke`

This is the test that tells you the product still works after a day of agent
changes. Run it every evening.
