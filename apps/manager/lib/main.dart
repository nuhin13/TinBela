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

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/api/connect_client.dart';
import 'core/auth/auth_session.dart';
import 'core/auth/firebase_auth_backend.dart';
import 'core/config/app_config.dart';
import 'core/data/repositories.dart';
import 'core/settings/locale_store.dart';
import 'core/settings/numerals_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  final localeStore = await LocaleStore.open();
  final numeralsStore = await NumeralsStore.open();

  // Task 08.9 + 09.2: the session owns the token, its refresh, and sign-in.
  // Dev signs in as the seeded manager and touches no Firebase, so a dev build
  // needs no google-services.json. Prod signs in with Google via Firebase,
  // which reads google-services.json (supplied at build time, never committed).
  final AuthBackend backend;
  if (config.isDev) {
    backend = DevAuthBackend(config.devFirebaseUid);
  } else {
    await Firebase.initializeApp();
    backend = FirebaseAuthBackend();
  }
  final auth = AuthSession(backend);

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
    numerals: NumeralsController(numeralsStore),
    session: RemoteSessionRepository(client),
    messes: RemoteMessesRepository(client),
    members: RemoteMembersRepository(client),
    onSignIn: auth.signIn,
  ));
}
