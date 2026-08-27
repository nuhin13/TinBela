// Epic 13 task 13.8 — in-app account deletion. FOUNDER-OWNED (★).
//
// The Done-when is "works in-app and matches the web page", which needs a
// DeleteAccount RPC and consequences copy that a Play reviewer reads word for
// word — that is the founder's to write, not an agent's to guess. This screen
// is the reachable entry point (Play requires deletion be findable in-app) and
// routes to the web deletion page (task 15.6) in the meantime, rather than
// faking an irreversible action.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../../core/i18n/l10n/app_localizations.dart';
import '../../core/theme/tokens.g.dart';
import '../../core/widgets/async_states.dart';

const String _deleteUrl = 'https://tinbela.app/delete-account';

// A wrapper, not the tear-off (url_launcher's launchUrl has optional named args).
Future<bool> _launchUrl(Uri uri) => launcher.launchUrl(uri);

class DeleteAccountScreen extends StatelessWidget {
  const DeleteAccountScreen({super.key, this.launchUrl = _launchUrl});

  final Future<bool> Function(Uri) launchUrl;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.deleteAccountTitle),
        backgroundColor: TinBelaColors.card,
      ),
      body: ListView(
        padding: const EdgeInsets.all(TinBelaSpace.lg),
        children: [
          Text(
            l.deleteAccountPending,
            style: const TextStyle(fontSize: 15, color: TinBelaColors.ink),
          ),
          const SizedBox(height: TinBelaSpace.xl),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: TinBelaTouch.min),
            child: OutlinedButton(
              onPressed: () async {
                final ok = await launchUrl(Uri.parse(_deleteUrl));
                if (!ok && context.mounted) showToast(context, l.errorGeneric);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: TinBelaColors.alert),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TinBelaRadius.button),
                ),
              ),
              child: Text(
                l.deleteAccountWebButton,
                style: const TextStyle(
                  color: TinBelaColors.alert,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
