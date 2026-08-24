// Shell smoke test. Epic 08, task 08.7.
//
// Guards the two things AGENTS.md calls scope changes rather than UI changes:
// exactly four tabs, and every label coming from an ARB key (bn by default).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tinbela_manager/app.dart';

void main() {
  testWidgets('shell shows exactly the four v1.0 tabs, in Bangla', (tester) async {
    await tester.pumpWidget(const TinBelaApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationDestination), findsNWidgets(4));
    for (final label in ['আজ', 'খাতা', 'হিসাব', 'আরও']) {
      expect(find.text(label), findsWidgets, reason: 'missing tab $label');
    }
  });

  testWidgets('tapping a tab switches the body', (tester) async {
    await tester.pumpWidget(const TinBelaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.account_balance_wallet_outlined));
    await tester.pumpAndSettle();

    // The selected destination and the placeholder heading both read হিসাব.
    expect(find.text('হিসাব'), findsNWidgets(2));
  });
}
