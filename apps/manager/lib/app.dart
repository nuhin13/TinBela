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

import 'core/api/api_error.dart';
import 'core/config/app_config.dart';
import 'core/data/repositories.dart';
import 'core/domain/models.dart';
import 'core/i18n/l10n/app_localizations.dart'; // run `flutter gen-l10n`
import 'core/settings/locale_store.dart';
import 'core/settings/numerals_store.dart';
import 'core/theme/tokens.g.dart'; // run `make tokens` to generate
import 'core/widgets/async_states.dart';
import 'features/onboarding/onboarding_flow.dart';
import 'features/settings/more_screen.dart';

class TinBelaApp extends StatelessWidget {
  const TinBelaApp({
    super.key,
    required this.config,
    required this.localeController,
    required this.numerals,
    required this.session,
    required this.messes,
    required this.members,
    required this.onSignIn,
  });

  final AppConfig config;
  final LocaleController localeController;
  final NumeralsController numerals;
  final SessionRepository session;
  final MessesRepository messes;
  final MembersRepository members;

  /// Runs interactive Google Sign-In (task 09.2). True once signed in.
  final Future<bool> Function() onSignIn;

  @override
  Widget build(BuildContext context) {
    // Rebuilds the whole app on a language change so every string re-resolves
    // -- including the ones already on screen behind the picker.
    return ListenableBuilder(
      listenable: localeController,
      builder: (context, _) => _buildApp(context),
    );
  }

  Widget _buildApp(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      // bn is the default and the source of truth; en is the translation.
      locale: localeController.locale,
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
      home: _Root(
        session: session,
        messes: messes,
        members: members,
        onSignIn: onSignIn,
        localeController: localeController,
        numerals: numerals,
      ),
    );
  }
}

/// Decides between onboarding and the shell, and is the only place that
/// decision is made.
///
/// The question "does this manager have a mess yet" is answered by GetMe,
/// not by a local flag: a manager who reinstalls, or signs in on a second
/// phone, must land in their mess rather than be asked to create it again.
class _Root extends StatefulWidget {
  const _Root({
    required this.session,
    required this.messes,
    required this.members,
    required this.onSignIn,
    required this.localeController,
    required this.numerals,
  });

  final SessionRepository session;
  final MessesRepository messes;
  final MembersRepository members;
  final Future<bool> Function() onSignIn;
  final LocaleController localeController;
  final NumeralsController numerals;

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  late Future<Session> _session = widget.session.getMe();

  void _reload() => setState(() => _session = widget.session.getMe());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Session>(
      future: _session,
      builder: (context, snapshot) {
        // An unauthenticated caller is not an error state here: it is a
        // manager with no account yet, and the answer is onboarding.
        final error = snapshot.error;
        if (error is ApiException &&
            error.code == ApiErrorCode.unauthenticated) {
          return _onboarding();
        }

        return Scaffold(
          body: AsyncStateView<Session>(
            snapshot: snapshot,
            onRetry: _reload,
            builder: (context, session) => session.needsOnboarding
                ? _onboarding()
                : HomeShell(
                    session: session,
                    members: widget.members,
                    localeController: widget.localeController,
                    numerals: widget.numerals,
                  ),
          ),
        );
      },
    );
  }

  Widget _onboarding() => OnboardingFlow(
        session: widget.session,
        messes: widget.messes,
        onSignIn: widget.onSignIn,
        locale: widget.localeController.locale,
        onLocaleSelected: widget.localeController.set,
        onFinished: (_) => _reload(),
      );
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
  const HomeShell({
    super.key,
    required this.session,
    required this.members,
    required this.localeController,
    required this.numerals,
  });

  final Session session;
  final MembersRepository members;
  final LocaleController localeController;
  final NumeralsController numerals;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  // TODO(08.7): replace placeholders as each feature lands.
  //   0 → features/today/today_screen.dart      (Epic 10) ★ the product
  //   1 → features/grid/grid_screen.dart        (Epic 10.9)
  //   2 → features/accounts/accounts_screen.dart(Epic 11)
  //   3 → the আরও tab — members & settings (Epic 13), below.
  late final List<Widget> _tabs = [
    const _Placeholder(tab: AppTab.today, epic: 'Epic 10 — the daily loop'),
    const _Placeholder(tab: AppTab.grid, epic: 'Epic 10.9 — khata grid fallback'),
    const _Placeholder(tab: AppTab.accounts, epic: 'Epic 11 — money & accounts'),
    MoreScreen(
      session: widget.session,
      members: widget.members,
      localeController: widget.localeController,
      numerals: widget.numerals,
    ),
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
