// Epic 13 — the আরও (More) tab: the setup-and-settings surface.
//
// The prototype's আরও menu also lists রুম/সিট, ক্লিনিং রোটা, খালা/বাবুর্চি,
// মাস কিনুন and পেমেন্ট লিংক. All are P2/P3/P5 and are ABSENT in v1.0, not
// greyed out (apps/manager/AGENTS.md: no dead rows — a Play reviewer opens
// every one). স্লট ও কাটঅফ (13.6) is omitted for the same reason until its
// editor RPC exists (Epic 05); adding it as a dead row would read as unfinished.

import 'package:flutter/material.dart';

import '../../core/data/repositories.dart';
import '../../core/domain/models.dart';
import '../../core/i18n/l10n/app_localizations.dart';
import '../../core/settings/locale_store.dart';
import '../../core/settings/numerals_store.dart';
import '../../core/theme/tokens.g.dart';
import '../members/members_screen.dart';
import 'about_screen.dart';
import 'delete_account_screen.dart';
import 'language_screen.dart';
import 'mess_profile_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({
    super.key,
    required this.session,
    required this.members,
    required this.localeController,
    required this.numerals,
  });

  final Session session;
  final MembersRepository members;
  final LocaleController localeController;
  final NumeralsController numerals;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final mess = session.messes.first;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(TinBelaSpace.lg),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: TinBelaSpace.md),
            child: Text(
              mess.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: TinBelaColors.ink,
              ),
            ),
          ),
          _MenuRow(
            icon: Icons.group_outlined,
            label: l.membersTitle,
            onTap: () => _push(context, MembersScreen(messId: mess.id, members: members)),
          ),
          _MenuRow(
            icon: Icons.storefront_outlined,
            label: l.messProfileTitle,
            onTap: () => _push(context, MessProfileScreen(mess: mess)),
          ),
          _MenuRow(
            icon: Icons.translate_outlined,
            label: l.languageTitle,
            onTap: () => _push(
              context,
              LanguageScreen(localeController: localeController, numerals: numerals),
            ),
          ),
          _MenuRow(
            icon: Icons.info_outline,
            label: l.aboutTitle,
            onTap: () => _push(context, const AboutScreen()),
          ),
          const SizedBox(height: TinBelaSpace.lg),
          // Play requires account deletion be reachable from inside the app.
          // The screen itself (task 13.8) is founder-owned (★).
          _MenuRow(
            icon: Icons.delete_outline,
            label: l.deleteAccountTitle,
            tone: _RowTone.alert,
            onTap: () => _push(context, const DeleteAccountScreen()),
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

enum _RowTone { normal, alert }

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.tone = _RowTone.normal,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final _RowTone tone;

  @override
  Widget build(BuildContext context) {
    final color = tone == _RowTone.alert ? TinBelaColors.alert : TinBelaColors.ink;
    return Padding(
      padding: const EdgeInsets.only(bottom: TinBelaSpace.sm),
      child: Material(
        color: TinBelaColors.card,
        borderRadius: BorderRadius.circular(TinBelaRadius.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(TinBelaRadius.card),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: TinBelaTouch.min),
            child: Padding(
              padding: const EdgeInsets.all(TinBelaSpace.lg),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 22),
                  const SizedBox(width: TinBelaSpace.lg),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(fontSize: 16, color: color),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: TinBelaColors.inkMuted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
