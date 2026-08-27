# TinBela MVP — Progress

Tick as you go. Full task detail in `docs/product/EPICS.md`.
★ = hand-written by the founder, never delegated to an agent.

**Rule:** an epic is done only when its GATE passes. Not when the tasks are ticked.

---

## Day 1 — Foundation

### EPIC 00 — Genesis ★ · *gate: fresh clone → running stack + green verify in 10 min*
- [x] 00.1 Monorepo skeleton
- [x] 00.2 `CLAUDE.md` root context
- [x] 00.3 Planning docs in `docs/product/`
- [x] 00.4 ADRs 0001–0015
- [x] 00.5 ADR template + `/adr` command
- [x] 00.6 Design tokens → Dart + Tailwind + CSS
- [x] 00.7 Component inventory (`docs/design/`)
- [x] 00.8 Tooling pins (`.mise.toml`)
- [x] 00.9 Makefile with `verify`
- [x] 00.10 CI pipeline
- [x] 00.11 Agent harness (`.claude/`)
- [x] 00.12 Conventions doc
- [x] 00.13 `docker-compose.yml`
- [x] 00.14 Secrets strategy

> Epic 00 ships **pre-completed in this scaffold.** Verify it yourself before
> trusting it: run `make dev` and `make verify`, then read `CLAUDE.md`.
>
> **Verified 2026-08-19 — the gate did NOT pass.** Eight defects fixed on
> `fix/epic-00-gate`; see that branch's commits. `make verify` now runs every
> gate but still fails one: hardcoded Bangla strings in `apps/manager/lib/app.dart`
> await ARB wiring (task 08.3). **Epic 00 is not done until that is green.**

### EPIC 01 — Data layer · *gate: RLS proven with 2 tenants; append-only proven*
- [x] 01.1 Migration tooling
- [x] 01.2 Core tables
- [x] 01.3 Meal tables
- [x] 01.4 Money tables
- [x] 01.5 ★ Append-only enforcement rules
      Proven by `services/api/internal/dbtest/append_only_test.go`: UPDATE and
      DELETE on all three protected tables report 0 rows and change nothing,
      and the `void_of` correction path works.
- [x] 01.6 Institution hedges
- [x] 01.7 ★ RLS policies — **write the two-tenant test**
      Fixed 2026-08-19: the API connected as a SUPERUSER, so RLS never
      applied. Migration 000003 adds a non-owner `tinbela_app` role;
      000002 forces RLS as defence in depth. Test:
      `services/api/internal/dbtest/rls_test.go`.
- [x] 01.8 Indexes verified with EXPLAIN — evidence in `docs/eng/indexes.md`
- [x] 01.9 sqlc config + first queries — 15 queries across 4 files, all
      tenant-filtered; generated code committed (CI has no sqlc); hand-edit
      blocked by `pre-edit-guard.sh`, verified
- [x] 01.10 Seed script

---

## Day 2 — ★ The engine. Do not delegate.

### EPIC 02 — Domain engine ★ · *gate: 9 properties + vectors green, benchmark recorded*
- [x] 02.1 Pure input/output types
- [~] 02.2 ★ **Nine property tests, written BEFORE implementation** — bodies
      written for all nine (P1 conservation, P7 idempotent close in
      `settle_test.go`; P2–P6, P8, P9 in `engine_test.go`) against the founder's
      scaffold, plus verified rapid generators (`*_generators_test.go`) they draw
      from. Each stays `t.Skip`-ped so the build is green until the engine
      lands: unskip one per property as `Materialize`/`Settle` (02.3/02.4 ★) are
      implemented. Generators + shuffle + compile are green now (`make property`
      passes, lint clean). Golden vectors (02.6) + runner (02.7) + benchmark
      (02.8) remain ★.
- [ ] 02.3 ★ `Materialize`
- [ ] 02.4 ★ `Settle`
- [ ] 02.5 ★ Conservation invariant asserted in code
- [ ] 02.6 ★ 30–50 golden vectors (3 seeded — 27+ to go)
- [ ] 02.7 ★ Vector runner reusable from Dart
- [ ] 02.8 ★ Benchmark 500 members × 31 days × 3 slots

