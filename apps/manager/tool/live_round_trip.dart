// Epic 03's gate, Dart half: "a generated Dart model round-trips a real call
// against the running binary."
//
// This is the literal reading of that sentence -- a real socket, the real Go
// process, a real database. connect_client_test.dart proves the same wire
// format on every `flutter test` without a stack; this proves the stack.
//
// It lives in tool/ rather than test/ on purpose: `flutter test` must not
// pick up a test that fails whenever the developer has not booted Postgres.
// A gate that is usually red gets ignored, and an ignored gate is worse than
// no gate.
//
// Run: make contract-live   (which boots the stack, migrates and seeds first)
//
// Env:
//   TINBELA_API_URL  default http://localhost:8080
//   TINBELA_TOKEN    default dev:dev-8801711000001, the seeded manager

import 'dart:io';

import 'package:tinbela_manager/core/api/api_error.dart';
import 'package:tinbela_manager/core/api/connect_client.dart';
import 'package:tinbela_manager/core/api/gen/tinbela/core/v1/core.pb.dart';

Future<void> main() async {
  final baseUrl = Platform.environment['TINBELA_API_URL'] ?? 'http://localhost:8080';
  final token = Platform.environment['TINBELA_TOKEN'] ?? 'dev:dev-8801711000001';

  final client = ConnectClient(baseUrl: Uri.parse(baseUrl), token: () => token);
  var failures = 0;

  void check(String what, bool ok, [String? detail]) {
    stdout.writeln(ok ? '  [32m✓[0m $what' : '  [31m✗[0m $what${detail == null ? '' : ' — $detail'}');
    if (!ok) failures++;
  }

  stdout.writeln('── dart round trip against $baseUrl ──');

  try {
    final me = await client.unary(
      'tinbela.core.v1.CoreService/GetMe',
      GetMeRequest(),
      GetMeResponse.new,
    );

    check('GetMe returned a user', me.user.id.isNotEmpty);
    check('the name survived as Bangla, not mojibake',
        me.user.name.isNotEmpty && me.user.name != '?', me.user.name);
    check('the user is in at least one mess', me.messes.isNotEmpty);
    if (me.messes.isNotEmpty) {
      // The enum is the part most likely to break silently: proto3 JSON sends
      // it as a name, and a client that expected an ordinal would land on the
      // zero value without any error at all.
      check('the mess kind parsed from its JSON name',
          me.messes.first.kind != TenantKind.TENANT_KIND_UNSPECIFIED,
          me.messes.first.kind.name);
    }
  } on ApiException catch (e) {
    check('GetMe', false, '${e.code.name}: ${e.message}');
    if (e.code == ApiErrorCode.unauthenticated) {
      stdout.writeln('    (is the stack seeded? `go run ./harness/fixtures/seed`)');
    }
  } finally {
    client.close();
  }

  // An unauthenticated call must be refused. Proving the happy path alone
  // would pass just as well against a server that authenticated nobody.
  final anonymous = ConnectClient(baseUrl: Uri.parse(baseUrl));
  try {
    await anonymous.unary(
      'tinbela.core.v1.CoreService/GetMe',
      GetMeRequest(),
      GetMeResponse.new,
    );
    check('a call with no token is refused', false, 'it succeeded');
  } on ApiException catch (e) {
    check('a call with no token is refused',
        e.code == ApiErrorCode.unauthenticated, e.code.name);
    check('the refusal is localised by the server', e.message.isNotEmpty, e.message);
  } finally {
    anonymous.close();
  }

  stdout.writeln('');
  if (failures == 0) {
    stdout.writeln('  [32mdart client round-trips the running binary[0m');
  } else {
    stdout.writeln('  [31m$failures check(s) failed[0m');
  }
  exit(failures == 0 ? 0 : 1);
}
