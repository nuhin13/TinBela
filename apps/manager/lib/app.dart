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

import 'package:flutter/material.dart';

import 'core/theme/tokens.g.dart'; // run `make tokens` to generate

class TinBelaApp extends StatelessWidget {
  const TinBelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TinBela',
      debugShowCheckedModeBanner: false,
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
      // TODO(08.3): wire AppLocalizations, bn default.
      //   locale: const Locale('bn'),
      //   localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const HomeShell(),
    );
  }
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
    _Placeholder(tab: 'আজ', epic: 'Epic 10 — the daily loop'),
    _Placeholder(tab: 'খাতা', epic: 'Epic 10.9 — khata grid fallback'),
    _Placeholder(tab: 'হিসাব', epic: 'Epic 11 — money & accounts'),
    _Placeholder(tab: 'আরও', epic: 'Epic 13 — members & settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: TinBelaColors.card,
        indicatorColor: TinBelaColors.tint,
        // Icons are ALWAYS paired with a Bangla label. Never icon-only —
        // English literacy varies across the user base.
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'আজ',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_on_outlined),
            selectedIcon: Icon(Icons.grid_on),
            label: 'খাতা',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'হিসাব',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz_outlined),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'আরও',
          ),
        ],
      ),
    );
  }
}

/// Temporary. Delete as each feature screen lands.
class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.tab, required this.epic});

  final String tab;
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
                tab,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: TinBelaColors.ink,
                ),
              ),
              const SizedBox(height: TinBelaSpace.sm),
              Text(
                epic,
                style: const TextStyle(
                  fontSize: 13,
                  color: TinBelaColors.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