---

## Day 3 — Contracts

### EPIC 03 — Contracts & transport · *gate: TS + Dart clients round-trip*
> **Gate MET 2026-08-25.** `make contract-live` boots the stack and drives
> both generated clients against the real binary; both also have stackless
> tests fed bytes captured from it. `buf breaking` still fails once against
> master on the new `go_package` options — expected, goes quiet on merge.
> See `docs/eng/transport.md`.
- [x] 03.1 buf workspace + breaking checks
- [x] 03.2 Proto packages
- [x] 03.3 ★ Common types (`Money`, `Date`, `MathExplain`)
- [x] 03.4 Connect handlers in one binary — 4 services, 20 RPCs; business logic stubbed to its owning epic
- [x] 03.5 Codegen: Go + TS + Dart — needed `option go_package` in all 5 protos
- [x] 03.6 Middleware (request id, slog, recovery, CORS, timeouts)
- [x] 03.7 Auth interceptor — TokenVerifier seam; dev verifier refuses to build outside APP_ENV=dev. Firebase impl is 04.1
- [x] 03.8 ★ Tenant interceptor + RLS session var — authorisation IS the RLS check, not an `if`
- [x] 03.9 Error taxonomy (`docs/eng/errors.md`)
- [x] 03.10 Rate limiting middleware — measured 36 allowed / 24 throttled on a 60-call burst
- [x] 03.11 Health / readiness / version

---

## Days 4–14 — Build

### EPIC 04 — Identity & tenancy · *gate: mess + 7 members + 7 links*
- [x] 04.1 Firebase token verification — RS256 + claim policy + cert cache,
      built on stdlib crypto rather than the Admin SDK (whose key source is
      not injectable, so the signature path could not be tested). Needs only
      `FIREBASE_PROJECT_ID`. **Not yet exercised with a token Google minted.**
- [~] 04.2 `CreateSession` / `GetMe` — GetMe done. **`CreateSession` is not
      in the proto at all**, and `Mess` carries no `role` field, so "returns
      user + tenants + role" needs a proto change. Awaiting approval
- [x] 04.3 `CreateMess` atomically
- [x] 04.4 `AddMember` + invite token
- [ ] 04.5 ★ Invite token entropy + revocation
- [ ] 04.6 ★ Phone matching, no duplicates
- [x] 04.7 Role checks at the interceptor — fail-closed procedure map;
      unlisted procedures are manager-only. Proved end to end: a MEMBER gets
      permission_denied on AddLedgerEntry where a MANAGER reaches the stub
- [x] 04.8 Soft leave — `LeaveMember` RPC sets `left_at` (today, Asia/Dhaka)
      via UPDATE; never deletes, so prior `meal_exceptions` still count (the
      API half of P8 — the engine half is 02.3 ★). Manager-only (fail-closed
      interceptor), refuses to remove the manager or a member who already
      left, and is tenant-scoped. Verified against a real Postgres:
      `leave_member_test.go` (leave, prior-meals-preserved, double-leave,
      not-found, manager-guard, two-tenant isolation) all green, plus the
      full `go test ./...`, `golangci-lint`, `buf lint`, and `buf breaking`.
      **Note:** TS/Dart clients regenerate on the next full `make proto` (buf's
      remote plugins are unreachable from this container); the RPC is additive
      so nothing breaks meanwhile.
- [ ] 04.9 ★ Account deletion policy

### EPIC 05 — Meal service · *gate: 30-day scenario matches hand-computed sheet*
- [ ] 05.1 Slots + cutoffs
- [ ] 05.2 `SetPatterns`, all slots ON by default
- [ ] 05.3 `CreateException`
- [ ] 05.4 Date ranges + null slot
- [ ] 05.5 ★ `VoidException`
- [ ] 05.6 ★ Cutoff in Asia/Dhaka, clock-skew tested
- [ ] 05.7 `after_cutoff` audit
- [ ] 05.8 `GetDay`
- [ ] 05.9 Bulk endpoint with `group_id`
- [ ] 05.10 Day flags
- [ ] 05.11 Integration tests

