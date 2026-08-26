// Epic 08 task 08.9 -- the token lifecycle, proven without a real hour passing.
//
// The whole point of the task is "survives token expiry mid-session". The
// clock is injected, so a token that would die at 10:00 can be pushed past its
// refresh window in a test that runs in a millisecond, and the session's
// refresh is observed directly rather than inferred.

import 'package:flutter_test/flutter_test.dart';
import 'package:tinbela_manager/core/auth/auth_session.dart';

void main() {
  late _Clock clock;
  late _FakeBackend backend;
  late AuthSession session;

  setUp(() {
    clock = _Clock(DateTime.utc(2026, 8, 26, 9));
    backend = _FakeBackend(clock);
    session = AuthSession(
      backend,
      clock: clock.now,
      refreshSkew: const Duration(minutes: 5),
    );
  });

  test('mints a token on cold start and reports signed in', () async {
    expect(session.status.value, AuthStatus.unknown);
    expect(await session.token(), 'token#1');
    expect(backend.issued, 1);
    expect(session.status.value, AuthStatus.signedIn);
  });

  test('serves the cached token while it is still good', () async {
    await session.token();
    clock.advance(const Duration(minutes: 30)); // 09:30, expiry is 10:00
    expect(await session.token(), 'token#1');
    expect(backend.issued, 1, reason: 'no refresh while the token is fresh');
  });

  test('refreshes once the token enters the skew window -- survives expiry',
      () async {
    await session.token(); // token#1, expires 10:00
    clock.advance(const Duration(minutes: 56)); // 09:56, inside the 5-min skew
    expect(await session.token(), 'token#2');
    expect(backend.issued, 2);
    expect(backend.lastForceRefresh, isTrue,
        reason: 'a stale token forces a real backend refresh, not a re-serve');
  });

  test('refresh() force-mints and reports success', () async {
    await session.token();
    expect(await session.refresh(), isTrue);
    expect(backend.issued, 2);
    expect(backend.lastForceRefresh, isTrue);
  });

  test('signOut drops the token and goes tokenless', () async {
    await session.token();
    await session.signOut();
    expect(session.status.value, AuthStatus.signedOut);
    expect(await session.token(), isNull);
  });

  test('no one signed in yields a null token and a false refresh', () async {
    backend.signedOut = true;
    expect(await session.token(), isNull);
    expect(session.status.value, AuthStatus.signedOut);
    expect(await session.refresh(), isFalse);
  });

  group('DevAuthBackend', () {
    test('issues the dev bearer the local verifier accepts', () async {
      final clock = _Clock(DateTime.utc(2026, 8, 26, 9));
      final backend = DevAuthBackend('dev-8801711000001', clock: clock.now);

      final token = await backend.issueToken();

      expect(token, isNotNull);
      expect(token!.jwt, 'dev:dev-8801711000001');
      // Synthetic 1-hour TTL: enough to drive the refresh path the same way
      // Firebase will, before Firebase exists.
      expect(token.expiresAt, DateTime.utc(2026, 8, 26, 10));
    });

    test('yields nothing after sign-out', () async {
      final backend = DevAuthBackend('dev-x');
      await backend.signOut();
      expect(await backend.issueToken(), isNull);
    });
  });
}

/// A hand-advanced UTC clock, so expiry is a test input, not a wait.
class _Clock {
  _Clock(this._now);

  DateTime _now;

  DateTime now() => _now;
  void advance(Duration d) => _now = _now.add(d);
}

/// Records how it was asked, so the session's refresh policy is observable.
class _FakeBackend implements AuthBackend {
  _FakeBackend(this._clock, {Duration ttl = const Duration(hours: 1)})
      : _ttl = ttl;

  final _Clock _clock;
  final Duration _ttl;

  int issued = 0;
  bool signedOut = false;
  bool? lastForceRefresh;

  @override
  Future<AuthToken?> issueToken({bool forceRefresh = false}) async {
    lastForceRefresh = forceRefresh;
    if (signedOut) return null;
    issued += 1;
    return AuthToken('token#$issued', _clock.now().add(_ttl));
  }

  @override
  Future<void> signOut() async => signedOut = true;
}
