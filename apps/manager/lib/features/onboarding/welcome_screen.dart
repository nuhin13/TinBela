// Task 09.1 -- splash / welcome. Prototype frame 1a.
//
// The prototype has no separate language-picker screen: bn/en is one line on
// this screen, and the real switch lives in আরও → ভাষা/সংখ্যা (task 13.7).
// Do not add a picker screen; it is a step in a flow whose gate is 90
// seconds end to end.
//
// RAISED, NOT BUILT: the prototype's line here reads
// "বাংলা · English · Free trial ৩০ দিন". The trial half is omitted. v1.0
// has no billing at all -- entitlements always return true and there is
// zero billing code in the repo (ADR-0010); purchase is P5
// (docs/design/SCREENS.md rows 38-39). Promising a 30-day trial on the first
// screen would be the app's first sentence to a user and it would be untrue.
// apps/manager/AGENTS.md says a third prototype-vs-decision conflict must be
// raised rather than resolved, so this one is raised.

import 'package:flutter/material.dart';

import '../../core/i18n/l10n/app_localizations.dart';
import '../../core/theme/tokens.g.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.onGetStarted,
    required this.onLocaleSelected,
    required this.locale,
  });

  final VoidCallback onGetStarted;
  final ValueChanged<Locale> onLocaleSelected;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(TinBelaSpace.xl),
          child: Column(
            children: [
              const Spacer(),
              const _BrandMark(),
              const SizedBox(height: TinBelaSpace.xl),
              Text(
                l.appTitle,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: TinBelaColors.ink,
                ),
              ),
              const SizedBox(height: TinBelaSpace.md),
              Text(
                l.brandTagline,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: TinBelaColors.ink),
              ),
              const SizedBox(height: TinBelaSpace.xs),
              Text(
                l.brandSubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: TinBelaColors.inkMuted,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 56),
                  child: FilledButton(
                    onPressed: onGetStarted,
                    style: FilledButton.styleFrom(
                      backgroundColor: TinBelaColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(TinBelaRadius.card),
                      ),
                    ),
                    child: Text(
                      l.getStarted,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: TinBelaSpace.lg),
              _LanguageRow(
                locale: locale,
                onSelected: onLocaleSelected,
              ),
              const SizedBox(height: TinBelaSpace.sm),
            ],
          ),
        ),
      ),
    );
  }
}

/// The ৳ brand mark from the prototype. A Text, not an asset: one glyph in a
/// font already bundled costs nothing against the shell budget.
class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: TinBelaColors.primary,
        borderRadius: BorderRadius.circular(TinBelaRadius.card),
        boxShadow: TinBelaShadow.one,
      ),
      alignment: Alignment.center,
      child: const Text(
        // The Bangla letter the brand is built from, not user-facing copy --
        // it is a logo, and a logo is not translated.
        // ignore: hardcoded
        'ত',
        style: TextStyle(
          fontSize: 44,
          fontWeight: FontWeight.w600,
          color: TinBelaColors.card,
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({required this.locale, required this.onSelected});

  final Locale locale;
  final ValueChanged<Locale> onSelected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LanguageChoice(
          label: l.languageBangla,
          selected: locale.languageCode == 'bn',
          onTap: () => onSelected(const Locale('bn')),
        ),
        const Text(
          // A separator, not copy.
          // ignore: hardcoded
          ' · ',
          style: TextStyle(color: TinBelaColors.inkMuted),
        ),
        _LanguageChoice(
          label: l.languageEnglish,
          selected: locale.languageCode == 'en',
          onTap: () => onSelected(const Locale('en')),
        ),
      ],
    );
  }
}

class _LanguageChoice extends StatelessWidget {
  const _LanguageChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(TinBelaRadius.chip),
      child: ConstrainedBox(
        // Two small words side by side are the easiest thing in the app to
        // mis-tap. The target stays full size even though the text is not.
        constraints: const BoxConstraints(
          minHeight: TinBelaTouch.min,
          minWidth: TinBelaTouch.min,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: TinBelaSpace.md),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color:
                    selected ? TinBelaColors.primary : TinBelaColors.inkMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
