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
import 'sign_in_screen.dart';
import 'welcome_screen.dart';

// splash → language → sign-in → 3 questions → how-it-works → invite
// (UI_SPEC §2). Sign-in (09.2) sits between welcome and the mess setup because
// CreateMess needs an authenticated caller.
enum _Step { welcome, signIn, explainer, setup, invite }

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({
    super.key,
    required this.session,
    required this.messes,
    required this.onSignIn,
    required this.locale,
    required this.onLocaleSelected,
    required this.onFinished,
  });

  final SessionRepository session;
  final MessesRepository messes;

  /// Runs interactive Google Sign-In (task 09.2). True once signed in.
  final Future<bool> Function() onSignIn;

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

  /// True while GetMe is re-checked right after sign-in, to route a returning
  /// manager (who already has a mess) straight to their mess.
  bool _routing = false;

  /// After a successful sign-in the caller might be a brand-new manager or one
  /// reinstalling. GetMe decides: an existing mess means skip setup entirely
  /// and hand off to the shell; none means carry on to create one.
  Future<void> _afterSignIn() async {
    setState(() {
      _routing = true;
      _error = null;
    });
    try {
      final session = await widget.session.getMe();
      if (!mounted) return;
      if (!session.needsOnboarding) {
        // Existing mess: hand off to the shell. This widget goes away, so the
        // routing flag is left as-is on purpose.
        widget.onFinished(session.messes.first);
        return;
      }
      setState(() {
        _step = _Step.explainer;
        _routing = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      // Keep _routing true so the error view (with retry) shows, rather than
      // falling back to the sign-in screen and losing the failure.
      setState(() => _error = e);
    }
  }

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
    // Re-checking GetMe after sign-in: a full-screen spinner, never a flash of
    // the setup form the returning manager is about to skip.
    if (_routing) {
      if (_error != null) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(TinBelaSpace.xl),
              child: ErrorState(error: _error, onRetry: _afterSignIn),
            ),
          ),
        );
      }
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return switch (_step) {
      _Step.welcome => WelcomeScreen(
          locale: widget.locale,
          onLocaleSelected: widget.onLocaleSelected,
          onGetStarted: () => setState(() => _step = _Step.signIn),
        ),
      _Step.signIn => SignInScreen(
          onSignIn: widget.onSignIn,
          onSignedIn: _afterSignIn,
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
