# Design

**Where each kind of UI information belongs.** Put it in the wrong place and
an agent will not find it.

```
docs/design/
  README.md          ← you are here: the map
  prototype.html     ← ★ THE APPROVED PROTOTYPE. Drop your file here.
  SCREENS.md         ← traceability: every prototype screen → v1.0 or a phase
  screens/           ← optional PNG exports, one per screen
docs/product/
  UI_SPEC.md         ← the written spec: navigation, layouts, UX laws
packages/design-tokens/
  tokens.json        ← colour, type, space, radius. The only source.
```

---

## The four layers, and what goes in each

| Layer | File | Contains | Who reads it |
|---|---|---|---|
| **1. Truth** | `prototype.html` | The actual approved design, openable in a browser | You, and any agent building a screen |
| **2. Spec** | `../product/UI_SPEC.md` | Navigation map, the three critical screens, component list, the ten UX laws | Every client task |
| **3. Trace** | `SCREENS.md` | Which prototype screen ships in v1.0, which is deferred, and where each is implemented | You, when deciding scope |
| **4. Tokens** | `../../packages/design-tokens/tokens.json` | Colour, type, space, radius, touch | `make tokens` → Dart, Tailwind, CSS |

**Why the prototype must live in the repo:** without it, the design exists
only as prose in `UI_SPEC.md` — which is a paraphrase. When an agent builds
the exception sheet and the spec is ambiguous about spacing or state, it
should open the real thing, not guess from a description.

---

## Rules

- **`prototype.html` is read-only history.** Never edit it to match the code.
  If the design changes, export a new prototype and bump the filename
  (`prototype-v2.html`), keeping the old one. You will want to see what
  changed.
- **`SCREENS.md` is the scope contract.** Every deferral is recorded there
  with its phase. If a screen is not in that table, nobody decided about it.
- **Never hardcode a colour anywhere.** `make verify` fails on it. Change
  `tokens.json` and regenerate.
- **The design is done for v1.0.** Do not reopen it during the MVP — every
  hour in a design tool is an hour not shipping. Changes go to P2.

---

## Adding screenshots (optional but useful)

If you export PNGs from the prototype, name them by screen so an agent can
find the right one:

```
docs/design/screens/
  01-onboarding.png
  02-today.png          ← the most important screen in the product
  03-exception-sheet.png
  04-khata-grid.png
  05-accounts.png
  06-member-statement.png
  07-month-close.png
  08-settings.png
  m1-member-today.png
  m2-member-hisab.png
```

Reference them from `SCREENS.md` so the trace table links design → spec →
code in one place.
