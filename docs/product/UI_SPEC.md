# TinBela — UI Specification
**Droid Builder · companion to BRD v4.0 · derived from the approved prototype**

> **The design is done.** The prototype covers every v1.0 screen. This document is the
> *inventory and the rules*, not a redesign. Do not reopen design decisions during P1.

---

## 1. DESIGN TOKENS

```
 COLOUR
 PRIMARY GREEN   #1B7A4E   brand · primary action · positive balance
 ACCENT YELLOW   #E39312   secondary action (+বাজার / +জমা)
 ALERT RED       #C0392B   debt · meal-off · cutoff passed
 SURFACE         #FAF6EF   warm off-white page background
 CARD            #FFFFFF
 INK             #1A1A1A   primary text
 INK MUTED       #6B6B6B   secondary text
 TINT            #E8F3ED   light green fill · selected state
 DIVIDER         #E8E2D8

 TYPE   Hind Siliguri (bn) · system (en)
        display 28/34 semibold · title 20/26 · body 16/24 ·
        caption 13/18 · number-lg 32/38 tabular
 SPACE  4 · 8 · 12 · 16 · 24 · 32
 RADIUS 16 card · 12 button · 8 chip · 64 app icon
 TOUCH  minimum 48×48dp — non-negotiable (glare + one-handed use)
 SHADOW one elevation only: 0 1 4 rgba(0,0,0,.08)
```

**Two rendering rules that are easy to get wrong and expensive to fix:**

1. **Numbers use tabular figures, always.** Balances change while you look at them; jitter reads
   as untrustworthiness.
2. **The Bangla numeral toggle is a formatter, never stored data.** `৳১,২৪০` and `৳1,240` are the
   same `124000` paisa.

---

## 2. NAVIGATION MAP

```
 MANAGER APP (Flutter, Android)

 ┌ FIRST RUN ────────────────────────────────────────────────┐
 │ splash → language → sign in (Google) → 3 questions →       │
 │ "how TinBela works" → mess created → invite link → HOME     │
 │                                    └→ [skip] → demo mess    │
 └────────────────────────────────────────────────────────────┘

 BOTTOM NAV (4 tabs, thumb zone)
 ┌──────────┬──────────┬──────────┬──────────┐
 │   আজ     │  খাতা    │  হিসাব   │   আরও    │
 │  Today ★ │  Grid    │ Accounts │   More   │
 └──────────┴──────────┴──────────┴──────────┘
      │          │          │           │
      │          │          │           ├─ মেস প্রোফাইল
      │          │          │           ├─ স্লট ও কাটঅফ সময়
      │          │          │           ├─ ভাষা / সংখ্যা
      │          │          │           ├─ সদস্য (members)
      │          │          │           └─ অ্যাকাউন্ট মুছুন
      │          │          │
      │          │          ├─ member statement (tap a row)
      │          │          ├─ math sheet (tap ANY number)
      │          │          └─ মাস শেষ করুন → 3-step wizard
      │          │                            → immutable statement
      │          │                            → share image
      │          └─ tap a cell → same exception sheet as Today
      │
      ├─ cutoff card (per-slot headcount)
      ├─ today's exception list
      ├─ [+ বাজার]  → amount + category sheet
      ├─ [+ জমা]    → member + amount sheet
      └─ tap a member row → exception sheet
                            (off / on / guest / qty · today / range)
```

```
 MEMBER PWA (Next.js, no install, no password, token in URL)
 /m/<token>
 ┌─────────────┬─────────────┐
 │  আজ/কাল     │ আমার হিসাব  │      ← 2 tabs only in v1.0
 └─────────────┴─────────────┘
   │               └─ my meals · my deposits · my balance · math sheets
   └─ my slots today + tomorrow · [অফ] [গেস্ট] · cutoff countdown
      + "হোমস্ক্রিনে যোগ করুন" prompt (A2HS) on second visit
```

```
 ADMIN PORTAL (Next.js, internal, staff role)

 sidebar
 ├─ Dashboard        active messes · exceptions today · closes this month
 ├─ Tenants          search → detail: members · ledger · exceptions
 │                   ★ READ-ONLY. Never mutate customer data from here.
 ├─ Users            lookup by phone / firebase uid
 ├─ Flags            feature flags · kill switch
 └─ Metrics          BRD §10 events
```

