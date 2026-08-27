// Epic 09 -- onboarding screens.
//
// These assert the product rules the screens exist to carry, not their
// pixels. Each test names the rule, because these are the rules most likely
// to be "tidied up" by someone reading the code without the brief.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinbela_manager/core/i18n/l10n/app_localizations.dart';
import 'package:tinbela_manager/core/theme/tokens.g.dart';
import 'package:tinbela_manager/core/widgets/demo_banner.dart';
import 'package:tinbela_manager/core/widgets/tab_empty_states.dart';
import 'package:tinbela_manager/features/onboarding/how_it_works_screen.dart';
import 'package:tinbela_manager/features/onboarding/invite_screen.dart';
import 'package:tinbela_manager/features/onboarding/sign_in_screen.dart';
import 'package:tinbela_manager/features/onboarding/welcome_screen.dart';

Widget _wrap(Widget child, {Locale locale = const Locale('bn')}) => MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    );

void main() {
  // Clipboard goes through a platform channel that no test binding answers by
  // default, so the await inside the copy handler never completes and the
  // toast after it never runs. Answering it here is what makes "confirmation
  // is a toast" testable at all.
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('09.1 welcome', () {
    testWidgets('offers bn and en, with bn selected by default',
        (tester) async {
      await tester.pumpWidget(_wrap(WelcomeScreen(
        locale: const Locale('bn'),
        onGetStarted: () {},
        onLocaleSelected: (_) {},
      )));

      expect(find.text('বাংলা'), findsOneWidget);
      // English names itself in both locales. Never translated.
      expect(find.text('English'), findsOneWidget);
      expect(find.text('শুরু করুন'), findsOneWidget);
    });

    testWidgets('does NOT promise a free trial', (tester) async {
      // The prototype's line reads "বাংলা · English · Free trial ৩০ দিন".
      // v1.0 has no billing at all (ADR-0010); purchase is P5. A trial
      // promise here would be the app's first sentence and it would be
      // untrue. Raised in the screen's own header comment.
      await tester.pumpWidget(_wrap(WelcomeScreen(
        locale: const Locale('bn'),
        onGetStarted: () {},
        onLocaleSelected: (_) {},
      )));

      expect(find.textContaining('trial'), findsNothing);
      expect(find.textContaining('ট্রায়াল'), findsNothing);
    });

    testWidgets('selecting a language reports the choice', (tester) async {
      Locale? chosen;
      await tester.pumpWidget(_wrap(WelcomeScreen(
        locale: const Locale('bn'),
        onGetStarted: () {},
        onLocaleSelected: (l) => chosen = l,
      )));

      await tester.tap(find.text('English'));
      expect(chosen, const Locale('en'));
    });

    testWidgets('the language targets meet the minimum touch size',
        (tester) async {
      // Two short words side by side are the easiest thing in the app to
      // mis-tap.
      await tester.pumpWidget(_wrap(WelcomeScreen(
        locale: const Locale('bn'),
        onGetStarted: () {},
        onLocaleSelected: (_) {},
      )));

      for (final label in ['বাংলা', 'English']) {
        final size = tester.getSize(
          find.ancestor(of: find.text(label), matching: find.byType(InkWell)),
        );
        expect(size.height, greaterThanOrEqualTo(TinBelaTouch.min),
            reason: '$label is under the minimum touch height');
      }
    });
  });

  group('09.2 sign-in', () {
    testWidgets('one tap signs in and hands off to the shell', (tester) async {
      var signedIn = false;
      await tester.pumpWidget(_wrap(SignInScreen(
        onSignIn: () async => true,
        onSignedIn: () => signedIn = true,
      )));

      await tester.tap(find.text('Google দিয়ে সাইন ইন'));
      await tester.pumpAndSettle();

      expect(signedIn, isTrue);
    });

    testWidgets('has no phone or OTP field — ADR-0009', (tester) async {
      // The prototype drew phone + OTP. ADR-0009 replaced it with Google, so a
      // text field on this screen would be the app re-growing the SMS path.
      await tester.pumpWidget(_wrap(SignInScreen(
        onSignIn: () async => true,
        onSignedIn: () {},
      )));

      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('backing out of the picker is not an error', (tester) async {
      // Dismissing the Google sheet returns false. It is a decision, not a
      // failure: no toast, and no hand-off.
      var signedIn = false;
      await tester.pumpWidget(_wrap(SignInScreen(
        onSignIn: () async => false,
        onSignedIn: () => signedIn = true,
      )));

      await tester.tap(find.text('Google দিয়ে সাইন ইন'));
      await tester.pumpAndSettle();

      expect(signedIn, isFalse);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('a real failure shows a retry, never a dead end',
        (tester) async {
      var signedIn = false;
      await tester.pumpWidget(_wrap(SignInScreen(
        onSignIn: () async => throw Exception('network'),
        onSignedIn: () => signedIn = true,
      )));

      await tester.tap(find.text('Google দিয়ে সাইন ইন'));
      await tester.pumpAndSettle();

      expect(signedIn, isFalse);
      expect(find.text('সাইন ইন হয়নি, আবার চেষ্টা করুন'), findsOneWidget);
    });
  });

  group('09.4 explainer', () {
    testWidgets('is skippable', (tester) async {
      // It sits inside a flow whose gate is 90 seconds end to end.
      var skipped = false;
      await tester.pumpWidget(_wrap(HowItWorksScreen(
        onContinue: () {},
        onSkip: () => skipped = true,
      )));

      await tester.tap(find.text('এড়িয়ে যান'));
      expect(skipped, isTrue);
    });

    testWidgets('states the product idea, not a feature list', (tester) async {
      await tester.pumpWidget(_wrap(HowItWorksScreen(
        onContinue: () {},
        onSkip: () {},
      )));

      expect(find.textContaining('ডিফল্ট প্যাটার্ন'), findsOneWidget);
      expect(find.textContaining('ব্যতিক্রম'), findsOneWidget);
    });
  });

  group('09.5 invite', () {
    testWidgets('shows the link and puts Messenger before WhatsApp',
        (tester) async {
      // Ordering is the task's Done-when: Messenger is where Bangladeshi
      // mess groups actually live.
      await tester.pumpWidget(_wrap(InviteScreen(
        messName: 'নীলক্ষেত মেস',
        inviteLink: 'https://tinbela.app/j/AbC123',
        onDone: () {},
        launchUrl: (_) async => true,
      )));

      expect(find.text('https://tinbela.app/j/AbC123'), findsOneWidget);

      final messenger = tester.getTopLeft(find.text('Messenger'));
      final whatsApp = tester.getTopLeft(find.text('WhatsApp'));
      expect(messenger.dx, lessThan(whatsApp.dx));
    });

    testWidgets('Messenger opens the Messenger deep link', (tester) async {
      Uri? launched;
      await tester.pumpWidget(_wrap(InviteScreen(
        messName: 'মেস',
        inviteLink: 'https://tinbela.app/j/AbC123',
        onDone: () {},
        launchUrl: (uri) async {
          launched = uri;
          return true;
        },
      )));

      await tester.tap(find.text('Messenger'));
      await tester.pumpAndSettle();

      expect(launched?.scheme, 'fb-messenger');
      expect(launched.toString(), contains(Uri.encodeComponent('https://tinbela.app/j/AbC123')));
    });

    testWidgets('falls back to the clipboard when the app is missing',
        (tester) async {
      // The link is the member's only credential. A dead share button would
      // strand the manager with no way to send it.
      await tester.pumpWidget(_wrap(InviteScreen(
        messName: 'মেস',
        inviteLink: 'https://tinbela.app/j/AbC123',
        onDone: () {},
        launchUrl: (_) async => false,
      )));

      await tester.tap(find.text('WhatsApp'));
      await tester.pumpAndSettle();

      expect(find.text('লিংক কপি হয়েছে'), findsOneWidget);
    });

    testWidgets('confirmation is a toast, never a dialog', (tester) async {
      await tester.pumpWidget(_wrap(InviteScreen(
        messName: 'মেস',
        inviteLink: 'https://tinbela.app/j/AbC123',
        onDone: () {},
        launchUrl: (_) async => true,
      )));

      await tester.tap(find.text('কপি'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  group('09.7 demo banner', () {
    testWidgets('promises poke-safety and offers one way out', (tester) async {
      var opened = false;
      await tester.pumpWidget(_wrap(
        Scaffold(body: DemoBanner(onOpenOwnMess: () => opened = true)),
      ));

      expect(find.textContaining('ডেমো মেস'), findsOneWidget);
      expect(find.textContaining('কিছুই ভাঙবে না'), findsOneWidget);

      await tester.tap(find.text('নিজের মেস খুলুন'));
      expect(opened, isTrue);
    });
  });

  group('09.8 empty states', () {
    testWidgets('each tab offers exactly ONE action', (tester) async {
      // Two actions on an empty screen is a menu, and a menu is what a
      // first-time user is least able to read.
      for (final widget in [
        GridEmptyState(onGoToToday: () {}),
        AccountsEmptyState(onAddBazar: () {}),
        MembersEmptyState(onAddMember: () {}),
      ]) {
        await tester.pumpWidget(_wrap(Scaffold(body: widget)));
        expect(find.byType(FilledButton), findsOneWidget,
            reason: '${widget.runtimeType} must offer exactly one action');
      }
    });

    testWidgets('a mess of one is a state, not a failure', (tester) async {
      // "আপনি একাই আছেন", not "কোনো সদস্য নেই". Running solo is supported.
      await tester.pumpWidget(_wrap(
        Scaffold(body: MembersEmptyState(onAddMember: () {})),
      ));

      expect(find.text('আপনি একাই আছেন'), findsOneWidget);
    });
  });
}
