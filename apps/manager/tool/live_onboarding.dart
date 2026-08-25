// Task 08.1 -- proves the wiring, not just the transport.
//
// tool/live_round_trip.dart proves the CLIENT reaches the binary. This proves
// the layer the screens actually depend on: config -> client -> repository ->
// domain type, driving exactly the calls OnboardingFlow makes, in order.
//
// It creates a real mess, so it is a dev-stack tool and never part of
// `verify`. Run: make onboarding-live
//
// Env: TINBELA_API_URL (default http://localhost:8080)
//      TINBELA_DEV_UID (default dev-8801711000001, the seeded manager)

import 'dart:io';

import 'package:tinbela_manager/core/api/api_error.dart';
import 'package:tinbela_manager/core/api/connect_client.dart';
import 'package:tinbela_manager/core/data/repositories.dart';

const _green = '[32m';
const _red = '[31m';
const _reset = '[0m';

Future<void> main() async {
  final baseUrl =
      Platform.environment['TINBELA_API_URL'] ?? 'http://localhost:8080';
  final uid = Platform.environment['TINBELA_DEV_UID'] ?? 'dev-8801711000001';

  var failures = 0;
  void check(String what, bool ok, [String? detail]) {
    final mark = ok ? '$_green✓$_reset' : '$_red✗$_reset';
    stdout.writeln('  $mark $what${detail == null ? '' : ' — $detail'}');
    if (!ok) failures++;
  }

  stdout.writeln('-- onboarding flow against $baseUrl --');

  // Exactly what main.dart builds for the dev flavor.
  final client = ConnectClient(
    baseUrl: Uri.parse(baseUrl),
    token: () => 'dev:$uid',
  );

  try {
    // Step 0: the question _Root asks before it picks a screen.
    final session = await RemoteSessionRepository(client).getMe();
    check('GetMe resolved a Session of domain types', session.user.id.isNotEmpty,
        session.user.name);
    check('needsOnboarding answered', true, '${session.needsOnboarding}');

    // Step 3: what the setup screen submits.
    final name = 'tool test mess ${DateTime.now().millisecondsSinceEpoch}';
    final created =
        await RemoteMessesRepository(client).create(name: name, slotCount: 3);
    check('CreateMess returned a mess', created.mess.id.isNotEmpty);
    check('the name round-tripped', created.mess.name == name);
    check('it came back with slots', created.mess.slots.length == 3,
        '${created.mess.slots.length} slots');
    check('a period is open', created.mess.currentPeriodId != null);

    // Step 4: what the invite screen renders and shares.
    //
    // CreateMess returns an EMPTY invite link, deliberately: the schema has
    // no mess-level invite, only a per-membership invite_token
    // (handlers.go, CreateMess). So the "mess created" screen cannot show
    // one link for the mess -- it has to show a link per member, which only
    // exists after AddMember. Raised as a prototype-vs-schema conflict.
    check('CreateMess returns no mess-level link, as designed',
        created.inviteLink.isEmpty);

    // And the member the manager adds next.
    final added = await RemoteMembersRepository(client)
        .add(messId: created.mess.id, displayName: 'Rahim');
    check('AddMember returned a member with their own link',
        added.member.id.isNotEmpty && added.inviteLink.isNotEmpty);

    final members =
        await RemoteMembersRepository(client).list(messId: created.mess.id);
    check('ListMembers sees the manager and the new member', members.length == 2,
        '${members.length} members');
  } on ApiException catch (e) {
    check('flow', false, '${e.code.name}: ${e.message}');
  } finally {
    client.close();
  }

  stdout.writeln('');
  stdout.writeln(failures == 0
      ? '  ${_green}the onboarding flow works against the running binary$_reset'
      : '  $_red$failures check(s) failed$_reset');
  exit(failures == 0 ? 0 : 1);
}
