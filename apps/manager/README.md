# TinBela Manager App (Flutter, Android)

**Scaffolded in Epic 08.** Not yet initialised — this is deliberate, so the
repo does not carry a half-configured Flutter project before it is needed.

## Initialise (Epic 08, task 08.1)

```bash
cd apps
flutter create --org com.droidbuilder --project-name tinbela_manager \
  --platforms android manager
```

Then, in order:
- **08.2** wire `lib/core/theme/tokens.g.dart` (run `make tokens` first)
- **08.3** ARB files, `bn` default — `lib/l10n/app_bn.arb`, `app_en.arb`
- **08.4** the Bangla numeral formatter and `MoneyText`
- **08.5** generated Dart models from `make proto`

## Structure (Epic 08)

```
lib/
  core/
    api/      generated models + thin HTTP transport (ADR-0003)
    theme/    tokens.g.dart — GENERATED, do not edit
    i18n/     ARB files
    widgets/  the shared component library (UI_SPEC section 5)
  features/
    onboarding/ today/ grid/ members/ accounts/ close/ settings/
```

## Rules enforced by `make verify`

- No hardcoded user-visible strings — every one is an ARB key
- No hardcoded colours — import `TinBelaColors`
- No money arithmetic in widgets — render the `MathExplain` the API sent
- Touch targets >= 48dp

See `.claude/skills/flutter-conventions/SKILL.md`.
