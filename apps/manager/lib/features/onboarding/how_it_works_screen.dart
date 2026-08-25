// Task 09.4 -- "তিনবেলা যেভাবে কাজ করে". Prototype frame 1c.
//
// Three lines, skippable. It is the only place the product's central idea is
// explained in words, and it is also a step in a flow whose gate is 90
// seconds -- so it must be skippable and must never grow a second page.

import 'package:flutter/material.dart';

import '../../core/i18n/l10n/app_localizations.dart';
import '../../core/theme/tokens.g.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({
    super.key,
    required this.onContinue,
    required this.onSkip,
  });

  final VoidCallback onContinue;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(TinBelaSpace.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onSkip,
                  child: Text(
                    l.skip,
                    style: const TextStyle(color: TinBelaColors.inkMuted),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(TinBelaSpace.xl),
                decoration: BoxDecoration(
                  color: TinBelaColors.tint,
                  borderRadius: BorderRadius.circular(TinBelaRadius.card),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.howItWorksTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: TinBelaColors.ink,
                      ),
                    ),
                    const SizedBox(height: TinBelaSpace.md),
                    Text(
                      l.howItWorksBody,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.7,
                        color: TinBelaColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: FilledButton(
                  onPressed: onContinue,
                  style: FilledButton.styleFrom(
                    backgroundColor: TinBelaColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TinBelaRadius.card),
                    ),
                  ),
                  child: Text(
                    l.createMess,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
