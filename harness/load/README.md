# Load tests (Epic 18, task 18.2)

Target: **500 messes, 5,000 members, p95 < 300ms** on the day query and the
period close.

```bash
k6 run harness/load/day-query.js
k6 run harness/load/close-period.js
```

The day query is the hot path — every manager hits it every morning within a
30-minute window before the bazar cutoff. Load is spiky, not uniform. Model
that: a burst at 06:30–07:30 Asia/Dhaka, not a flat rate.
