// TinBela manager app entrypoint.
//
// Setup, in order:
//   1. make tokens          → generates core/theme/tokens.g.dart
//   2. cd apps/manager && flutter pub get   (also runs gen-l10n, see l10n.yaml)
//   3. flutter run                          → Android emulator or device
//      flutter run -d chrome                → no emulator needed, same shell
//
// You will see the four-tab navigation shell immediately.
//
// The Android emulator wants ~12 GB of free disk before it will boot; the
// chrome target wants none, which is the only difference between the two.

import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  // TODO(08.9): Firebase.initializeApp() + Google Sign-In before runApp.
  runApp(const TinBelaApp());
}
