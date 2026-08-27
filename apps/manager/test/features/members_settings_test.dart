// Epic 13 — members list, add-member flow, and the settings screens.
//
// These assert the product-visible rules (invite state at a glance; the numeral
// toggle is instant), not pixels.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tinbela_manager/core/data/repositories.dart';
import 'package:tinbela_manager/core/domain/models.dart';
import 'package:tinbela_manager/core/i18n/l10n/app_localizations.dart';
import 'package:tinbela_manager/core/settings/numerals_store.dart';
import 'package:tinbela_manager/features/members/members_screen.dart';
import 'package:tinbela_manager/features/settings/about_screen.dart';
import 'package:tinbela_manager/features/settings/language_screen.dart';
import 'package:tinbela_manager/core/settings/locale_store.dart';

Widget _wrap(Widget child) => MaterialApp(
      locale: const Locale('bn'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    );

class _FakeMembers implements MembersRepository {
  _FakeMembers(this._members);
  final List<Member> _members;

  @override
  Future<List<Member>> list({required String messId}) async => _members;

  @override
  Future<({Member member, String inviteLink})> add({
    required String messId,
    required String displayName,
    String? phoneE164,
  }) async =>
      (
        member: Member(id: 'n', displayName: displayName, role: MemberRole.member),
        inviteLink: 'https://tinbela.app/j/AbC',
      );
}

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async => null);
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('13.1 members list', () {
    testWidgets('shows each member with its invite state at a glance',
        (tester) async {
      final members = _FakeMembers([
        const Member(id: 'a', displayName: 'রফিকুল', role: MemberRole.manager),
        const Member(
          id: 'b',
          displayName: 'সাদিয়া',
          role: MemberRole.member,
          inviteProgress: InviteProgress.sent,
        ),
        const Member(
          id: 'c',
          displayName: 'তানভীর',
          role: MemberRole.member,
          inviteProgress: InviteProgress.linked,
        ),
      ]);

      await tester.pumpWidget(_wrap(MembersScreen(messId: 'm1', members: members)));
      await tester.pumpAndSettle();

      expect(find.text('রফিকুল'), findsOneWidget);
      expect(find.text('ম্যানেজার'), findsOneWidget); // manager badge
      expect(find.text('পাঠানো'), findsOneWidget); // invite sent
      expect(find.text('যুক্ত'), findsOneWidget); // linked/joined
    });
  });

  group('13.7 language & numerals', () {
    testWidgets('the numeral toggle flips the choice instantly', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final numerals = NumeralsController(await NumeralsStore.open());
      final locale = LocaleController(await LocaleStore.open());
      expect(numerals.useBanglaNumerals, isTrue); // Bangla by default

      await tester.pumpWidget(_wrap(
        LanguageScreen(localeController: locale, numerals: numerals),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('123 (ইংরেজি)'));
      await tester.pumpAndSettle();

      expect(numerals.useBanglaNumerals, isFalse);
    });
  });

  group('13.10 about', () {
    testWidgets('names the version and the maker', (tester) async {
      await tester.pumpWidget(_wrap(AboutScreen(launchUrl: (_) async => true)));
      await tester.pumpAndSettle();

      expect(find.textContaining('সংস্করণ'), findsOneWidget); // "Version …"
      expect(find.textContaining('Droid Builder'), findsOneWidget);
    });
  });
}
