// Epic 13 task 13.7 — language and Bangla numerals. Instant, no restart
// (the Done-when): both are ChangeNotifiers, so a tap rebuilds the app and the
// choice is on screen before the sheet closes.
//
// The numeral choice persists now even though the formatter that renders it
// (MoneyText, task 08.4 ★) is not built yet — that is what makes it instant
// the moment 08.4 lands, rather than a restart-to-apply setting.

import 'package:flutter/material.dart';

import '../../core/i18n/l10n/app_localizations.dart';
import '../../core/settings/locale_store.dart';
import '../../core/settings/numerals_store.dart';
import '../../core/theme/tokens.g.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({
    super.key,
    required this.localeController,
    required this.numerals,
  });

  final LocaleController localeController;
  final NumeralsController numerals;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.languageTitle),
        backgroundColor: TinBelaColors.card,
      ),
      body: ListView(
        padding: const EdgeInsets.all(TinBelaSpace.lg),
        children: [
          _SectionLabel(text: l.languageSectionLabel),
          _ChoiceCard(
            children: [
              // English names itself in both locales; never translated.
              _ChoiceRow(
                label: l.languageBangla,
                selected: localeController.locale.languageCode == 'bn',
                onTap: () => localeController.set(const Locale('bn')),
              ),
              _ChoiceRow(
                label: l.languageEnglish,
                selected: localeController.locale.languageCode == 'en',
                onTap: () => localeController.set(const Locale('en')),
              ),
            ],
          ),
          const SizedBox(height: TinBelaSpace.xl),
          _SectionLabel(text: l.numeralsSectionLabel),
          ListenableBuilder(
            listenable: numerals,
            builder: (context, _) => _ChoiceCard(
              children: [
                _ChoiceRow(
                  label: l.numeralsBangla,
                  selected: numerals.useBanglaNumerals,
                  onTap: () => numerals.set(true),
                ),
                _ChoiceRow(
                  label: l.numeralsLatin,
                  selected: !numerals.useBanglaNumerals,
                  onTap: () => numerals.set(false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TinBelaSpace.sm, left: TinBelaSpace.xs),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: TinBelaColors.inkMuted),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TinBelaColors.card,
        borderRadius: BorderRadius.circular(TinBelaRadius.card),
        border: Border.all(color: TinBelaColors.divider),
      ),
      child: Column(children: children),
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
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
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: TinBelaTouch.min),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TinBelaSpace.lg,
            vertical: TinBelaSpace.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? TinBelaColors.primary : TinBelaColors.ink,
                  ),
                ),
              ),
              if (selected) const Icon(Icons.check, color: TinBelaColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
