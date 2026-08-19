# SCREENS — prototype traceability

**Purpose:** every screen, sheet, and component in `prototype.html` mapped to
its fate. If something is not in this table, nobody decided about it.

> ⚠ **STATUS: NEEDS VERIFICATION.** This table was reconstructed from the
> first analysis of the prototype, not from the file itself. Open
> `prototype.html` and walk it screen by screen. Correct any row that is
> wrong, and add any screen missing from the list. **Until you have done
> that, treat this as a draft, not a contract.**

Legend: **v1.0** ships in the MVP · **P2/P3/P5** deferred to that phase ·
★ carries the differentiation, never cut

---

## Manager app

| # | Prototype screen | Fate | Epic / task | Code path |
|---|---|---|---|---|
| 1 | Splash + language picker | v1.0 | 09.1 | `features/onboarding/` |
| 2 | Sign-in | v1.0 | 09.2 | `features/onboarding/` |
| 3 | Mess setup (3 questions) | v1.0 | 09.3 ★ | `features/onboarding/` |
| 4 | "How TinBela works" card | v1.0 | 09.4 | `features/onboarding/` |
| 5 | Invite link + share | v1.0 | 09.5 | `features/onboarding/` |
| 6 | **আজ / Today** | v1.0 | 10.1–10.3 ★ | `features/today/` |
| 7 | **Exception sheet** | v1.0 | 10.4 ★ | `features/today/` |
| 8 | Range picker ("কয়েকদিন") | v1.0 | 10.5 | `features/today/` |
| 9 | **খাতা / Khata grid** | v1.0 | 10.9 | `features/grid/` |
| 10 | +বাজার sheet | v1.0 | 11.1 | `features/accounts/` |
| 11 | +জমা sheet | v1.0 | 11.2 | `features/accounts/` |
| 12 | **হিসাব / Accounts** | v1.0 | 11.3 | `features/accounts/` |
| 13 | **Math sheet** | v1.0 | 11.4 ★ | `core/widgets/math_sheet.dart` |
| 14 | Member statement | v1.0 | 11.5 | `features/accounts/` |
| 15 | Month-close wizard | v1.0 | 12.1–12.3 | `features/close/` |
| 16 | Statement + share image | v1.0 | 12.4–12.5 | `features/close/` |
| 17 | Members list + add | v1.0 | 13.1–13.2 | `features/members/` |
| 18 | Settings / আরও | v1.0 | 13.5–13.10 | `features/settings/` |
| — | | | | |
| 19 | Manager handover | **P2** | — | v1.1 |
| 20 | Photo receipt on expense | **P2** | — | v1.1 |
| 21 | PDF export | **P2** | — | v1.1 |
| 22 | FEAST / good-food-day flag | **P2** | — | v1.1 |
| 23 | Rent / utility shared pool | **P2** | — | v1.1 |
| 24 | Bazar duty rota | **P2** | — | v1.1 |
| 25 | Maid / cook module | **P3** | — | v2.2 ops |
| 26 | Rooms & seats | **P3** | — | v2.2 ops |
| 27 | Cleaning rota | **P3** | — | v2.2 ops |
| 28 | Day-pass gate (watch 2 ads) | **P5** | — | needs entitlements |
| 29 | Month-purchase calendar | **P5** | — | needs entitlements |
| 30 | Payment-link preview (bKash) | **P5** | — | needs entitlements |
| 31 | Ad banner slots | **P5** | — | your own instruction: ads later |

## Member PWA

| # | Prototype screen | Fate | Epic / task | Code path |
|---|---|---|---|---|
| M1 | আজ / কাল + 1-tap off/guest | v1.0 | 14.2–14.3 ★ | `apps/web/app/m/[token]/` |
| M2 | আমার হিসাব | v1.0 | 14.4 | `apps/web/app/m/[token]/` |
| M3 | গ্রুপ / group view | **P2** | — | third tab, v1.1 |

---

## The deferrals most worth arguing about

Three cuts where reasonable people disagree. If any feels wrong, say so and
the epic list gets re-cut.

**Group view (M3).** Cut to get the member PWA to two screens and hold the
<500KB budget. The counter-argument is real: members want to see the whole
mess, not just themselves, and seeing everyone's numbers is part of what
makes the app feel fair. It is roughly one day of work.

**Day-pass gate (28).** Cut because it needs the entitlements module, which
is P5. Nothing about it can ship earlier without building billing — and
billing on zero users returns zero either way.

**Khata grid (9).** In v1.0, but it is first on the cut list if a day slips.
Worth knowing: it is the risk-R2 mitigation for managers who think in
notebook rows. Cutting it saves a day and costs you the khata-minded
segment for two weeks.

---

## How to verify this table

```
1. Open docs/design/prototype.html in a browser.
2. Walk every screen and every sheet, in order.
3. For each: find its row here. If there is no row, ADD ONE.
4. For each row marked v1.0: confirm the epic task actually covers it.
5. For each deferral: confirm you agree with the phase.
6. Commit with: "00.7: verify prototype traceability"
```

Step 3 is the one that matters. A screen you designed but never recorded a
decision about is the most likely thing to surface as a surprise in week two.
