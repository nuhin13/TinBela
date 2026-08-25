// Epic 08 task 08.8.
//
// These assert the product rules, not the pixels. Each test names the rule
// it protects, because the rules are the kind that get "cleaned up" by
// someone who reads an empty state as an absence rather than a success.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinbela_manager/core/api/api_error.dart';
import 'package:tinbela_manager/core/i18n/l10n/app_localizations.dart';
import 'package:tinbela_manager/core/theme/tokens.g.dart';
import 'package:tinbela_manager/core/widgets/async_states.dart';

Widget _wrap(Widget child) => MaterialApp(
      locale: const Locale('bn'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    );

void main() {
  group('no spinner without a skeleton', () {
    testWidgets('a waiting snapshot shows a skeleton, never a spinner',
        (tester) async {
      await tester.pumpWidget(_wrap(
        AsyncStateView<String>(
          snapshot: const AsyncSnapshot<String>.waiting(),
          builder: (_, data) => Text(data),
        ),
      ));
      await tester.pump();

      expect(find.byType(SkeletonList), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('no error without a retry', () {
    testWidgets('a retryable failure offers a retry that fires', (tester) async {
      var retried = 0;
      await tester.pumpWidget(_wrap(
        ErrorState(
          error: const ApiException(
            code: ApiErrorCode.unavailable,
            message: 'ইন্টারনেট সংযোগ নেই',
          ),
          onRetry: () => retried++,
        ),
      ));

      final retry = find.byType(FilledButton);
      expect(retry, findsOneWidget);
      await tester.tap(retry);
      expect(retried, 1);
    });

    testWidgets('a permission failure offers NO retry', (tester) async {
      // Trying again cannot make you the manager. A retry button here would
      // be a lie the user taps repeatedly.
      await tester.pumpWidget(_wrap(
        ErrorState(
          error: const ApiException(
            code: ApiErrorCode.permissionDenied,
            message: 'শুধু ম্যানেজার এটি করতে পারেন',
          ),
          onRetry: () {},
        ),
      ));

      expect(find.byType(FilledButton), findsNothing);
      // The server's message is still shown -- it explains the refusal.
      expect(find.text('শুধু ম্যানেজার এটি করতে পারেন'), findsOneWidget);
    });

    testWidgets('renders the server message rather than a client string',
        (tester) async {
      // bn is the source of truth and it lives on the server. A client that
      // writes its own copy grows a second vocabulary that drifts.
      await tester.pumpWidget(_wrap(
        const ErrorState(
          error: ApiException(
            code: ApiErrorCode.failedPrecondition,
            message: 'কাটঅফের সময় শেষ, ম্যানেজারকে বলুন',
            requestId: 'req-42',
          ),
        ),
      ));

      expect(find.text('কাটঅফের সময় শেষ, ম্যানেজারকে বলুন'), findsOneWidget);
      // The request id survives to the screen: it is what a user quotes.
      expect(find.textContaining('req-42'), findsOneWidget);
    });

    testWidgets('the retry target is at least the minimum touch size',
        (tester) async {
      await tester.pumpWidget(_wrap(
        ErrorState(
          error: const ApiException(
            code: ApiErrorCode.unavailable,
            message: 'নেই',
          ),
          onRetry: () {},
        ),
      ));

      final size = tester.getSize(find.byType(FilledButton));
      expect(size.height, greaterThanOrEqualTo(TinBelaTouch.min));
      expect(size.width, greaterThanOrEqualTo(TinBelaTouch.min));
    });
  });

  group('a zero-exception day must look FINISHED', () {
    testWidgets('the empty state states the product, and does not apologise',
        (tester) async {
      await tester.pumpWidget(_wrap(const FinishedState()));

      // Product rule, quoted in apps/manager/AGENTS.md: do not soften or
      // remove either line.
      expect(find.text('কিছু করার নেই'), findsOneWidget);
      expect(find.text('বাকি সবাই ডিফল্ট প্যাটার্নে ✓'), findsOneWidget);
    });

    testWidgets('a null payload is FINISHED, not an error', (tester) async {
      await tester.pumpWidget(_wrap(
        AsyncStateView<String?>(
          snapshot: const AsyncSnapshot<String?>.withData(
            ConnectionState.done,
            null,
          ),
          builder: (_, data) => Text(data!),
        ),
      ));

      expect(find.byType(FinishedState), findsOneWidget);
      expect(find.byType(ErrorState), findsNothing);
    });
  });

  testWidgets('data renders through the builder', (tester) async {
    await tester.pumpWidget(_wrap(
      AsyncStateView<String>(
        snapshot: const AsyncSnapshot<String>.withData(
            ConnectionState.done, 'রফিকুল'),
        builder: (_, data) => Text(data),
      ),
    ));

    expect(find.text('রফিকুল'), findsOneWidget);
  });
}