### EPIC 06 — Money · *gate: conservation asserted at the API boundary*
- [ ] 06.1 `AddLedgerEntry`
- [ ] 06.2 Categories
- [ ] 06.3 ★ Void
- [ ] 06.4 ★ `GetAccounts`
- [ ] 06.5 ★ `MathExplain` on every money field
- [ ] 06.6 ★ Visible rounding remainder
- [ ] 06.7 Deposit attribution
- [ ] 06.8 Member statement
- [ ] 06.9 Money formatting service

### EPIC 07 — Periods · *gate: reopen a closed month, identical numbers*
- [ ] 07.1 Period lifecycle
- [ ] 07.2 `PreviewClose`
- [ ] 07.3 ★ `ClosePeriod`
- [ ] 07.4 ★ Immutability proven
- [ ] 07.5 ★ Property P7
- [ ] 07.6 ★ Rollover
- [ ] 07.7 Close guard rails
- [ ] 07.8 `GetStatement`

### EPIC 08 — Flutter foundation · *gate: signed-in shell, 4 tabs, Bangla, real device*
- [x] 08.1 Project + flavors — builds a debug APK; flavors still to add
- [x] 08.2 Theme from tokens
- [x] 08.3 ★ ARB bn + en
- [ ] 08.4 ★ Bangla numerals + `MoneyText`
- [x] 08.5 Generated Dart client — HTTP/JSON over Connect's codec; round-trips GetMe live
- [x] 08.6 State + repository layer — interfaces + remote impls; domain
      types in core/domain, mapping isolated to core/data. P6 offline lands
      as a cache decorator, not an `if` in every screen
- [x] 08.7 Bottom nav shell — verified on a real device (CPH2745, Android 16)
- [x] 08.8 Error/loading/empty primitives — skeleton, retry, toast,
      FinishedState. Retry suppressed on non-retryable codes; the server's
      localised message is rendered rather than re-invented
- [~] 08.9 Google Sign-In — token lifecycle done: `AuthSession` owns the
      cache + refresh policy (proactive before expiry, reactive retry-once on a
      401 via `ConnectClient.onUnauthenticated`), plus `signOut()`. Proven in
      `test/core/auth/auth_session_test.dart` and the retry cases in
      `connect_client_test.dart`. Dev signs in as the seeded manager; the
      concrete `FirebaseAuthBackend` + the Google button + manifest are 09.2.

### EPIC 09 — Onboarding · *gate: stranger → usable Today screen in <90s*
- [x] 09.1 Splash + language — bn default, persisted in shared_preferences pre-auth
- [~] 09.2 Sign-in — Google Sign-In via Firebase (ADR-0009), one tap, no OTP,
      no READ_SMS. `FirebaseAuthBackend` fills the 08.9 `AuthBackend` seam;
      `SignInScreen` sits between welcome and mess setup and, on success,
      re-checks GetMe so a reinstalling manager lands in their mess instead of
      re-creating it. Gradle applies google-services only when
      `google-services.json` is present, so dev builds (DevAuthBackend, no
      Firebase) still compile. **NOT verified here:** no Flutter SDK to
      `pub get`/build, and prod needs a real `google-services.json` + the
      SHA-1 in the Firebase console. Screen logic tested in `onboarding_test`.
- [ ] 09.3 ★ 3-question setup — **no fourth question, ever**
- [x] 09.4 How-it-works card — skippable
- [x] 09.5 Invite link + Messenger share — Messenger first, clipboard
      fallback when neither app is installed
- [ ] 09.6 ★ Solo-manager path
- [x] 09.7 Demo mess — banner + one-tap discard (local seeding still to wire)
- [x] 09.8 Empty states — খাতা · হিসাব · সদস্য, one action each. আজ is 10.3 ★

### EPIC 10 — Daily loop ★ · *gate: tap-count audit ≤6 taps on a real device*
- [ ] 10.1 ★ Cutoff card
- [ ] 10.2 ★ Today layout
- [ ] 10.3 ★ Empty-day SUCCESS state
- [ ] 10.4 ★ Exception sheet
- [ ] 10.5 Range picker
- [ ] 10.6 Guest flow
- [ ] 10.7 ★ Optimistic write + rollback
- [ ] 10.8 Post-cutoff state
- [ ] 10.9 Khata grid
- [ ] 10.10 Void UX
- [ ] 10.11 Instrument `exception_marked`
- [ ] 10.12 ★ **Tap-count audit — this gate IS the product**

