---
name: flutter-conventions
description: Flutter conventions for the TinBela manager app — structure, state, i18n, performance.
---

# Flutter Conventions

## Structure
```
lib/
  core/
    api/        generated Dart models + thin HTTP transport
    theme/      generated from design-tokens
    i18n/       ARB files, bn + en
    widgets/    the shared component library
  features/
    onboarding/ today/ grid/ members/ accounts/ close/ settings/
```

## Non-negotiables
- **No hardcoded user-visible strings.** Every one is an ARB key.
  `harness/check-hardcoded-strings.sh` fails the build otherwise.
- **No hardcoded colours.** Import the generated theme.
  `harness/check-hardcoded-colors.sh` fails the build otherwise.
- **No money arithmetic in widgets.** Render the `MathExplain` the API sent.
- Touch targets >= 48dp.

## State
Repository layer returns domain types, never DTOs. Repositories are
designed with an offline seam in mind (P6): a repository is the only place
that knows whether data came from network or cache.

## Performance budget
60fps on a 4-year-old mid-range Android. That means: no blur effects, one
shadow elevation, no heavy animation, `const` constructors everywhere
possible, lists are lazy.

## Text scaling
Every screen must survive 130% system text size without clipping. Bangla
script at large sizes overflows fixed-height rows — this is the most common
visual bug in Bangladeshi apps. Test it, do not assume it.

## Transport
Generated Dart protobuf models over plain HTTP/JSON against Connect's JSON
codec (ADR-0003). Do not add a Connect Dart client dependency.
