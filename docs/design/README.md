# Design

The prototype is **approved and complete**. Do not redesign during the MVP —
every hour in a design tool is an hour not shipping.

| File | Contents |
|---|---|
| `../product/UI_SPEC.md` | Screen inventory, navigation map, the three critical screens, component library, UX laws, per-phase UI |
| `../../packages/design-tokens/tokens.json` | The source of truth for colour, type, space, radius |

## Generated outputs — never edit these

```
apps/manager/lib/core/theme/tokens.g.dart
packages/design-tokens/tailwind.tokens.js
packages/design-tokens/tokens.css
```

Run `make tokens` after changing `tokens.json`.

## The three screens that decide the product

1. **আজ / Today** — the cutoff card, two buttons, and the empty-day success
   state. A day with zero exceptions must look *finished*.
2. **The exception sheet** — 2 taps, under 10 seconds, measured.
3. **The math sheet** — every number tappable, rendered from the API's
   `MathExplain`, never recomputed on the client.

Everything else is competent CRUD. These three carry the differentiation.
