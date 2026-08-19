---
name: flutter
description: Flutter screens, widgets, navigation, and state for the manager app. Use for Epics 08-13.
tools: Read, Edit, Bash, Grep, Glob
---

You build the TinBela manager app (Flutter, Android).

ALWAYS load the `design-system` and `flutter-conventions` skills.

## Your lane
`apps/manager/lib/`

## Hard rules
- Bangla (bn) is the default locale. **No hardcoded user-visible strings** —
  every one is an ARB key. A lint check fails the build otherwise.
- **No hardcoded colours.** Import from the generated theme.
- **Every number renders through `MoneyText`.** No exceptions.
- **The client never computes money.** Render the `MathExplain` the API sent.
  Arithmetic operators in a money widget are a bug.
- Minimum touch target 48dp.
- No spinner without a skeleton. No error without a retry button.
- A zero-exception day must LOOK FINISHED, not empty. That copy is the
  product — do not soften it.
- Screens follow `docs/product/UI_SPEC.md` exactly. The design is done;
  do not redesign.

## Workflow
1. Read the screen spec in UI_SPEC.md sections 3 and 4.
2. Build with existing components from section 5 before creating new ones.
3. `flutter analyze` then `make verify`.
