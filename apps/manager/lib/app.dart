// The TinBela navigation shell.
//
// THIS IS THE UI NAVIGATION. Spec: docs/product/UI_SPEC.md §2.
// Epic 08, task 08.7.
//
//   ┌──────────┬──────────┬──────────┬──────────┐
//   │   আজ     │  খাতা    │  হিসাব   │   আরও    │
//   │  Today ★ │  Grid    │ Accounts │   More   │
//   └──────────┴──────────┴──────────┴──────────┘
//
// Bottom nav, not a drawer: managers use this one-handed, standing up, in
// sunlight. Everything reachable in the thumb zone.

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/i18n/l10n/app_localizations.dart'; // run `flutter gen-l10n`
import 'core/theme/tokens.g.dart'; // run `make tokens` to generate

class TinBelaApp extends StatelessWidget {
  const TinBelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      // bn is the default and the source of truth; en is the translation.
      locale: const Locale('bn'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: TinBelaColors.surface,
        colorScheme: ColorScheme.fromSeed(
          seedColor: TinBelaColors.primary,
          primary: TinBelaColors.primary,
          secondary: TinBelaColors.accent,
          error: TinBelaColors.alert,
          surface: TinBelaColors.card,
        ),
        // Bangla renders with Hind Siliguri. TODO(08.2): bundle the font.
        fontFamily: 'Hind Siliguri',
      ),
      home: const HomeShell(),
    );
  }
}

/// The four tabs of v1.0. Adding a fifth is a scope change, not a UI change.
enum AppTab { today, grid, accounts, more }

extension AppTabLabel on AppTab {
  String label(AppLocalizations l) => switch (this) {
        AppTab.today => l.navToday,
        AppTab.grid => l.navGrid,
        AppTab.accounts => l.navAccounts,
        AppTab.more => l.navMore,
      };
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  // TODO(08.7): replace placeholders as each feature lands.
  //   0 → features/today/today_screen.dart      (Epic 10) ★ the product
  //   1 → features/grid/grid_screen.dart        (Epic 10.9)
  //   2 → features/accounts/accounts_screen.dart(Epic 11)
  //   3 → features/settings/more_screen.dart    (Epic 13)
  static const _tabs = <Widget>[
    _Placeholder(tab: AppTab.today, epic: 'Epic 10 — the daily loop'),
    _Placeholder(tab: AppTab.grid, epic: 'Epic 10.9 — khata grid fallback'),
    _Placeholder(tab: AppTab.accounts, epic: 'Epic 11 — money & accounts'),
    _Placeholder(tab: AppTab.more, epic: 'Epic 13 — members & settings'),
  ];

  static const _icons = <(IconData, IconData)>[
    (Icons.today_outlined, Icons.today),
    (Icons.grid_on_outlined, Icons.grid_on),
    (Icons.account_balance_wallet_outlined, Icons.account_balance_wallet),
    (Icons.more_horiz_outlined, Icons.more_horiz),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: TinBelaColors.card,
        indicatorColor: TinBelaColors.tint,
        // Icons are ALWAYS paired with a Bangla label. Never icon-only —
        // English literacy varies across the user base.
        destinations: [
          for (final tab in AppTab.values)
            NavigationDestination(
              icon: Icon(_icons[tab.index].$1),
              selectedIcon: Icon(_icons[tab.index].$2),
              label: tab.label(l),
            ),
        ],
      ),
    );
  }
}

/// Temporary. Delete as each feature screen lands.
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.tab, required this.epic});

  final AppTab tab;

  /// Developer scaffolding, not product copy — rendered in debug builds only,
  /// which is why it is not an ARB key.
  final String epic;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(TinBelaSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tab.label(AppLocalizations.of(context)),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: TinBelaColors.ink,
                ),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: TinBelaSpace.sm),
                Text(
                  epic,
                  style: const TextStyle(
                    fontSize: 13,
                    color: TinBelaColors.inkMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
