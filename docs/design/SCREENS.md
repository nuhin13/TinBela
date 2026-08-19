# SCREENS — prototype traceability

**Purpose:** every screen, sheet, and component in `prototype.html` mapped to
its fate. If something is not in this table, nobody decided about it.

> ✅ **STATUS: VERIFIED** against `prototype.html` (canvas frames 1a–1c, 2/2a/2b,
> 3/3a/3b). Rows marked ⚠ are where the prototype and a settled decision
> disagree — build the "v1.0 behaviour" column, not the drawing.

Legend: **v1.0** ships in the MVP · **P2/P3/P5** deferred to that phase ·
★ carries the differentiation, never cut · ⚠ prototype is superseded

---

## Manager app

| # | Prototype screen | Fate | Epic / task | Code path |
|---|---|---|---|---|
| 1 | Splash / welcome (৳ brand, "শুরু করুন") | v1.0 | 09.1 | `features/onboarding/` |
| 2 | ⚠ Phone entry + OTP (2 screens, Bangla keypad, resend timer) | **CUT** | 09.2 | superseded by ADR-0009 — build **Google Sign-In**, one tap, phone collected later as a profile field |
| 3 | Mess setup (3 questions: name · ধরন · কয় বেলা) | v1.0 | 09.3 ★ | `features/onboarding/` |
| 4 | "তিনবেলা যেভাবে কাজ করে" explainer card | v1.0 | 09.4 | `features/onboarding/` |
| 5 | Mess created 🎉 + invite link + copy / WhatsApp / Messenger | v1.0 | 09.5 | `features/onboarding/` |
| 6 | "সদস্য না থাকলেও চলবে" solo-manager line | v1.0 | 09.6 ★ | `features/onboarding/` |
| 7 | Demo-mess banner ("👋 এটি একটি ডেমো মেস" → "নিজের মেস খুলুন") | v1.0 | 09.7 | `features/today/` |
| 8 | **আজ / Today** — cutoff card, rate chip, exception feed | v1.0 | 10.1–10.3 ★ | `features/today/` |
| 9 | Zero-exception state ("আজ কোনো পরিবর্তন নেই · কিছু করার নেই ✓") | v1.0 | 10.3 ★ | `features/today/` |
| 10 | **Exception sheet** (off / on / guest / qty) | v1.0 | 10.4 ★ | `features/today/` |
| 11 | Range picker ("কয়েকদিন") | v1.0 | 10.5 | `features/today/` |
| 12 | Cutoff-passed lock state ("🔒 সময় শেষ", late-mark badge) | v1.0 | 10.6 ★ | `features/today/` |
| 13 | **খাতা / Khata grid** — members × slots, tap a cell | v1.0 | 10.9 | `features/grid/` |
| 14 | +বাজার sheet (amount, category chips, payer) | v1.0 | 11.1 | `features/accounts/` |
| 15 | +জমা sheet (member, amount) | v1.0 | 11.2 | `features/accounts/` |
| 16 | **হিসাব / Accounts** — rate, totals, per-member balances | v1.0 | 11.3 | `features/accounts/` |
| 17 | **Math sheet** (tap any number → the arithmetic) | v1.0 | 11.4 ★ | `core/widgets/math_sheet.dart` |
| 18 | Member statement (tap a row in হিসাব) | v1.0 | 11.5 | `features/accounts/` |
| 19 | Month-close wizard, 3 steps (review → confirm → done) | v1.0 | 12.1–12.3 | `features/close/` |
| 20 | Immutable statement + share image / WhatsApp / Messenger | v1.0 | 12.4–12.5 | `features/close/` |
| 21 | "হিসাব শেষ — আপনি মুক্ত!" completion state | v1.0 | 12.3 ★ | `features/close/` |
| 22 | Members list + সিট chip | v1.0 | 13.1 | `features/members/` |
| 23 | Add member by phone + "লিংক পাঠান" | v1.0 | 13.2 | `features/members/` |
| 24 | **Pending-member matching** ("অপেক্ষমাণ · ফোন মেলানো বাকি" → auto-match on link open, no duplicate) | v1.0 | 13.3 ★ | `features/members/` |
| 25 | Toast system (confirmations; dialogs only for irreversible) | v1.0 | 13.4 | `core/widgets/` |
| 26 | Settings / আরও | v1.0 | 13.5–13.10 | `features/settings/` |
| — | | | | |
| 27 | ⚠ 5th nav tab (সদস্য as a bottom-nav destination) | **CUT** | — | UI_SPEC §2 — 4 tabs; সদস্য lives under আরও |
| 28 | Manager handover | **P2** | — | v1.1 |
| 29 | Photo receipt on expense ("📷 রসিদ" — present in the +বাজার sheet) | **P2** | — | v1.1 |
| 30 | PDF export (button drawn on the statement) | **P2** | — | v1.1 |
| 31 | FEAST / good-food-day flag | **P2** | — | v1.1 |
| 32 | Rent / utility shared pool | **P2** | — | v1.1 |
| 33 | Bazar duty rota | **P2** | — | v1.1 |
| 34 | পেমেন্ট লিংক / বাকি (bKash per-member) — already labelled "ভবিষ্যৎ P2" in the prototype itself | **P2** | — | v1.1 |
| 35 | রুম / সিট module + "সিট দিন" assign sheet — prototype shows it **চালু** | **P3** | — | v2.2 ops. Hide the আরও row entirely in v1.0 |
| 36 | ক্লিনিং রোটা — prototype shows it **চালু** | **P3** | — | v2.2 ops. Hide the row |
| 37 | খালা / বাবুর্চি (attendance grid, salary, advance) | **P3** | — | v2.2 ops. Hide the row |
| 38 | Day-pass gate ("▶ ২টি অ্যাড দেখে আজ ফ্রি চালান") | **P5** | — | needs entitlements |
| 39 | মাস কিনুন — month-purchase calendar, ৳৩৯, no auto-renew | **P5** | — | needs entitlements |
| 40 | Ad slots — 2 in the prototype (foodpanda on Today, bKash on the PWA) | **P5** | — | your own instruction: ads later. Reserve space, render nothing |