### 2.1 Where this map deliberately differs from the prototype

`apps/manager/AGENTS.md` says the prototype wins when it disagrees with this
spec. **These three are the exception** — they are settled decisions made after
the design was drawn, not spec drift. Do not "correct" them back.

| The prototype shows | This spec says | Authority |
|---|---|---|
| Phone → 4-digit OTP sign-in | Google Sign-In, one tap | ADR-0009 |
| 5 manager tabs: হোম · মিল · হিসাব · সদস্য · আরও | 4 tabs: আজ · খাতা · হিসাব · আরও | this §2 |
| 3 PWA tabs incl. গ্রুপ | 2 tabs | SCREENS.md M6 (P2) |

Tab-label wording is load-bearing, not decoration. **আজ** names the manager's
daily job — the entire thesis of §3.1 — where "হোম" is a generic container.
**খাতা** is the word that earns the notebook association from managers
currently keeping paper accounts, which is the R2 risk mitigation; "মিল"
throws that away for nothing.

Any *fourth* conflict is a real inconsistency: raise it, do not resolve it.

---

## 3. THE THREE SCREENS THAT DECIDE THE PRODUCT

Everything else is competent CRUD. These three carry the differentiation.

### 3.1 আজ / Today — the manager's whole daily job

```
 ┌──────────────────────────────────────────┐
 │ আজ · মঙ্গলবার ৮ জুলাই            [৩ জন] │  ← header
 ├──────────────────────────────────────────┤
 │ ╭──────────────────────────────────────╮ │
 │ │ দুপুরের কাটঅফ শেষ হতে ১ ঘণ্টা         │ │  ← CUTOFF CARD
 │ │                                      │ │    the reason to open
 │ │  সকাল ৮   ·   দুপুর ৭   ·   রাত ৮    │ │    the app. Above the
 │ │                                      │ │    fold, always.
 │ ╰──────────────────────────────────────╯ │
 │                                          │
 │  [ + বাজার ]        [ + জমা ]           │  ← 2 actions. No more.
 │                                          │
 │ আজকের পরিবর্তন                          │
 │  রিফাত — দুপুরের মিল অফ    সকাল ৮:১২    │
 │  আদনান — রাতে গেস্ট ১      সকাল ৯:০৫    │
 │                                          │
 │  বাকি সবাই ডিফল্ট প্যাটার্নে ✓          │  ← THE PRODUCT, stated
 │  কিছু করার নেই                          │    in words. Do not cut
 └──────────────────────────────────────────┘    this line.
```

```
 RULES
 · Nothing above the fold except the cutoff card and the two buttons.
 · A day with zero exceptions must LOOK finished. The empty state is
   a success state, not an absence — this is the single most important
   piece of copy in the app.
 · Post-cutoff: the affected slot greys, shows "ম্যানেজার এন্ট্রি",
   and any edit is stamped and surfaced later in member statements.
 · Tapping a member row opens the exception sheet. Two taps to done.
```

### 3.2 The exception sheet — ≤2 taps, <10 seconds

```
 ┌──────────────────────────────────────────┐
 │  রিফাত                              ✕   │
 ├──────────────────────────────────────────┤
 │   [ সকাল ]   [ দুপুর ]   [ রাত ]        │  ← slot chips, multi-select
 │                                          │
 │   ╭────────╮ ╭────────╮ ╭────────╮      │
 │   │  অফ    │ │ গেস্ট  │ │ সংখ্যা │      │  ← 48dp+, thumb row
 │   ╰────────╯ ╰────────╯ ╰────────╯      │
 │                                          │
 │   আজ  ·  কাল  ·  কয়েকদিন →              │  ← range entry lives here
 │                                          │
 │            [ হলো ]                       │
 └──────────────────────────────────────────┘
 · Opens with today + the tapped slot preselected → "অফ" then "হলো"
   is the entire interaction.
 · "কয়েকদিন" expands to a date range picker ("৩ দিন বাড়ি যাচ্ছি").
 · Confirmation is a toast, never a dialog. Never block the thumb.
```

### 3.3 The math sheet — Wedge #3

