// Epic 08 task 08.6.
//
// These drive the repositories through a real socket serving bytes captured
// from the running binary, so what is under test is the whole path a screen
// depends on: wire -> generated message -> domain type.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tinbela_manager/core/api/connect_client.dart';
import 'package:tinbela_manager/core/data/repositories.dart';
import 'package:tinbela_manager/core/domain/models.dart';

/// Captured from the running binary.
const _getMeBody =
    '{"user":{"id":"6d521664-8b2b-5429-b4bd-464e0b73d5a9", "name":"রফিকুল ইসলাম", '
    '"phoneE164":"+8801711000001", "locale":"bn", "useBanglaNumerals":true}, '
    '"messes":[{"id":"b5ced3ea-f30f-588e-8cc0-9e79acddd2a9", '
    '"name":"নীলক্ষেত ব্যাচেলর মেস", "kind":"TENANT_KIND_MESS"}]}';

void main() {
  late _Stub stub;

  setUp(() async => stub = await _Stub.start());
  tearDown(() async => stub.stop());

  test('GetMe becomes a Session of domain types', () async {
    stub.body = _getMeBody;
    final repo = RemoteSessionRepository(ConnectClient(baseUrl: stub.baseUrl));

    final session = await repo.getMe();

    expect(session.user.name, 'রফিকুল ইসলাম');
    expect(session.user.useBanglaNumerals, isTrue);
    expect(session.messes.single.kind, MessKind.mess);
    expect(session.needsOnboarding, isFalse);
  });

  test('a manager with no mess needs onboarding, not an empty Today', () async {
    stub.body = '{"user":{"id":"u1","name":"নতুন","locale":"bn"}}';
    final repo = RemoteSessionRepository(ConnectClient(baseUrl: stub.baseUrl));

    final session = await repo.getMe();

    expect(session.messes, isEmpty);
    expect(session.needsOnboarding, isTrue);
  });

  test('an empty proto3 string becomes null, not ""', () async {
    // "No period is open" is a real state screens branch on. Proto3 cannot
    // distinguish it from "" on the wire, so the mapper has to.
    stub.body = '{"user":{"id":"u1"},"messes":[{"id":"m1","name":"মেস",'
        '"kind":"TENANT_KIND_MESS"}]}';
    final repo = RemoteSessionRepository(ConnectClient(baseUrl: stub.baseUrl));

    final session = await repo.getMe();

    expect(session.messes.single.currentPeriodId, isNull);
  });

  test('an unknown enum value maps to unknown rather than throwing', () async {
    // The server can be a deploy ahead of an installed app: ROLE_ACCOUNTANT
    // and friends are already in the contract for P3. Crashing here would
    // let a server deploy brick the app.
    stub.body = '{"members":[{"id":"m1","displayName":"করিম",'
        '"role":"ROLE_ACCOUNTANT","inviteState":"INVITE_STATE_SENT"}]}';
    final repo = RemoteMembersRepository(ConnectClient(baseUrl: stub.baseUrl));

    final members = await repo.list(messId: 'mess-1');

    expect(members.single.role, MemberRole.unknown);
    expect(members.single.inviteProgress, InviteProgress.sent);
  });

  test('a member who has left is still a member, with a leftAt', () async {
    // Leaving is soft: their prior meals still count, and a closed month's
    // statement must not change (task 04.8).
    stub.body = '{"members":[{"id":"m1","displayName":"রহিম","role":"ROLE_MEMBER",'
        '"joinedAt":{"value":"2026-07-27"},"leftAt":{"value":"2026-08-10"}}]}';
    final repo = RemoteMembersRepository(ConnectClient(baseUrl: stub.baseUrl));

    final member = (await repo.list(messId: 'mess-1')).single;

    expect(member.hasLeft, isTrue);
    expect(member.leftAt, const MessDate('2026-08-10'));
    expect(member.joinedAt, const MessDate('2026-07-27'));
  });

  test('AddMember returns the member and the invite link together', () async {
    // The link is the member's only credential and is not re-derivable
    // client-side, so losing it here means the manager cannot invite them.
    stub.body = '{"member":{"id":"m9","displayName":"সাকিব","role":"ROLE_MEMBER"},'
        '"inviteLink":"https://tinbela.app/j/AbC123"}';
    final repo = RemoteMembersRepository(ConnectClient(baseUrl: stub.baseUrl));

    final added = await repo.add(messId: 'mess-1', displayName: 'সাকিব');

    expect(added.member.displayName, 'সাকিব');
    expect(added.inviteLink, 'https://tinbela.app/j/AbC123');
  });

  test('a member added without a phone sends "" and reads back as null',
      () async {
    stub.body = '{"member":{"id":"m9","displayName":"সাকিব"},"inviteLink":"x"}';
    final repo = RemoteMembersRepository(ConnectClient(baseUrl: stub.baseUrl));

    final added = await repo.add(messId: 'mess-1', displayName: 'সাকিব');

    expect(jsonDecode(stub.lastBody!)['phoneE164'], anyOf(isNull, ''));
    expect(added.member.phoneE164, isNull);
  });
}

class _Stub {
  _Stub._(this._server);

  final HttpServer _server;
  bool _stopped = false;

  String body = '{}';
  String? lastBody;

  static Future<_Stub> start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final stub = _Stub._(server);
    stub._serve();
    return stub;
  }

  Uri get baseUrl => Uri.parse('http://127.0.0.1:${_server.port}');

  Future<void> _serve() async {
    await for (final req in _server) {
      lastBody = await utf8.decoder.bind(req).join();
      req.response.statusCode = 200;
      req.response.headers.contentType = ContentType.json;
      req.response.add(utf8.encode(body));
      await req.response.close();
    }
  }

  Future<void> stop() async {
    if (_stopped) return;
    _stopped = true;
    await _server.close(force: true);
  }
}