### EPIC 11 — Money & accounts · *gate: zero client-side money arithmetic*
- [ ] 11.1 `+বাজার` sheet
- [ ] 11.2 `+জমা` sheet
- [ ] 11.3 হিসাব screen
- [ ] 11.4 ★ Math sheet
- [ ] 11.5 Member statement
- [ ] 11.6 Ledger history + void
- [ ] 11.7 ★ Numeral toggle everywhere
- [ ] 11.8 Instrument `number_tapped_for_math`

### EPIC 12 — Month close · *gate: close, share, reopen next day unchanged*
- [ ] 12.1 Step 1 review
- [ ] 12.2 ★ Step 2 confirm
- [ ] 12.3 Step 3 done
- [ ] 12.4 Statement → image
- [ ] 12.5 Share sheet
- [ ] 12.6 Historical viewer
- [ ] 12.7 Instrument

### EPIC 13 — Members & settings · *gate: deletion works in-app and on web*
> The **আরও (More) tab** is now real (was a placeholder): a menu into members
> and settings, built on the completed core service. Written without a Flutter
> SDK in the container — verified by the hardcoded-string/colour guards
> (green) + inspection; widget tests run in CI.
- [x] 13.1 Members list — `members_screen.dart`, invite-state chips
      (পাঠানো/খুলেছেন/যুক্ত) via `ListMembers`.
- [x] 13.2 Add member — sheet (name + optional phone) → `AddMember` → invite
      link with Messenger/WhatsApp/copy share.
- [ ] 13.3 Pattern editor — deferred: needs `SetPatterns` (Epic 05, engine-blocked).
- [ ] 13.4 Remove/leave — deferred: `LeaveMember` RPC exists (04.8) but its Dart
      client isn't generated (`make proto`); no dead button shipped meanwhile.
- [x] 13.5 Mess profile — `mess_profile_screen.dart`, name + kind (read-only;
      rename needs an UpdateMess RPC).
- [ ] 13.6 Slots & cutoffs — deferred: needs a slots-edit RPC (Epic 05).
- [x] 13.7 Language + numerals — `language_screen.dart`; locale + a new
      `NumeralsController` (local pref), instant, no restart.
- [ ] 13.8 ★ In-app account deletion — founder-owned; reachable placeholder that
      routes to the web deletion page in the meantime (`delete_account_screen.dart`).
- [x] 13.9 Data export request — mailto path (v1.0), inside About.
- [x] 13.10 About — version, Droid Builder, privacy/terms links.

### EPIC 14 — Member PWA · *gate: Lighthouse CI size + speed budget*
- [ ] 14.1 `/m/[token]` route
- [ ] 14.2 আজ/কাল screen
- [ ] 14.3 1-tap অফ / গেস্ট
- [ ] 14.4 আমার হিসাব
- [ ] 14.5 ★ <500KB, <3s on 3G
- [ ] 14.6 A2HS on 2nd visit
- [ ] 14.7 bn/en + numerals
- [ ] 14.8 Token revocation
- [ ] 14.9 Instrument `member_link_opened`

### EPIC 15 — Landing · *gate: privacy page matches data safety form*
- [ ] 15.1 ★ Home — one idea
- [x] 15.2 Tap comparison graphic — `TapComparison`: khata ৩/দিন · other apps
      ৩/দিন · TinBela **০/দিন** (highlighted, "কিছু করার নেই"). The zero is the
      differentiator. Token colours, bn numerals, accessible marks.
- [x] 15.3 Screenshots + Play badge — `AppShowcase`: a built Today-screen mock
      (finished-day state, no binary asset — real captures are 19.4) + a Play
      CTA. Official Play badge art ships with the listing (19.x).