```
 Any number, anywhere in the app, is tappable.

 ┌──────────────────────────────────────────┐
 │  মিল রেট                            ✕   │
 ├──────────────────────────────────────────┤
 │            ৳ ৪০                          │
 │                                          │
 │   মোট বাজার ÷ মোট মিল                   │
 │   ৳১২,৪০০  ÷  ৩১০                       │
 │                                          │
 │   বাকি ৳০ মেসের হিসাবে যোগ আছে          │  ← the remainder, visible
 │                                          │
 │   কোনো লুকানো হিসাব নেই                 │
 └──────────────────────────────────────────┘
 · The client NEVER computes this. It renders the `math` object the
   API returned (Build Spec §5). One source of truth, no drift.
 · Applies to: meal rate · every balance · every total · every
   statement line.
```

---

## 4. FULL SCREEN INVENTORY — v1.0

### Manager app (Flutter) — 8 screens + 6 sheets

| # | Screen | Notes |
|---|---|---|
| 1 | Onboarding flow | language → sign-in → 3 questions → how-it-works → invite |
| 2 | **আজ / Today** ★ | §3.1 |
| 3 | **খাতা / Grid** | member × slot table, looks like the notebook. Tap a cell → same sheet. Risk R2 mitigation |
| 4 | **হিসাব / Accounts** | meal rate · totals · per-member balance list · [মাস শেষ করুন] |
| 5 | Member statement | one member: meals, deposits, balance, after-cutoff flags |
| 6 | Members | list with invite state (পাঠানো / খুলেছেন / যুক্ত) · add member |
| 7 | Month-close wizard | 3 steps: review → confirm → done. Statement + share image |
| 8 | আরও / More | mess profile · slots & cutoffs · language · numerals · account deletion |

| Sheets | |
|---|---|
| Exception sheet | §3.2 |
| Math sheet | §3.3 |
| +বাজার | amount · category · date · note |
| +জমা | member · amount · date |
| Add member | name · phone (optional) · → invite link |
| Range picker | "কয়েকদিন অফ" |

### Member PWA (Next.js) — 2 screens

| # | Screen | Notes |
|---|---|---|
| 1 | আজ / কাল | my slots today + tomorrow, [অফ] [গেস্ট], cutoff countdown, A2HS prompt on 2nd visit |
| 2 | আমার হিসাব | my meals · deposits · balance, all tappable to math sheets |

**Hard budget:** <500KB shell, <3s first paint on throttled 3G. This is a marketing surface as
much as a feature — a member who waits 8 seconds never opens it again, and the growth loop dies.

### Admin portal (Next.js) — 5 screens

Dashboard · Tenants (list + read-only detail) · Users · Flags · Metrics.

Build the tenant inspector on **Day 5**, not at the end. Without Django admin, it is your only
window into the running system for the following nine days.

### Landing site (Next.js) — 4 pages

Home · Privacy · Terms · Delete account. Home leads with the one idea that differentiates you:
**"স্বাভাবিক দিনে কিছুই করতে হবে না।"** Not a feature list. One idea, one screenshot, one button.

---

## 5. COMPONENT LIBRARY (build once, reuse everywhere)

```
 CutoffCard          per-slot headcount + countdown + passed state
 MoneyText           ★ formats paisa → ৳ · bn/en numerals · tabular ·
                     tappable → math sheet. EVERY number uses this.
 SlotChipRow         multi-select slot chips
 ActionPillRow       48dp+ pill buttons (অফ / গেস্ট / সংখ্যা)
 MemberRow           avatar initial · name · today's state · balance
 ExceptionListItem   who · what · when · marked_by · after-cutoff flag
 EmptyState          illustration + one teaching line + one action
 MathSheet           renders the API `math` object
 AmountInput         numeric keypad, paisa-safe, no decimals typed
 DateRangeChip       আজ · কাল · কয়েকদিন
 StatementCard       shareable, renders to image at 1080×1920
 VoidBanner          "বাতিল হলো" with the original still visible
```

**`MoneyText` is the most important component in the codebase.** If every number routes through
it, the numeral toggle, the tabular figures, and the tappable math all come free and stay
consistent. If numbers get formatted ad hoc in screens, all three decay within a month.

---

