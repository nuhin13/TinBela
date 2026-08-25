// Epic 08 task 08.5, and the Dart third of Epic 03's gate.
//
// The response bodies below are NOT invented. They were captured verbatim
// from the running binary:
//
//   curl -s -X POST localhost:8080/tinbela.core.v1.CoreService/GetMe \
//     -H 'Content-Type: application/json' \
//     -H 'Authorization: Bearer dev:dev-8801711000001' -d '{}'
//
// That matters more than it looks. A test that feeds the client JSON the
// test itself composed proves only that the client agrees with the test
// author. These bytes carry the server's real choices -- proto3 JSON
// lowerCamelCase, the enum as a name rather than an ordinal, omitted default
// fields, the spaces Go's protojson emits after commas -- and every one of
// those is a way a hand-rolled client can silently differ.
//
// The live call against a running binary is `make contract-dart`. This file
// is what runs on every `flutter test`, with no stack up.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tinbela_manager/core/api/api_error.dart';
import 'package:tinbela_manager/core/api/connect_client.dart';
import 'package:tinbela_manager/core/api/gen/tinbela/core/v1/core.pb.dart';

/// Captured from the running binary. Do not reformat.
const _getMeBody =
    '{"user":{"id":"6d521664-8b2b-5429-b4bd-464e0b73d5a9", "name":"রফিকুল ইসলাম", '
    '"phoneE164":"+8801711000001", "locale":"bn", "useBanglaNumerals":true}, '
    '"messes":[{"id":"b5ced3ea-f30f-588e-8cc0-9e79acddd2a9", '
    '"name":"নীলক্ষেত ব্যাচেলর মেস", "kind":"TENANT_KIND_MESS"}]}';

/// Also captured: the shape every failure arrives in (docs/eng/errors.md).
const _permissionDeniedBody =
    '{"code":"permission_denied","message":"শুধু ম্যানেজার এটি করতে পারেন"}';

