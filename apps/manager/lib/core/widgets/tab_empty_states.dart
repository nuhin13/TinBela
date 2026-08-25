// Task 09.8 -- empty states for all four tabs.
//
// "Empty states teach, not apologise. Each has one action." (UX law 5.)
//
// ONE action, not two. An empty screen offering three things to try is a
// menu, and a menu is the thing a first-time user is least able to read.
// The single action is always the next step in the daily loop.
//
// Today is the exception and is deliberately NOT here: its empty state is a
// SUCCESS state ("কিছু করার নেই"), it is task 10.3, and it is ★. Routing it
// through a generic "empty" widget is exactly how it would decay into an
// apology. Use `FinishedState` for that.

import 'package:flutter/material.dart';

import '../i18n/l10n/app_localizations.dart';
import '../theme/tokens.g.dart';

/// An empty state that teaches: a line that explains, and exactly one action.
class TeachingEmptyState extends StatelessWidget {
  const TeachingEmptyState({
    super.key,
    required this.headline,
    required this.actionLabel,
    required this.onAction,
  });

  final String headline;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TinBelaSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              headline,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TinBelaColors.ink,
              ),
            ),
            const SizedBox(height: TinBelaSpace.lg),
            ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: TinBelaTouch.min,
                minWidth: TinBelaTouch.min,
              ),
              child: FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: TinBelaColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(TinBelaRadius.button),
                  ),
                ),
                child: Text(actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// খাতা — the month grid, before the month has anything in it.
class GridEmptyState extends StatelessWidget {
  const GridEmptyState({super.key, required this.onGoToToday});

  final VoidCallback onGoToToday;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return TeachingEmptyState(
      headline: l.emptyGridTitle,
      actionLabel: l.emptyGridAction,
      onAction: onGoToToday,
    );
  }
}

/// হিসাব — before any bazar or deposit exists.
class AccountsEmptyState extends StatelessWidget {
  const AccountsEmptyState({super.key, required this.onAddBazar});

  final VoidCallback onAddBazar;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return TeachingEmptyState(
      headline: l.emptyAccountsTitle,
      actionLabel: l.emptyAccountsAction,
      onAction: onAddBazar,
    );
  }
}

/// সদস্য (under আরও) — a mess of one.
///
/// The headline says "আপনি একাই আছেন", not "কোনো সদস্য নেই". Running a mess
/// alone is a supported path (task 09.6), so the empty members list is not a
/// failure to fix -- it is a state to offer a next step from.
class MembersEmptyState extends StatelessWidget {
  const MembersEmptyState({super.key, required this.onAddMember});

  final VoidCallback onAddMember;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return TeachingEmptyState(
      headline: l.emptyMembersTitle,
      actionLabel: l.emptyMembersAction,
      onAction: onAddMember,
    );
  }
}
