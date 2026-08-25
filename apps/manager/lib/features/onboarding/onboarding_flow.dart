// Epic 09 -- the flow the screens live in.
//
// welcome -> explainer -> (09.3 ★ mess setup) -> invite -> the app.
//
// The gate is 90 seconds for someone who has never seen the app, which is
// why every step here is skippable or one tap. Nothing may be added to this
// sequence without measuring it again.
//
// WHAT IS STUBBED, AND WHY
//
// Step 3 is the 3-question mess setup (09.3) and it is ★ -- the founder
// writes it, and "no fourth question, ever" is a decision an agent must not
// be able to erode. Until it lands, `_MessSetupPlaceholder` collects the one
// field CreateMess cannot default (the name) so the rest of the flow is
// exercisable end to end. It is clearly marked and is not a design.

import 'package:flutter/material.dart';

import '../../core/api/api_error.dart';
import '../../core/data/repositories.dart';
import '../../core/domain/models.dart';
import '../../core/i18n/l10n/app_localizations.dart';
import '../../core/theme/tokens.g.dart';
import '../../core/widgets/async_states.dart';
import 'how_it_works_screen.dart';
import 'invite_screen.dart';
import 'welcome_screen.dart';

enum _Step { welcome, explainer, setup, invite }

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({
    super.key,
    required this.messes,
    required this.locale,
    required this.onLocaleSelected,
    required this.onFinished,
  });

  final MessesRepository messes;
  final Locale locale;
  final ValueChanged<Locale> onLocaleSelected;

  /// Called once the manager has a mess. The shell takes over from here.
  final ValueChanged<Mess> onFinished;

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  _Step _step = _Step.welcome;
  Mess? _created;
  String? _inviteLink;
  bool _submitting = false;
  ApiException? _error;

  Future<void> _createMess(String name) async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final result = await widget.messes.create(name: name, slotCount: 3);
      if (!mounted) return;
      setState(() {
        _created = result.mess;
        _inviteLink = result.inviteLink;
        _step = _Step.invite;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_step) {
      _Step.welcome => WelcomeScreen(
          locale: widget.locale,
          onLocaleSelected: widget.onLocaleSelected,
          onGetStarted: () => setState(() => _step = _Step.explainer),
        ),
      _Step.explainer => HowItWorksScreen(
          onContinue: () => setState(() => _step = _Step.setup),
          onSkip: () => setState(() => _step = _Step.setup),
        ),
      _Step.setup => _MessSetupPlaceholder(
          submitting: _submitting,
          error: _error,
          onSubmit: _createMess,
        ),
      _Step.invite => InviteScreen(
          messName: _created?.name ?? '',
          inviteLink: _inviteLink ?? '',
          onDone: () => widget.onFinished(_created!),
        ),
    };
  }
}

/// TODO(09.3 ★): replace with the real 3-question setup — name · ধরন · কয় বেলা.
///
/// Deliberately plain. It exists so the flow can be walked end to end against
/// a running API before the ★ screen is written, and it should be deleted the
/// moment that screen lands. Slot count is hard-coded to 3 here, which is the
/// third question this screen is NOT asking.
class _MessSetupPlaceholder extends StatefulWidget {
  const _MessSetupPlaceholder({
    required this.submitting,
    required this.error,
    required this.onSubmit,
  });

  final bool submitting;
  final ApiException? error;
  final ValueChanged<String> onSubmit;

  @override
  State<_MessSetupPlaceholder> createState() => _MessSetupPlaceholderState();
}

class _MessSetupPlaceholderState extends State<_MessSetupPlaceholder> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
              // Developer scaffolding, rendered in English on purpose: it is
              // not product copy and must not be mistaken for it.
              const Text(
                // ignore: hardcoded
                'Task 09.3 - the real 3-question setup goes here',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: TinBelaColors.inkMuted),
              ),
              const SizedBox(height: TinBelaSpace.lg),
              TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(TinBelaRadius.button),
                  ),
                ),
              ),
              if (widget.error != null) ...[
                const SizedBox(height: TinBelaSpace.lg),
                ErrorState(error: widget.error),
              ],
              const SizedBox(height: TinBelaSpace.lg),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: FilledButton(
                  onPressed: widget.submitting
                      ? null
                      : () {
                          final name = _controller.text.trim();
                          if (name.isNotEmpty) widget.onSubmit(name);
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: TinBelaColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(TinBelaRadius.card),
                    ),
                  ),
                  child: widget.submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: TinBelaColors.card,
                          ),
                        )
                      : Text(l.createMess),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