## 6. UX LAWS (design-lock)

```
  1 Manager home = one glance: cutoff card + two buttons. Nothing else
    above the fold.
  2 ≤2 taps for any daily action. ≤3 for any monthly action.
  3 Member PWA <500KB shell, <3s on 3G.
  4 Bangla-first. Numerals toggle. Thumb-zone bottom nav.
  5 Empty states teach. A zero-exception day must look FINISHED.
  6 Every money number is tappable and shows its math.
  7 Every destructive action is a void, never a delete — and the UI
    says so, with the original still visible in history.
  8 No spinner without a skeleton. No error without a retry button.
    Mess wifi is bad and users blame the app, not the network.
  9 Confirmation is a toast. Dialogs only for irreversible actions
    (month close, account deletion).
 10 RELEASE GATE: a 4-person mess sees ONE screen and understands its
    whole month.
```

---

## 7. UI BY PHASE

### P2 — v1.1 Retention
```
 + Handover flow (2 screens: pick successor → confirm → data stays)
 + Shared-pool section on হিসাব (rent · utility · split rule)
 + Landlord payout log
 + Budget bar on Today (soft, never blocking)
 + Rota strip on Today ("আজ তানভীরের পালা")
 + Photo thumbnail on ledger rows
 + FEAST flag on Today (a small badge, not a screen)
 + Member PWA gains a 3rd tab: গ্রুপ
 + Push notification designs (cutoff · bazar day · month end)
```

### P3 — v1.2 Institution mode (the information architecture changes)
```
 THIS IS NOT A RESKIN. Plan for a distinct navigation.

 BOTTOM NAV becomes:  আজ · ছাত্র · হিসাব · রিপোর্ট
 + Group tree navigation (block → batch → room → resident)
 + BULK exception UI — select a whole batch, one action. The single
   most important new screen: a warden marking 60 students off for
   exam leave must take under 30 seconds.
 + Resident list with fee_category badges (ফুল · আংশিক · লিল্লাহ)
 + Dues screen — who owes, how long, collection actions
 + Ration store — stock in / consumption out / closing balance
 + Cook forecast card — "আগামীকাল রাত: ২৩৮ জন"
 + Staff module (cook, warden, cleaner — salary, advance, attendance)
 + Reports: consumption · dues · collection · lillah fund
 + Guardian view (magic link, reuses the member-PWA token mechanism):
   my child's attendance + dues. Read-only. 1 screen.
 ✗ NO member PWA for residents — they are often minors without phones.
```

### P4 — v1.3 Home mode
```
 · Bottom nav collapses to 3 tabs: আজ · হিসাব · আরও
 · Grid hidden by default (a 4-person household does not need a khata)
 · Meal rate optional — default view is "কে কত দিয়েছে, কে কত পাবে"
 · Copy pass: মেস → বাসা
 Mostly configuration and strings. The screens already exist.
```

### P6 — v2.1 Offline
```
 · Sync status chip in the header: সিঙ্ক হয়েছে · অপেক্ষমাণ (৩)
 · Offline banner — calm, never alarming. "অফলাইনে চলছে, পরে সিঙ্ক হবে"
 · Entitlement lapse state: falls back to online mode, NEVER locks the
   data. A user who stops paying still sees everything.
 · Per-row pending indicator on unsynced exceptions and ledger entries
```

---

## 8. ACCESSIBILITY & FIELD CONDITIONS

These are not compliance checkboxes; they are conditions your actual users are in.

```
 · Sunlight: minimum contrast 4.5:1 on all text. The warm surface
   (#FAF6EF) was chosen for glare, not for taste — do not "modernise"
   it to pure white.
 · One-handed: every primary action within the bottom third.
 · Cheap devices: target 60fps on a 4-year-old mid-range Android.
   No blur effects, one shadow elevation, no heavy animation.
 · Bad network: skeletons everywhere, optimistic writes on exceptions
   with clear rollback, retry on every error.
 · Low literacy in English: Bangla default, icons always paired with
   a Bangla label, never icon-only navigation.
 · Font scaling: layouts must survive 130% system text size without
   clipping — Bangla script at large sizes overflows fixed-height rows,
   which is the most common visual bug in Bangladeshi apps.
```
