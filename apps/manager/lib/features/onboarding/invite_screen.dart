// Task 09.5 -- "মেস তৈরি হয়েছে 🎉" + the invite link. Prototype frame 1d.
//
// This screen is the growth loop. Every member who opens the link is a free
// acquisition impression, so the share targets are not a convenience -- they
// are the distribution channel (ADR-0009: the link IS the credential).
//
// Messenger is listed first because it is where Bangladeshi mess groups
// actually live. That ordering is the task's Done-when, not a preference.
//
// NOT BUILT HERE: the "সদস্য না থাকলেও চলবে" solo-manager line and its
// one-tap path. It sits on this screen in the prototype but it is task 09.6,
// which is ★ and belongs to the founder. The gap is marked below rather than
// filled with a guess.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/i18n/l10n/app_localizations.dart';
import '../../core/theme/tokens.g.dart';
import '../../core/widgets/async_states.dart';

class InviteScreen extends StatelessWidget {
  const InviteScreen({
    super.key,
    required this.messName,
    required this.inviteLink,
    required this.onDone,
    this.launchUrl = launchUrl_,
  });

  final String messName;
  final String inviteLink;
  final VoidCallback onDone;

  /// Injected so a test can assert WHICH app was launched without opening
  /// one. Sharing is the whole point of this screen, so "did it try to open
  /// Messenger" is a behaviour worth asserting.
  final Future<bool> Function(Uri) launchUrl;

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
              const Spacer(),
              Text(
                l.messCreated,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: TinBelaColors.ink,
                ),
              ),
              const SizedBox(height: TinBelaSpace.sm),
              Text(
                messName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: TinBelaColors.inkMuted,
                ),
              ),
              const SizedBox(height: TinBelaSpace.xl),
              Text(
                l.inviteLinkLabel,
                style: const TextStyle(
                  fontSize: 14,
                  color: TinBelaColors.inkMuted,
                ),
              ),
              const SizedBox(height: TinBelaSpace.sm),
              _LinkRow(link: inviteLink),
              const SizedBox(height: TinBelaSpace.lg),
              Row(
                children: [
                  // Messenger first (task 09.5's Done-when).
                  Expanded(
                    child: _ShareButton(
                      label: l.shareMessenger,
                      onTap: () => _share(context, _messengerUri(inviteLink)),
                    ),
                  ),
                  const SizedBox(width: TinBelaSpace.md),
                  Expanded(
                    child: _ShareButton(
                      label: l.shareWhatsApp,
                      onTap: () => _share(context, _whatsAppUri(inviteLink)),
                    ),
                  ),
                ],
              ),

              // TODO(09.6 ★): the solo-manager line and its one-tap path
              // ("সদস্য না থাকলেও চলবে — আপনি একাই সবার মিল মার্ক করতে
              // পারবেন।") belongs here. Founder-owned; left empty rather
              // than guessed.

              const Spacer(),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: FilledButton(
                  onPressed: onDone,
                  style: FilledButton.styleFrom(
                    backgroundColor: TinBelaColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TinBelaRadius.card),
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
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _share(BuildContext context, Uri uri) async {
    final l = AppLocalizations.of(context);
    final opened = await launchUrl(uri);
    if (!opened && context.mounted) {
      // The app is not installed. Falling back to the clipboard keeps the
      // link recoverable -- it is the member's only credential, and a dead
      // share button would strand the manager with no way to send it.
      await Clipboard.setData(ClipboardData(text: inviteLink));
      if (context.mounted) showToast(context, l.copied);
    }
  }
}

/// Deep links, not a generic share sheet: the task asks for Messenger first,
/// and a system sheet orders targets by the OS's own recency heuristics.
Uri _messengerUri(String link) =>
    Uri.parse('fb-messenger://share?link=${Uri.encodeComponent(link)}');

Uri _whatsAppUri(String link) =>
    Uri.parse('whatsapp://send?text=${Uri.encodeComponent(link)}');

Future<bool> launchUrl_(Uri uri) => launchUrl(uri);

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.link});

  final String link;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: TinBelaColors.card,
        borderRadius: BorderRadius.circular(TinBelaRadius.button),
        border: Border.all(color: TinBelaColors.divider),
      ),
      padding: const EdgeInsets.only(left: TinBelaSpace.lg),
      child: Row(
        children: [
          Expanded(
            child: Text(
              link,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: TinBelaColors.ink),
            ),
          ),
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: link));
              if (context.mounted) showToast(context, l.copied);
            },
            style: TextButton.styleFrom(
              minimumSize: const Size(TinBelaTouch.min, TinBelaTouch.min),
            ),
            child: Text(
              l.copy,
              style: const TextStyle(
                color: TinBelaColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: TinBelaTouch.min),
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: TinBelaColors.divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TinBelaRadius.button),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: TinBelaColors.ink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
