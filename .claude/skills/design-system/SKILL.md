---
name: design-system
description: TinBela design tokens, component inventory, and the ten UX laws. Load for any client task (Flutter, member PWA, landing, admin).
---

# TinBela Design System

Full detail in `docs/product/UI_SPEC.md`. This is the enforcement summary.

## Tokens — never hardcode, always import from generated theme

```
PRIMARY GREEN   #1B7A4E   brand · primary action · positive balance
ACCENT YELLOW   #E39312   secondary action (+বাজার / +জমা)
ALERT RED       #C0392B   debt · meal-off · cutoff passed
SURFACE         #FAF6EF   warm off-white page background
CARD            #FFFFFF
INK             #1A1A1A   primary text
INK MUTED       #6B6B6B
TINT            #E8F3ED   light green fill · selected state
DIVIDER         #E8E2D8

TYPE    Hind Siliguri (bn) · system (en)
RADIUS  16 card · 12 button · 8 chip
SPACE   4 · 8 · 12 · 16 · 24 · 32
TOUCH   minimum 48x48dp
SHADOW  one elevation only: 0 1 4 rgba(0,0,0,.08)
```

The warm surface was chosen for **sunlight glare**, not taste. Do not
"modernise" it to pure white.

## The ten UX laws

1. Manager home = one glance: cutoff card + two buttons. Nothing above it.
2. <=2 taps for any daily action. <=3 for any monthly action.
3. Member PWA <500KB shell, <3s on 3G.
4. Bangla-first. Numerals toggle. Thumb-zone bottom nav.
5. Empty states teach. **A zero-exception day must look FINISHED.**
6. Every money number is tappable and shows its math.
7. Every destructive action is a void, never a delete — and the UI says so.
8. No spinner without a skeleton. No error without a retry button.
9. Confirmation is a toast. Dialogs only for irreversible actions.
10. Release gate: a 4-person mess sees ONE screen and understands its month.

## Components — build once, reuse

`CutoffCard` · `MoneyText` · `SlotChipRow` · `ActionPillRow` · `MemberRow` ·
`ExceptionListItem` · `EmptyState` · `MathSheet` · `AmountInput` ·
`DateRangeChip` · `StatementCard` · `VoidBanner`

**`MoneyText` is the most important component in the codebase.** If every
number routes through it, the numeral toggle, tabular figures, and tappable
math all come free and stay consistent. If numbers get formatted ad hoc in
screens, all three decay within a month.

## Field conditions these serve

Sunlight · one-handed use · 4-year-old mid-range Android at 60fps · bad mess
wifi · Bangla script overflow at 130% text scale.
