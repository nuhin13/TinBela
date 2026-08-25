// Task 09.7 -- the demo-mess banner. Prototype frame 2.
//
// The promise it makes is "poke-safe": nothing the user does in a demo mess
// can break anything. That promise is what makes a stranger willing to tap
// around, which is what gets them to a working mess inside 90 seconds.
//
// It is a banner, not a dialog. Blocking the screen to explain that nothing
// is blocked would be self-defeating.

import 'package:flutter/material.dart';

import '../i18n/l10n/app_localizations.dart';
import '../theme/tokens.g.dart';

class DemoBanner extends StatelessWidget {
  const DemoBanner({super.key, required this.onOpenOwnMess});

  /// Discards the demo and starts a real mess. One tap, per the task.
  final VoidCallback onOpenOwnMess;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.all(TinBelaSpace.lg),
      padding: const EdgeInsets.all(TinBelaSpace.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TinBelaRadius.card),
        // Dashed in the prototype; a solid tinted border reads the same at a
        // glance and costs no custom painter on a mid-range device.
        border: Border.all(color: TinBelaColors.accent, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.demoBannerTitle,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: TinBelaColors.ink,
            ),
          ),
          const SizedBox(height: TinBelaSpace.xs),
          Text(
            l.demoBannerBody,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: TinBelaColors.inkMuted,
            ),
          ),
          const SizedBox(height: TinBelaSpace.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: TinBelaTouch.min),
              child: TextButton(
                onPressed: onOpenOwnMess,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(TinBelaTouch.min, TinBelaTouch.min),
                ),
                child: Text(
                  l.demoBannerAction,
                  style: const TextStyle(
                    color: TinBelaColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
