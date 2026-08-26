// TinBela manager app entrypoint.
//
// Setup, in order:
//   1. make tokens          → generates core/theme/tokens.g.dart
//   2. cd apps/manager && flutter pub get   (also runs gen-l10n, see l10n.yaml)
//   3. Boot the API:  make dev              → localhost:8080, seeded
//   4. ./tool/run_dev.sh                    → picks the right host for your
//                                             emulator or wireless device
//
// The dev flavor authenticates as a seeded user with a `dev:<uid>` bearer
// token, so the whole onboarding flow runs against the real API before
// Firebase exists (task 09.2).

import 'package:flutter/material.dart';

import 'app.dart';
import 'core/api/connect_client.dart';
import 'core/auth/auth_session.dart';
import 'core/config/app_config.dart';
import 'core/data/repositories.dart';
import 'core/settings/locale_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  final localeStore = await LocaleStore.open();

  // Task 08.9: the session owns the token and its refresh. Dev signs in as the
  // seeded manager; prod has no sign-in until Firebase lands (task 09.2), so it
  // runs tokenless and the server answers `unauthenticated` → onboarding.
  final auth = AuthSession(
    config.isDev
        ? DevAuthBackend(config.devFirebaseUid)
        : const UnauthenticatedBackend(),
  );

  // ConnectClient still just asks for a token per call and, on a 401, asks the
  // session to refresh and retries once -- the seam was always this shape.
  final client = ConnectClient(
    baseUrl: config.apiBaseUrl,
    token: auth.token,
    onUnauthenticated: auth.refresh,
  );

  runApp(TinBelaApp(
    config: config,
    localeController: LocaleController(localeStore),
    session: RemoteSessionRepository(client),
    messes: RemoteMessesRepository(client),
  ));
}
