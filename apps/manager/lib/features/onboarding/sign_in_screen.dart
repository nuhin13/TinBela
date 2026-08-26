// Task 09.2 -- Google Sign-In. Prototype row 2 was phone + OTP; ADR-0009
// replaced it with one-tap Google, so there is deliberately no phone field,
// no OTP keypad and no resend timer here.
//
// The screen owns nothing about Firebase: it calls [onSignIn], which returns
// whether someone is now signed in, and on success calls [onSignedIn] so the
// shell can re-run GetMe. The Google/Firebase plumbing lives in
// core/auth/firebase_auth_backend.dart.

import 'package:flutter/material.dart';

import '../../core/i18n/l10n/app_localizations.dart';
import '../../core/theme/tokens.g.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({
    super.key,
    required this.onSignIn,
    required this.onSignedIn,
  });

  /// Runs interactive sign-in. True once a manager is signed in; false when
  /// they backed out of the account picker. Throws on a real failure.
  final Future<bool> Function() onSignIn;

  /// Called after a successful sign-in, so the shell re-evaluates GetMe.
  final VoidCallback onSignedIn;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _busy = false;

  Future<void> _signIn() async {
    final l = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final signedIn = await widget.onSignIn();
      if (!mounted) return;
      // A false result is a back-out, not an error: leave the screen as it is.
      if (signedIn) widget.onSignedIn();
    } catch (_) {
      if (!mounted) return;
      // No error without a retry: the button below is the retry, and the toast
      // says what happened rather than stranding the manager on a dead screen.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.signInFailed)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(TinBelaSpace.xl),
          child: Column(
            children: [
              const Spacer(),
              const _BrandMark(),
              const SizedBox(height: TinBelaSpace.xl),
              Text(
                l.signInPrompt,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: TinBelaColors.ink,
                ),
              ),
              const SizedBox(height: TinBelaSpace.md),
              Text(
                l.signInReassure,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: TinBelaColors.inkMuted),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: TinBelaTouch.min),
                  child: FilledButton(
                    onPressed: _busy ? null : _signIn,
                    style: FilledButton.styleFrom(
                      backgroundColor: TinBelaColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(TinBelaRadius.card),
                      ),
                    ),
                    child: _busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: TinBelaColors.card,
                            ),
                          )
                        : Text(
                            l.signInWithGoogle,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: TinBelaSpace.lg),
            ],
          ),
        ),
      ),
    );
  }
}

/// The ৳ brand mark, matching the welcome screen. A glyph in a bundled font,
/// not an asset -- it costs nothing against the shell size budget.
class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: TinBelaColors.primary,
        borderRadius: BorderRadius.circular(TinBelaRadius.card),
        boxShadow: TinBelaShadow.one,
      ),
      alignment: Alignment.center,
      child: const Text(
        // The brand letter, a logo -- not translated.
        // ignore: hardcoded
        'ত',
        style: TextStyle(
          fontSize: 44,
          fontWeight: FontWeight.w600,
          color: TinBelaColors.card,
        ),
      ),
    );
  }
}
