// Task 08.1 -- build flavors.
//
// Everything here comes from --dart-define at build time, so a release build
// physically cannot be pointed at a developer's laptop by a runtime setting.
// There is no in-app "server URL" field and there should never be one: it is
// a support burden and a phishing vector, and the people using this app have
// no reason to know what a base URL is.
//
//   flutter run                                   -> dev, localhost
//   flutter run --dart-define=API_BASE_URL=...    -> dev, a real host
//   flutter build apk --dart-define=FLAVOR=prod \
//                     --dart-define=API_BASE_URL=https://api.tinbela.app
//
// See tool/run_dev.sh for the emulator/device variants, which differ only in
// how each reaches the host machine.

enum Flavor { dev, prod }

class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.apiBaseUrl,
    required this.devFirebaseUid,
  });

  final Flavor flavor;
  final Uri apiBaseUrl;

  /// In dev only, the app authenticates as this seeded user by sending
  /// `Bearer dev:<uid>` -- the token shape `NewDevVerifier` accepts. It lets
  /// the whole flow run against the local stack before Firebase exists
  /// (task 09.2), and it is inert anywhere else: the server refuses to build
  /// the dev verifier unless APP_ENV=dev, so a prod API rejects these.
  final String devFirebaseUid;

  bool get isDev => flavor == Flavor.dev;

  static AppConfig fromEnvironment() {
    const flavorName = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    const flavor = flavorName == 'prod' ? Flavor.prod : Flavor.dev;

    const baseUrl = String.fromEnvironment(
      'API_BASE_URL',
      // The Android emulator's alias for the host machine. A physical device
      // over wireless debugging needs the machine's LAN address instead --
      // hence tool/run_dev.sh.
      defaultValue: 'http://10.0.2.2:8080',
    );

    const devUid = String.fromEnvironment(
      'DEV_FIREBASE_UID',
      // The manager in harness/fixtures/seed.
      defaultValue: 'dev-8801711000001',
    );

    if (flavor == Flavor.prod && !baseUrl.startsWith('https://')) {
      // A release build talking plain HTTP would put every bearer token on
      // the wire in clear text. Failing at startup is the point: this is a
      // build-time mistake and it should never reach a phone.
      throw StateError(
        'the prod flavor requires an https API_BASE_URL, got "$baseUrl"',
      );
    }

    return AppConfig(
      flavor: flavor,
      apiBaseUrl: Uri.parse(baseUrl),
      devFirebaseUid: devUid,
    );
  }
}