void main() {
  late _FakeApi api;

  setUp(() async => api = await _FakeApi.start());
  tearDown(() async => api.stop());

  test('round-trips GetMe from the real wire format', () async {
    api.respond(200, _getMeBody, headers: {'X-Request-Id': 'req-1'});
    final client = ConnectClient(baseUrl: api.baseUrl);

    final res = await client.unary(
      'tinbela.core.v1.CoreService/GetMe',
      GetMeRequest(),
      GetMeResponse.new,
    );

    expect(res.user.id, '6d521664-8b2b-5429-b4bd-464e0b73d5a9');
    expect(res.user.name, 'রফিকুল ইসলাম');
    expect(res.user.phoneE164, '+8801711000001');
    expect(res.user.locale, 'bn');
    expect(res.user.useBanglaNumerals, isTrue);

    expect(res.messes, hasLength(1));
    expect(res.messes.single.name, 'নীলক্ষেত ব্যাচেলর মেস');
    // The enum arrives as a name, not an ordinal. A client that assumed the
    // number would parse this as the zero value and show nothing.
    expect(res.messes.single.kind, TenantKind.TENANT_KIND_MESS);

    // Posted to the procedure path Connect mounts, with a JSON body.
    expect(api.lastPath, '/tinbela.core.v1.CoreService/GetMe');
    expect(jsonDecode(api.lastBody!), isEmpty);
  });

  test('sends the auth and tenant headers the server reads', () async {
    api.respond(200, _getMeBody);
    final client = ConnectClient(
      baseUrl: api.baseUrl,
      token: () => 'dev:dev-8801711000001',
      tenant: () => 'b5ced3ea-f30f-588e-8cc0-9e79acddd2a9',
    );

    await client.unary(
      'tinbela.core.v1.CoreService/GetMe',
      GetMeRequest(),
      GetMeResponse.new,
    );

    expect(api.lastHeaders!['authorization'], 'Bearer dev:dev-8801711000001');
    expect(api.lastHeaders!['x-tenant-id'], 'b5ced3ea-f30f-588e-8cc0-9e79acddd2a9');
  });

  test('omits the tenant header when there is no tenant', () async {
    // GetMe and CreateMess are tenant-free. Sending an empty header would be
    // read as a malformed tenant id rather than as no tenant at all.
    api.respond(200, _getMeBody);
    final client = ConnectClient(baseUrl: api.baseUrl, token: () => 'dev:x');

    await client.unary(
      'tinbela.core.v1.CoreService/GetMe',
      GetMeRequest(),
      GetMeResponse.new,
    );

    expect(api.lastHeaders!.containsKey('x-tenant-id'), isFalse);
  });

  test('surfaces the server message and request id, already localised',
      () async {
    api.respond(403, _permissionDeniedBody, headers: {'X-Request-Id': 'req-7'});
    final client = ConnectClient(baseUrl: api.baseUrl);

    await expectLater(
      client.unary('tinbela.core.v1.CoreService/AddMember', GetMeRequest(),
          GetMeResponse.new),
      throwsA(
        isA<ApiException>()
            .having((e) => e.code, 'code', ApiErrorCode.permissionDenied)
            // Rendered as sent. The app does not write its own copy for this.
            .having((e) => e.message, 'message', 'শুধু ম্যানেজার এটি করতে পারেন')
            .having((e) => e.requestId, 'requestId', 'req-7')
            // No retry button on "you are not the manager".
            .having((e) => e.isRetryable, 'isRetryable', isFalse),
      ),
    );
  });

  test('an empty body is all-defaults, not a failure', () async {
    // Proto3 JSON omits default values, so a response where every field is
    // its default is literally `{}`. A client that treated that as malformed
    // would break on the emptiest and most common day.
    api.respond(200, '{}');
    final client = ConnectClient(baseUrl: api.baseUrl);

    final res = await client.unary(
      'tinbela.core.v1.CoreService/GetMe',
      GetMeRequest(),
      GetMeResponse.new,
    );

    expect(res.messes, isEmpty);
    expect(res.user.id, '');
  });

  test('a non-JSON error body does not escape as a parse crash', () async {
    // A proxy or captive portal answering instead of the API. The user gets
    // a sentence, not a FormatException.
    api.respond(502, '<html>Bad Gateway</html>');
    final client = ConnectClient(baseUrl: api.baseUrl);

    await expectLater(
      client.unary('tinbela.core.v1.CoreService/GetMe', GetMeRequest(),
          GetMeResponse.new),
      throwsA(isA<ApiException>()
          .having((e) => e.code, 'code', ApiErrorCode.unknown)
          .having((e) => e.isRetryable, 'isRetryable', isTrue)),
    );
  });

  test('a dead server is unavailable and retryable, never a socket error',
      () async {
    // Read the address before closing: the port is gone once unbound.
    final address = api.baseUrl;
    await api.stop();
    final client = ConnectClient(baseUrl: address);

    await expectLater(
      client.unary('tinbela.core.v1.CoreService/GetMe', GetMeRequest(),
          GetMeResponse.new),
      throwsA(isA<ApiException>()
          .having((e) => e.code, 'code', ApiErrorCode.unavailable)
          .having((e) => e.isRetryable, 'isRetryable', isTrue)),
    );
  });

  test('a slow server times out as retryable', () async {
    api.hang = true;
    final client = ConnectClient(
      baseUrl: api.baseUrl,
      timeout: const Duration(milliseconds: 100),
    );

    await expectLater(
      client.unary('tinbela.core.v1.CoreService/GetMe', GetMeRequest(),
          GetMeResponse.new),
      throwsA(isA<ApiException>()
          .having((e) => e.code, 'code', ApiErrorCode.deadlineExceeded)
          .having((e) => e.isRetryable, 'isRetryable', isTrue)),
    );
  });
}

/// A real HTTP server on a real socket. Not a mocked http.Client: the point
/// is to exercise encoding, headers and status handling end to end, and a
/// mock would only replay what the test already believes.
class _FakeApi {
  _FakeApi._(this._server);

  final HttpServer _server;
  bool _stopped = false;

  int _status = 200;
  String _body = '{}';
  Map<String, String> _headers = const {};

  /// When true the server accepts the request and never answers.
  bool hang = false;

  String? lastPath;
  String? lastBody;
  Map<String, String>? lastHeaders;

  static Future<_FakeApi> start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final api = _FakeApi._(server);
    unawaited(api._serve());
    return api;
  }

  Uri get baseUrl => Uri.parse('http://127.0.0.1:${_server.port}');

  void respond(int status, String body, {Map<String, String> headers = const {}}) {
    _status = status;
    _body = body;
    _headers = headers;
  }

  Future<void> _serve() async {
    await for (final req in _server) {
      lastPath = req.uri.path;
      lastBody = await utf8.decoder.bind(req).join();
      lastHeaders = {
        for (final name in _headerNames(req)) name: req.headers.value(name)!,
      };

      if (hang) continue;

      req.response.statusCode = _status;
      req.response.headers.contentType = ContentType.json;
      _headers.forEach(req.response.headers.set);
      req.response.add(utf8.encode(_body));
      await req.response.close();
    }
  }

  static List<String> _headerNames(HttpRequest req) {
    final names = <String>[];
    req.headers.forEach((name, _) => names.add(name));
    return names;
  }

  Future<void> stop() async {
    if (_stopped) return;
    _stopped = true;
    await _server.close(force: true);
  }
}

void unawaited(Future<void> future) {}