- [ ] 15.4 ★ `/privacy`
- [ ] 15.5 ★ `/terms`
- [ ] 15.6 ★ `/delete-account`
- [~] 15.7 SEO + OG images — full metadata (title template, canonical, robots,
      openGraph bn_BD, twitter card, metadataBase) + a generated
      `opengraph-image.tsx` rendering the brand + tagline in Hind Siliguri
      (visually verified — Bangla conjuncts correct). Messenger preview done.
      **NOT done:** bn/en locale routing — the site is bn-only; en routing is a
      larger i18n lift beyond the Messenger-preview done-when. Flagged.

### EPIC 16 — Admin portal · *gate: answer "what did mess X do Tuesday" in 30s*
> **Start on Day 5.** Without Django admin this is your only window into the
> running system for the next nine days.
> **Backend + portal built and verified end to end** (API binary + Next.js
> portal against real Postgres, screenshots taken). ADR-0016 adds a read-only
> `tinbela_admin` role (BYPASSRLS, SELECT-only) so cross-tenant reads work while
> "no mutation path" is a database grant. Only 16.4 (the inspector) is left — ★.
- [x] 16.1 Auth + IP allowlist — `adminGuard`: staff Firebase-uid allow-list +
      IP allow-list; a valid manager token gets 403 (verified live).
- [x] 16.2 Dashboard — one screen: active messes · exceptions today · closes
      this month · member links opened (Asia/Dhaka windows).
- [x] 16.3 Tenant search — paginated `ListTenants`, name search, most-active
      first, member_count + last_activity derived on read.
- [ ] 16.4 ★ Read-only inspector — `GetTenant` intentionally unimplemented;
      route + staff gate + read-only pool are in place for the founder.
- [x] 16.5 User lookup — by phone / firebase uid; a miss is an empty answer.
- [x] 16.6 Feature flags — `feature_flags` table + `SetFlag` (the only write)
      + toggle UI incl. kill switch; takes effect on next read, no deploy.
- [x] 16.7 Metrics — the dashboard counts (BRD §10 subset).
- [x] 16.8 Admin audit log — `admin_audit_log`; every admin read writes a row.

### EPIC 17 — Telemetry · *gate: answer "how many exceptions yesterday"*
- [ ] 17.1 Analytics wired
- [ ] 17.2 ★ All 14 events verified in DebugView
- [ ] 17.3 Crashlytics + symbols
- [ ] 17.4 Remote Config kill switch
- [ ] 17.5 ★ Entitlement stub
- [ ] 17.6 ★ All gated features route through `Has()`
- [ ] 17.7 Server-side event sink

### EPIC 18 — Hardening · *gate: smoke green, restore drill done, Bangla signed off*
- [ ] 18.1 ★ Smoke test script
- [ ] 18.2 Load test p95 <300ms
- [ ] 18.3 ★ Security pass
- [ ] 18.4 Dependency + secret scanning
- [ ] 18.5 ★ **Backup + RESTORE DRILL**
- [ ] 18.6 ★ Bangla copy read aloud by a native speaker
- [ ] 18.7 130% text scale, no clipping
- [ ] 18.8 ★ Low-end device 60fps
- [ ] 18.9 ★ Bad-network matrix
- [ ] 18.10 ★ 3 days crash-free own use

### EPIC 19 — Release · *gate: live on Play, alerts reach your phone*
- [ ] 19.1 ★ Keystore backed up **off the dev server**
- [ ] 19.2 Release pipeline → signed AAB
- [ ] 19.3 ★ Listing bn-BD **and** en-US
- [ ] 19.4 ★ Icon, feature graphic, 6 screenshots
- [ ] 19.5 ★ Data safety form matches the build
- [ ] 19.6 ★ Content rating, audience **18+**
- [ ] 19.7 ★ Permissions: INTERNET only, no READ_SMS
- [ ] 19.8 ★ Production deploy + backups
- [ ] 19.9 ★ Rollback plan + kill switch drill
- [ ] 19.10 ★ Post-launch alerting

---

## If a day slips, cut in this order

1. Khata grid (10.9)
2. Demo mess (09.7)
3. Admin metrics (16.7)
4. Landing polish (15.2, 15.3)

**Never cut:** Epic 02 · task 10.4 · task 11.4 · Epic 14.
Those four *are* the differentiation. Everything else is table stakes your
competitors already ship.
