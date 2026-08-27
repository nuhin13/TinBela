// Epic 13 tasks 13.1 (members list) + 13.2 (add member + immediate share).
//
// The invite state is visible at a glance (13.1's Done-when): a chip per
// member — পাঠানো / খুলেছেন / যুক্ত — so a manager can see who has actually
// joined without opening anything.
//
// NOT BUILT HERE, deliberately:
//   13.3 pattern editor — needs SetPatterns (Epic 05, engine-blocked).
//   13.4 remove/leave   — the LeaveMember RPC exists (04.8) but its Dart client
//                         is not generated yet (needs `make proto`); a remove
//                         action wired to a type that does not exist would not
//                         compile, so it waits rather than ship a dead button.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../../core/data/repositories.dart';
import '../../core/domain/models.dart';
import '../../core/i18n/l10n/app_localizations.dart';
import '../../core/theme/tokens.g.dart';
import '../../core/widgets/async_states.dart';
import '../../core/widgets/tab_empty_states.dart';

// A wrapper, not the tear-off: url_launcher's launchUrl carries optional named
// params, and the field type is the bare `Future<bool> Function(Uri)`.
Future<bool> _launchUrl(Uri uri) => launcher.launchUrl(uri);

class MembersScreen extends StatefulWidget {
  const MembersScreen({
    super.key,
    required this.messId,
    required this.members,
    this.launchUrl = _launchUrl,
  });

  final String messId;
  final MembersRepository members;

  /// Injected so a test can assert which app a share opened without launching
  /// one — sharing the invite is the growth loop (ADR-0009).
  final Future<bool> Function(Uri) launchUrl;

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  late Future<List<Member>> _future = widget.members.list(messId: widget.messId);

  void _reload() =>
      setState(() => _future = widget.members.list(messId: widget.messId));

  Future<void> _add() async {
    final result = await showModalBottomSheet<({Member member, String inviteLink})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: TinBelaColors.card,
      builder: (_) => _AddMemberSheet(messId: widget.messId, members: widget.members),
    );
    if (result == null || !mounted) return;
    _reload();
    await _showInvite(result.member.displayName, result.inviteLink);
  }

  Future<void> _showInvite(String name, String link) async {
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: TinBelaColors.card,
      builder: (_) => _InviteSheet(name: name, link: link, launchUrl: widget.launchUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.membersTitle),
        backgroundColor: TinBelaColors.card,
      ),
      body: FutureBuilder<List<Member>>(
        future: _future,
        builder: (context, snapshot) => AsyncStateView<List<Member>>(
          snapshot: snapshot,
          onRetry: _reload,
          builder: (context, members) => members.isEmpty
              ? MembersEmptyState(onAddMember: _add)
              : ListView.separated(
                  padding: const EdgeInsets.all(TinBelaSpace.lg),
                  itemCount: members.length,
                  separatorBuilder: (_, __) => const SizedBox(height: TinBelaSpace.sm),
                  itemBuilder: (_, i) => _MemberRow(member: members[i]),
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        backgroundColor: TinBelaColors.primary,
        foregroundColor: TinBelaColors.card,
        icon: const Icon(Icons.person_add_alt_1),
        label: Text(l.addMember),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isManager = member.role == MemberRole.manager;
    return Container(
      padding: const EdgeInsets.all(TinBelaSpace.lg),
      decoration: BoxDecoration(
        color: TinBelaColors.card,
        borderRadius: BorderRadius.circular(TinBelaRadius.card),
        border: Border.all(color: TinBelaColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: TinBelaColors.ink,
                  ),
                ),
                if (member.phoneE164 != null && member.phoneE164!.isNotEmpty) ...[
                  const SizedBox(height: TinBelaSpace.xs),
                  Text(
                    member.phoneE164!,
                    style: const TextStyle(fontSize: 13, color: TinBelaColors.inkMuted),
                  ),
                ],
              ],
            ),
          ),
          if (isManager)
            _Chip(label: l.roleManager, tone: _ChipTone.manager)
          else
            _InviteChip(progress: member.inviteProgress),
        ],
      ),
    );
  }
}

