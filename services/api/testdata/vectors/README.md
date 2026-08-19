# Golden vectors ★ HAND-OWNED

Language-neutral test cases for the meal + settlement engine.

**Why these exist:** in P6 the engine is reimplemented in Dart for on-device
offline computation. The Go engine runs these files in CI today; the Dart
engine will run *the same files*. That is the only practical guarantee that
on-device math equals server math — and if they ever disagree, a mess sees
two different numbers, which destroys the exact thing TinBela sells.

**Rules**
- Keep the schema language-neutral. No Go types, no Dart types, no enums
  that only one language understands.
- An agent may propose new vectors as a diff. Only a human commits them.
- **Every fixed bug becomes a new vector.** That is how this set earns its
  keep over time.

**Target: 30–50 vectors** (Epic 02, task 02.6), covering at minimum:

- [ ] simple month, no exceptions            (Law 1 — the common case)
- [ ] single-day OFF
- [ ] range OFF across a month boundary
- [ ] GUEST added on the same slot as an OFF
- [ ] SET_QTY then OFF then ON, same day
- [ ] exception created then voided
- [ ] void of a void (should be rejected upstream, engine must not crash)
- [ ] member joins mid-period
- [ ] member leaves mid-period
- [ ] member joins AND leaves within one period
- [ ] OFF_DAY flag zeroing every slot
- [ ] zero total meals (division guard — rate must be 0, not a panic)
- [ ] rate with a non-zero remainder (the ৳3 case)
- [ ] single member, single slot
- [ ] 500 members (performance + correctness at scale)
- [ ] all deposits voided
- [ ] deposits exceeding food cost (positive balance for everyone)