## Member PWA

| # | Prototype screen | Fate | Epic / task | Code path |
|---|---|---|---|---|
| M1 | Invite landing ("রিফাত, আপনাকে ডাকা হয়েছে" → যোগ দিন) | v1.0 | 14.1 | `apps/web/app/m/[token]/` |
| M2 | "আপনি কে?" — self-select from the manager's pre-added names | v1.0 | 14.1 ★ | `apps/web/app/m/[token]/` |
| M3 | আজ / কাল + 1-tap অফ / গেস্ট + cutoff countdown | v1.0 | 14.2–14.3 ★ | `apps/web/app/m/[token]/` |
| M4 | আমার হিসাব + per-number math sheets | v1.0 | 14.4 | `apps/web/app/m/[token]/` |
| M5 | A2HS prompt ("📌 হোমস্ক্রিনে যোগ করুন") — second visit only | v1.0 | 14.6 | `apps/web/app/m/[token]/` |
| M6 | ⚠ গ্রুপ tab (3rd tab, read-only group view) | **P2** | — | ships with **2 tabs** in v1.0 |

---

## The deferrals most worth arguing about

Three cuts where reasonable people disagree. If any feels wrong, say so and
the epic list gets re-cut.

**Group view (M6).** Cut to get the member PWA to two screens and hold the
<500KB budget. The counter-argument is real: members want to see the whole
mess, not just themselves, and seeing everyone's numbers is part of what
makes the app feel fair. It is roughly one day of work, and it is the first
thing to add once the budget shows headroom.

**Day-pass gate (38).** Cut because it needs the entitlements module, which
is P5. Nothing about it can ship earlier without building billing — and
billing on zero users returns zero either way.

**Khata grid (13).** In v1.0, but it is first on the cut list if a day slips.
Worth knowing: it is the risk-R2 mitigation for managers who think in
notebook rows. Cutting it saves a day and costs you the khata-minded
segment for two weeks.

---

## Two rows that changed after the first pass

Recorded so the reasoning is not lost.

**Row 2 — sign-in.** The prototype draws a complete phone+OTP flow: 11-digit
entry with a Bangla numeric keypad, a 4-digit code screen, a resend timer.
ADR-0009 supersedes all of it. Building it would add an SMS gateway
dependency, a per-message cost, real deliverability failure modes in
Bangladesh, and the temptation of a `READ_SMS` permission that triggers a Play
permissions review — on the release where review latency matters most.

**Row 27 — the fifth tab.** The prototype's nav is হোম · মিল · হিসাব · সদস্য ·
আরও. The spec's is আজ · খাতা · হিসাব · আরও. Three reasons the spec wins:
সদস্য is a setup-time screen a manager visits once and then almost never
again, so it does not earn a permanent thumb-zone slot; **আজ** states the
product thesis where **হোম** is generic; and **খাতা** is what earns the
notebook association that মিল throws away.
