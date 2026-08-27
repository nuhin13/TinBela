// Epic 08 task 08.5 -- the app's transport.
//
// Plain HTTP/JSON against Connect's JSON codec, using the generated protobuf
// message types (ADR-0003). Deliberately NOT a Connect Dart client
// dependency: apps/manager/AGENTS.md forbids one, and Connect's unary JSON
// protocol is small enough that a wrapper over `package:http` is less code
// than the dependency would be.
//
// The protocol, in full, for a unary call:
//   POST {baseUrl}/{package}.{Service}/{Method}
//   Content-Type: application/json
//   body:     the request message as proto3 JSON
//   200:      the response message as proto3 JSON
//   non-200:  {"code": "...", "message": "..."} -- see docs/eng/errors.md
//
// Nothing here knows about meals, money or messes. Services are thin
// functions over `unary`; repositories (task 08.6) turn their DTOs into
// domain types.

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:protobuf/protobuf.dart';

import 'api_error.dart';

/// Supplies the bearer token for each call, or null when signed out.
///
/// A function rather than a stored string because Firebase ID tokens expire
/// after an hour and the app has to survive that mid-session (task 08.9).
/// Asking per call means the refresh happens where the token is owned, not
/// wherever the client happened to be constructed.
typedef TokenProvider = FutureOr<String?> Function();

/// Supplies the mess the call acts inside, or null for the tenant-free ones
/// (GetMe, CreateMess).
typedef TenantProvider = FutureOr<String?> Function();

/// Recovers from a rejected token: force a refresh, and report whether a new
/// one was obtained. Returning true means "retry the call worthwhile".
///
/// This is the reactive half of surviving token expiry (task 08.9). The
/// proactive half lives in the [TokenProvider], which refreshes before expiry;
/// this covers the token the server rejects that our own clock still believed
/// in -- revocation, or clock skew past the refresh window.
typedef UnauthenticatedRecovery = FutureOr<bool> Function();

/// The header names the server reads. They are part of the contract
/// (services/api/internal/transport), not local convention.
const _authorizationHeader = 'Authorization';
const _tenantHeader = 'X-Tenant-Id';
const _requestIdHeader = 'X-Request-Id';

class ConnectClient {
  factory ConnectClient({
    required Uri baseUrl,
    http.Client? httpClient,
    TokenProvider? token,
    TenantProvider? tenant,
    UnauthenticatedRecovery? onUnauthenticated,
    Duration timeout = const Duration(seconds: 15),
  }) =>
      ConnectClient._(
        baseUrl,
        httpClient ?? http.Client(),
        token,
        tenant,
        onUnauthenticated,
        timeout,
      );

  ConnectClient._(
    this._baseUrl,
    this._http,
    this._token,
    this._tenant,
    this._onUnauthenticated,
    this._timeout,
  );

  final Uri _baseUrl;
  final http.Client _http;
  final TokenProvider? _token;
  final TenantProvider? _tenant;
  final UnauthenticatedRecovery? _onUnauthenticated;
  final Duration _timeout;

  /// Calls one unary procedure.
  ///
  /// [procedure] is the full path Connect mounts, e.g.
  /// `tinbela.core.v1.CoreService/GetMe`. [response] builds the empty message
  /// to parse into -- generated Dart has no reflection to find it from a type
  /// parameter alone.
  /// [tenantId] scopes this one call, overriding the client-wide provider.
  ///
  /// It is per call rather than per client because a person can manage one
  /// mess and be an ordinary member of another: a single ambient "current
  /// tenant" would be wrong the moment they look at the second one. The
  /// server authorises the header, never the body's mess_id, so getting this
  /// wrong is a permission_denied rather than a silent cross-tenant read.
  Future<R> unary<Q extends GeneratedMessage, R extends GeneratedMessage>(
    String procedure,
    Q request,
    R Function() response, {
    String? tenantId,
  }) async {
    final uri = _baseUrl.replace(
      path: '${_baseUrl.path}/$procedure'.replaceAll('//', '/'),
    );
    final body = jsonEncode(request.toProto3Json());

    // Built per attempt, not once: the retry after a token refresh must carry
    // the NEW token, so the header is re-read from the provider each time.
    Future<http.Response> send() async {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      final token = await _token?.call();
      if (token != null && token.isNotEmpty) {
        headers[_authorizationHeader] = 'Bearer $token';
      }
      final tenant = tenantId ?? await _tenant?.call();
      if (tenant != null && tenant.isNotEmpty) {
        headers[_tenantHeader] = tenant;
      }
      return _http.post(uri, headers: headers, body: body).timeout(_timeout);
    }

    http.Response res;
    try {
      res = await send();
      // A 401 mid-session is usually an expired token. Give the session one
      // chance to mint a fresh one and retry -- once, never a loop: if the
      // second answer is still 401, the manager genuinely has to sign in again.
      if (res.statusCode == 401 && _onUnauthenticated != null) {
        if (await _onUnauthenticated!()) {
          res = await send();
        }
      }
    } on TimeoutException {
      // Mess wifi, not a server fault. Retryable, and the UI says so.
      throw const ApiException(
        code: ApiErrorCode.deadlineExceeded,
        message: 'সংযোগ পাওয়া যাচ্ছে না',
      );
    } catch (_) {
      // Socket failures, DNS, a captive portal. Never surface the raw
      // exception: it is English, technical, and blames the wrong thing.
      throw const ApiException(
        code: ApiErrorCode.unavailable,
        message: 'ইন্টারনেট সংযোগ নেই',
      );
    }

    final requestId = res.headers[_requestIdHeader.toLowerCase()];

    if (res.statusCode != 200) {
      throw _errorFrom(res, requestId);
    }

    // utf8.decode, not res.body: res.body guesses latin-1 when the server
    // omits a charset, and every user-visible string in this app is Bangla.
    final decoded = jsonDecode(utf8.decode(res.bodyBytes));
    final message = response();
    // Proto3 JSON omits default values, so an empty body is a valid response
    // whose fields are all defaults -- not an error.
    message.mergeFromProto3Json(decoded, ignoreUnknownFields: true);
    return message;
  }

  ApiException _errorFrom(http.Response res, String? requestId) {
    try {
      final body = jsonDecode(utf8.decode(res.bodyBytes));
      if (body is Map<String, dynamic>) {
        return ApiException(
          code: ApiErrorCode.parse(body['code'] as String?),
          message: (body['message'] as String?) ?? 'কিছু একটা ভুল হয়েছে',
          requestId: requestId,
        );
      }
    } catch (_) {
      // A non-JSON error body means something upstream of the API answered --
      // a proxy, a load balancer, a captive portal. Fall through.
    }
    return ApiException(
      code: _codeFromStatus(res.statusCode),
      message: 'কিছু একটা ভুল হয়েছে',
      requestId: requestId,
    );
  }

  static ApiErrorCode _codeFromStatus(int status) => switch (status) {
        401 => ApiErrorCode.unauthenticated,
        403 => ApiErrorCode.permissionDenied,
        404 => ApiErrorCode.notFound,
        429 => ApiErrorCode.resourceExhausted,
        503 => ApiErrorCode.unavailable,
        504 => ApiErrorCode.deadlineExceeded,
        _ => ApiErrorCode.unknown,
      };

  void close() => _http.close();
}
