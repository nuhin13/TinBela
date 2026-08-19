# Vector format

```jsonc
{
  "name": "range_off_with_guest",
  "description": "Human-readable statement of what this proves.",
  "range": { "from": "2026-07-01", "to": "2026-07-31" },

  "input": {
    "memberships": [
      { "id": "m1", "joined_at": "2026-07-01", "left_at": null }
    ],
    "slots": [
      { "id": "s1", "order": 1, "active": true }
    ],
    "patterns": [
      { "membership_id": "m1", "slot_id": "s1",
        "dow_mask": 127, "qty": 1, "effective_from": "2026-07-01" }
    ],
    "day_flags": [],
    "exceptions": [
      { "id": "e1", "membership_id": "m1", "slot_id": "s1",
        "date_from": "2026-07-09", "date_to": "2026-07-11",
        "action": "OFF", "qty": null, "void_of": null,
        "created_at": "2026-07-08T08:12:00+06:00" }
    ],
    "ledger": [
      { "id": "l1", "kind": "FOOD_COST", "amount_paisa": 1240000,
        "membership_id": null, "occurred_on": "2026-07-15", "void_of": null }
    ]
  },

  "expect": {
    "cells": { "m1|s1|2026-07-09": 0, "m1|s1|2026-07-12": 1 },
    "settlement": {
      "total_meals": 28,
      "food_paisa": 1240000,
      "meal_rate_paisa": 44285,
      "remainder_paisa": 20,
      "members": [
        { "membership_id": "m1", "meals_qty": 28,
          "food_cost_paisa": 1239980, "deposits_paisa": 0,
          "balance_paisa": -1239980 }
      ]
    }
  }
}
```

## Notes

- **Money is integer paisa.** `1240000` is ৳12,400.00.
- **Cell keys** are `membership_id|slot_id|YYYY-MM-DD`.
- `dow_mask` bit 0 = Saturday (Bangladesh week starts Saturday).
- `created_at` on exceptions is used **only** for ordering when two
  exceptions touch the same cell. It is never a date boundary.
- `remainder_paisa` must always satisfy:
  `sum(member.food_cost_paisa) + remainder_paisa == food_paisa`