class _InviteChip extends StatelessWidget {
  const _InviteChip({required this.progress});

  final InviteProgress progress;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return switch (progress) {
      InviteProgress.linked => _Chip(label: l.inviteLinked, tone: _ChipTone.linked),
      InviteProgress.opened => _Chip(label: l.inviteOpened, tone: _ChipTone.pending),
      InviteProgress.sent => _Chip(label: l.inviteSent, tone: _ChipTone.pending),
      InviteProgress.unknown => _Chip(label: l.inviteSent, tone: _ChipTone.pending),
    };
  }
}

enum _ChipTone { manager, linked, pending }

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.tone});

  final String label;
  final _ChipTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      _ChipTone.manager => (TinBelaColors.tint, TinBelaColors.primary),
      _ChipTone.linked => (TinBelaColors.tint, TinBelaColors.primary),
      _ChipTone.pending => (TinBelaColors.surface, TinBelaColors.inkMuted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TinBelaSpace.md,
        vertical: TinBelaSpace.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(TinBelaRadius.chip),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

class _AddMemberSheet extends StatefulWidget {
  const _AddMemberSheet({required this.messId, required this.members});

  final String messId;
  final MembersRepository members;

  @override
  State<_AddMemberSheet> createState() => _AddMemberSheetState();
}

class _AddMemberSheetState extends State<_AddMemberSheet> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final phone = _phone.text.trim();
    setState(() => _submitting = true);
    try {
      final result = await widget.members.add(
        messId: widget.messId,
        displayName: name,
        phoneE164: phone.isEmpty ? null : phone,
      );
      if (mounted) Navigator.of(context).pop(result);
    } catch (_) {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: TinBelaSpace.xl,
        right: TinBelaSpace.xl,
        top: TinBelaSpace.xl,
        bottom: MediaQuery.of(context).viewInsets.bottom + TinBelaSpace.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.addMember,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: TinBelaColors.ink,
            ),
          ),
          const SizedBox(height: TinBelaSpace.lg),
          TextField(
            controller: _name,
            autofocus: true,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l.memberNameLabel,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TinBelaRadius.button),
              ),
            ),
          ),
          const SizedBox(height: TinBelaSpace.md),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: l.memberPhoneOptional,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(TinBelaRadius.button),
              ),
            ),
          ),
          const SizedBox(height: TinBelaSpace.lg),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: TinBelaTouch.min),
            child: FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: TinBelaColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TinBelaRadius.button),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: TinBelaColors.card,
                      ),
                    )
                  : Text(l.addMemberSend),
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteSheet extends StatelessWidget {
  const _InviteSheet({
    required this.name,
    required this.link,
    required this.launchUrl,
  });

  final String name;
  final String link;
  final Future<bool> Function(Uri) launchUrl;

  Future<void> _share(BuildContext context, Uri uri) async {
    final l = AppLocalizations.of(context);
    final opened = await launchUrl(uri);
    if (!opened && context.mounted) {
      // Fall back to the clipboard: the link is the member's only credential.
      await Clipboard.setData(ClipboardData(text: link));
      if (context.mounted) showToast(context, l.copied);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(TinBelaSpace.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.inviteLinkLabel,
            style: const TextStyle(fontSize: 14, color: TinBelaColors.inkMuted),
          ),
          const SizedBox(height: TinBelaSpace.sm),
          Container(
            decoration: BoxDecoration(
              color: TinBelaColors.surface,
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
          ),
          const SizedBox(height: TinBelaSpace.lg),
          Row(
            children: [
              // Messenger first — where Bangladeshi mess groups live (09.5).
              Expanded(
                child: _ShareButton(
                  label: l.shareMessenger,
                  onTap: () => _share(
                    context,
                    Uri.parse('fb-messenger://share?link=${Uri.encodeComponent(link)}'),
                  ),
                ),
              ),
              const SizedBox(width: TinBelaSpace.md),
              Expanded(
                child: _ShareButton(
                  label: l.shareWhatsApp,
                  onTap: () => _share(
                    context,
                    Uri.parse('whatsapp://send?text=${Uri.encodeComponent(link)}'),
                  ),
                ),
              ),
            ],
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
