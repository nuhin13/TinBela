// Shell + root routing. Epic 08 tasks 08.7 and 08.1.
//
// Guards the two things AGENTS.md calls scope changes rather than UI changes:
// exactly four tabs, and every label coming from an ARB key (bn by default).
// Also guards where a manager LANDS, which is the one decision that stands
// between a returning user and their mess.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinbela_manager/app.dart';
import 'package:tinbela_manager/core/api/api_error.dart';
import 'package:tinbela_manager/core/config/app_config.dart';
import 'package:tinbela_manager/core/data/repositories.dart';
import 'package:tinbela_manager/core/domain/models.dart';
import 'package:tinbela_manager/core/settings/locale_store.dart';
import 'package:tinbela_manager/features/onboarding/welcome_screen.dart';

const _user = User(
  id: 'u1',
  name: 'রফিকুল',
  phoneE164: '+8801711000001',
  locale: 'bn',
  useBanglaNumerals: true,
);

const _mess = Mess(id: 'm1', name: 'নীলক্ষেত মেস', kind: MessKind.mess);

class _FakeSession implements SessionRepository {
  _FakeSession(this._result);
  final Object _result;

  @override
  Future<Session> getMe() async {
    if (_result is Session) return _result;
    throw _result;
  }
}

class _FakeMesses implements MessesRepository {
  @override
  Future<({Mess mess, String inviteLink})> create({
    required String name,
    required int slotCount,
  }) async =>
      (mess: _mess, inviteLink: 'https://tinbela.app/j/x');
}

Future<Widget> _app(Object sessionResult) async {
  SharedPreferences.setMockInitialValues({});
  final store = await LocaleStore.open();
  return TinBelaApp(
    config: AppConfig(
      flavor: Flavor.dev,
      apiBaseUrl: Uri.parse('http://localhost:8080'),
      devFirebaseUid: 'dev-8801711000001',
    ),
    localeController: LocaleController(store),
    session: _FakeSession(sessionResult),
    messes: _FakeMesses(),
  );
}

void main() {
  testWidgets('a manager with a mess lands on the four v1.0 tabs, in Bangla',
      (tester) async {
    await tester.pumpWidget(
      await _app(const Session(user: _user, messes: [_mess])),
    );
    await tester.pumpAndSettle();

    expect(find.byType(NavigationDestination), findsNWidgets(4));
    for (final label in ['আজ', 'খাতা', 'হিসাব', 'আরও']) {
      expect(find.text(label), findsWidgets, reason: 'missing tab $label');
    }
  });

  testWidgets('tapping a tab switches the body', (tester) async {
    await tester.pumpWidget(
      await _app(const Session(user: _user, messes: [_mess])),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
    await tester.pumpAndSettle();

    // The selected destination and the placeholder heading both read হিসাব.
    expect(find.text('হিসাব'), findsNWidgets(2));
  });

  testWidgets('a manager with no mess yet goes to onboarding', (tester) async {
    await tester.pumpWidget(
      await _app(const Session(user: _user, messes: [])),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNothing);
  });

  testWidgets('an unauthenticated caller is onboarding, not an error',
      (tester) async {
    // Having no account yet is the normal first-launch state. Showing an
    // error screen with a retry button would strand every new user.
    await tester.pumpWidget(await _app(
      const ApiException(
        code: ApiErrorCode.unauthenticated,
        message: 'আবার সাইন ইন করুন',
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('a real failure IS an error, with a retry', (tester) async {
    // The distinction matters: "we could not reach the server" must not be
    // silently turned into "you have no account", which would invite a
    // manager with an existing mess to create a second one.
    await tester.pumpWidget(await _app(
      const ApiException(
        code: ApiErrorCode.unavailable,
        message: 'ইন্টারনেট সংযোগ নেই',
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(WelcomeScreen), findsNothing);
    expect(find.text('আবার চেষ্টা করুন'), findsOneWidget);
  });
}
