// Epic 13 task 13.5 — mess profile: name and kind.
//
// Read-only in v1.0: renaming a mess needs an UpdateMess RPC that does not
// exist yet, and inventing one here would be a proto change nobody approved.
// The screen shows what CreateMess set; editing is a later task.

import 'package:flutter/material.dart';

import '../../core/domain/models.dart';
import '../../core/i18n/l10n/app_localizations.dart';
import '../../core/theme/tokens.g.dart';

class MessProfileScreen extends StatelessWidget {
  const MessProfileScreen({super.key, required this.mess});

  final Mess mess;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.messProfileTitle),
        backgroundColor: TinBelaColors.card,
      ),
      body: ListView(
        padding: const EdgeInsets.all(TinBelaSpace.lg),
        children: [
          _Field(label: l.messNameLabel, value: mess.name),
          const SizedBox(height: TinBelaSpace.md),
          _Field(label: l.messKindLabel, value: _kind(l, mess.kind)),
        ],
      ),
    );
  }

  String _kind(AppLocalizations l, MessKind kind) => switch (kind) {
        MessKind.mess => l.messKindMess,
        // v1.0 only creates messes; the others are P3/P4 hedges (ADR-0011).
        _ => l.messKindMess,
      };
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TinBelaSpace.lg),
      decoration: BoxDecoration(
        color: TinBelaColors.card,
        borderRadius: BorderRadius.circular(TinBelaRadius.card),
        border: Border.all(color: TinBelaColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: TinBelaColors.inkMuted),
          ),
          const SizedBox(height: TinBelaSpace.xs),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: TinBelaColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
