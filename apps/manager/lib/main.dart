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
import 'core/config/app_config.dart';
import 'core/data/repositories.dart';
import 'core/settings/locale_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  final localeStore = await LocaleStore.open();

  // TODO(08.9): in prod the token comes from Firebase, refreshed per call.
  // The seam is already the right shape -- ConnectClient asks for a token on
  // every request rather than holding one, so nothing above changes.
  final client = ConnectClient(
    baseUrl: config.apiBaseUrl,
    token: () => config.isDev ? 'dev:${config.devFirebaseUid}' : null,
  );

  runApp(TinBelaApp(
    config: config,
    localeController: LocaleController(localeStore),
    session: RemoteSessionRepository(client),
    messes: RemoteMessesRepository(client),
  ));
}
