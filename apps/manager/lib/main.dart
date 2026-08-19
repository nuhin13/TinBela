// TinBela manager app entrypoint.
//
// Setup, in order:
//   1. cd apps && flutter create --org com.droidbuilder \
//        --project-name tinbela_manager --platforms android manager
//      (this file and app.dart replace the generated lib/main.dart)
//   2. make tokens          → generates core/theme/tokens.g.dart
//   3. cd apps/manager && flutter run
//
// You will see the four-tab navigation shell immediately.

import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  // TODO(08.9): Firebase.initializeApp() + Google Sign-In before runApp.
  runApp(const TinBelaApp());
}
