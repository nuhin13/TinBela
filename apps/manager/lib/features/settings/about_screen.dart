// Epic 13 tasks 13.10 (about) and 13.9 (data export request).
//
// The privacy and terms links point at the landing site's Play-required pages
// (Epic 15). Data export is "email to you in v1.0" (13.9's Done-when): a mailto
// that opens the manager's mail app pre-addressed — no server endpoint needed,
// which is the whole point of the v1.0 shortcut.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../../core/i18n/l10n/app_localizations.dart';
import '../../core/theme/tokens.g.dart';
import '../../core/widgets/async_states.dart';

// TODO(19.x): read from package_info_plus once the release build wires it, so
// this cannot drift from pubspec. A const keeps the About screen dependency-free
// until then.
const String _appVersion = '1.0.0';
const String _supportEmail = 'support@tinbela.app';
const String _privacyUrl = 'https://tinbela.app/privacy';
const String _termsUrl = 'https://tinbela.app/terms';

// A wrapper, not the tear-off (url_launcher's launchUrl has optional named args).
Future<bool> _launchUrl(Uri uri) => launcher.launchUrl(uri);

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key, this.launchUrl = _launchUrl});

  final Future<bool> Function(Uri) launchUrl;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.aboutTitle),
        backgroundColor: TinBelaColors.card,
      ),
      body: ListView(
        padding: const EdgeInsets.all(TinBelaSpace.lg),
        children: [
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.appTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: TinBelaColors.ink,
                  ),
                ),
                const SizedBox(height: TinBelaSpace.xs),
                Text(
                  l.aboutVersion(_appVersion),
                  style: const TextStyle(fontSize: 14, color: TinBelaColors.inkMuted),
                ),
                const SizedBox(height: TinBelaSpace.xs),
                Text(
                  l.aboutDroidBuilder,
                  style: const TextStyle(fontSize: 14, color: TinBelaColors.inkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: TinBelaSpace.lg),
          _LinkRow(label: l.aboutPrivacy, onTap: () => _open(context, _privacyUrl)),
          _LinkRow(label: l.aboutTerms, onTap: () => _open(context, _termsUrl)),
          const SizedBox(height: TinBelaSpace.xl),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.dataExportTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: TinBelaColors.ink,
                  ),
                ),
                const SizedBox(height: TinBelaSpace.sm),
                Text(
                  l.dataExportBody,
                  style: const TextStyle(fontSize: 14, color: TinBelaColors.inkMuted),
                ),
                const SizedBox(height: TinBelaSpace.lg),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: TinBelaTouch.min),
                  child: OutlinedButton(
                    onPressed: () => _requestExport(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: TinBelaColors.divider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(TinBelaRadius.button),
                      ),
                    ),
                    child: Text(
                      l.dataExportButton,
                      style: const TextStyle(
                        color: TinBelaColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _open(BuildContext context, String url) async {
    final l = AppLocalizations.of(context);
    final ok = await launchUrl(Uri.parse(url));
    if (!ok && context.mounted) showToast(context, l.errorGeneric);
  }

  Future<void> _requestExport(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query: 'subject=${Uri.encodeComponent(l.dataExportSubject)}',
    );
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) showToast(context, l.errorGeneric);
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TinBelaSpace.lg),
      decoration: BoxDecoration(
        color: TinBelaColors.card,
        borderRadius: BorderRadius.circular(TinBelaRadius.card),
        border: Border.all(color: TinBelaColors.divider),
      ),
      child: child,
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                  Expanded(
                    child: Text(
                      label,
                      style: const TextStyle(fontSize: 16, color: TinBelaColors.ink),
                    ),
                  ),
                  const Icon(Icons.open_in_new, size: 18, color: TinBelaColors.inkMuted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
